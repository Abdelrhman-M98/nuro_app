import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_assets.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class SuccessValidation extends StatelessWidget {
  const SuccessValidation({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.kDoneIcon, width: 109.w, height: 109.h),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 61.w),
              child: Text(
                "PleaseYour account have been verified",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: FontStyles.roboto24.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 175.h),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go(AppRouter.kAllPatientsView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                minimumSize: Size(321.w, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                "Login Now",
                style: FontStyles.roboto16.copyWith(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
