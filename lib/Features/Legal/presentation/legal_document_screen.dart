import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(title, style: FontStyles.roboto18),
        centerTitle: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 32.h),
          itemCount: paragraphs.length,
          separatorBuilder: (context, _) => SizedBox(height: 18.h),
          itemBuilder: (context, i) {
            return Text(
              paragraphs[i],
              style: FontStyles.roboto14.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
