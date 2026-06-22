import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../services/face_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FaceAuthService _faceAuthService = FaceAuthService(); // Assuming it can be instantiated like this

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<FaceVerificationCompleted>(_onFaceVerificationCompleted);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(email: event.email, password: event.password);
      emit(FaceVerificationRequired(user, true));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(email: event.email, password: event.password);
      emit(FaceVerificationRequired(user, false));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.signInWithGoogle();
      final user = result.$1;
      final isNewUser = result.$2;
      emit(FaceVerificationRequired(user, isNewUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onFaceVerificationCompleted(FaceVerificationCompleted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.isSignUp) {
        // Save embedding
        await authRepository.saveFaceEmbedding(event.user.uid, event.embedding);
        await authRepository.saveUserLocal(event.user);
        emit(Authenticated(event.user));
      } else {
        // Fetch and compare
        final savedEmbedding = await authRepository.getFaceEmbedding(event.user.uid);
        if (savedEmbedding == null) {
          emit(const AuthError("Face data not found for this user."));
          return;
        }

        final similarity = _faceAuthService.cosineSimilarity(savedEmbedding, event.embedding);
        print("Face Similarity: $similarity");

        // Lowered threshold from 0.85 to 0.65 to allow for angle and background changes
        if (similarity > 0.65) {
          await authRepository.saveUserLocal(event.user);
          emit(Authenticated(event.user));
        } else {
          // Emit FaceVerificationFailed instead of logging out completely
          emit(const FaceVerificationFailed("Face Mismatch. Please try again."));
        }
      }
    } catch (e) {
      emit(FaceVerificationFailed(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await authRepository.getCachedUser();
      if (user != null) {
        // App start hote hi har baar face verification mangega
        emit(FaceVerificationRequired(user, false));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
