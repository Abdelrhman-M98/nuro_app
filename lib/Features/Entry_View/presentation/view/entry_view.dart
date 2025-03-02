import 'package:flutter/material.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/entry_view_body.dart';

class EntryView extends StatelessWidget {
  const EntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: EntryViewBody()));
  }
}
