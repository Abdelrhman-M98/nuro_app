import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class PatientsCardInfo extends StatelessWidget {
  const PatientsCardInfo({
    super.key,
    required this.patientName,
    required this.age,
    required this.condition,
    required this.imageUrl,
    required this.percentage,
    this.onPressed,
  });

  final String patientName;
  final String age;
  final String condition;
  final String imageUrl;
  final String percentage;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 279.h,
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(radius: 30.r, backgroundImage: NetworkImage(imageUrl)),
          SizedBox(width: 18.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                patientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontStyles.roboto16.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Text(
                    "$age Y.O",
                    style: FontStyles.roboto12.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    condition,
                    style: FontStyles.roboto12.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    "$percentage%",
                    style: FontStyles.roboto12.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
