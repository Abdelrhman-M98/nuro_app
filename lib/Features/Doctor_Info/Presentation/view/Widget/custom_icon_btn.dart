import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    required this.iconColor,
    required this.size,
  });

  final void Function()? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border:
            borderColor != null
                ? Border.all(color: borderColor!, width: 3.w)
                : null,
        borderRadius: BorderRadius.circular(41.r),
      ),
      child: Center(
        child: IconButton(
          iconSize: size * 0.5,
          onPressed: onPressed,
          icon: FaIcon(icon, color: iconColor),
        ),
      ),
    );
  }
}
