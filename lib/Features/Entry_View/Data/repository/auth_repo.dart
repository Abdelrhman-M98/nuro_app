import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  // 1. تعريف النسخة الوحيدة من FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. استخدام .instance للوصول لمكتبة جوجل (حل مشكلة الـ Constructor)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // --- دالة تسجيل الدخول بجوجل (التحديث الأخير 2026 متوافق مع الإصدار 7.2.0) ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // أ- تهيئة المكتبة (Initialize)
      await _googleSignIn.initialize();

      // ب- فتح واجهة جوجل واختيار الحساب (authenticate في الإصدارات الجديدة)
      // ملاحظة: authenticate تطرح استثناء في حال الإلغاء بدلاً من إرجاع null
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // ج- الحصول على بيانات التوكن (Authentication للحصول على idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // د- الحصول على accessToken (يتطلب الآن طلباً منفصلاً في الإصدار 7.2.0 عبر authorizationClient)
      final GoogleSignInClientAuthorization authorization = 
          await googleUser.authorizationClient.authorizeScopes([]);

      // هـ- إنشاء بيانات الاعتماد لـ Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorization.accessToken,
      );

      // و- تسجيل الدخول النهائي في Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // معالجة حالة إلغاء المستخدم لتسجيل الدخول
      if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        print("تم إلغاء عملية تسجيل الدخول من قبل المستخدم");
        return null; 
      }
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
