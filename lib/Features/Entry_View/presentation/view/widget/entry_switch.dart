import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/entry_background.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/entry_btn.dart';

class EntrySwitch extends StatelessWidget {
  final bool isSignIn;
  final ValueChanged<bool> onToggle;

  const EntrySwitch({
    super.key,
    required this.isSignIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 321.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: kFloatingButtonColor,
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.w),
            child: EntryBackground(isSignIn: isSignIn),
          ),
          Row(
            children: [
              Expanded(
                child: EntryButton(
                  text: "Sign In",
                  isActive: isSignIn,
                  onTap: () => onToggle(true),
                ),
              ),
              Expanded(
                child: EntryButton(
                  text: "Sign Up",
                  isActive: !isSignIn,
                  onTap: () => onToggle(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
