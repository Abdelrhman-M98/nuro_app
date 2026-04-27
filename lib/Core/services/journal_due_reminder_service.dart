// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';
import 'package:nervix_app/Core/widgets/journal_reminder_dialog.dart';

class JournalDueReminderService {
  JournalDueReminderService._();
  static final JournalDueReminderService instance = JournalDueReminderService._();

  final WidgetsBindingObserver _lifecycleObserver = _JournalLifecycleObserver();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dueSub;
  StreamSubscription<String>? _ackSub;
  Timer? _foregroundTimer;
  Timer? _nextReminderTimer;
  
  final Set<String> _handledDueIds = <String>{};
  final Set<String> _processingDocIds = <String>{};
  bool _dialogOpen = false;
  bool _started = false;
  bool _isScanningDueNow = false;

  void start() {
    if (_started) return;
    _started = true;
    
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    (_lifecycleObserver as _JournalLifecycleObserver).onResumed = () async {
      await reconcilePendingAcknowledgedReminders();
      await scanDueRemindersNow();
    };

    _authSub ??= FirebaseAuth.instance.authStateChanges().listen((user) {
      _dueSub?.cancel();
      _handledDueIds.clear();
      if (user == null) {
        _stopForegroundTimer();
        return;
      }
      _dueSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_journal')
          .where('reminderAt', isNull: false)
          .snapshots()
          .listen(_handleDueSnapshot);
      
      _startForegroundTimer();
      reconcilePendingAcknowledgedReminders();
      scanDueRemindersNow();
    });

    _ackSub ??= NotificationService.journalReminderAcknowledgedStream.listen(
      _consumeAcknowledgedReminder,
    );
    
    reconcilePendingAcknowledgedReminders();
    scanDueRemindersNow();
  }

  void _startForegroundTimer() {
    _foregroundTimer?.cancel();
    // Keep a periodic scan every 30s as a fallback, but we'll use precise timers too.
    _foregroundTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      scanDueRemindersNow();
    });
  }

  void _stopForegroundTimer() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    _nextReminderTimer?.cancel();
    _nextReminderTimer = null;
  }

  Future<void> _handleDueSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final now = DateTime.now();
    DateTime? closestFutureTime;
    
    final dueDocs = snapshot.docs.where((doc) {
      if (_handledDueIds.contains(doc.id)) return false;
      final ts = doc.data()['reminderAt'] as Timestamp?;
      if (ts == null) return false;
      
      final reminderAt = ts.toDate();
      if (reminderAt.isAfter(now)) {
        // Find the closest future reminder to schedule a precise timer
        if (closestFutureTime == null || reminderAt.isBefore(closestFutureTime!)) {
          closestFutureTime = reminderAt;
        }
        return false;
      }
      return true; // Already due
    }).toList();
    
    // Schedule precise timer for the next reminder
    if (closestFutureTime != null) {
      _schedulePreciseTimer(closestFutureTime!);
    }

    if (_dialogOpen || dueDocs.isEmpty) return;

    for (final doc in dueDocs) {
      await _processDueReminder(doc.id, doc.data());
    }
  }

  void _schedulePreciseTimer(DateTime time) {
    _nextReminderTimer?.cancel();
    final duration = time.difference(DateTime.now());
    if (duration.isNegative) return;
    
    _nextReminderTimer = Timer(duration, () {
      scanDueRemindersNow();
    });
  }

  Future<void> _processDueReminder(String docId, Map<String, dynamic> data) async {
    if (_handledDueIds.contains(docId) || _dialogOpen) return;
    
    // Add to handled list immediately to prevent duplicate dialogs during scan/snapshot overlaps
    _handledDueIds.add(docId);

    final note = (data['note'] as String? ?? '').trim();
    final tag = (data['tag'] as String? ?? 'general').trim();
    
    final ctx = await _waitForNavigatorContext();
    if (ctx != null) {
      _dialogOpen = true;
      // Cancel the system notification immediately to avoid "double" notification
      await NotificationService.cancelJournalReminder(docId);
      
      try {
        await JournalReminderDialog.show(
          ctx,
          tag: tag,
          note: note,
          onDismiss: () {},
        );
      } finally {
        _dialogOpen = false;
      }
      
      // After acknowledgment, consume it (delete/mark done)
      await _consumeAcknowledgedReminder(
        docId,
        fallbackTag: tag,
        showAcknowledgedPopup: false,
      );
    } else {
      // If we couldn't show the dialog, remove from handled so it can be retried
      _handledDueIds.remove(docId);
    }
  }

  Future<void> _consumeAcknowledgedReminder(
    String docId, {
    String? fallbackTag,
    bool showAcknowledgedPopup = true,
  }) async {
    if (docId.trim().isEmpty || _handledDueIds.contains(docId)) return;
    if (_processingDocIds.contains(docId)) return;
    _processingDocIds.add(docId);
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _processingDocIds.remove(docId);
      return;
    }
    
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('health_journal')
        .doc(docId);
        
    try {
      final existing = await ref.get();
      if (!existing.exists) {
        _handledDueIds.add(docId);
        await NotificationService.cancelJournalReminder(docId);
        await NotificationService.markAcknowledgedReminderProcessed(docId);
        _processingDocIds.remove(docId);
        return;
      }

      final data = existing.data()!;
      final tag = (data['tag'] as String? ?? fallbackTag ?? 'unknown').trim();
      final note = (data['note'] as String? ?? '').trim();
      
      if (showAcknowledgedPopup && !_dialogOpen) {
        final ctx = await _waitForNavigatorContext();
        if (ctx != null) {
          _dialogOpen = true;
          try {
            await JournalReminderDialog.show(
              ctx,
              tag: tag,
              note: note,
              onDismiss: () {},
            );
          } finally {
            _dialogOpen = false;
          }
        }
      }
      
      await NotificationService.cancelJournalReminder(docId);
      // We keep the logic of deleting the reminder entry if that's what's intended,
      // but usually for a journal we might just want to set reminderAt to null.
      // Given the user wants to "fix" it, I'll update it to set reminderAt to null instead of deleting the whole note.
      await ref.update({'reminderAt': null});
      
      await NotificationService.markAcknowledgedReminderProcessed(docId);
      _handledDueIds.add(docId);
      
      await TelemetryService.logEvent(
        'journal_reminder_consumed',
        parameters: {'tag': tag},
      );
      _processingDocIds.remove(docId);
    } catch (e) {
      await TelemetryService.recordError(
        e,
        StackTrace.current,
        reason: 'journal reminder consume failed',
      );
      _processingDocIds.remove(docId);
    }
  }

  Future<void> reconcilePendingAcknowledgedReminders() async {
    final pending = await NotificationService.getPendingAcknowledgedReminderDocIds();
    if (pending.isEmpty) return;
    for (final docId in pending) {
      await _consumeAcknowledgedReminder(docId);
    }
  }

  Future<void> scanDueRemindersNow() async {
    if (_isScanningDueNow || _dialogOpen) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    _isScanningDueNow = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('health_journal')
          .where('reminderAt', isNull: false)
          .get();
      await _handleDueSnapshot(snapshot);
    } catch (e) {
      debugPrint('Scan due reminders error: $e');
    } finally {
      _isScanningDueNow = false;
    }
  }

  Future<BuildContext?> _waitForNavigatorContext() async {
    for (var i = 0; i < 15; i++) {
      final ctx = AppRouter.rootNavigatorKey.currentContext;
      if (ctx != null) return ctx;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    return AppRouter.rootNavigatorKey.currentContext;
  }
}

class _JournalLifecycleObserver with WidgetsBindingObserver {
  Future<void> Function()? onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed?.call();
    }
  }
}

