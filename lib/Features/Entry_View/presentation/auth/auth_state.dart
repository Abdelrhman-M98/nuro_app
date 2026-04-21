abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  /// `true` إذا وُجد مستند `users/{uid}` في Firestore وفيه `name` غير فارغ.
  final bool hasCompletedProfile;

  AuthSuccess({required this.hasCompletedProfile});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
