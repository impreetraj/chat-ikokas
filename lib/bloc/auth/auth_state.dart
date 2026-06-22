import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class FaceVerificationRequired extends AuthState {
  final UserModel user;
  final bool isSignUp;

  const FaceVerificationRequired(this.user, this.isSignUp);

  @override
  List<Object?> get props => [user, isSignUp];
}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

class FaceVerificationFailed extends AuthState {
  final String message;

  const FaceVerificationFailed(this.message);

  @override
  List<Object?> get props => [message];
}
