import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 307.w),
      height: 56.h,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: FaIcon(
              FontAwesomeIcons.solidUser,
              color: kAccentColor,
              size: 18.sp,
            ),
          ),
          Expanded(
            child: TextField(
              style: FontStyles.getRoboto12(context).copyWith(color: context.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.t("Patient ID", "اسم المريض"),
                hintStyle: FontStyles.getRoboto12(context).copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.54),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: kAccentColor,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}
