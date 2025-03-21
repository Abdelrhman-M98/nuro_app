import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuro_app/Features/Entry_View/Data/repository/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  String? userId;
  void initializeAuth() {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      userId = user.uid;
      emit(AuthSuccess(userId!));
    } else {
      emit(AuthInitial());
    }
  }

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    loadUser();
  }

  void loadUser() {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      userId = user.uid;
      emit(AuthSuccess(user.uid));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmail(email, password);
      if (user != null) {
        userId = user.uid;
        emit(AuthSuccess(user.uid));
      } else {
        emit(AuthFailure("Failed to login"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmail(
        username: username,
        email: email,
        phone: phone,
        password: password,
      );

      if (user != null) {
        userId = user.uid;
        emit(AuthSuccess(user.uid));
      } else {
        emit(AuthFailure("Failed to sign up"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        userId = user.uid;
        emit(AuthSuccess(user.uid));
      } else {
        emit(AuthFailure("Google Sign-In failed"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      userId = null;
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Failed to sign out: $e"));
    }
  }
}
