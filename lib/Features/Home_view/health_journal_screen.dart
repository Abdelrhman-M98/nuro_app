import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class HealthJournalScreen extends StatefulWidget {
  const HealthJournalScreen({super.key});

  @override
  State<HealthJournalScreen> createState() => _HealthJournalScreenState();
}

class _HealthJournalScreenState extends State<HealthJournalScreen> {
  final _noteController = TextEditingController();
  String _selectedTag = 'general';
  String? _editingDocId;
  DateTime? _reminderAt;
  static const int _maxNoteLength = 500;
  static const List<String> _tags = [
    'general',
    'sleep',
    'stress',
    'medication',
    'symptom',
  ];

  Color _tagColor(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'sleep':
        return const Color(0xFF5C9DFF);
      case 'stress':
        return const Color(0xFFFF8A65);
      case 'medication':
        return const Color(0xFF66BB6A);
      case 'symptom':
        return const Color(0xFFBA68C8);
      case 'general':
      default:
        return const Color(0xFF26C6DA);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String? _validateNote(String text) {
    if (text.isEmpty) return 'Please write a short note first.';
    if (text.length > _maxNoteLength) {
      return 'Note is too long. Maximum $_maxNoteLength characters.';
    }
    return null;
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    final validation = _validateNote(text);
    if (validation != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('health_journal');

    final payload = <String, dynamic>{
      'note': text,
      'tag': _selectedTag,
      'updatedAt': FieldValue.serverTimestamp(),
      'reminderAt':
          _reminderAt != null ? Timestamp.fromDate(_reminderAt!) : null,
    };
    if (_editingDocId == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      final doc = await collection.add(payload);
      if (_reminderAt != null) {
        await NotificationService.scheduleJournalReminder(
          docId: doc.id,
          reminderAt: _reminderAt!,
          note: text,
          tag: _selectedTag,
        );
      }
      await TelemetryService.logEvent('journal_note_created', parameters: {
        'tag': _selectedTag,
      });
    } else {
      await collection.doc(_editingDocId).update(payload);
      if (_reminderAt != null) {
        await NotificationService.scheduleJournalReminder(
          docId: _editingDocId!,
          reminderAt: _reminderAt!,
          note: text,
          tag: _selectedTag,
        );
      } else {
        await NotificationService.cancelJournalReminder(_editingDocId!);
      }
      await TelemetryService.logEvent('journal_note_updated', parameters: {
        'tag': _selectedTag,
      });
    }
    if (mounted) {
      final wasEditing = _editingDocId != null;
      setState(() {
        _editingDocId = null;
        _reminderAt = null;
      });
      _noteController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing ? 'Note updated' : 'Note saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteNote(String uid, String docId) async {
    await NotificationService.cancelJournalReminder(docId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('health_journal')
        .doc(docId)
        .delete();
    await TelemetryService.logEvent('journal_note_deleted');
  }

  void _startEdit(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    setState(() {
      _editingDocId = doc.id;
      _noteController.text = (data['note'] as String? ?? '').trim();
      _selectedTag = (data['tag'] as String? ?? 'general').trim();
      final ts = data['reminderAt'] as Timestamp?;
      _reminderAt = ts?.toDate();
    });
  }

  Future<void> _pickReminderDateTime() async {
    final initialDate = _reminderAt ?? DateTime.now().add(const Duration(minutes: 15));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (picked.isBefore(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a future time for the reminder.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _reminderAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.journalTitle, style: FontStyles.roboto18),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in', style: TextStyle(color: Colors.white70)))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                  child: Text(
                    'Optional notes about symptoms, sleep, or triggers for discussions with your clinician.',
                    style: FontStyles.roboto12.copyWith(color: Colors.white54),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          maxLines: 3,
                          minLines: 1,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Write a note…',
                            hintStyle: TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: kSurfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: const BorderSide(color: kAccentColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: _saveNote,
                        icon: Icon(
                          _editingDocId == null
                              ? Icons.send_rounded
                              : Icons.check_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickReminderDateTime,
                        icon: const Icon(Icons.alarm_add_rounded),
                        label: Text(
                          _reminderAt == null
                              ? 'Set reminder'
                              : DateFormat('dd MMM, HH:mm').format(_reminderAt!),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (_reminderAt != null)
                        TextButton(
                          onPressed: () => setState(() => _reminderAt = null),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final tag = _tags[i];
                      final selected = tag == _selectedTag;
                      final tagColor = _tagColor(tag);
                      return ChoiceChip(
                        label: Text(tag),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedTag = tag),
                        selectedColor: tagColor,
                        labelStyle: TextStyle(
                          color: selected ? Colors.black87 : tagColor.withValues(alpha: 0.95),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: tagColor.withValues(alpha: 0.13),
                        side: BorderSide(color: tagColor.withValues(alpha: 0.42)),
                      );
                    },
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemCount: _tags.length,
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('health_journal')
                        .orderBy('createdAt', descending: true)
                        .limit(100)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No notes yet.',
                            style: FontStyles.roboto14.copyWith(color: Colors.white54),
                          ),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: docs.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, i) {
                          final data = docs[i].data();
                          final note = data['note'] as String? ?? '';
                          final tag = data['tag'] as String? ?? 'general';
                          final tagColor = _tagColor(tag);
                          final reminderTs = data['reminderAt'] as Timestamp?;
                          final ts = data['createdAt'] as Timestamp?;
                          final when = ts != null
                              ? DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate())
                              : '';
                          return Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: kSurfaceColor,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: tagColor.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  when,
                                  style: FontStyles.roboto12.copyWith(
                                    color: tagColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tagColor.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        tag,
                                        style: FontStyles.roboto12.copyWith(
                                          color: tagColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _startEdit(docs[i]),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _deleteNote(uid, docs[i].id),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                if (reminderTs != null)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.alarm_rounded,
                                          color: Colors.amber.shade200,
                                          size: 15.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Reminder: ${DateFormat('dd MMM yyyy, HH:mm').format(reminderTs.toDate())}',
                                          style: FontStyles.roboto12.copyWith(
                                            color: Colors.amber.shade100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  note,
                                  style: FontStyles.roboto14.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
