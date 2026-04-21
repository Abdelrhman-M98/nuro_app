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

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dueSub;
  final Set<String> _handledDueIds = <String>{};
  bool _dialogOpen = false;

  void start() {
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
    });
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

    for (final doc in dueDocs) {
      final ctx = AppRouter.rootNavigatorKey.currentContext;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (ctx == null || uid == null) return;

      final data = doc.data();
      final note = (data['note'] as String? ?? '').trim();
      final tag = (data['tag'] as String? ?? 'general').trim();
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

      await NotificationService.cancelJournalReminder(doc.id);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('health_journal')
          .doc(doc.id)
          .delete();
      _handledDueIds.add(doc.id);
      await TelemetryService.logEvent(
        'journal_reminder_consumed_and_deleted',
        parameters: {'tag': tag},
      );
    }
  }
}
