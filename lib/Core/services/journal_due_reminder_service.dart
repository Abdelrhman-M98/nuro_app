// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';

class JournalDueReminderService {
  JournalDueReminderService._();
  static final JournalDueReminderService instance = JournalDueReminderService._();

  final WidgetsBindingObserver _lifecycleObserver = _JournalLifecycleObserver();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dueSub;
  StreamSubscription<String>? _ackSub;
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
      if (user == null) return;
      _dueSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_journal')
          .where('reminderAt', isNull: false)
          .snapshots()
          .listen(_handleDueSnapshot);
      // Critical for tap-from-notification flow: retry queued acknowledgments
      // as soon as auth becomes available in this app session.
      reconcilePendingAcknowledgedReminders();
      scanDueRemindersNow();
    });
    _ackSub ??= NotificationService.journalReminderAcknowledgedStream.listen(
      _consumeAcknowledgedReminder,
    );
    reconcilePendingAcknowledgedReminders();
    scanDueRemindersNow();
  }

  Future<void> _handleDueSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (_dialogOpen) return;
    final now = DateTime.now();
    final dueDocs = snapshot.docs.where((doc) {
      if (_handledDueIds.contains(doc.id)) return false;
      final ts = doc.data()['reminderAt'] as Timestamp?;
      if (ts == null) return false;
      return !ts.toDate().isAfter(now);
    }).toList();
    if (dueDocs.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Auth can be briefly unavailable right after app wake-up.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await reconcilePendingAcknowledgedReminders();
      return;
    }

    for (final doc in dueDocs) {
      final ctx = await _waitForNavigatorContext();

      final data = doc.data();
      final note = (data['note'] as String? ?? '').trim();
      final tag = (data['tag'] as String? ?? 'general').trim();
      if (ctx != null) {
        _dialogOpen = true;
        try {
          await showDialog<void>(
            context: ctx,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: kSurfaceColor,
              title: const Text('Reminder due', style: TextStyle(color: Colors.white)),
              content: Text(
                '$tag: $note',
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        } finally {
          _dialogOpen = false;
        }
      }
      await _consumeAcknowledgedReminder(
        doc.id,
        fallbackTag: tag,
        showAcknowledgedPopup: false,
      );
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
    String tag = fallbackTag ?? 'unknown';
    try {
      final existing = await ref.get();
      if (!existing.exists) {
        _handledDueIds.add(docId);
        await NotificationService.cancelJournalReminder(docId);
        await NotificationService.markAcknowledgedReminderProcessed(docId);
        _processingDocIds.remove(docId);
        return;
      }
      tag = (existing.data()?['tag'] as String? ?? tag).trim();
      final note = (existing.data()?['note'] as String? ?? '').trim();
      final ctx = await _waitForNavigatorContext();
      if (showAcknowledgedPopup && ctx != null && !_dialogOpen) {
        _dialogOpen = true;
        try {
          await showDialog<void>(
            context: ctx,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              backgroundColor: kSurfaceColor,
              title: const Text('Reminder acknowledged', style: TextStyle(color: Colors.white)),
              content: Text(
                '$tag: $note',
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } finally {
          _dialogOpen = false;
        }
      }
      await NotificationService.cancelJournalReminder(docId);
      await ref.delete();
      await NotificationService.markAcknowledgedReminderProcessed(docId);
      _handledDueIds.add(docId);
      await TelemetryService.logEvent(
        'journal_reminder_consumed_and_deleted',
        parameters: {'tag': tag},
      );
      _processingDocIds.remove(docId);
    } catch (e) {
      await TelemetryService.recordError(
        e,
        StackTrace.current,
        reason: 'journal acknowledged reminder consume failed',
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
    if (_isScanningDueNow) return;
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
      await TelemetryService.recordError(
        e,
        StackTrace.current,
        reason: 'manual due reminder scan failed',
      );
    } finally {
      _isScanningDueNow = false;
    }
  }

  Future<BuildContext?> _waitForNavigatorContext() async {
    for (var i = 0; i < 12; i++) {
      final ctx = AppRouter.rootNavigatorKey.currentContext;
      if (ctx != null) return ctx;
      await Future<void>.delayed(const Duration(milliseconds: 250));
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
