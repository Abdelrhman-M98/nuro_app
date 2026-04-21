import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.user);
  final UserModel user;
}

class ProfileUpdating extends ProfileState {}

/// نفس [ProfileLoaded] للعرض، مع إشعار نجاح في الـ listener (لا يستبدل بيانات الواجهة).
class ProfileUpdateSuccess extends ProfileLoaded {
  ProfileUpdateSuccess(super.user);
}

class ProfileError extends ProfileState {
  ProfileError(this.message);
  final String message;
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserModel? _currentUser;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  /// حد طول سلسلة Base64 في المستند (Firestore ~1MiB للمستند كله؛ نترك هامش لباقي الحقول).
  static const int _maxProfileImageBase64Length = 520000;

  Future<void> fetchUserData() async {
    emit(ProfileLoading());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError('No user logged in'));
        return;
      }
      await _ensureGoogleProfilePhotoInFirestore(uid);
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        emit(ProfileLoaded(_currentUser!));
      } else {
        _currentUser = UserModel.fromFirebaseAuthUser(_auth.currentUser);
        emit(ProfileLoaded(_currentUser!));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// إن كان المستخدم من Google وليس لديه صورة في Firestore، نخزّن `photoURL` في `profileImageUrl`.
  Future<void> _ensureGoogleProfilePhotoInFirestore(String uid) async {
    final u = _auth.currentUser;
    if (u == null) return;
    final isGoogle =
        u.providerData.any((p) => p.providerId == 'google.com');
    if (!isGoogle) return;
    final photo = u.photoURL;
    if (photo == null || photo.isEmpty) return;

    final ref = _firestore.collection('users').doc(uid);
    final snap = await ref.get();
    final data = snap.data() ?? {};
    final url = (data['profileImageUrl'] as String?) ?? '';
    final b64 = (data['profileImageBase64'] as String?) ?? '';
    if (b64.isNotEmpty) return;
    if (url.isNotEmpty) return;

    await ref.set({'profileImageUrl': photo}, SetOptions(merge: true));
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required String country,
    required String diseases,
    required String phone,
    required String gender,
    String? linkLoginPassword,
  }) async {
    emit(ProfileUpdating());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final user = _auth.currentUser;
      if (user != null &&
          linkLoginPassword != null &&
          linkLoginPassword.trim().length >= 6) {
        await _linkEmailPasswordIfNeeded(user, linkLoginPassword.trim());
      }

      final data = {
        'name': name,
        'age': age,
        'country': country,
        'diseases': diseases,
        'phone': phone,
        'gender': gender,
        'email': user?.email ?? '',
      };

      await _firestore.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
      await fetchUserData();
      if (_currentUser != null) {
        emit(ProfileUpdateSuccess(_currentUser!));
      }
    } on FirebaseAuthException catch (e) {
      emit(ProfileError(_mapLinkError(e)));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  String _mapLinkError(FirebaseAuthException e) {
    switch (e.code) {
      case 'credential-already-in-use':
        return 'This email is already linked to another account.';
      case 'provider-already-linked':
        return 'Email/password is already enabled for this account.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return e.message ?? e.code;
    }
  }

  Future<void> _linkEmailPasswordIfNeeded(User user, String password) async {
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Account has no email to link password.',
      );
    }
    final hasPassword =
        user.providerData.any((p) => p.providerId == 'password');
    if (hasPassword) return;

    final credential =
        EmailAuthProvider.credential(email: email.trim(), password: password);
    await user.linkWithCredential(credential);
  }

  /// رفع من المعرض وتخزين الصورة في Firestore كـ Base64 (لا يستخدم Storage).
  Future<void> uploadProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 72,
      );
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      if (!file.existsSync()) {
        emit(ProfileError('Selected image file not found on device.'));
        return;
      }

      final bytes = await file.readAsBytes();
      emit(ProfileUpdating());
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError('User session expired. Please login again.'));
        await fetchUserData();
        return;
      }

      final b64 = base64Encode(bytes);
      if (b64.length > _maxProfileImageBase64Length) {
        emit(ProfileError(
          'Image is too large for cloud save. Pick a smaller image.',
        ));
        await fetchUserData();
        return;
      }

      await _firestore.collection('users').doc(uid).set(
        {
          'profileImageBase64': b64,
        },
        SetOptions(merge: true),
      );

      await fetchUserData();
      if (_currentUser != null) {
        emit(ProfileUpdateSuccess(_currentUser!));
      }
    } catch (e) {
      emit(ProfileError('Upload failed: ${e.toString()}'));
      await fetchUserData();
    }
  }
}
