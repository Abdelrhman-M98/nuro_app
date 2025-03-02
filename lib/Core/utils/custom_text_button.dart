import 'package:flutter/material.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key, required this.text, this.onPressed});
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: FontStyles.roboto16),
    );
  }
}
