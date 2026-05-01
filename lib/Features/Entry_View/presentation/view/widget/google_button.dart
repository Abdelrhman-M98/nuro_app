import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nervix_app/Core/utils/styles.dart';

import 'package:nervix_app/Core/localization/translation_extension.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
        label: Text(
          context.t("Continue with Google", "المتابعة باستخدام جوجل"),
          style: FontStyles.roboto16.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}
