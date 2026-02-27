import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  // 1. تعريف النسخة الوحيدة من FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. استخدام .instance للوصول لمكتبة جوجل (حل مشكلة الـ Constructor)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // --- دالة تسجيل الدخول بجوجل (التحديث الأخير 2026) ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // أ- تهيئة المكتبة (Initialize)
      await _googleSignIn.initialize();

      // ب- فتح واجهة جوجل واختيار الحساب (Authenticate بدل signIn)
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) return null; // لو المستخدم قفل النافذة

      // ج- الحصول على بيانات التوكن (Authentication)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // د- إنشاء بيانات الاعتماد لـ Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: (googleAuth as dynamic).accessToken,
      );

      // هـ- تسجيل الدخول النهائي في Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("خطأ في تسجيل دخول جوجل: $e");
      rethrow;
    }
  }

  // --- دالة إنشاء حساب بالبريد الإلكتروني ---
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- دالة تسجيل دخول ببريد موجود ---
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- دالة تسجيل الخروج من كل شيء ---
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("خطأ أثناء تسجيل الخروج: $e");
    }
  }
}
