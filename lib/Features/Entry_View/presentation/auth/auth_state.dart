import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  final bool hasCompletedProfile;
  AuthSuccess({required this.user, required this.hasCompletedProfile});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class PasswordResetSent extends AuthState {}

class PasswordResetFailure extends AuthState {
  final String message;
  PasswordResetFailure(this.message);
}

class ProfileUpdated extends AuthState {
  final UserModel user;
  ProfileUpdated(this.user);
}
