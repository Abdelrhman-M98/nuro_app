import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Home_view/logic/profile_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:country_picker/country_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchUserData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Settings", style: FontStyles.roboto18),
          backgroundColor: kBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: kBackgroundColor,
        body: const ProfileViewBody(),
      ),
    );
  }
}

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final countryController = TextEditingController();
  final diseasesController = TextEditingController();
  final phoneController = TextEditingController();
  String genderSelection = 'Male';

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    countryController.dispose();
    diseasesController.dispose();
    phoneController.dispose();
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
        if (state is ProfileLoaded) {
          if (nameController.text.isEmpty) _populateData(state);
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());

        String profileUrl = "";
        String currentGender = genderSelection;
        if (state is ProfileLoaded) {
          profileUrl = state.user.profileImageUrl;
        }

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
                        child: profileUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profileUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => _buildDefaultAvatar(currentGender),
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
              
              SizedBox(height: 40.h),
              
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: state is ProfileUpdating 
                    ? null 
                    : () {
                        context.read<ProfileCubit>().updateProfile(
                          name: nameController.text,
                          age: int.tryParse(ageController.text) ?? 25,
                          country: countryController.text,
                          diseases: diseasesController.text,
                          phone: phoneController.text,
                          gender: genderSelection,
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
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
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
                        "Log Out",
                        style: FontStyles.roboto18.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
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
