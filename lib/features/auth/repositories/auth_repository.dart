import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

/// Interface for authentication operations
abstract class AuthRepository {
  /// Get the current authenticated user
  Future<User?> getCurrentUser();
  
  /// Sign in with Google
  Future<void> signInWithGoogle();
  
  /// Sign in with Apple
  Future<void> signInWithApple();
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  
  /// Update user profile data
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  });
  
  /// Listen for authentication state changes
  void onAuthStateChange(void Function(User?) callback);
}

/// Implementation of AuthRepository using Supabase
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  
  AuthRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;
  
  @override
  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }
  
  @override
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb
              ? '${Uri.base.origin}/auth/callback'
              : null,
        );
      } else {
        // Native implementation
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile', 'openid'],
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google sign in was canceled');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = OAuthCredential(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );
      }
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> signInWithApple() async {
    try {
      if (kIsWeb) {
        // Web implementation
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kIsWeb
              ? '${Uri.base.origin}/auth/callback'
              : null,
        );
      } else {
        // Native implementation
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: appleCredential.identityToken!,
          nonce: appleCredential.nonce,
        );
      }
    } catch (e) {
      debugPrint('Error in signInWithApple: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
  
  @override
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _supabase
        .from('profiles')
        .upsert({
          'id': userId,
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select();
  }
  
  @override
  void onAuthStateChange(void Function(User?) callback) {
    _supabase.auth.onAuthStateChange.listen((data) {
      callback(data.session?.user);
    });
  }
}
