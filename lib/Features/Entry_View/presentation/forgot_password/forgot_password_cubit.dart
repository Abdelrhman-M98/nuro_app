import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nervix_app/Features/Entry_View/Data/repository/auth_repo.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordSending extends ForgotPasswordState {}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  ForgotPasswordEmailSent(this.email);
  final String email;
}

class ForgotPasswordFailure extends ForgotPasswordState {
  ForgotPasswordFailure(this.message);
  final String message;
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._repository) : super(ForgotPasswordInitial());

  final AuthRepository _repository;

  Future<void> sendResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      emit(ForgotPasswordFailure('Please enter your email address.'));
      return;
    }
    emit(ForgotPasswordSending());
    try {
      await _repository.sendPasswordResetEmail(trimmed);
      emit(ForgotPasswordEmailSent(trimmed));
    } on FirebaseAuthException catch (e) {
      emit(ForgotPasswordFailure(_mapAuthException(e)));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found for this email. Check spelling or sign up.';
      case 'too-many-requests':
        return 'Too many requests. Wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'Password reset is not enabled. Contact support.';
      default:
        return e.message ?? 'Could not send reset email. Try again.';
    }
  }
}
