import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

/// Interface for profile data operations
abstract class ProfileRepository {
  /// Get a user's profile
  Future<Profile?> getProfile(String userId);
  
  /// Update a user's profile
  Future<void> updateProfile(Profile profile);
  
  /// Upload a profile avatar
  Future<String?> uploadAvatar(String userId, List<int> fileBytes, String fileName);
}

/// Implementation of ProfileRepository using Supabase
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;
  
  ProfileRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;
  
  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }
  
  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      await _supabase
          .from('profiles')
          .upsert(profile.toJson())
          .select();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
  
  @override
  Future<String?> uploadAvatar(String userId, List<int> fileBytes, String fileName) async {
    try {
      final fileExt = fileName.split('.').last;
      final filePath = 'avatars/$userId.$fileExt';
      
      await _supabase.storage
          .from('profiles')
          .uploadBinary(filePath, fileBytes);
      
      final imageUrlResponse = _supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);
      
      return imageUrlResponse;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }
}
