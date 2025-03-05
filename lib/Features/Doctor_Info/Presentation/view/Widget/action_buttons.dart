import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/custom_icon_btn.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, this.onPressedAudio, this.onPressedDownload});
  final void Function()? onPressedAudio;
  final void Function()? onPressedDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomIconButton(
          onPressed: onPressedAudio,
          icon: FontAwesomeIcons.headphones,
          borderColor: kPrimaryColor,
          iconColor: kPrimaryColor,
          size: 43.w,
        ),
        SizedBox(height: 13.h),
        CustomIconButton(
          onPressed: onPressedDownload,
          icon: FontAwesomeIcons.cloudArrowDown,
          backgroundColor: const Color(0XFFFFBE32),
          iconColor: Colors.black,
          size: 60.w,
        ),
      ],
    );
  }
}
