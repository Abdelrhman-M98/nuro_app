import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';

class DoctorInfoView extends StatelessWidget {
  const DoctorInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 45.w),
          child: Column(
            children: [
              CustomAppBarButton(
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kUserTypeView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
