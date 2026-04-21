import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

/// صورة المستخدم من [UserModel] (Base64 أو رابط أو افتراضي).
class ProfileAvatarImage extends StatelessWidget {
  const ProfileAvatarImage({
    super.key,
    required this.user,
    required this.genderFallback,
    this.fit = BoxFit.cover,
  });

  final UserModel user;
  final String genderFallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarFromFields(
      profileImageUrl: user.profileImageUrl,
      profileImageBase64: user.profileImageBase64,
      genderFallback: genderFallback,
      fit: fit,
    );
  }
}

/// نفس منطق العرض بدون بناء [UserModel] كامل (مثل بطاقة الهوم).
class ProfileAvatarFromFields extends StatelessWidget {
  const ProfileAvatarFromFields({
    super.key,
    required this.profileImageUrl,
    required this.profileImageBase64,
    required this.genderFallback,
    this.fit = BoxFit.cover,
  });

  final String profileImageUrl;
  final String profileImageBase64;
  final String genderFallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (profileImageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64);
        return Image.memory(
          bytes,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              _DefaultGenderAvatar(gender: genderFallback),
        );
      } catch (_) {
        return _DefaultGenderAvatar(gender: genderFallback);
      }
    }
    if (profileImageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) =>
            _DefaultGenderAvatar(gender: genderFallback),
      );
    }
    return _DefaultGenderAvatar(gender: genderFallback);
  }
}

class _DefaultGenderAvatar extends StatelessWidget {
  const _DefaultGenderAvatar({required this.gender});

  final String gender;

  @override
  Widget build(BuildContext context) {
    final isFemale =
        gender.trim().toLowerCase() == 'female' || gender.trim() == 'أنثى';
    final url = isFemale
        ? 'https://cdn-icons-png.flaticon.com/512/3135/3135823.png'
        : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }
}
