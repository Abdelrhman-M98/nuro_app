import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? id;
  final String email;
  final String? name;
  final int? age;
  final String? country;
  final String? phoneNumber;
  final String? gender; // 'male', 'female', 'other'
  final List<String>? chronicDiseases;
  final String? profileImageUrl;
  final String? profileImageBase64;
  final String? authProvider; // 'email', 'google'
  final bool hasCompletedProfile;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    this.id,
    required this.email,
    this.name,
    this.age,
    this.country,
    this.phoneNumber,
    this.gender,
    this.chronicDiseases,
    this.profileImageUrl,
    this.profileImageBase64,
    this.authProvider,
    this.hasCompletedProfile = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Backward compatibility getter for 'phone' and 'condition' if needed elsewhere
  String get phone => phoneNumber ?? '';
  String get condition => (chronicDiseases != null && chronicDiseases!.isNotEmpty) 
      ? chronicDiseases!.join(', ') 
      : 'None';

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? country,
    String? phoneNumber,
    String? gender,
    List<String>? chronicDiseases,
    String? profileImageUrl,
    String? profileImageBase64,
    String? authProvider,
    bool? hasCompletedProfile,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      authProvider: authProvider ?? this.authProvider,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'country': country,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'chronicDiseases': chronicDiseases,
      'profileImageUrl': profileImageUrl,
      'profileImageBase64': profileImageBase64,
      'authProvider': authProvider,
      'hasCompletedProfile': hasCompletedProfile,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return UserModel(
      id: docId,
      email: json['email'] ?? '',
      name: json['name'],
      age: json['age'],
      country: json['country'],
      phoneNumber: json['phoneNumber'] ?? json['phone'], // Support legacy 'phone'
      gender: json['gender'],
      chronicDiseases: json['chronicDiseases'] != null 
          ? List<String>.from(json['chronicDiseases']) 
          : (json['diseases'] != null ? [json['diseases'].toString()] : null),
      profileImageUrl: json['profileImageUrl'],
      profileImageBase64: json['profileImageBase64'],
      authProvider: json['authProvider'] ?? (json['isGoogle'] == true ? 'google' : 'email'),
      hasCompletedProfile: json['hasCompletedProfile'] ?? json['hasCompletedUserProfile'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromFirebaseAuthUser(User? user) {
    if (user == null) {
      return UserModel(
        email: '',
        createdAt: DateTime.now(),
      );
    }
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      profileImageUrl: user.photoURL,
      authProvider: 'google',
      hasCompletedProfile: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }
}
