import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        elevation: 0,
        title: Text(title, style: FontStyles.getRoboto18(context)),
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
              style: FontStyles.getRoboto14(context).copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.88),
                height: 1.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
