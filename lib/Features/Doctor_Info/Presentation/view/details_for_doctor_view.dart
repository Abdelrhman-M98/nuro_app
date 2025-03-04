import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/custom_appbar.dart';
import 'package:neuro_app/Core/utils/patient_card_button.dart';
import 'package:neuro_app/Core/utils/patient_card_info.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';

class DetailsForDoctorView extends StatelessWidget {
  const DetailsForDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    var x =
        "https://scontent.faly2-1.fna.fbcdn.net/v/t39.30808-1/476922286_2544388139247627_7229207242334962872_n.jpg?stp=cp6_dst-jpg_s480x480_tt6&_nc_cat=111&ccb=1-7&_nc_sid=1d2534&_nc_ohc=amU81QxZixgQ7kNvgE3jtNf&_nc_oc=Adgc9lFJLgfkJR2pDob2KA1AcnOWnvKVUkGWrjq2EJaC6O7InGarqV_FPARJsMgUlJk&_nc_zt=24&_nc_ht=scontent.faly2-1.fna&_nc_gid=A70g6tzlQtlwRkT-KitTw3q&oh=00_AYBZmRO2TpTW5qUu1GF6xPqmBmRTUHB3qwuMRs1gL2ZwYQ&oe=67CD705F";
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                height: 655.5.h,
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomAppBarButton(onPressed: () {}),
                          SizedBox(width: 30.w),
                          PatientsCardInfo(
                            patientName: 'Mohamed Ali',
                            age: '25',
                            condition: 'Diabetics - Heart',
                            imageUrl: x,
                            percentage: '92',
                          ),
                        ],
                      ),
                      SizedBox(height: 39.h),
                      SizedBox(
                        width: 381.w,
                        height: 445.h,
                        child: DynamicLineChart(),
                      ),
                      // Added height
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
