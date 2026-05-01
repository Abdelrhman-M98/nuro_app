import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:nervix_app/Features/Home_view/logic/profile_cubit.dart';
import 'package:nervix_app/Core/utils/profile_avatar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as auth_google;
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:country_picker/country_picker.dart';
import 'package:nervix_app/Core/utils/pdf_generator.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:nervix_app/Features/Home_view/Widget/monitoring_guide_sheet.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/localization/locale_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchUserData(),
      child: ProfileViewBody(onboarding: onboarding),
    );
  }
}


class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  UserModel? _lastUserForAvatar;
  late bool _editing;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final countryController = TextEditingController();
  final diseasesController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String genderSelection = 'male';

  // Local UI State for mockup demonstration
  ThemeMode _themeMode = ThemeMode.dark;

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _themeMode == ThemeMode.dark ? kBackgroundColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.t('Select Language', 'اختر اللغة'), style: FontStyles.roboto18.copyWith(fontWeight: FontWeight.bold, color: _themeMode == ThemeMode.dark ? Colors.white : Colors.black)),
              SizedBox(height: 10.h),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('English', style: TextStyle(color: _themeMode == ThemeMode.dark ? Colors.white : Colors.black)),
                onTap: () { 
                  context.read<LocaleCubit>().changeLanguage('en'); 
                  Navigator.pop(context); 
                },
              ),
              ListTile(
                leading: const Text('🇪🇬', style: TextStyle(fontSize: 24)),
                title: Text('العربية', style: TextStyle(color: _themeMode == ThemeMode.dark ? Colors.white : Colors.black)),
                onTap: () { 
                  context.read<LocaleCubit>().changeLanguage('ar'); 
                  Navigator.pop(context); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    super.initState();
    _editing = widget.onboarding;
  }

  bool get _fieldsEditable => widget.onboarding || _editing;

  bool _needsPasswordLink(User? user) {
    if (user == null || user.email == null || user.email!.isEmpty) {
      return false;
    }
    return !user.providerData.any((p) => p.providerId == 'password');
  }

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);
    if (_lastLocale != newLocale) {
      _lastLocale = newLocale;
      // Only auto-refresh from backend data if we aren't in the middle of editing
      if (!_editing) {
        final state = context.read<ProfileCubit>().state;
        if (state is ProfileLoaded) {
          _populateFromUser(state.user);
        } else if (_lastUserForAvatar != null) {
          _populateFromUser(_lastUserForAvatar!);
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    countryController.dispose();
    diseasesController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateFromUser(UserModel user) {
    nameController.text = user.name ?? '';
    ageController.text = user.age?.toString() ?? '25';
    
    // Smart Country Localization
    String rawData = user.country ?? '';
    String displayCountry = rawData;
    
    if (rawData.isNotEmpty) {
      // Try finding by code first (Robust)
      String cleanCode = rawData.trim().replaceAll(RegExp(r'[^A-Z]'), '');
      if (cleanCode.length > 3) cleanCode = ''; // Too long to be a code
      
      Country? countryObj;
      if (cleanCode.length >= 2) {
        countryObj = CountryService().findByCode(cleanCode);
      }
      
      // Fallback: try parsing emoji + name
      if (countryObj == null) {
        final parts = rawData.split(' ');
        for (var p in parts) {
           final found = CountryService().findByName(p.trim());
           if (found != null) {
             countryObj = found;
             break;
           }
        }
      }

      if (countryObj != null) {
        final locName = CountryLocalizations.of(context)?.countryName(countryCode: countryObj.countryCode) ?? countryObj.name;
        displayCountry = "${countryObj.flagEmoji} $locName";
      }
    }
    countryController.text = displayCountry;
    
    // Medical conditions
    diseasesController.text = user.chronicDiseases != null ? user.chronicDiseases!.join(', ') : (user.condition);
    
    phoneController.text = user.phoneNumber ?? '';
    genderSelection = (user.gender ?? 'male').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          _lastUserForAvatar = state.user;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.t('Profile updated successfully!', 'تم تحديث الملف الشخصي بنجاح!')),
              backgroundColor: Colors.green,
            ),
          );
          if (!widget.onboarding) {
            setState(() => _editing = false);
          }
          if (widget.onboarding && context.mounted) {
            GoRouter.of(context).go(AppRouter.kHomeView);
          }
        } else if (state is ProfileLoaded) {
          _lastUserForAvatar = state.user;
          if (nameController.text.isEmpty) _populateFromUser(state.user);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) return const Scaffold(backgroundColor: kBackgroundColor, body: Center(child: CircularProgressIndicator()));

        String currentGender = genderSelection;
        final UserModel? loadedUser = state is ProfileLoaded
            ? state.user
            : _lastUserForAvatar;

        final authUser = FirebaseAuth.instance.currentUser;
        final showPasswordLink =
            widget.onboarding && _needsPasswordLink(authUser);

        final isDark = _themeMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        return Theme(
          data: isDark 
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: kBackgroundColor,
                  primaryColor: kAccentColor,
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: Colors.grey[50], 
                  primaryColor: kAccentColor,
                ),
          child: Directionality(
            textDirection: context.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? null : Colors.grey[50],
                gradient: isDark ? kBackgroundGradient : null,
              ),
              child: Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    widget.onboarding ? context.t('Complete your profile', 'أكمل بياناتك') : context.t('Profile Settings', 'إعدادات الحساب'),
                    style: FontStyles.roboto18.copyWith(color: textColor, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () async {
                      if (widget.onboarding) {
                        await FirebaseAuth.instance.signOut();
                        await auth_google.GoogleSignIn.instance.signOut();
                        if (context.mounted) {
                          GoRouter.of(context).go(AppRouter.kLoginView);
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    if (!widget.onboarding && state is ProfileLoaded)
                      IconButton(
                        icon: Icon(
                          _editing ? Icons.close : Icons.edit_outlined,
                          color: _editing ? Colors.redAccent : textColor,
                        ),
                        onPressed: state is ProfileUpdating
                            ? null
                            : () {
                                if (_editing) {
                                  if (loadedUser != null) _populateFromUser(loadedUser);
                                }
                                setState(() => _editing = !_editing);
                              },
                      ),
                    IconButton(
                      icon: const Icon(Icons.language),
                      color: textColor,
                      onPressed: _showLanguageSelector,
                    ),
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      color: textColor,
                      onPressed: _toggleTheme,
                    ),
                  ],
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    child: Column(
                      children: [
                        Builder(

                builder: (context) {
                  final avatarStack = Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 145.r,
                        height: 145.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isDark)
                              BoxShadow(
                                color: kAccentColor.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                          ],
                          border: Border.all(
                            color: kAccentColor.withValues(
                              alpha: _fieldsEditable ? 1 : (_editing ? 1 : 0.3),
                            ),
                            width: 3,
                          ),
                          color: kSurfaceColor,
                        ),
                        child: ClipOval(
                          child: Opacity(
                            opacity: _fieldsEditable ? 1 : 0.92,
                            child: loadedUser != null
                                ? ProfileAvatarImage(
                                    user: loadedUser,
                                    genderFallback: currentGender,
                                  )
                                : _buildDefaultAvatar(currentGender),
                          ),
                        ),
                      ),
                      if (_fieldsEditable)
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            color: kAccentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 22.sp,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  );
                  if (!_fieldsEditable) {
                    return avatarStack;
                  }
                  return GestureDetector(
                    onTap: () =>
                        context.read<ProfileCubit>().uploadProfileImage(),
                    child: avatarStack,
                  );
                },
              ),
              SizedBox(height: 16.h),
              if (!_fieldsEditable)
                Column(
                  children: [
                    Text(
                      nameController.text.isNotEmpty ? nameController.text : context.t("User Name", "اسم المستخدم"),
                      style: FontStyles.roboto24.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      authUser?.email ?? context.t("No Email", "لا يوجد بريد"),
                      style: FontStyles.roboto14.copyWith(color: Colors.white70),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              if (!widget.onboarding && !_editing && state is ProfileLoaded) ...[
                SizedBox(height: 20.h),

                _buildLegalInfoSection(context),
              ],
              SizedBox(height: 32.h),
              
              _buildField(context.t("Full Name", "الاسم بالكامل"), nameController, Icons.person, readOnly: !_fieldsEditable),
              _buildField(context.t("Age", "السن"), ageController, Icons.calendar_today, isNumber: true, readOnly: !_fieldsEditable),
              
              _buildCountryField(readOnly: !_fieldsEditable),
              
              _fieldsEditable
                  ? _DiseasesEditorWidget(
                      controller: diseasesController,
                      labelTitle: context.t("Medical Condition (Neural History)", "الأمراض المزمنة"),
                      hintText: context.t("Type and press Enter", "اكتب ثُم اضغط إدخال ↵"),
                    )
                  : _buildDiseasesChips(),
              
              _buildField(context.t("Phone Number", "رقم التيليفون"), phoneController, Icons.phone, readOnly: !_fieldsEditable, isPhone: true),

              
              if (_fieldsEditable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      context.t("Gender", "الجنس"),
                      style: FontStyles.roboto14.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              _buildGenderRadioButtons(readOnly: !_fieldsEditable),

              if (showPasswordLink) ...[
                SizedBox(height: 8.h),
                Text(
                  context.t('Set a password to sign in with this email later (same as your Google email).', 'قم بتعيين كلمة مرور لتسجيل الدخول بهذا البريد لاحقاً (نفس بريد جوجل).'),
                  style: FontStyles.roboto12.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 12.h),
                _buildPasswordField(
                  context.t('Login password', 'كلمة سر الدخول'),
                  passwordController,
                  obscure: true,
                ),
                _buildPasswordField(
                  context.t('Confirm password', 'تأكيد كلمة السر'),
                  confirmPasswordController,
                  obscure: true,
                ),
              ],

              if (state is ProfileLoaded && !widget.onboarding && !_editing) ...[
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        PdfReportGenerator.generateAndPrintReport(state.user),
                    icon: const Icon(Icons.picture_as_pdf, color: kAccentColor),
                    label: Text(
                      context.t("Generate PDF Report", "استخراج تقرير PDF"),
                      style: FontStyles.roboto16.copyWith(color: kAccentColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kAccentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              if (widget.onboarding || _editing) SizedBox(height: 16.h),
              
              if (widget.onboarding || _editing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: state is ProfileUpdating
                        ? null
                        : () {
                            final user = FirebaseAuth.instance.currentUser;
                            final needLink = _needsPasswordLink(user);
                            final p = passwordController.text.trim();
                            final c = confirmPasswordController.text.trim();

                            if (widget.onboarding && needLink) {
                              if (p.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.t('Enter a password of at least 6 characters to use email login later.', 'أدخل كلمة مرور مكونة من 6 أحرف على الأقل لاستخدامها لاحقاً.'),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (p != c) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.t('Passwords do not match.', 'كلمات المرور غير متطابقة.')),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                            }

                            final String? linkPw =
                                (widget.onboarding && needLink) ? p : null;

                            context.read<ProfileCubit>().updateProfile(
                                  name: nameController.text.trim(),
                                  age: int.tryParse(ageController.text) ?? 25,
                                  country: countryController.text.trim(),
                                  diseases: diseasesController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  gender: genderSelection,
                                  linkLoginPassword: linkPw,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      disabledBackgroundColor: kAccentColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 4,
                    ),
                    child: state is ProfileUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(context.t("Save Changes", "حفظ التعديلات"), style: FontStyles.roboto18.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (!widget.onboarding) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: state is ProfileUpdating
                          ? null
                          : () {
                              if (loadedUser != null) _populateFromUser(loadedUser);
                              setState(() => _editing = false);
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(context.t("Cancel", "إلغاء"), style: FontStyles.roboto18.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],

              SizedBox(height: 16.h),

              if (!widget.onboarding && !_editing)
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    onPressed: () async {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        GoRouter.of(context).go(AppRouter.kLoginView);
                      }
                    },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 8.w),
                        Text(
                          context.t('Log Out', 'تسجيل الخروج'),
                          style: FontStyles.roboto18.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },

    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    required bool obscure,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FontStyles.roboto14.copyWith(color: Colors.white70)),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline, color: kAccentColor, size: 20.sp),
              filled: true,
              fillColor: kSurfaceColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: kAccentColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _translateDisease(String d, BuildContext context) {
    final clean = d.trim().toLowerCase();
    if (clean == 'diabetes' || clean == 'السكري') return context.t('Diabetes', 'السكري');
    if (clean == 'hypertension' || clean == 'ضغط الدم') return context.t('Hypertension', 'ضغط الدم');
    if (clean == 'heart disease' || clean == 'أمراض القلب') return context.t('Heart Disease', 'أمراض القلب');
    if (clean == 'asthma' || clean == 'الربو') return context.t('Asthma', 'الربو');
    if (clean == 'arthritis' || clean == 'التهاب المفاصل') return context.t('Arthritis', 'التهاب المفاصل');
    if (clean == 'kidney disease' || clean == 'أمراض الكلى') return context.t('Kidney Disease', 'أمراض الكلى');
    if (clean == 'liver disease' || clean == 'أمراض الكبد') return context.t('Liver Disease', 'أمراض الكبد');
    if (clean == 'cancer' || clean == 'السرطان') return context.t('Cancer', 'السرطان');
    if (clean == 'none' || clean == 'لا يوجد') return context.t('None', 'لا يوجد');
    return d;
  }

  Widget _buildReadonlyCard(String label, String value, IconData icon, {bool isMultiline = false, bool forceLtr = false, bool isCountry = false}) {
    String displayValue = value;
    if (isCountry && value.isNotEmpty) {
      // Try to re-translate country if it has flag + name
      final parts = value.split(' ');
      if (parts.length >= 2) {
        final emoji = parts[0];
        // Note: Full dynamic country translation requires keeping the code, 
        // but for now we maintain existing behavior with localized name injection on selection.
      }
    }
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: kAccentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kAccentColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: FontStyles.roboto12.copyWith(color: Colors.white54, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4.h),
                  Directionality(
                    textDirection: forceLtr ? TextDirection.ltr : (context.isArabic ? TextDirection.rtl : TextDirection.ltr),
                    child: Text(
                      displayValue.isEmpty ? context.t('Not specified', 'غير محدد') : displayValue,
                      style: FontStyles.roboto16.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: isMultiline ? null : 1,
                      overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
                      textAlign: forceLtr && context.isArabic ? TextAlign.right : TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseasesChips() {
    final text = diseasesController.text.trim();
    if (text.isEmpty) {
      return _buildReadonlyCard(context.t("Chronic Diseases", "الأمراض المزمنة"), context.t("None", "لا يوجد"), Icons.medical_services);
    }
    
    final List<String> items = text.split(RegExp(r'[,،\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t("Chronic Diseases", "الأمراض المزمنة"),
            style: FontStyles.roboto14.copyWith(color: Colors.white70),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items.map((disease) {
              return Chip(
                label: Text(
                  _translateDisease(disease, context),
                  style: FontStyles.roboto14.copyWith(color: Colors.white),
                ),
                backgroundColor: kAccentColor.withValues(alpha: 0.2),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    bool isMultiline = false,
    bool isPhone = false,
    bool readOnly = false,
  }) {
    if (readOnly) {
      return _buildReadonlyCard(label, controller.text, icon, isMultiline: isMultiline, forceLtr: isPhone);
    }
    
    final fill = kSurfaceColor;
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FontStyles.roboto14.copyWith(color: Colors.white70),
          ),
          SizedBox(height: 8.h),
          Directionality(
            textDirection: isPhone ? TextDirection.ltr : (context.isArabic ? TextDirection.rtl : TextDirection.ltr),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              textDirection: isPhone ? TextDirection.ltr : null,
              enableInteractiveSelection: !readOnly,
              keyboardType: isPhone ? TextInputType.phone : (isMultiline ? TextInputType.multiline : (isNumber ? TextInputType.number : TextInputType.text)),
              maxLines: isMultiline ? null : 1,
              minLines: isMultiline ? 3 : 1,
            style: TextStyle(
              color: Colors.white.withValues(alpha: readOnly ? 0.58 : 1),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: kAccentColor.withValues(alpha: readOnly ? 0.4 : 1),
                size: 20.sp,
              ),
              filled: true,
              fillColor: fill,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: readOnly
                    ? BorderSide(color: Colors.white.withValues(alpha: 0.08))
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: readOnly
                    ? BorderSide(color: Colors.white.withValues(alpha: 0.08))
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: readOnly ? Colors.transparent : kAccentColor,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildCountryField({bool readOnly = false}) {
    if (readOnly) {
      return _buildReadonlyCard(context.t("Country", "الدولة"), countryController.text, Icons.public, isCountry: true);
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t("Country", "الدولة"),
            style: FontStyles.roboto14.copyWith(color: Colors.white70),
          ),
          SizedBox(height: 8.h),
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  final localizedName = CountryLocalizations.of(context)?.countryName(countryCode: country.countryCode) ?? country.name;
                  setState(() {
                    countryController.text = "${country.flagEmoji} $localizedName";
                    if (phoneController.text.isEmpty || !phoneController.text.startsWith('+')) {
                      phoneController.text = "+${country.phoneCode} ";
                    }
                  });
                },
                countryListTheme: CountryListThemeData(
                  borderRadius: BorderRadius.circular(20.r),
                  backgroundColor: kSurfaceColor,
                  textStyle: const TextStyle(color: Colors.white),
                  searchTextStyle: const TextStyle(color: Colors.white),
                  inputDecoration: InputDecoration(
                    hintText: context.t("Search Country", "ابحث عن دولتك"),
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: kAccentColor),
                    filled: true,
                    fillColor: kSurfaceLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.public, color: kAccentColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      countryController.text.isEmpty ? context.t("Select Country", "اختر الدولة") : countryController.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRadioButtons({bool readOnly = false}) {
    if (readOnly) {
      return _buildReadonlyCard(
        context.t("Gender", "الجنس"),
        genderSelection.toLowerCase() == "male" ? context.t("Male", "ذكر") : context.t("Female", "أنثى"),
        genderSelection.toLowerCase() == "female" ? Icons.female : Icons.male,
      );
    }
    return Row(
      children: [
        _buildGenderOption("male", context.t("Male", "ذكر")),
        SizedBox(width: 20.w),
        _buildGenderOption("female", context.t("Female", "أنثى")),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label) {
    bool isSelected = genderSelection.toLowerCase() == value.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => genderSelection = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor.withValues(alpha: 0.2) : kSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? kAccentColor : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              value.toLowerCase() == "male" ? Icons.male : Icons.female,
              color: isSelected ? kAccentColor : Colors.white70,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurfaceColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
            child: Text(
              context.t('Legal & information', 'المعلومات والقوانين'),
              style: FontStyles.roboto16.copyWith(
                color: kAccentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.privacy_tip_outlined, color: kAccentColor, size: 22.sp),
            title: Text(
              context.t('Privacy Policy', 'سياسة الخصوصية'),
              style: FontStyles.roboto14.copyWith(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 22.sp),
            onTap: () => context.push(AppRouter.kPrivacyPolicyView),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.article_outlined, color: kAccentColor, size: 22.sp),
            title: Text(
              context.t('Terms of Service', 'شروط الخدمة'),
              style: FontStyles.roboto14.copyWith(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 22.sp),
            onTap: () => context.push(AppRouter.kTermsOfServiceView),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.monitor_heart_outlined, color: kAccentColor, size: 22.sp),
            title: Text(
              context.t('Monitoring guide', 'دليل المراقبة'),
              style: FontStyles.roboto14.copyWith(color: Colors.white),
            ),
            trailing: Icon(Icons.menu_book_outlined, color: Colors.white54, size: 20.sp),
            onTap: () => showMonitoringGuideManual(context),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.medical_information_outlined, color: kAccentColor, size: 22.sp),
            title: Text(
              context.t('Medical disclaimer', 'إخلاء المسؤولية الطبية'),
              style: FontStyles.roboto14.copyWith(color: Colors.white),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 22.sp),
            onTap: () => context.push(
              AppRouter.kMedicalDisclaimerView,
              extra: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String gender) {
    final g = gender.trim().toLowerCase();
    final isFemale = g == 'female' || g == 'f' || g == 'woman';
    String avatarUrl = isFemale
        ? "https://cdn-icons-png.flaticon.com/512/3135/3135823.png"
        : "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";
        
    return Image.network(
      avatarUrl, 
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }
}

class _DiseasesEditorWidget extends StatefulWidget {
  final TextEditingController controller;
  final String labelTitle;
  final String hintText;
  
  const _DiseasesEditorWidget({required this.controller, required this.labelTitle, required this.hintText});

  @override
  State<_DiseasesEditorWidget> createState() => _DiseasesEditorWidgetState();
}

class _DiseasesEditorWidgetState extends State<_DiseasesEditorWidget> {
  late List<String> diseases;
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _parseController();
  }
  
  void _parseController() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      diseases = [];
    } else {
      diseases = text.split(RegExp(r'[,،\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
  }

  void _updateController() {
    widget.controller.text = diseases.join(', ');
  }

  void _addDisease(String val) {
    final trimmed = val.trim();
    if (trimmed.isNotEmpty && !diseases.contains(trimmed)) {
      setState(() {
        diseases.add(trimmed);
      });
      _updateController();
    }
    _inputCtrl.clear();
    _focusNode.requestFocus();
  }

  void _removeDisease(String val) {
    setState(() {
      diseases.remove(val);
    });
    _updateController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.labelTitle, style: FontStyles.roboto14.copyWith(color: Colors.white70)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (diseases.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: diseases.map((d) {
                      return Chip(
                        label: Text(d, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                        backgroundColor: kAccentColor.withValues(alpha: 0.2),
                        deleteIconColor: Colors.white70,
                        onDeleted: () => _removeDisease(d),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                if (diseases.isNotEmpty) SizedBox(height: 12.h),
                TextField(
                  controller: _inputCtrl,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  onSubmitted: _addDisease,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 14.sp),
                    prefixIcon: Icon(Icons.add_circle_outline, color: kAccentColor, size: 20.sp),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: kAccentColor),
                      onPressed: () => _addDisease(_inputCtrl.text),
                    ),
                    filled: true,
                    fillColor: kBackgroundColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
