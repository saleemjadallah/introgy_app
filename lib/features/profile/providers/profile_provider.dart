import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import '../../../shared/services/ai_service.dart';

/// Provider for the profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(supabase: Supabase.instance.client);
});

/// Provider for the AI service
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Provider for the current user's profile
final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    return null;
  }
  
  return repository.getProfile(user.id);
});

/// Provider for updating the user's profile
final updateProfileProvider = FutureProvider.family.autoDispose<bool, Profile>((ref, profile) async {
  final repository = ref.watch(profileRepositoryProvider);
  await repository.updateProfile(profile);
  
  // Refresh the profile provider
  ref.invalidate(profileProvider);
  
  return true;
});

/// Provider for uploading a profile avatar
final uploadAvatarProvider = FutureProvider.family.autoDispose<String?, ({String userId, Uint8List fileBytes, String fileName})>(
  (ref, params) async {
    final repository = ref.watch(profileRepositoryProvider);
    final avatarUrl = await repository.uploadAvatar(
      params.userId,
      params.fileBytes,
      params.fileName,
    );
    
    if (avatarUrl != null) {
      // Refresh the profile provider
      ref.invalidate(profileProvider);
    }
    
    return avatarUrl;
  },
);

/// Provider for AI-generated bio suggestions
final bioSuggestionProvider = FutureProvider.family.autoDispose<String, ({String interests, String personality})>(
  (ref, params) async {
    final aiService = ref.watch(aiServiceProvider);
    try {
      return await aiService.generateBioSuggestion(
        params.interests,
        params.personality,
      );
    } catch (e) {
      debugPrint('Error generating bio suggestion: $e');
      return 'Unable to generate bio suggestion at this time.';
    }
  },
);

/// Provider for completing the onboarding process
final completeOnboardingProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final profile = await ref.watch(profileProvider.future);
  
  if (profile == null) {
    return false;
  }
  
  final updatedProfile = profile.copyWith(onboardingCompleted: true);
  await repository.updateProfile(updatedProfile);
  
  // Refresh the profile provider
  ref.invalidate(profileProvider);
  
  return true;
});
