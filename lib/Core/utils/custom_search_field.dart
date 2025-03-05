// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 307.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: Color(0XFF919191).withOpacity(0.5),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22.w, right: 12.w),
            child: FaIcon(
              FontAwesomeIcons.solidUser,
              color: Color(0XFF919191),
              size: 19.sp,
            ),
          ),
          Expanded(
            child: TextField(
              style: FontStyles.roboto12,
              decoration: InputDecoration(
                hintText: "Patient ID",
                hintStyle: FontStyles.roboto12.copyWith(
                  color: Color(0Xff919191),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {},
              icon: FaIcon(
                FontAwesomeIcons.search,
                color: kPrimaryColor,
                size: 25.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
