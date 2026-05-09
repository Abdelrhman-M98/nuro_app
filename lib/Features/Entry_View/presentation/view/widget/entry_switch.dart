import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/entry_background.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/entry_btn.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class EntrySwitch extends StatelessWidget {
  final bool isSignIn;
  final ValueChanged<bool> onToggle;

  const EntrySwitch({
    super.key,
    required this.isSignIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pillWidth = (constraints.maxWidth - 22.w) / 2;
        return Container(
          width: double.infinity,
          height: 44.h,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(17.r),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: EntryBackground(
                  isSignIn: isSignIn,
                  pillWidth: pillWidth,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: EntryButton(
                      text: context.t("Sign In", "تسجيل الدخول"),
                      isActive: isSignIn,
                      onTap: () => onToggle(true),
                    ),
                  ),
                  Expanded(
                    child: EntryButton(
                      text: context.t("Sign Up", "إنشاء حساب"),
                      isActive: !isSignIn,
                      onTap: () => onToggle(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
