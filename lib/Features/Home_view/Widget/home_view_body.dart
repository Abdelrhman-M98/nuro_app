import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/data_section.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/patient_info_section.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var imageUrl =
        "https://icons.veryicon.com/png/o/miscellaneous/user-avatar/user-avatar-male-5.png";

    return Column(
      children: [
        PatientInfoSection(imageUrl: imageUrl),
        SizedBox(height: 23.h),
        DataSection(),
      ],
    );
  }
}
