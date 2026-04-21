import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String name;
  final int age;
  final String condition;
  final String gender;
  final String email;
  final String phone;
  final String country;
  final String profileImageUrl;
  final String profileImageBase64;

  UserModel({
    required this.name,
    required this.age,
    required this.condition,
    required this.gender,
    required this.email,
    required this.phone,
    required this.country,
    required this.profileImageUrl,
    this.profileImageBase64 = '',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      name: data['name'] ?? 'User Name',
      age:
          data['age'] is int
              ? data['age']
              : int.tryParse(data['age']?.toString() ?? '25') ?? 25,
      condition: data['diseases'] ?? 'Unknown',
      gender: data['gender'] ?? 'Unknown',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      profileImageBase64: data['profileImageBase64'] is String
          ? data['profileImageBase64'] as String
          : '',
    );
  }

  factory UserModel.fromFirebaseAuthUser(User? user) {
    if (user == null) {
      return UserModel(
        name: '',
        age: 25,
        condition: '',
        gender: 'Male',
        email: '',
        phone: '',
        country: '',
        profileImageUrl: '',
        profileImageBase64: '',
      );
    }
    return UserModel(
      name: user.displayName ?? '',
      age: 25,
      condition: '',
      gender: 'Male',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      country: '',
      profileImageUrl: user.photoURL ?? '',
      profileImageBase64: '',
    );
  }
}
