import 'package:flutter/material.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/entry_view_body.dart';

class EntryView extends StatelessWidget {
  const EntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(child: EntryViewBody()),
      ),
    );
  }
}
