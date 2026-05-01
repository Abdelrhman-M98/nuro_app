import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nervix_app/Features/Entry_View/Data/repository/auth_repo.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_state.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      // 1. Check if email is registered with Google only
      final isGoogleOnly = await authRepository.isEmailRegisteredWithGoogle(email);
      if (isGoogleOnly) {
        emit(AuthFailure('هذا البريد مسجل عن طريق Google، استخدم زر "تسجيل الدخول بجوجل"'));
        return;
      }

      // 2. Proceed with sign in
      final user = await authRepository.signInWithEmail(email, password);
      if (user != null) {
        emit(AuthSuccess(
          user: user, 
          hasCompletedProfile: user.hasCompletedProfile,
        ));
      } else {
        emit(AuthFailure('فشل تسجيل الدخول. تأكد من البيانات.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmail(name, email, password);
      if (user != null) {
        emit(AuthSuccess(user: user, hasCompletedProfile: false));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        emit(AuthSuccess(
          user: user, 
          hasCompletedProfile: user.hasCompletedProfile,
        ));
      } else {
        emit(AuthInitial());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authRepository.sendPasswordResetEmail(email);
      emit(PasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(PasswordResetFailure(_mapAuthError(e)));
    } catch (e) {
      emit(PasswordResetFailure(e.toString()));
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    emit(AuthLoading());
    try {
      await authRepository.updateUserProfile(updatedUser);
      emit(ProfileUpdated(updatedUser));
      emit(AuthSuccess(
        user: updatedUser, 
        hasCompletedProfile: updatedUser.hasCompletedProfile,
      ));
    } catch (e) {
      emit(AuthFailure('فشل تحديث البيانات: $e'));
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthInitial());
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح.';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً.';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت.';
      default:
        return e.message ?? 'حدث خطأ غير متوقع.';
    }
  }
}
