import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../Data/repository/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  bool _googleSignInInProgress = false;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await authRepository.signInWithEmail(email, password);
      final complete = await authRepository.hasCompletedUserProfile();
      emit(AuthSuccess(hasCompletedProfile: complete));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthFailure(_handleError(e)));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    emit(AuthLoading());
    try {
      final cred = await authRepository.signUpWithEmail(email, password);
      final user = cred.user;
      if (user == null) {
        emit(AuthFailure('Could not create account.'));
        return;
      }
      final trimmedName = fullName?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
        await user.reload();
      }
      await authRepository.seedInitialProfileFromSignup(
        uid: user.uid,
        email: email,
        fullName: trimmedName,
        phone: phone?.trim(),
      );
      final complete = await authRepository.hasCompletedUserProfile();
      emit(AuthSuccess(hasCompletedProfile: complete));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthFailure(_handleError(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    if (_googleSignInInProgress) return;
    _googleSignInInProgress = true;
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        final complete = await authRepository.hasCompletedUserProfile();
        emit(AuthSuccess(hasCompletedProfile: complete));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    } finally {
      _googleSignInInProgress = false;
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    emit(AuthInitial());
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Wrong email or password. Try again or use Google sign-in.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    String msg = e.toString().toLowerCase();

    if (msg.contains('user-not-found')) return 'No user found with this email.';
    if (msg.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (msg.contains('weak-password')) return 'The password is too weak.';
    if (msg.contains('invalid-email')) return 'The email address is invalid.';
    if (msg.contains('user-disabled')) {
      return 'This user account has been disabled.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Try again later.';
    }
    if (msg.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    if (msg.contains('operation-not-allowed')) {
      return 'This operation is not allowed.';
    }
    if (msg.contains('channel-error')) return 'Please fill in all fields.';

    return 'An unexpected error occurred. Please try again.';
  }
}
