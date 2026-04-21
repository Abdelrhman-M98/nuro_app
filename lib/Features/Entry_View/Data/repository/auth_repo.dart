import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      final u = cred.user;
      if (u != null) {
        await _syncGoogleProfileImageToFirestoreIfNeeded(u);
      }
      return cred;
    } catch (e) {
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }

      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e, st) {
      debugPrint('signOut: $e $st');
    }
  }

  Future<void> _syncGoogleProfileImageToFirestoreIfNeeded(User u) async {
    final photo = u.photoURL;
    if (photo == null || photo.isEmpty) return;
    final isGoogle =
        u.providerData.any((p) => p.providerId == 'google.com');
    if (!isGoogle) return;

    final ref = FirebaseFirestore.instance.collection('users').doc(u.uid);
    final snap = await ref.get();
    final data = snap.data() ?? {};
    final url = (data['profileImageUrl'] as String?) ?? '';
    final b64 = (data['profileImageBase64'] as String?) ?? '';
    if (b64.isNotEmpty) return;
    if (url.isNotEmpty) return;

    await ref.set(
      {
        'profileImageUrl': photo,
        if (u.email != null) 'email': u.email,
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> hasCompletedUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!snap.exists) return false;
    final name = snap.data()?['name'];
    return name is String && name.trim().isNotEmpty;
  }
}
