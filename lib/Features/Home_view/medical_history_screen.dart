import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        gradient: context.isDarkMode ? kDarkGradient : kLightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            context.t("Medical History Log", "سجل التاريخ الطبي"),
            style: FontStyles.getRoboto18(context).copyWith(color: context.colorScheme.onSurface),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: context.colorScheme.onSurface),
          actions: [
            IconButton(
              onPressed: () => _confirmDeleteAll(context, uid),
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: context.t("Clear All Logs", "مسح جميع السجلات"),
            ),
          ],
        ),
        body: uid == null
            ? Center(child: Text(context.t("Please Login", "يرجى تسجيل الدخول")))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('history')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        context.t("No emergency records found.", "لا يوجد سجلات طوارئ حالياً."),
                        style: FontStyles.getRoboto14(context).copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final date = timestamp != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                          : context.t("Unknown Date", "تاريخ غير معروف");
                      final signal = data['signalValue'] ?? 0;

                      return Card(
                        color: context.colorScheme.surface.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.05))),
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          ),
                          title: Text(
                            context.t("Abnormal Activity", "نشاط غير طبيعي"),
                            style: FontStyles.getRoboto16(context).copyWith(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            date,
                            style: FontStyles.getRoboto14(context).copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          trailing: Text(
                            "${context.t('Signal', 'الإشارة')}: ${signal.toInt()}",
                            style: FontStyles.getRoboto14(context).copyWith(color: kAccentColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, String? uid) {
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: Text(context.t("Clear History?", "مسح السجل؟"), style: FontStyles.getRoboto18(context).copyWith(color: context.colorScheme.onSurface)),
        content: Text(
          context.t("Are you sure you want to delete all medical records? This action cannot be undone.", "هل أنت متأكد من حذف جميع السجلات الطبية؟ لا يمكن التراجع عن هذا الإجراء."),
          style: FontStyles.getRoboto14(context).copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t("Cancel", "إلغاء")),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllHistory(uid);
            },
            child: Text(context.t("Delete All", "حذف الكل"), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllHistory(String uid) async {
    final collection = FirebaseFirestore.instance.collection('users').doc(uid).collection('history');
    final snapshots = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
