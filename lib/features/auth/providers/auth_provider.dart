import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

/// Provider for the authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(supabase: Supabase.instance.client);
});

/// Provider for the current authentication state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});

/// Notifier class to manage authentication state changes
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  
  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    // Initialize by checking current session
    _initialize();
  }
  
  /// Initialize the auth state by checking for an existing session
  Future<void> _initialize() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final needsOnboarding = await _checkIfNeedsOnboarding(user);
        state = state.copyWith(
          user: user,
          isLoading: false,
          needsOnboarding: needsOnboarding,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    
    // Listen for auth state changes
    _authRepository.onAuthStateChange((user) {
      if (user != null) {
        _checkIfNeedsOnboarding(user).then((needsOnboarding) {
          state = state.copyWith(
            user: user,
            needsOnboarding: needsOnboarding,
            error: null,
          );
        });
      } else {
        state = state.copyWith(
          user: null,
          needsOnboarding: false,
          error: null,
        );
      }
    });
  }
  
  /// Check if the user needs to complete onboarding
  Future<bool> _checkIfNeedsOnboarding(User user) async {
    try {
      final profile = await _authRepository.getUserProfile(user.id);
      return profile == null || !profile.onboardingCompleted;
    } catch (e) {
      return true; // Default to needing onboarding if there's an error
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authRepository.signInWithGoogle();
      // Auth state will be updated by the listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed: ${e.toString()}',
      );
    }
  }
  
  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authRepository.signInWithApple();
      // Auth state will be updated by the listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Apple sign-in failed: ${e.toString()}',
      );
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authRepository.signOut();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign out failed: ${e.toString()}',
      );
    }
  }
  
  /// Complete the onboarding process
  Future<void> completeOnboarding() async {
    try {
      if (state.user == null) return;
      
      state = state.copyWith(isLoading: true, error: null);
      await _authRepository.updateUserProfile(
        userId: state.user!.id,
        data: {'onboarding_completed': true},
      );
      
      state = state.copyWith(
        isLoading: false,
        needsOnboarding: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete onboarding: ${e.toString()}',
      );
    }
  }
}
