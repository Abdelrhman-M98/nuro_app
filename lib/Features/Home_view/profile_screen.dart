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
  UserModel? _lastUserForAvatar;
  late bool _editing;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final countryController = TextEditingController();
  final diseasesController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String genderSelection = 'Male';

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
    nameController.text = user.name;
    ageController.text = user.age.toString();
    countryController.text = user.country;
    diseasesController.text = user.condition;
    phoneController.text = user.phone;
    genderSelection = user.gender;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          _lastUserForAvatar = state.user;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
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
        if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());

        String currentGender = genderSelection;
        final UserModel? loadedUser = state is ProfileLoaded
            ? state.user
            : _lastUserForAvatar;

        final authUser = FirebaseAuth.instance.currentUser;
        final showPasswordLink =
            widget.onboarding && _needsPasswordLink(authUser);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  final avatarStack = Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120.r,
                        height: 120.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kAccentColor.withValues(
                              alpha: _fieldsEditable ? 1 : 0.45,
                            ),
                            width: 2,
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
                            size: 18.sp,
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
              if (!widget.onboarding && !_editing && state is ProfileLoaded)
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton.icon(
                      onPressed: state is ProfileUpdating
                          ? null
                          : () => setState(() => _editing = true),
                      icon: Icon(Icons.edit_outlined, color: kAccentColor, size: 22.sp),
                      label: Text(
                        'Edit profile',
                        style: FontStyles.roboto16.copyWith(
                          color: kAccentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kAccentColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: kAccentColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 32.h),
              
              _buildField("Full Name", nameController, Icons.person, readOnly: !_fieldsEditable),
              _buildField("Age", ageController, Icons.calendar_today, isNumber: true, readOnly: !_fieldsEditable),
              
              _buildCountryField(readOnly: !_fieldsEditable),
              
              _buildField("Medical Condition (Neural History)", diseasesController, Icons.medical_services, isMultiline: true, readOnly: !_fieldsEditable),
              _buildField("Phone Number", phoneController, Icons.phone, readOnly: !_fieldsEditable),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    "Gender",
                    style: FontStyles.roboto14.copyWith(
                      color: _fieldsEditable
                          ? Colors.white70
                          : Colors.white.withValues(alpha: 0.42),
                    ),
                  ),
                ),
              ),
              _buildGenderRadioButtons(readOnly: !_fieldsEditable),

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
                      "Generate PDF Report",
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
              ],

              SizedBox(height: 16.h),
              if (!widget.onboarding && !_editing)
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    bool isMultiline = false,
    bool readOnly = false,
  }) {
    final fill = readOnly
        ? kSurfaceColor.withValues(alpha: 0.35)
        : kSurfaceColor;
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FontStyles.roboto14.copyWith(
              color: readOnly
                  ? Colors.white.withValues(alpha: 0.42)
                  : Colors.white70,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            readOnly: readOnly,
            enableInteractiveSelection: !readOnly,
            keyboardType: isMultiline ? TextInputType.multiline : (isNumber ? TextInputType.number : TextInputType.text),
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
        ],
      ),
    );
  }

  Widget _buildCountryField({bool readOnly = false}) {
    final fill = readOnly
        ? kSurfaceColor.withValues(alpha: 0.35)
        : kSurfaceColor;
    final field = AbsorbPointer(
      absorbing: readOnly,
      child: TextField(
        controller: countryController,
        readOnly: true,
        style: TextStyle(
          color: Colors.white.withValues(alpha: readOnly ? 0.58 : 1),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.public,
            color: kAccentColor.withValues(alpha: readOnly ? 0.4 : 1),
            size: 20.sp,
          ),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: readOnly
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white70,
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
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Country",
            style: FontStyles.roboto14.copyWith(
              color: readOnly
                  ? Colors.white.withValues(alpha: 0.42)
                  : Colors.white70,
            ),
          ),
          SizedBox(height: 8.h),
          readOnly
              ? field
              : GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        setState(() {
                          countryController.text =
                              "${country.flagEmoji} ${country.name}";
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
                  child: field,
                ),
        ],
      ),
    );
  }

  Widget _buildGenderRadioButtons({bool readOnly = false}) {
    if (readOnly) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: kSurfaceColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              genderSelection == "Female" ? Icons.female : Icons.male,
              color: kAccentColor.withValues(alpha: 0.42),
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              genderSelection,
              style: FontStyles.roboto16.copyWith(
                color: Colors.white.withValues(alpha: 0.58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
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
