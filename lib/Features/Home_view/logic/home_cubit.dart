import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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
  double _timeCounter = 0;
  String _currentState = "normal";
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
    _timeCounter = 0;
    _latestSignal = 0;
    _currentState = 'normal';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(HomeError("No user logged in"));
      return;
    }

    _profileSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) {
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
                profileImageUrl: user.photoURL ?? "",
                profileImageBase64: '',
              );
              _emitUpdate();
            }
          },
          onError: (e) {
            emit(HomeError("Profile connection issue. Pull to reconnect or tap Retry."));
            TelemetryService.recordError(
              e,
              StackTrace.current,
              reason: 'profile stream error',
            );
            _scheduleReconnect('profile');
          },
        );

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
              _latestSignal = newValue;
              _timeCounter += 1;

              _signalHistory.add(FlSpot(_timeCounter, newValue));
              if (_signalHistory.length > 50) {
                _signalHistory.removeAt(0);
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

    _statusSubscription =
        _dbRef.child('currentState').onValue.listen(
          (event) {
            final data = event.snapshot.value;
            if (data != null) {
              String newStatus = data.toString().toLowerCase();

              if (newStatus == 'abnormal' && _currentState != 'abnormal') {
                NotificationService.showEmergencyNotification();
                _recordEmergencyEvent();
              } else if (newStatus == 'normal') {
                NotificationService.stopAlarm();
              }

              _currentState = newStatus;
              _emitUpdate();
              _reconnectAttempt = 0;
            }
          },
          onError: (e) {
            emit(HomeError("Status stream error. Check network and tap Retry."));
            TelemetryService.recordError(
              e,
              StackTrace.current,
              reason: 'status stream error',
            );
            _scheduleReconnect('status');
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
            'status': 'abnormal',
          });
    }
  }

  void _emitUpdate() {
    if (_cachedUser != null) {
      emit(
        HomeLoaded(
          signalHistory: List.from(_signalHistory),
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
