import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';
import 'package:neuro_app/Core/utils/styles.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/custom_user_type.dart';

class UserTypeView extends StatefulWidget {
  const UserTypeView({super.key});

  @override
  UserTypeViewState createState() => UserTypeViewState();
}

class UserTypeViewState extends State<UserTypeView> {
  final ValueNotifier<String?> selectedUserType = ValueNotifier<String?>(null);

  @override
  void dispose() {
    selectedUserType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 284.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17.r),
                      color: kFloatingButtonColor,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 156.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17.r),
                          color: Color(0XFFFFBE32),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "50 %",
                    style: FontStyles.roboto12.copyWith(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 150.h),
              Text("I'm a", style: FontStyles.roboto24),
              SizedBox(height: 64.h),
              CustomUserTypeButton(
                onPressed: () => selectedUserType.value = "Patient Relative",
                imagePath: 'assets/images/Patient.png',
                userType: "Patient Relative",
                selectedUserType: selectedUserType,
              ),
              SizedBox(height: 21.h),
              CustomUserTypeButton(
                onPressed: () => selectedUserType.value = "Doctor",
                imagePath: 'assets/images/Doctor.png',
                userType: "Doctor",
                selectedUserType: selectedUserType,
              ),
              SizedBox(height: 21.h),
              CustomUserTypeButton(
                onPressed: () => selectedUserType.value = "Nurse",
                userType: "Nurse",
                imagePath: "assets/images/Nuers.png",
                selectedUserType: selectedUserType,
              ),
              SizedBox(height: 91.h),
              CustomButton(
                text: "Continue Registration",
                onPressed: () {
                  if (selectedUserType.value == "Patient Relative") {
                    GoRouter.of(context).go(AppRouter.kPatientInfoView);
                  } else if (selectedUserType.value == "Doctor") {
                    // GoRouter.of(context).go(AppRouter.kDoctorInfoView);
                  } else {
                    GoRouter.of(context).go(AppRouter.kHomeView);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
