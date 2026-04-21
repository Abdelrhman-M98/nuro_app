import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static const _prefEmergencySound = 'emergency_alarm_sound_enabled';

  static bool _emergencyActive = false;
  static DateTime? _lastEmergencyAt;
  static const Duration _emergencyCooldown = Duration(seconds: 30);

  static final ValueNotifier<bool> emergencySoundEnabled =
      ValueNotifier<bool>(true);

  static int _journalReminderId(String docId) {
    return 200000 + (docId.hashCode.abs() % 900000);
  }

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
    tz.initializeTimeZones();
    try {
      final String localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    final prefs = await SharedPreferences.getInstance();
    emergencySoundEnabled.value =
        prefs.getBool(_prefEmergencySound) ?? true;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: {
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: const AudioContextAndroid(),
      ));
    }

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static Future<void> toggleEmergencySoundEnabled() async {
    final nextSoundOn = !emergencySoundEnabled.value;
    emergencySoundEnabled.value = nextSoundOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEmergencySound, nextSoundOn);
    if (!nextSoundOn) {
      await _audioPlayer.stop();
    } else {
      await _resumeEmergencyAlarmAudioIfNeeded();
    }
  }

  static Future<void> _resumeEmergencyAlarmAudioIfNeeded() async {
    if (!_emergencyActive || !emergencySoundEnabled.value) return;
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint('Resume alarm audio error: $e');
    }
  }

  static Future<void> showStatusNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'status_channel',
      'App Status',
      channelDescription: 'General app status updates',
      importance: Importance.low,
      priority: Priority.low,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: 888,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> showEmergencyNotification() async {
    final now = DateTime.now();
    if (_lastEmergencyAt != null &&
        now.difference(_lastEmergencyAt!) < _emergencyCooldown) {
      await TelemetryService.logEvent(
        'emergency_alert_throttled',
        parameters: {'cooldown_seconds': _emergencyCooldown.inSeconds},
      );
      return;
    }
    _lastEmergencyAt = now;
    _emergencyActive = true;
    final soundOn = emergencySoundEnabled.value;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel_v2',
      'Emergency Alerts',
      channelDescription: 'Alarm for abnormal neural activity (sound optional)',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundOn,
      enableVibration: true,
      vibrationPattern: soundOn
          ? null
          : Int64List.fromList([0, 450, 150, 450, 150, 450, 150, 600]),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundOn,
      ),
    );

    await _notificationsPlugin.show(
      id: 911,
      title: '🚨 Emergency Alert',
      body: 'Abnormal Neural Activity Detected!',
      notificationDetails: platformChannelSpecifics,
    );
    await TelemetryService.logEvent(
      'emergency_alert_triggered',
      parameters: {'sound_enabled': soundOn ? 1 : 0},
    );

    if (soundOn) {
      try {
        await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      } catch (e) {
        debugPrint('Audio Playback Error: $e');
        await TelemetryService.recordError(
          e,
          StackTrace.current,
          reason: 'Emergency audio playback failed',
        );
      }
    } else {
      for (var i = 0; i < 4; i++) {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 140));
      }
    }
  }

  static void stopAlarm() {
    _emergencyActive = false;
    _audioPlayer.stop();
  }

  static Future<void> scheduleJournalReminder({
    required String docId,
    required DateTime reminderAt,
    required String note,
    required String tag,
  }) async {
    final now = DateTime.now();
    if (!reminderAt.isAfter(now)) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'journal_reminder_channel',
        'Health Journal Reminders',
        channelDescription: 'Scheduled reminders for health journal notes',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notificationsPlugin.zonedSchedule(
      id: _journalReminderId(docId),
      title: 'Health note reminder',
      body: '$tag: ${note.trim()}',
      scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'journal:$docId',
    );
    await TelemetryService.logEvent(
      'journal_reminder_scheduled',
      parameters: {
        'minutes_from_now': reminderAt.difference(now).inMinutes,
      },
    );
  }

  static Future<void> cancelJournalReminder(String docId) async {
    await _notificationsPlugin.cancel(id: _journalReminderId(docId));
  }
}
