import 'package:flutter/material.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Home_view/Widget/home_view_body.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(child: HomeViewBody()),
      ),
    );
  }
}
