// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/custom_search_field.dart';
import 'package:neuro_app/Core/utils/patient_card_button.dart';

class AllPatientsView extends StatelessWidget {
  const AllPatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HeaderSection()),
          SliverToBoxAdapter(child: _SearchAndFilterSection()),
          _PatientsListSection(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Row(
              children: [
                CustomAppBarButton(onPressed: () {}),
                SizedBox(width: 31.w),
                Text(
                  "All Patients",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilterSection extends StatelessWidget {
  const _SearchAndFilterSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17.h, bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomSearchField(),
          SizedBox(width: 17.w),
          IconButton(
            onPressed: () {},
            icon: FaIcon(
              FontAwesomeIcons.filter,
              color: kPrimaryColor,
              size: 25.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientsListSection extends StatelessWidget {
  const _PatientsListSection();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> patients = [
      {
        "patientName": "Ali Ahmed",
        "age": "30",
        "condition": "Diabetes",
        "imageUrl": "https://randomuser.me/api/portraits/men/1.jpg",
        "percentage": 30,
      },
      {
        "patientName": "Sara Khaled",
        "age": "25",
        "condition": "Hypertension",
        "imageUrl": "https://randomuser.me/api/portraits/women/2.jpg",
        "percentage": 78,
      },
      {
        "patientName": "Hassan Mahmoud",
        "age": "40",
        "condition": "Heart Disease",
        "imageUrl": "https://randomuser.me/api/portraits/men/3.jpg",
        "percentage": 92,
      },
      {
        "patientName": "Mona Youssef",
        "age": "35",
        "condition": "Asthma",
        "imageUrl": "https://randomuser.me/api/portraits/women/4.jpg",
        "percentage": 10,
      },
      {
        "patientName": "Omar Tarek",
        "age": "50",
        "condition": "Arthritis",
        "imageUrl": "https://randomuser.me/api/portraits/men/5.jpg",
        "percentage": 89,
      },
      {
        "patientName": "Laila Sameh",
        "age": "28",
        "condition": "Migraine",
        "imageUrl": "https://randomuser.me/api/portraits/women/6.jpg",
        "percentage": 81,
      },
      {
        "patientName": "Mohamed Adel",
        "age": "33",
        "condition": "Allergy",
        "imageUrl": "https://randomuser.me/api/portraits/men/7.jpg",
        "percentage": 12,
      },
      {
        "patientName": "Ali Ahmed",
        "age": "30",
        "condition": "Diabetes",
        "imageUrl": "https://randomuser.me/api/portraits/men/1.jpg",
        "percentage": 30,
      },
      {
        "patientName": "Sara Khaled",
        "age": "25",
        "condition": "Hypertension",
        "imageUrl": "https://randomuser.me/api/portraits/women/2.jpg",
        "percentage": 78,
      },
      {
        "patientName": "Hassan Mahmoud",
        "age": "40",
        "condition": "Heart Disease",
        "imageUrl": "https://randomuser.me/api/portraits/men/3.jpg",
        "percentage": 92,
      },
      {
        "patientName": "Mona Youssef",
        "age": "35",
        "condition": "Asthma",
        "imageUrl": "https://randomuser.me/api/portraits/women/4.jpg",
        "percentage": 10,
      },
      {
        "patientName": "Omar Tarek",
        "age": "50",
        "condition": "Arthritis",
        "imageUrl": "https://randomuser.me/api/portraits/men/5.jpg",
        "percentage": 89,
      },
      {
        "patientName": "Laila Sameh",
        "age": "28",
        "condition": "Migraine",
        "imageUrl": "https://randomuser.me/api/portraits/women/6.jpg",
        "percentage": 81,
      },
      {
        "patientName": "Mohamed Adel",
        "age": "33",
        "condition": "Allergy",
        "imageUrl": "https://randomuser.me/api/portraits/men/7.jpg",
        "percentage": 12,
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final patient = patients[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 13.h),
          child: PatientsCardButton(
            patientName: patient["patientName"],
            age: patient["age"],
            condition: patient["condition"],
            imageUrl: patient["imageUrl"],
            percentage: patient["percentage"],
            onPressed: () {
              GoRouter.of(context).go(AppRouter.kDetailsForDoctorView);
            },
          ),
        );
      }, childCount: patients.length),
    );
  }
}
