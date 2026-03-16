import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PatientsCardInfo extends StatelessWidget {
  const PatientsCardInfo({
    super.key,
    required this.patientName,
    required this.age,
    required this.condition,
    required this.imageUrl,
    required this.signalValue,
    required this.gender,
    required this.currentState,
    this.onPressed,
  });

  final String patientName;
  final int age;
  final String condition;
  final String imageUrl;
  final double signalValue;
  final String gender;
  final String currentState;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = currentState == 'abnormal';
    
    // Avatar Logic
    Widget avatarWidget;
    if (imageUrl.isNotEmpty) {
      avatarWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    } else {
      avatarWidget = _buildDefaultAvatar();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isAbnormal ? Colors.red : Colors.green,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAbnormal ? Colors.red : Colors.green).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: ClipOval(child: avatarWidget),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontStyles.roboto18.copyWith(
                    color: kOnBackgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "$age Y.O",
                      style: FontStyles.roboto14.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      "Signal: ",
                      style: FontStyles.roboto14.copyWith(
                        color: kOnSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      "${signalValue.toInt()}",
                      style: FontStyles.roboto16.copyWith(
                        color: kAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
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
