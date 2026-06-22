import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class FaceVerificationCompleted extends AuthEvent {
  final UserModel user;
  final List<double> embedding;
  final bool isSignUp;

  const FaceVerificationCompleted(this.user, this.embedding, this.isSignUp);

  @override
  List<Object?> get props => [user, embedding, isSignUp];
}
