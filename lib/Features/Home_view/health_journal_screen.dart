import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/services/journal_due_reminder_service.dart';
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
  final _searchController = TextEditingController();
  String _selectedTag = 'general';
  String? _editingDocId;
  DateTime? _reminderAt;
  String _searchQuery = '';
  String _filterTag = 'All';

  static const int _maxNoteLength = 500;
  static const List<String> _tags = ['general', 'sleep', 'stress', 'medication', 'symptom'];
  static const List<String> _filterTags = ['All', ..._tags];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _tagColor(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'sleep': return const Color(0xFF5C9DFF);
      case 'stress': return const Color(0xFFFF8A65);
      case 'medication': return const Color(0xFF66BB6A);
      case 'symptom': return const Color(0xFFBA68C8);
      default: return kAccentColor;
    }
  }

  IconData _tagIcon(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'sleep': return Icons.nights_stay_rounded;
      case 'stress': return Icons.psychology_rounded;
      case 'medication': return Icons.medication_rounded;
      case 'symptom': return Icons.coronavirus_rounded;
      default: return Icons.notes_rounded;
    }
  }

  void _showStatusSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      _showStatusSnackBar('Please enter a note', Colors.orange);
      return;
    }
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final collection = FirebaseFirestore.instance.collection('users').doc(uid).collection('health_journal');
    final wasEditing = _editingDocId != null;

    final payload = <String, dynamic>{
      'note': text,
      'tag': _selectedTag,
      'updatedAt': FieldValue.serverTimestamp(),
      'reminderAt': _reminderAt != null ? Timestamp.fromDate(_reminderAt!) : null,
    };

    try {
      if (_editingDocId == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
        final doc = await collection.add(payload);
        if (_reminderAt != null) {
          await NotificationService.scheduleJournalReminder(
            docId: doc.id, reminderAt: _reminderAt!, note: text, tag: _selectedTag);
        }
      } else {
        await collection.doc(_editingDocId).update(payload);
        if (_reminderAt != null) {
          await NotificationService.scheduleJournalReminder(
            docId: _editingDocId!, reminderAt: _reminderAt!, note: text, tag: _selectedTag);
        } else {
          await NotificationService.cancelJournalReminder(_editingDocId!);
        }
      }
      if (mounted) Navigator.pop(context); // Close sheet
      _showStatusSnackBar(
        wasEditing ? 'Changes saved successfully' : 'Journal entry added', 
        Colors.green.shade600
      );
      _resetInput();
    } catch (e) {
      _showStatusSnackBar('Failed to save: $e', Colors.orange);
    }
  }

  void _resetInput() {
    setState(() {
      _editingDocId = null;
      _reminderAt = null;
      _noteController.clear();
      _selectedTag = 'general';
    });
  }

  void _showComposer({String? editId, Map<String, dynamic>? initialData}) {
    if (editId != null && initialData != null) {
      _editingDocId = editId;
      _noteController.text = (initialData['note'] as String? ?? '').trim();
      _selectedTag = (initialData['tag'] as String? ?? 'general').trim();
      _reminderAt = (initialData['reminderAt'] as Timestamp?)?.toDate();
    } else {
      _resetInput();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(_editingDocId == null ? 'New Entry' : 'Edit Entry', style: FontStyles.roboto18),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white38),
                    ),
                  ],
                ),
                TextField(
                  controller: _noteController,
                  maxLines: 6,
                  minLines: 3,
                  autofocus: true,
                  maxLength: _maxNoteLength,
                  style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts...', 
                    border: InputBorder.none,
                    counterStyle: TextStyle(color: Colors.white24),
                  ),
                  onChanged: (_) => setSheetState(() {}),
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tags.map((tag) {
                      final selected = tag == _selectedTag;
                      final color = _tagColor(tag);
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          avatar: Icon(_tagIcon(tag), size: 14, color: selected ? Colors.black : color),
                          label: Text(tag),
                          selected: selected,
                          onSelected: (_) => setSheetState(() => _selectedTag = tag),
                          selectedColor: color,
                          backgroundColor: color.withValues(alpha: 0.1),
                          side: BorderSide(color: color.withValues(alpha: 0.3)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await _pickReminderDateTime();
                        setSheetState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _reminderAt != null ? kAccentColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm_rounded, size: 18, color: _reminderAt != null ? kAccentColor : Colors.white38),
                            SizedBox(width: 8.w),
                            Text(
                              _reminderAt == null ? 'Set Reminder' : DateFormat('hh:mm a').format(_reminderAt!),
                              style: TextStyle(color: _reminderAt != null ? kAccentColor : Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _noteController.text.trim().isEmpty ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(_editingDocId == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (picked.isBefore(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a future time.')));
      return;
    }
    setState(() => _reminderAt = picked);
  }

  Future<void> _deleteNote(String uid, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        title: const Text('Delete Entry?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) {
      await NotificationService.cancelJournalReminder(docId);
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('health_journal').doc(docId).delete();
      _showStatusSnackBar('Entry deleted', Colors.redAccent);
    }
  }

  // --- Date Grouping Helper ---
  String _dateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    if (date.year == now.year && date.month == now.month && date.day == now.day - 1) return 'Yesterday';
    return DateFormat('EEEE, dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposer(),
        backgroundColor: kAccentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text('Add Entry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).journalTitle, style: FontStyles.roboto18),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => JournalDueReminderService.instance.scanDueRemindersNow(), 
            icon: const Icon(Icons.sync_rounded, color: Colors.white24),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(105.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search your journal...',
                    prefixIcon: const Icon(Icons.search_rounded, color: kAccentColor),
                    filled: true,
                    fillColor: kSurfaceColor.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(
                height: 38.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final tag = _filterTags[i];
                    final selected = tag == _filterTag;
                    final color = tag == 'All' ? kAccentColor : _tagColor(tag);
                    return ChoiceChip(
                      label: Text(tag, style: TextStyle(fontSize: 11.sp)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterTag = tag),
                      selectedColor: color,
                      backgroundColor: color.withValues(alpha: 0.05),
                      side: BorderSide(color: selected ? color : color.withValues(alpha: 0.2)),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemCount: _filterTags.length,
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('health_journal').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var docs = snapshot.data!.docs;
          
          // Apply Search Query & Category Filter
          if (_searchQuery.isNotEmpty || _filterTag != 'All') {
            docs = docs.where((d) {
              final note = (d['note'] as String? ?? '').toLowerCase();
              final tag = (d['tag'] as String? ?? '').toLowerCase();
              
              final matchesSearch = _searchQuery.isEmpty || note.contains(_searchQuery) || tag.contains(_searchQuery);
              final matchesTag = _filterTag == 'All' || tag == _filterTag.toLowerCase();
              
              return matchesSearch && matchesTag;
            }).toList();
          }

          if (docs.isEmpty) return _buildEmptyState();

          // Grouping logic
          Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> groups = {};
          for (var doc in docs) {
            final date = (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final header = _dateHeader(date);
            groups.putIfAbsent(header, () => []).add(doc);
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
            itemCount: groups.keys.length,
            itemBuilder: (context, index) {
              final header = groups.keys.elementAt(index);
              final items = groups[header]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                    child: Text(header, style: FontStyles.roboto12.copyWith(color: kAccentColor, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                  ...items.map((doc) => _buildNoteCard(doc)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final color = _tagColor(data['tag'] ?? 'general');
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: kSurfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.r),
        onTap: () => _showComposer(editId: doc.id, initialData: data),
        title: Row(
          children: [
            Icon(_tagIcon(data['tag'] ?? 'general'), size: 16, color: color),
            SizedBox(width: 8.w),
            Text(data['tag']?.toUpperCase() ?? 'GENERAL', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Spacer(),
            Text(
              data['createdAt'] != null ? DateFormat('hh:mm a').format((data['createdAt'] as Timestamp).toDate()) : '',
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.white24),
              onSelected: (val) {
                if (val == 'delete' && uid != null) _deleteNote(uid, doc.id);
                if (val == 'edit') _showComposer(editId: doc.id, initialData: data);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(data['note'] ?? '', style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 15)),
            if (data['reminderAt'] != null)
              Container(
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm_rounded, size: 12, color: Colors.amber),
                    SizedBox(width: 6.w),
                    Text(DateFormat('hh:mm a').format((data['reminderAt'] as Timestamp).toDate()), style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: Colors.white10),
          SizedBox(height: 20.h),
          Text('Your space for thoughts is empty.', style: TextStyle(color: Colors.white38, fontSize: 16)),
          Text('Tap the "+" to start journaling.', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
