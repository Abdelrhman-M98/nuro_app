import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.onPressed});
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(-3, 3),
              ),
            ],
          ),

          width: 55.w,
          height: 55.h,
          child: IconButton(
            isSelected: false,
            highlightColor: Colors.transparent,
            icon: Icon(Icons.chevron_left, color: kPrimaryColor, size: 30.sp),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}
