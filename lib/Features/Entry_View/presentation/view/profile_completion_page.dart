import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_state.dart';
import 'package:nervix_app/Features/Home_view/logic/profile_cubit.dart';
import 'package:nervix_app/Core/utils/profile_avatar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_button.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCountry;
  String? _selectedGender;
  String? _profileImageUrl;
  String? _profileImageBase64;
  final Set<String> _selectedDiseases = {};

  List<String> _diseasesOptions(BuildContext context) => [
    context.t("Diabetes", "السكري"), 
    context.t("Hypertension", "ضغط الدم"), 
    context.t("Heart Disease", "أمراض القلب"), 
    context.t("Asthma", "الربو"), 
    context.t("Arthritis", "التهاب المفاصل"), 
    context.t("Kidney Disease", "أمراض الكلى"), 
    context.t("Liver Disease", "أمراض الكبد"), 
    context.t("Cancer", "السرطان"), 
    context.t("None", "لا يوجد")
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().authRepository.currentUser;
    if (user != null) {
      _profileImageUrl = user.photoURL;
      _nameController.text = user.displayName ?? '';
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    await context.read<ProfileCubit>().uploadProfileImage();
  }

  Future<void> _cancelRegistration() async {
    final cubit = context.read<AuthCubit>();
    final user = cubit.authRepository.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
      } catch (e) {
        debugPrint('Account deletion error on cancel: $e');
      }
    }
    await cubit.logout();
    if (mounted) {
      GoRouter.of(context).go(AppRouter.kLoginView);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountry == null) {
        _showSnackBar(context.t('Please select your country', 'يرجى اختيار بلدك'));
        return;
      }
      if (_selectedGender == null) {
        _showSnackBar(context.t('Please select your gender', 'يرجى اختيار جنسك'));
        return;
      }
      if (_selectedDiseases.isEmpty) {
        _showSnackBar(context.t('Please select health status (or None)', 'يرجى اختيار الحالة الصحية'));
        return;
      }

      final cubit = context.read<AuthCubit>();
      final currentUser = cubit.authRepository.currentUser;
      
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (currentUser.displayName ?? 'User'),
          age: int.parse(_ageController.text),
          country: _selectedCountry,
          phoneNumber: _phoneController.text.trim(),
          gender: _selectedGender,
          chronicDiseases: _selectedDiseases.toList(),
          profileImageUrl: _profileImageUrl,
          profileImageBase64: _profileImageBase64 ?? '',
          hasCompletedProfile: true,
          createdAt: DateTime.now(), // Fallback
          lastLoginAt: DateTime.now(),
        );
        
        cubit.updateUserProfile(updatedUser);
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchUserData(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, profileState) {
          if (profileState is ProfileUpdateSuccess) {
            setState(() {
              _profileImageBase64 = profileState.user.profileImageBase64;
              _profileImageUrl = profileState.user.profileImageUrl;
            });
          } else if (profileState is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(profileState.message), backgroundColor: Colors.red),
            );
          } else if (profileState is ProfileLoaded) {
            // Initial load if user already has data
            if (_profileImageBase64 == null) {
              setState(() {
                _profileImageBase64 = profileState.user.profileImageBase64;
                _profileImageUrl = profileState.user.profileImageUrl;
                
                // Pre-fill name if it was already collected during signup/google
                if (_nameController.text.isEmpty && profileState.user.name != null && profileState.user.name!.isNotEmpty) {
                  _nameController.text = profileState.user.name!;
                }
              });
            }
          }
        },
        builder: (context, profileState) {
          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: context.colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
                onPressed: _cancelRegistration,
              ),
              title: Text(context.t("Complete Your Profile", "أكمل ملفك الشخصي"), 
                style: FontStyles.getRoboto18(context).copyWith(color: context.colorScheme.onSurface)),
              centerTitle: true,
            ),
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                await _cancelRegistration();
              },
              child: BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                if (state is ProfileUpdated || (state is AuthSuccess && state.hasCompletedProfile)) {
                  GoRouter.of(context).go(AppRouter.kHomeView);
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image Section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70.r,
                                  backgroundColor: context.colorScheme.surfaceContainer,
                                  child: ClipOval(
                                    child: ProfileAvatarFromFields(
                                      profileImageUrl: _profileImageUrl ?? '',
                                      profileImageBase64: _profileImageBase64 ?? '',
                                      genderFallback: _selectedGender ?? 'Male',
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: kAccentColor,
                                    child: profileState is ProfileUpdating
                                        ? CircularProgressIndicator(strokeWidth: 2, color: context.colorScheme.onPrimary)
                                        : IconButton(
                                            icon: Icon(Icons.camera_alt, size: 20.sp, color: context.colorScheme.onPrimary),
                                            onPressed: () { _pickAndUploadImage(context); },
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            TextButton(
                              onPressed: profileState is ProfileUpdating ? null : () { _pickAndUploadImage(context); },
                              child: Text(
                                profileState is ProfileUpdating ? context.t("Uploading...", "جاري الرفع...") : context.t("Change Photo", "تغيير الصورة"),
                                style: TextStyle(color: kAccentColor, fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: 10.h),
                _buildSectionTitle(context.t("General Information", "معلومات عامة")),
                // Name is already collected at signup/google, skipping redundant field for professional flow
                SizedBox(height: 10.h),
                SizedBox(height: 20.h),
                
                // Age Field
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colorScheme.onSurface),
                  decoration: _inputDecoration(context.t("Age", "العمر"), Icons.calendar_today),
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\x00-\x7F]'))],
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.t("Required", "مطلوب");
                    if (RegExp(r'[٠-٩]').hasMatch(v)) return context.t("Use English numbers only", "استخدم الأرقام الإنجليزية فقط");
                    final age = int.tryParse(v);
                    if (age == null || age < 16 || age > 100) return context.t("Valid age range: 16-100", "العمر المسموح: 16-100");
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Country Field
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        final localizedName = CountryLocalizations.of(context)?.countryName(countryCode: country.countryCode) ?? country.name;
                        setState(() {
                          _selectedCountry = "${country.flagEmoji} $localizedName";
                          if (_phoneController.text.isEmpty || !_phoneController.text.startsWith('+')) {
                            _phoneController.text = "+${country.phoneCode} ";
                          }
                        });
                      },
                      countryListTheme: CountryListThemeData(
                        borderRadius: BorderRadius.circular(20.r),
                        backgroundColor: context.colorScheme.surface,
                        textStyle: TextStyle(color: context.colorScheme.onSurface),
                        searchTextStyle: TextStyle(color: context.colorScheme.onSurface),
                        inputDecoration: InputDecoration(
                          hintText: context.t("Search Country", "ابحث عن بلد"),
                          hintStyle: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.38)),
                          prefixIcon: const Icon(Icons.search, color: kAccentColor),
                          filled: true,
                          fillColor: context.colorScheme.surfaceContainer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, color: kAccentColor, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedCountry ?? context.t("Select Country", "اختر البلد"),
                          style: TextStyle(color: _selectedCountry == null ? context.colorScheme.onSurface.withValues(alpha: 0.38) : context.colorScheme.onSurface),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: context.colorScheme.onSurface.withValues(alpha: 0.54)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: context.colorScheme.onSurface),
                  decoration: _inputDecoration(context.t("Phone Number", "رقم الهاتف"), Icons.phone),
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\x00-\x7F]'))],
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.t("Required", "مطلوب");
                    if (RegExp(r'[٠-٩]').hasMatch(v)) return context.t("Use English numbers only", "استخدم الأرقام الإنجليزية فقط");
                    if (v.length < 8) return context.t("Invalid phone number", "رقم هاتف غير صحيح");
                    return null;
                  },
                ),
                SizedBox(height: 32.h),

                _buildSectionTitle(context.t("Gender", "الجنس")),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["male", "female"].map((g) {
                    final isSelected = _selectedGender == g;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ChoiceChip(
                          label: Center(child: Text(g == 'male' ? context.t('Male', 'ذكر') : context.t('Female', 'أنثى'))),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedGender = g),
                          selectedColor: kAccentColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : context.colorScheme.onSurface),
                          backgroundColor: context.colorScheme.surfaceContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32.h),

                _buildSectionTitle(context.t("Chronic Diseases", "الأمراض المزمنة")),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _diseasesOptions(context).map((d) {
                    final isSelected = _selectedDiseases.contains(d);
                    return FilterChip(
                      label: Text(d),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            if (d == context.t('None', 'لا يوجد')) {
                              _selectedDiseases.clear();
                              _selectedDiseases.add(d);
                            } else {
                              _selectedDiseases.remove(context.t('None', 'لا يوجد'));
                              _selectedDiseases.add(d);
                            }
                          } else {
                            _selectedDiseases.remove(d);
                          }
                        });
                      },
                      selectedColor: kAccentColor,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : context.colorScheme.onSurface),
                      backgroundColor: context.colorScheme.surfaceContainer,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),

                SizedBox(height: 48.h),
                
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      text: context.t("Save & Continue", "حفظ ومتابعة"),
                    );
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FontStyles.roboto16.copyWith(color: kAccentColor, fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.38)),
      prefixIcon: Icon(icon, color: kAccentColor, size: 20.sp),
      filled: true,
      fillColor: context.colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
    );
  }
}
