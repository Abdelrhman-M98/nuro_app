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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:country_picker/country_picker.dart';
import 'package:nervix_app/Core/utils/pdf_generator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onboarding = false});

  /// `true` عند فتح الشاشة بعد التسجيل لإكمال البيانات (من تسجيل الدخول وليس من الهوم).
  final bool onboarding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchUserData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            onboarding ? 'Complete your profile' : 'Profile Settings',
            style: FontStyles.roboto18,
          ),
          backgroundColor: kBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (onboarding) {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn.instance.signOut();
                if (context.mounted) {
                  GoRouter.of(context).go(AppRouter.kLoginView);
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: kBackgroundColor,
        body: ProfileViewBody(onboarding: onboarding),
      ),
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
  /// يبقى ظاهراً أثناء [ProfileUpdating] لأن الحالة دي ما فيهاش [UserModel].
  UserModel? _lastUserForAvatar;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final countryController = TextEditingController();
  final diseasesController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String genderSelection = 'Male';

  bool _needsPasswordLink(User? user) {
    if (user == null || user.email == null || user.email!.isEmpty) {
      return false;
    }
    return !user.providerData.any((p) => p.providerId == 'password');
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

  void _populateData(ProfileLoaded state) {
    nameController.text = state.user.name;
    ageController.text = state.user.age.toString();
    countryController.text = state.user.country;
    diseasesController.text = state.user.condition;
    phoneController.text = state.user.phone;
    genderSelection = state.user.gender;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // [ProfileUpdateSuccess] يرث [ProfileLoaded] — نتعامل معه أولاً حتى يظهر الـ SnackBar.
        if (state is ProfileUpdateSuccess) {
          _lastUserForAvatar = state.user;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onboarding && context.mounted) {
            GoRouter.of(context).go(AppRouter.kHomeView);
          }
        } else if (state is ProfileLoaded) {
          _lastUserForAvatar = state.user;
          if (nameController.text.isEmpty) _populateData(state);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());

        String currentGender = genderSelection;
        final UserModel? loadedUser = state is ProfileLoaded
            ? state.user
            : _lastUserForAvatar;

        final authUser = FirebaseAuth.instance.currentUser;
        // ربط كلمة المرور مع Google يُعرض فقط عند أول إكمال للبروفايل، وليس من إعدادات الهوم.
        final showPasswordLink =
            widget.onboarding && _needsPasswordLink(authUser);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () => context.read<ProfileCubit>().uploadProfileImage(),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kAccentColor, width: 2),
                        color: kSurfaceColor,
                      ),
                      child: ClipOval(
                        child: loadedUser != null
                            ? ProfileAvatarImage(
                                user: loadedUser,
                                genderFallback: currentGender,
                              )
                            : _buildDefaultAvatar(currentGender),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(color: kAccentColor, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, size: 18.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              
              _buildField("Full Name", nameController, Icons.person),
              _buildField("Age", ageController, Icons.calendar_today, isNumber: true),
              
              // Country Picker Field
              _buildCountryField(),
              
              _buildField("Medical Condition (Neural History)", diseasesController, Icons.medical_services, isMultiline: true),
              _buildField("Phone Number", phoneController, Icons.phone),
              
              // Gender Selection
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text("Gender", style: FontStyles.roboto14.copyWith(color: Colors.white70)),
                ),
              ),
              _buildGenderRadioButtons(),

              if (showPasswordLink) ...[
                SizedBox(height: 8.h),
                Text(
                  'Set a password to sign in with this email later (same as your Google email).',
                  style: FontStyles.roboto12.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 12.h),
                _buildPasswordField(
                  'Login password',
                  passwordController,
                  obscure: true,
                ),
                _buildPasswordField(
                  'Confirm password',
                  confirmPasswordController,
                  obscure: true,
                ),
              ],

              SizedBox(height: 30.h),

              if (state is ProfileLoaded && !widget.onboarding)
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    onPressed: () => PdfReportGenerator.generateAndPrintReport(state.user),
                    icon: const Icon(Icons.picture_as_pdf, color: kAccentColor),
                    label: Text("Generate PDF Report", style: FontStyles.roboto16.copyWith(color: kAccentColor)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kAccentColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                  ),
                ),
                
              SizedBox(height: 16.h),
              
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
                                const SnackBar(
                                  content: Text(
                                    'Enter a password of at least 6 characters to use email login later.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            if (p != c) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match.'),
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
                    : Text("Save Changes", style: FontStyles.roboto18.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 16.h),
              if (!widget.onboarding)
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn.instance.signOut();
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
                          'Log Out',
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

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FontStyles.roboto14.copyWith(color: Colors.white70)),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            keyboardType: isMultiline ? TextInputType.multiline : (isNumber ? TextInputType.number : TextInputType.text),
            maxLines: isMultiline ? null : 1,
            minLines: isMultiline ? 3 : 1,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kAccentColor, size: 20.sp),
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

  Widget _buildCountryField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Country", style: FontStyles.roboto14.copyWith(color: Colors.white70)),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  setState(() {
                    countryController.text = "${country.flagEmoji} ${country.name}";
                  });
                },
                countryListTheme: CountryListThemeData(
                  borderRadius: BorderRadius.circular(20.r),
                  backgroundColor: kSurfaceColor,
                  textStyle: const TextStyle(color: Colors.white),
                  searchTextStyle: const TextStyle(color: Colors.white),
                  inputDecoration: InputDecoration(
                    hintText: "Search Country",
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
            child: AbsorbPointer(
              child: TextField(
                controller: countryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.public, color: kAccentColor, size: 20.sp),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRadioButtons() {
    return Row(
      children: [
        _buildGenderOption("Male"),
        SizedBox(width: 20.w),
        _buildGenderOption("Female"),
      ],
    );
  }

  Widget _buildGenderOption(String value) {
    bool isSelected = genderSelection == value;
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
              value == "Male" ? Icons.male : Icons.female,
              color: isSelected ? kAccentColor : Colors.white70,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              value,
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

  Widget _buildDefaultAvatar(String gender) {
    bool isFemale = gender.trim().toLowerCase() == 'female' || gender.trim() == 'أنثى';
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
