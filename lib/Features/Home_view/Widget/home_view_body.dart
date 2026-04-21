import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/data_section.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/patient_info_section.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
        } else if (state is HomeLoaded) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                PatientInfoSection(state: state),
                SizedBox(height: 24.h),
                DataSection(
                  currentState: state.currentState,
                  user: state.user,
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
