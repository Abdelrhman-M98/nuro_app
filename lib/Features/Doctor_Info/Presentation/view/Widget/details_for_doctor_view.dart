import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/data_section.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/patient_info_section.dart';

class DetailsForDoctorBody extends StatelessWidget {
  const DetailsForDoctorBody({super.key});

  @override
  Widget build(BuildContext context) {
    var imageUrl =
        "https://scontent.faly2-1.fna.fbcdn.net/v/t39.30808-1/476922286_2544388139247627_7229207242334962872_n.jpg?stp=cp6_dst-jpg_s480x480_tt6&_nc_cat=111&ccb=1-7&_nc_sid=1d2534&_nc_ohc=amU81QxZixgQ7kNvgE3jtNf&_nc_oc=Adgc9lFJLgfkJR2pDob2KA1AcnOWnvKVUkGWrjq2EJaC6O7InGarqV_FPARJsMgUlJk&_nc_zt=24&_nc_ht=scontent.faly2-1.fna&_nc_gid=A70g6tzlQtlwRkT-KitTw3q&oh=00_AYBZmRO2TpTW5qUu1GF6xPqmBmRTUHB3qwuMRs1gL2ZwYQ&oe=67CD705F";

    return Column(
      children: [
        PatientInfoSection(imageUrl: imageUrl),
        SizedBox(height: 23.h),
        DataSection(),
      ],
    );
  }
}
