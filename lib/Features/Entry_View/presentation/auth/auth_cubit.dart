import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neuro_app/Features/Entry_View/Data/repository/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmail(email, password);
      if (user != null) {
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
      final user = await authRepository.signUpWithEmail(email, password);
      if (user != null) {
        emit(AuthSuccess(user.uid));
      } else {
        emit(AuthFailure("Failed to sign up"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthFailure("Google Sign-In was canceled."));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      String uid = userCredential.user!.uid; // Get the user's Firebase UID

      emit(AuthSuccess(uid)); // Pass the UID in AuthSuccess
    } catch (e) {
      emit(AuthFailure("Google Sign-In failed: $e"));
      print(e.toString());
    }
  }
}
