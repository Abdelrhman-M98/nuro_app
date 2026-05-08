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
  StreamSubscription? _profileSubscription;

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
    _profileSubscription?.cancel();
    _signalsSubscription = null;
    _statusSubscription = null;
    _profileSubscription = null;
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
    
    // Add a small delay for session stabilization
    await Future.delayed(const Duration(seconds: 1));
    
    debugPrint('HomeCubit: Attempting one-time get for ${user.uid}');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (doc.exists) {
        debugPrint('HomeCubit: Profile fetched successfully via get()');
        _cachedUser = UserModel.fromFirestore(doc);
        _emitUpdate();
      } else {
        debugPrint('HomeCubit: Document not found via get(), creating default');
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
      debugPrint('HomeCubit One-time Get Error: $e');
      emit(HomeError("Profile connection issue: $e"));
      TelemetryService.recordError(
        e,
        StackTrace.current,
        reason: 'profile fetch error',
      );
    }

    _startListening();
  }

  Future<void> reconnect() async {
    _reconnectAttempt = 0;
    await TelemetryService.logEvent('manual_reconnect');
    await init();
  }

  void _scheduleReconnect(String source) {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      emit(HomeError("Connection unstable. Pull to refresh or tap Retry."));
      return;
    }
    final delaySeconds = [2, 5, 10, 15, 20, 30][_reconnectAttempt];
    _reconnectAttempt += 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      await TelemetryService.logEvent(
        'auto_reconnect_attempt',
        parameters: {
          'attempt': _reconnectAttempt,
          'source': source,
          'delay_seconds': delaySeconds,
        },
      );
      await init();
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
              
              // Logic moved from device-side/remote-state to signal-based local calculation
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
              _streamingCounter += 1;

              _signalHistory.add(FlSpot(_timeCounter, newValue));
              _streamingHistory.add(FlSpot(_streamingCounter, newValue));

              if (_signalHistory.length > 50) {
                _signalHistory.removeAt(0);
              }
              if (_streamingHistory.length > 20) {
                _streamingHistory.removeRange(0, 4);
              }
              _emitUpdate();
              _reconnectAttempt = 0;
            }
          },
          onError: (e) {
            emit(HomeError("Live signal stream error. Check network and tap Retry."));
            TelemetryService.recordError(
              e,
              StackTrace.current,
              reason: 'signals stream error',
            );
            _scheduleReconnect('signals');
          },
        );

    // Status is now calculated locally from Signals to ensure faster and more reliable warnings.
    // _statusSubscription =
    //     _dbRef.child('currentState').onValue.listen(
    //       (event) {
    //         // Logic moved to _signalsSubscription
    //       },
    //       onError: (e) {
    //         debugPrint('Status stream error (ignored): $e');
    //       },
    //     );
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
