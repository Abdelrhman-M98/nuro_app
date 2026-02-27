import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../Data/repository/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await authRepository.signInWithEmail(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(_handleError(e)));
    }
  }

  // إنشاء حساب جديد
  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await authRepository.signUpWithEmail(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(_handleError(e)));
    }
  }

  // جوجل
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    emit(AuthInitial());
  }

  String _handleError(dynamic e) {
    String msg = e.toString();
    if (msg.contains('user-not-found')) return 'الايميل غير مسجل لدينا';
    if (msg.contains('wrong-password')) return 'كلمة المرور غير صحيحة';
    if (msg.contains('email-already-in-use')) return 'هذا البريد مستخدم بالفعل';
    if (msg.contains('weak-password')) return 'كلمة المرور ضعيفة جداً';
    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }
}
