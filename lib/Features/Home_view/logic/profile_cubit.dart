import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserModel user;
  ProfileLoaded(this.user);
}
class ProfileUpdating extends ProfileState {}
class ProfileUpdateSuccess extends ProfileState {}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserModel? _currentUser;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  Future<void> fetchUserData() async {
    emit(ProfileLoading());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError("No user logged in"));
        return;
      }
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        emit(ProfileLoaded(_currentUser!));
      } else {
        emit(ProfileError("User profile not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required String country,
    required String diseases,
    required String phone,
    required String gender,
  }) async {
    emit(ProfileUpdating());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final data = {
        'name': name,
        'age': age,
        'country': country,
        'diseases': diseases,
        'phone': phone,
        'gender': gender,
      };

      await _firestore.collection('users').doc(uid).update(data);
      await fetchUserData(); // Refresh local user model
      emit(ProfileUpdateSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> uploadProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      
      // Validation: Check local file existence before upload
      if (!file.existsSync()) {
        emit(ProfileError("Selected image file not found on device."));
        return;
      }

      emit(ProfileUpdating());
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError("User session expired. Please login again."));
        return;
      }

      // Create storage reference
      final Reference ref = _storage.ref().child('profiles').child('$uid.jpg');
      
      // 1. Start Upload Task
      final UploadTask uploadTask = ref.putFile(file);

      // 2. Wait for Completion: Directly await the task to get the final snapshot
      final TaskSnapshot snapshot = await uploadTask;

      // 3. Get Download URL: Using the ref from the successful snapshot
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Update Firestore: Ensure consistency
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });

      // 5. Emit Success and refresh data
      await fetchUserData();
      emit(ProfileUpdateSuccess());

    } on FirebaseException catch (e) {
      // Exception Handling: Catching Firebase specific errors
      String errorMessage = "Upload failed: ${e.message}";
      if (e.code == 'object-not-found') {
        errorMessage = "Storage error: Object not found. Ensure your Firebase Storage Rules allow access.";
      } else if (e.code == 'permission-denied') {
        errorMessage = "Storage error: Access denied. Check your Firebase Storage security rules.";
      }
      emit(ProfileError(errorMessage));
    } catch (e) {
      // General catch block
      emit(ProfileError("Unexpected error: ${e.toString()}"));
    }
  }
}
