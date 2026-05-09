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
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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

  String _tagLabel(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'general': return context.t('general', 'عام');
      case 'sleep': return context.t('sleep', 'النوم');
      case 'stress': return context.t('stress', 'الضغط العصبي');
      case 'medication': return context.t('medication', 'العلاج');
      case 'symptom': return context.t('symptom', 'الأعراض');
      default: return tag;
    }
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
      _showStatusSnackBar(context.t('Please enter a note', 'يرجى إدخال ملاحظة'), Colors.orange);
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
        wasEditing ? context.t('Changes saved successfully', 'تم حفظ التعديلات بنجاح') : context.t('Journal entry added', 'تمت إضافة تدوينة جديدة'), 
        Colors.green.shade600
      );
      _resetInput();
    } catch (e) {
      _showStatusSnackBar(context.t('Failed to save', 'فشل في الحفظ') + ': $e', Colors.orange);
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
            color: context.colorScheme.surface,
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
                    decoration: BoxDecoration(color: context.colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(_editingDocId == null ? context.t('New Entry', 'تدوينة جديدة') : context.t('Edit Entry', 'تعديل التدوينة'), style: FontStyles.roboto18),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: context.colorScheme.onSurface.withValues(alpha: 0.38)),
                    ),
                  ],
                ),
                TextField(
                  controller: _noteController,
                  maxLines: 6,
                  minLines: 3,
                  autofocus: true,
                  maxLength: _maxNoteLength,
                  style: TextStyle(color: context.colorScheme.onSurface, height: 1.5, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: context.t('Share your thoughts...', 'شارك أفكارك...'), 
                    border: InputBorder.none,
                    counterStyle: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.24)),
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
                          label: Text(_tagLabel(tag)),
                          selected: selected,
                          onSelected: (_) => setSheetState(() => _selectedTag = tag),
                          selectedColor: color,
                          backgroundColor: color.withValues(alpha: 0.1),
                          side: BorderSide(color: selected ? Colors.transparent : color.withValues(alpha: 0.2)),
                          labelStyle: TextStyle(color: selected ? Colors.white : color, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
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
                          color: _reminderAt != null ? kAccentColor.withValues(alpha: 0.1) : context.colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm_rounded, size: 18, color: _reminderAt != null ? kAccentColor : context.colorScheme.onSurface.withValues(alpha: 0.38)),
                            SizedBox(width: 8.w),
                            Text(
                              _reminderAt == null ? context.t('Set Reminder', 'ضبط تذكير') : DateFormat('hh:mm a').format(_reminderAt!),
                              style: TextStyle(color: _reminderAt != null ? kAccentColor : context.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 13),
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
                      child: Text(_editingDocId == null ? context.t('Add', 'إضافة') : context.t('Update', 'تحديث'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Please choose a future time.', 'يرجى اختيار وقت في المستقبل.'))));
      return;
    }
    setState(() => _reminderAt = picked);
  }

  Future<void> _deleteNote(String uid, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: Text(context.t('Delete Entry?', 'حذف التدوينة؟'), style: TextStyle(color: context.colorScheme.onSurface)),

        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Cancel', 'إلغاء'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('Delete', 'حذف'), style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) {
      await NotificationService.cancelJournalReminder(docId);
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('health_journal').doc(docId).delete();
      _showStatusSnackBar(context.t('Entry deleted', 'تم حذف التدوينة'), Colors.redAccent);
    }
  }

  // --- Date Grouping Helper ---
  String _dateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return context.t('Today', 'اليوم');
    if (date.year == now.year && date.month == now.month && date.day == now.day - 1) return context.t('Yesterday', 'أمس');
    return DateFormat('EEEE, dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Container(
      decoration: BoxDecoration(
        gradient: context.isDarkMode ? kDarkGradient : kLightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showComposer(),
          backgroundColor: kAccentColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(context.t('Add Entry', 'إضافة تدوينة'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).journalTitle, style: FontStyles.getRoboto18(context).copyWith(color: context.colorScheme.onSurface)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(105.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: context.t('Search your journal...', 'ابحث في مذكراتك...'),
                      prefixIcon: const Icon(Icons.search_rounded, color: kAccentColor),
                      filled: true,
                      fillColor: context.colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
                      ),
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
                      final label = tag == 'All' ? context.t('All', 'الكل') : _tagLabel(tag);
                      return ChoiceChip(
                        label: Text(label, style: TextStyle(fontSize: 11.sp)),
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

            return RefreshIndicator(
              onRefresh: () async {
                await JournalDueReminderService.instance.scanDueRemindersNow();
              },
              color: kAccentColor,
              backgroundColor: context.colorScheme.surface,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: groups.keys.length,
                itemBuilder: (context, index) {
                  final header = groups.keys.elementAt(index);
                  final items = groups[header]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                        child: Text(header, style: FontStyles.getRoboto12(context).copyWith(color: kAccentColor, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),

                      ...items.map((doc) => _buildNoteCard(doc)),
                    ],
                  );
                },
              ),
            );
          },
        ),
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
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),

      child: ListTile(
        contentPadding: EdgeInsets.all(16.r),
        onTap: () => _showComposer(editId: doc.id, initialData: data),
        title: Row(
          children: [
            Icon(_tagIcon(data['tag'] ?? 'general'), size: 16, color: color),
            SizedBox(width: 8.w),
            Text(_tagLabel(data['tag'] ?? 'general').toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Spacer(),
            Text(
              data['createdAt'] != null ? DateFormat('hh:mm a').format((data['createdAt'] as Timestamp).toDate()) : '',
              style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 10),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 18, color: context.colorScheme.onSurface.withValues(alpha: 0.24)),

              onSelected: (val) {
                if (val == 'delete' && uid != null) _deleteNote(uid, doc.id);
                if (val == 'edit') _showComposer(editId: doc.id, initialData: data);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(context.t('Edit', 'تعديل'))),
                PopupMenuItem(value: 'delete', child: Text(context.t('Delete', 'حذف'), style: const TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(data['note'] ?? '', style: TextStyle(color: context.colorScheme.onSurface, height: 1.4, fontSize: 15)),

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
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
          SizedBox(height: 20.h),
          Text(context.t('Your space for thoughts is empty.', 'مساحة أفكارك فارغة.'), style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 16)),
          Text(context.t('Tap the "+" to start journaling.', 'اضغط على "+" لبدء التدوين.'), style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 12)),
        ],

      ),
    );
  }
}
