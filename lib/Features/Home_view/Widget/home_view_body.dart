import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/widgets/connectivity_banner.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/data_section.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/patient_info_section.dart';
import 'package:nervix_app/Features/Home_view/Widget/emergency_strip.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 56.sp, color: Colors.white54),
                  SizedBox(height: 20.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: FontStyles.roboto14.copyWith(
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Semantics(
                    button: true,
                    label: 'Retry live stream connection',
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                      ),
                      onPressed: () => context.read<HomeCubit>().reconnect(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        l10n.retryConnection,
                        style: FontStyles.roboto16.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is HomeLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ConnectivityBanner(),
              Expanded(
                child: RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: () => context.read<HomeCubit>().reconnect(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: const EmergencyStrip(),
                        ),
                        PatientInfoSection(state: state),
                        SizedBox(height: 24.h),
                        DataSection(
                          currentState: state.currentState,
                          user: state.user,
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
