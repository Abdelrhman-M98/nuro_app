import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';

// State
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<FlSpot> signalHistory;
  final String currentState;
  final double latestSignal;
  final UserModel user;

  HomeLoaded({
    required this.signalHistory,
    required this.currentState,
    required this.latestSignal,
    required this.user,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: "https://nervix-10d98-default-rtdb.firebaseio.com/",
  ).ref();

  StreamSubscription? _signalsSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _profileSubscription;

  final List<FlSpot> _signalHistory = [];
  double _timeCounter = 0;
  String _currentState = "normal";
  double _latestSignal = 0;
  UserModel? _cachedUser;

  Future<void> init() async {
    emit(HomeLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(HomeError("No user logged in"));
      return;
    }

    // 1. Listen to Profile changes
    _profileSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _cachedUser = UserModel.fromFirestore(doc);
        _emitUpdate();
      } else {
        _cachedUser = UserModel(
          name: user.displayName ?? "User",
          age: 25,
          condition: "Unknown",
          gender: "Unknown",
          email: user.email ?? "",
          phone: "",
          country: "",
          profileImageUrl: "",
        );
        _emitUpdate();
      }
    }, onError: (e) {
      emit(HomeError("Profile Error: $e"));
    });

    // 2. Subscribe to RTDB Streams
    _startListening();
  }

  void _startListening() {
    _signalsSubscription = _dbRef.child('Signals').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double newValue = double.tryParse(data.toString()) ?? 0.0;
        _latestSignal = newValue;
        _timeCounter += 1;
        
        _signalHistory.add(FlSpot(_timeCounter, newValue));
        if (_signalHistory.length > 50) {
          _signalHistory.removeAt(0);
        }
        _emitUpdate();
      }
    }, onError: (e) {
      emit(HomeError("Signals Error: $e"));
    });

    _statusSubscription = _dbRef.child('currentState').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        String newStatus = data.toString().toLowerCase();
        
        // Trigger alert if status changes to abnormal
        if (newStatus == 'abnormal' && _currentState != 'abnormal') {
          NotificationService.showEmergencyNotification();
          _recordEmergencyEvent();
        } else if (newStatus == 'normal') {
          NotificationService.stopAlarm();
        }

        _currentState = newStatus;
        _emitUpdate();
      }
    }, onError: (e) {
      emit(HomeError("Status Error: $e"));
    });
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
        'status': 'abnormal',
      });
    }
  }

  void _emitUpdate() {
    if (_cachedUser != null) {
      emit(HomeLoaded(
        signalHistory: List.from(_signalHistory),
        currentState: _currentState,
        latestSignal: _latestSignal,
        user: _cachedUser!,
      ));
    }
  }

  @override
  Future<void> close() {
    _signalsSubscription?.cancel();
    _statusSubscription?.cancel();
    _profileSubscription?.cancel();
    return super.close();
  }
}
