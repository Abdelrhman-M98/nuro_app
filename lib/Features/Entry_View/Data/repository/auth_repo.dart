import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> isEmailRegisteredWithGoogle(String email) async {
    try {
      final snap = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();
      if (snap.docs.isEmpty) return false;
      
      final userData = snap.docs.first.data();
      return userData['authProvider'] == 'google' || userData['isGoogle'] == true;
    } catch (e) {
      debugPrint('Firestore Error (isEmailRegistered): $e');
      return false;
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        debugPrint('Auth Success: UID=${credential.user!.uid}');
        await _updateLastLogin(credential.user!.uid);
        return await getCurrentUserData(credential.user!.uid, Source.server);
      }
    } catch (e) {
      debugPrint('SignIn Error: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signUpWithEmail(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        debugPrint('SignUp Success: UID=${credential.user!.uid}');
        await credential.user!.updateDisplayName(name.trim());
        
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          authProvider: 'email',
          hasCompletedProfile: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(credential.user!.uid).set(newUser.toJson());
        return newUser;
      }
    } catch (e) {
      debugPrint('SignUp Error: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In...');
      try { await _googleSignIn.signOut(); } catch (_) {}
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      final dynamic googleAuth = await googleUser.authentication;
      debugPrint('Google Auth obtained. ID Token: ${googleAuth.idToken != null}');
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        debugPrint('Firebase Google Auth Success: UID=${user.uid}');
        final docRef = _firestore.collection('users').doc(user.uid);
        debugPrint('Attempting to read Firestore: ${docRef.path}');
        
        try {
          final doc = await docRef.get();
          if (!doc.exists) {
            debugPrint('Creating new user document in Firestore...');
            final newUser = UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName,
              profileImageUrl: user.photoURL,
              authProvider: 'google',
              hasCompletedProfile: false,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            );
            await docRef.set(newUser.toJson());
            return newUser;
          } else {
            debugPrint('User document found. Updating last login...');
            await _updateLastLogin(user.uid);
            return await getCurrentUserData(user.uid, Source.server);
          }
        } catch (e) {
          debugPrint('Firestore Permission/Access Error: $e');
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Global Google Sign-In Error: $e');
      rethrow;
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel?> getCurrentUserData([String? uid, Source source = Source.serverAndCache]) async {
    final id = uid ?? _auth.currentUser?.uid;
    if (id == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(id).get(GetOptions(source: source));
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (_) {
      // Fallback if server fetch fails
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (user.id == null) return;
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
