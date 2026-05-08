import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:intl/intl.dart';

class PdfReportGenerator {
  static Future<Uint8List> _buildPdfBytes(UserModel user) async {
    final pdf = pw.Document(
      title: 'Nervix Medical Report - ${user.name}',
      author: 'Nervix AI System',
    );

    // Load Logo
    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/logoN.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('PDF Generator: Logo load failed: $e');
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final List<Map<String, dynamic>> historyData = [];

    if (uid.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .limit(25)
            .get();
        for (var doc in snap.docs) {
          historyData.add(doc.data());
        }
      } catch (e) {
        debugPrint('PDF Generator: History fetch failed: $e');
      }
    }

    final primaryColor = PdfColor.fromInt(0xFF5B3E90);
    final accentColor = PdfColor.fromInt(0xFF00D9FF);
    final reportDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (logo != null)
                pw.Image(logo, width: 80, height: 80)
              else
                pw.PdfLogo(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'MEDICAL REPORT',
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Report ID: ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Generated on: $reportDate',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Nervix Neural Monitoring System - Confidential',
                style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
              ),
            ],
          ),
        ),
        build: (pw.Context context) => [
          // Patient Profile Section
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PATIENT PROFILE',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField('Name', user.name ?? 'Unknown'),
                    ),
                    pw.Expanded(
                      child: _buildInfoField('Age', '${user.age} Years'),
                    ),
                    pw.Expanded(
                      child: _buildInfoField('Gender', user.gender?.toUpperCase() ?? 'N/A'),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField('Diagnosis', user.condition.isEmpty ? 'Stable Monitoring' : user.condition),
                    ),
                    pw.Expanded(
                      child: _buildInfoField('Contact', user.phone.isEmpty ? 'N/A' : user.phone),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 25),

          // Events Table Header
          pw.Text(
            'NEURAL EVENT LOG (LAST 25 EVENTS)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 12),

          // Events Table
          if (historyData.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 20),
              alignment: pw.Alignment.center,
              child: pw.Text(
                'No abnormal neural activity detected during the monitoring period.',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
              ),
            )
          else
            pw.Table(
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
              ),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
                  ),
                  children: [
                    _buildTableCell('Date & Time', isHeader: true),
                    _buildTableCell('Clinical Status', isHeader: true),
                    _buildTableCell('Signal Value', isHeader: true, align: pw.Alignment.centerRight),
                  ],
                ),
                // Table Body
                ...historyData.map((data) {
                  final ts = data['timestamp'] as Timestamp?;
                  final dateStr = ts != null 
                      ? DateFormat('MMM dd, HH:mm:ss').format(ts.toDate())
                      : 'N/A';
                  return pw.TableRow(
                    children: [
                      _buildTableCell(dateStr),
                      _buildTableCell(data['status']?.toString() ?? 'Abnormal'),
                      _buildTableCell(data['signalValue']?.toString() ?? 'N/A', align: pw.Alignment.centerRight),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 30),

          // Medical Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: accentColor, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Clinical Note:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'This report contains data captured by the Nervix AI monitoring system. The detected events should be reviewed by a qualified medical professional for clinical diagnosis and treatment planning.',
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static Future<void> generateAndPrintReport(UserModel user) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _buildPdfBytes(user),
    );
  }

  static Future<void> shareReport(UserModel user) async {
    final bytes = await _buildPdfBytes(user);
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'nervix_report_$stamp.pdf',
    );
  }
}
