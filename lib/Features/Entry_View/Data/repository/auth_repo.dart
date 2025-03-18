import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signUpWithEmail({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await _saveUserData(
          uid: user.uid,
          username: username,
          email: email,
          phone: phone,
        );
      }
      return user;
    } catch (e) {
      print("❌ Sign-up error: $e");
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("❌ Sign-in error: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserData(
          uid: user.uid,
          username: user.displayName ?? "Unknown",
          email: user.email ?? "",
          phone: user.phoneNumber ?? "",
        );
      }

      return user;
    } catch (e) {
      print("❌ Google Sign-in error: $e");
      return null;
    }
  }

  Future<void> _saveUserData({
    required String uid,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        await _firestore.collection("users").doc(uid).set({
          "uid": uid,
          "username": username,
          "email": email,
          "phone": phone,
          "profileImage": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
        print("✅ User data saved successfully!");
      }
    } catch (e) {
      print("❌ Error saving user data: $e");
    }
  }

  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      var userDoc = await _firestore.collection("users").doc(uid).get();
      return userDoc.exists ? userDoc : null;
    } catch (e) {
      print("❌ Error fetching user data: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("✅ User signed out successfully!");
    } catch (e) {
      print("❌ Error signing out: $e");
    }
  }
}
