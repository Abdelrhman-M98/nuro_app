import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<FlSpot> signalHistory;
  final List<FlSpot> streamingHistory;
  final String currentState;
  final double latestSignal;
  final UserModel user;

  HomeLoaded({
    required this.signalHistory,
    required this.streamingHistory,
    required this.currentState,
    required this.latestSignal,
    required this.user,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final DatabaseReference _dbRef =
      FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: "https://nervix-10d98-default-rtdb.firebaseio.com/",
      ).ref();

  StreamSubscription? _signalsSubscription;
  StreamSubscription? _statusSubscription;
  Timer? _visualTimer; // Replicates window.setInterval(mycallback, 1000)

  final List<FlSpot> _signalHistory = [];
  final List<FlSpot> _streamingHistory = [const FlSpot(0, 0)];
  double _timeCounter = 0;
  double _streamingCounter = 0;
  String _currentState = "Normal";
  double _latestSignal = 0;
  UserModel? _cachedUser;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  static const int _maxReconnectAttempts = 6;

  void _cancelSubscriptions() {
    _signalsSubscription?.cancel();
    _statusSubscription?.cancel();
    _visualTimer?.cancel();
    _signalsSubscription = null;
    _statusSubscription = null;
    _visualTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> init() async {
    emit(HomeLoading());
    _cancelSubscriptions();
    _signalHistory.clear();
    _streamingHistory.clear();
    _streamingHistory.add(const FlSpot(0, 0));
    _timeCounter = 0;
    _streamingCounter = 0;
    _latestSignal = 0;
    _currentState = 'Normal';

    _reconnectAttempt++;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(HomeError("No user logged in"));
      return;
    }
    
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (doc.exists) {
        _cachedUser = UserModel.fromFirestore(doc);
        _emitUpdate();
      } else {
        _cachedUser = UserModel(
          id: user.uid,
          email: user.email ?? "",
          name: user.displayName ?? "User",
          age: 25,
          country: "Unknown",
          phoneNumber: user.phoneNumber,
          gender: "male",
          chronicDiseases: const ["None"],
          profileImageUrl: user.photoURL,
          authProvider: 'google',
          hasCompletedProfile: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _emitUpdate();
      }
    } catch (e) {
      if (_cachedUser != null) {
        // Fallback to cache silently
        _emitUpdate();
      } else {
        emit(HomeError("Profile issue: $e"));
      }
    }

    _startListening();
    _startVisualTimer(); // Start the 1-second interval
  }

  Future<void> reconnect() async {
    _reconnectAttempt = 0;
    await init();
  }

  void _scheduleReconnect(String source) {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      // Don't destroy UI if we are already loaded, just stop trying to reconnect manually
      return; 
    }
    final delaySeconds = [2, 5, 10, 15, 20, 30][_reconnectAttempt];
    _reconnectAttempt += 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _startListening();
    });
  }

  void _startVisualTimer() {
    _visualTimer?.cancel();
    _visualTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _streamingCounter += 1;
      
      // Just like JS: ch.data.datasets[0].data.push(Signals);
      _streamingHistory.add(FlSpot(_streamingCounter, _latestSignal));

      // Provide a continuous smooth scroll by ONLY removing points 
      // that have completely fallen off the left edge. 
      // We keep one point just off-screen (minVisibleX - 1) 
      // so the line stays firmly connected to the left wall!
      double minVisibleX = _streamingCounter - 20;
      _streamingHistory.removeWhere((spot) => spot.x < minVisibleX - 1);
      
      _emitUpdate();
    });
  }

  void _startListening() {
    _signalsSubscription =
        _dbRef.child('Signals').onValue.listen(
          (event) {
            final data = event.snapshot.value;
            if (data != null) {
              double newValue = double.tryParse(data.toString()) ?? 0.0;
              
              String oldStatus = _currentState;
              String newStatus;
              
              if (newValue > 1000) {
                newStatus = "95% Eplipce";
              } else if (newValue > 800) {
                newStatus = "90% Eplipce";
              } else if (newValue > 700) {
                newStatus = "80% Eplipce";
              } else {
                newStatus = "Normal";
              }

              bool wasAbnormal = oldStatus != "Normal";
              bool isAbnormal = newStatus != "Normal";

              if (isAbnormal && !wasAbnormal) {
                NotificationService.showEmergencyNotification();
                _recordEmergencyEvent();
              } else if (!isAbnormal && wasAbnormal) {
                NotificationService.stopAlarm();
              }

              _latestSignal = newValue;
              _currentState = newStatus;
              _timeCounter += 1;

              // We only add to full history here, the visible graph is handled by the visual Timer
              _signalHistory.add(FlSpot(_timeCounter, newValue));
              if (_signalHistory.length > 50) {
                _signalHistory.removeAt(0);
              }
              _reconnectAttempt = 0;
            }
          },
          onError: (e) {
            _scheduleReconnect('signals');
          },
        );
  }

  Future<void> _recordEmergencyEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
            'timestamp': FieldValue.serverTimestamp(),
            'signalValue': _latestSignal,
            'status': _currentState,
          });
    }
  }

  void _emitUpdate() {
    if (_cachedUser != null) {
      emit(
        HomeLoaded(
          signalHistory: List.from(_signalHistory),
          streamingHistory: List.from(_streamingHistory),
          currentState: _currentState,
          latestSignal: _latestSignal,
          user: _cachedUser!,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    _reconnectTimer?.cancel();
    return super.close();
  }
}
