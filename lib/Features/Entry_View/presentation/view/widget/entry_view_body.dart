import 'package:flutter/material.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/entry_switch.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/signin_body.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/signup_body.dart';

class EntryViewBody extends StatefulWidget {
  const EntryViewBody({super.key});

  @override
  State<EntryViewBody> createState() => _EntryViewBodyState();
}

class _EntryViewBodyState extends State<EntryViewBody> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EntrySwitch(
          isSignIn: isSignIn,
          onToggle: (bool value) => setState(() => isSignIn = value),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSignIn ? const SigninBody() : const SignupBody(),
          ),
        ),
      ],
    );
  }
}
