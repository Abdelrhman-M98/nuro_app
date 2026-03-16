import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Medical History Log", style: FontStyles.roboto18),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _confirmDeleteAll(context, uid),
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: "Clear All Logs",
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text("Please Login"))
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
                      "No emergency records found.",
                      style: FontStyles.roboto14.copyWith(color: Colors.white70),
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
                        : "Unknown Date";
                    final signal = data['signalValue'] ?? 0;

                    return Card(
                      color: kSurfaceColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        ),
                        title: Text(
                          "Abnormal Activity",
                          style: FontStyles.roboto16.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          date,
                          style: FontStyles.roboto14.copyWith(color: Colors.white70),
                        ),
                        trailing: Text(
                          "Signal: ${signal.toInt()}",
                          style: FontStyles.roboto14.copyWith(color: kAccentColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _confirmDeleteAll(BuildContext context, String? uid) {
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        title: Text("Clear History?", style: FontStyles.roboto18.copyWith(color: Colors.white)),
        content: Text("Are you sure you want to delete all medical records? This action cannot be undone.",
            style: FontStyles.roboto14.copyWith(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllHistory(uid);
            },
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
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
