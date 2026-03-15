import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 307.w),
      height: 56.h,
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: kOnSurfaceVariantColor.withValues(alpha: 0.4),
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
              style: FontStyles.roboto12.copyWith(color: kOnSurfaceColor),
              decoration: InputDecoration(
                hintText: "Patient ID",
                hintStyle: FontStyles.roboto12.copyWith(
                  color: kOnSurfaceVariantColor,
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
