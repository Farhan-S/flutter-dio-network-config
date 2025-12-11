import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User requests login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// User requests logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Token refresh triggered
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}
