import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:arabic_reshaper/arabic_reshaper.dart';

import 'package:nervix_app/Core/utils/disease_translator.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

import 'package:bidi/bidi.dart' as bidi;

class PdfReportGenerator {
  static String _fixArabic(String text) {
    try {
      if (text.isEmpty) return text;
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      if (!hasArabic) return text;
      
      // Step 1: Visual Order (Bidi) - handles numbers and mixed text perfectly
      final visualOrder = bidi.logicalToVisual(text);
      final visualString = String.fromCharCodes(visualOrder);
      
      // Step 2: Shape the visual string
      // Note: Re-shaping a visual string works because the connection logic
      // remains consistent even if the string is visually reversed.
      return ArabicReshaper().reshape(visualString);
    } catch (e) {
      // Fallback: If Bidi fails, just try simple shaping
      try {
        return ArabicReshaper().reshape(text);
      } catch (e2) {
        return text;
      }
    }
  }

  static Future<Uint8List> _buildPdfBytes(UserModel user, bool isArabic) async {
    String t(String en, String ar) => isArabic ? _fixArabic(ar) : en;

    final pdf = pw.Document(
      title: isArabic ? _fixArabic('تقرير نيرفيكس الطبي') : 'Nervix Medical Report - ${user.name}',
      author: 'Nervix AI System',
    );

    // Load Fonts
    pw.Font? arabicFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      arabicFont = pw.Font.ttf(fontData);
    } catch (e) {
      debugPrint('PDF Generator: Arabic Font load failed: $e');
    }

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
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFont,
          fontFallback: arabicFont != null ? [arabicFont] : [],
        ),
        header: (context) => pw.Container(
          alignment: isArabic ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Directionality(
            textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logo != null)
                  pw.Image(logo, width: 80, height: 80)
                else
                  pw.PdfLogo(),
                pw.Column(
                  crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      t('MEDICAL REPORT', 'تقرير طبي'),
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${t('Report ID', 'رقم التقرير')}: ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      '${t('Generated on', 'تم الاستخراج في')}: $reportDate',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: isArabic ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Directionality(
            textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  t('Nervix Neural Monitoring System - Confidential', 'نظام نيرفيكس للمراقبة العصبية - سري للغاية'),
                  style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
                ),
                pw.Text(
                  '${t('Page', 'صفحة')} ${context.pageNumber} ${t('of', 'من')} ${context.pagesCount}',
                  style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
                ),
              ],
            ),
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
              crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  t('PATIENT PROFILE', 'ملف المريض'),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Directionality(
                  textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildInfoField(t('Name', 'الاسم'), _fixArabic(user.name ?? 'Unknown'), isArabic),
                      ),
                      pw.Expanded(
                        child: _buildInfoField(t('Age', 'العمر'), '${user.age} ${t('Years', 'سنة')}', isArabic),
                      ),
                      pw.Expanded(
                        child: _buildInfoField(t('Gender', 'الجنس'), 
                          user.gender?.toLowerCase() == 'male' ? t('Male', 'ذكر') : t('Female', 'أنثى'), 
                          isArabic),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
                // Detailed Diseases Section
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: isArabic ? pw.BorderSide.none : const pw.BorderSide(color: PdfColors.grey400, width: 2),
                      right: isArabic ? const pw.BorderSide(color: PdfColors.grey400, width: 2) : pw.BorderSide.none,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        t('MEDICAL HISTORY & CHRONIC CONDITIONS', 'التاريخ الطبي والأمراض المزمنة'),
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _fixArabic(DiseaseTranslator.translateWithLocale(user.condition.isEmpty ? 'None' : user.condition, isArabic)),
                        style: pw.TextStyle(
                          fontSize: 11,
                          lineSpacing: 2,
                          font: arabicFont,
                        ),
                        textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildInfoField(t('Contact Source', 'رقم المتصل'), user.phone.isEmpty ? 'N/A' : user.phone, isArabic),
              ],
            ),
          ),

          pw.SizedBox(height: 25),

          // Events Table Header
          pw.Text(
            t('NEURAL EVENT LOG (LAST 25 EVENTS)', 'سجل الأحداث العصبية (آخر 25 حدث)'),
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
                t('No abnormal neural activity detected during the monitoring period.', 'لم يتم تسجيل أي نشاط عصبي غير طبيعي خلال فترة المراقبة.'),
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
                    if (isArabic)
                      _buildTableCell(t('Signal Value', 'قيمة الإشارة'), isHeader: true, align: pw.Alignment.centerLeft)
                    else
                      _buildTableCell(t('Date & Time', 'التاريخ والوقت'), isHeader: true),
                    
                    _buildTableCell(t('Clinical Status', 'الحالة السريرية'), isHeader: true),
                    
                    if (isArabic)
                      _buildTableCell(t('Date & Time', 'التاريخ والوقت'), isHeader: true, align: pw.Alignment.centerRight)
                    else
                      _buildTableCell(t('Signal Value', 'قيمة الإشارة'), isHeader: true, align: pw.Alignment.centerRight),
                  ],
                ),
                // Table Body
                ...historyData.map((data) {
                  final ts = data['snapshot_at'] != null 
                    ? (data['snapshot_at'] as Timestamp).toDate()
                    : (data['timestamp'] as Timestamp?)?.toDate();
                  
                  final dateStr = ts != null 
                      ? DateFormat('MMM dd, HH:mm:ss').format(ts)
                      : 'N/A';
                  
                  final statusText = DiseaseTranslator.translateWithLocale(data['status']?.toString() ?? 'Abnormal', isArabic);
                  final signalValue = data['signalValue']?.toString() ?? 'N/A';

                  return pw.TableRow(
                    children: [
                      if (isArabic)
                        _buildTableCell(signalValue, align: pw.Alignment.centerLeft)
                      else
                        _buildTableCell(dateStr),
                      
                      _buildTableCell(_fixArabic(statusText)),
                      
                      if (isArabic)
                        _buildTableCell(dateStr, align: pw.Alignment.centerRight)
                      else
                        _buildTableCell(signalValue, align: pw.Alignment.centerRight),
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
              crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  t('Clinical Note:', 'ملاحظة طبية:'),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  t('This report contains data captured by the Nervix AI monitoring system. The detected events should be reviewed by a qualified medical professional for clinical diagnosis and treatment planning.',
                    'يحتوي هذا التقرير على بيانات تم تسجيلها بواسطة نظام نيرفيكس للمراقبة بالذكاء الاصطناعي. يجب مراجعة الأحداث المسجلة من قبل طبيب مختص للتشخيص السريري والتخطيط للعلاج.'),
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                  textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoField(String label, String value, bool isArabic) {
    return pw.Column(
      crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
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

  static Future<void> generateAndPrintReport(BuildContext context, UserModel user) async {
    final isArabic = context.isArabic;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _buildPdfBytes(user, isArabic),
    );
  }

  static Future<void> shareReport(BuildContext context, UserModel user) async {
    final isArabic = context.isArabic;
    final bytes = await _buildPdfBytes(user, isArabic);
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'nervix_report_$stamp.pdf',
    );
  }
}
