import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/custom_appbar.dart';

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
              CustomAppBar(
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
