import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/app_assets.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class WaitDataValidation extends StatelessWidget {
  const WaitDataValidation({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.kCoffeeIcon, width: 109.w, height: 109.h),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 61.w),
              child: Text(
                "Please take a cup of coffee until verification",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: FontStyles.roboto24.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "Almost from 10 mins to 30 mins",
              maxLines: 2,
              textAlign: TextAlign.center,
              style: FontStyles.roboto16.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
