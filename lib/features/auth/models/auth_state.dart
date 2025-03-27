import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the current authentication state of the application
class AuthState {
  /// The currently authenticated user (null if not authenticated)
  final User? user;
  
  /// Whether authentication operations are in progress
  final bool isLoading;
  
  /// Error message if authentication operations failed
  final String? error;
  
  /// Whether the user needs to complete onboarding
  final bool needsOnboarding;
  
  const AuthState({
    this.user,
    this.isLoading = true,
    this.error,
    this.needsOnboarding = false,
  });
  
  /// Create a copy of this state with the given fields replaced
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? needsOnboarding,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    );
  }
  
  /// Whether the user is authenticated
  bool get isAuthenticated => user != null;
}
