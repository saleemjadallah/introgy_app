import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../widgets/avatar_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _interests = '';
  String _personality = '';
  bool _isGeneratingBio = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final profileAsync = ref.read(profileProvider);
    
    profileAsync.whenData((profile) {
      if (profile != null) {
        setState(() {
          _nameController.text = profile.fullName ?? '';
          _bioController.text = profile.bio ?? '';
          
          // Extract interests and personality from preferences if available
          if (profile.preferences != null) {
            _interests = profile.preferences!['interests'] ?? '';
            _personality = profile.preferences!['personality'] ?? '';
          }
        });
      }
    });
  }

  Future<void> _generateBioSuggestion() async {
    if (_interests.isEmpty || _personality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your interests and personality traits first'),
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingBio = true;
    });

    try {
      final params = (
        interests: _interests,
        personality: _personality,
      );
      
      final bioSuggestion = await ref.read(bioSuggestionProvider(params).future);
      
      if (mounted) {
        setState(() {
          _bioController.text = bioSuggestion;
          _isGeneratingBio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating bio: $e')),
        );
        setState(() {
          _isGeneratingBio = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileAsync = ref.read(profileProvider);
      final currentProfile = profileAsync.value;
      
      if (currentProfile == null) {
        throw Exception('Profile not found');
      }

      final updatedProfile = currentProfile.copyWith(
        fullName: _nameController.text,
        bio: _bioController.text,
        preferences: {
          ...currentProfile.preferences ?? {},
          'interests': _interests,
          'personality': _personality,
        },
      );

      await ref.read(updateProfileProvider(updatedProfile).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }
          
          return _buildForm(context, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading profile: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildForm(BuildContext context, Profile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: AvatarPicker(
                currentAvatarUrl: profile.avatarUrl,
                userId: profile.id,
                size: 120,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: const OutlineInputBorder(),
                hintText: 'Tell us about yourself...',
                suffixIcon: _isGeneratingBio
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        tooltip: 'Generate bio with AI',
                        onPressed: _generateBioSuggestion,
                      ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Bio Generator',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your interests and personality traits to generate a bio with AI',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _interests,
              decoration: const InputDecoration(
                labelText: 'Your Interests',
                hintText: 'e.g., hiking, reading, technology',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _interests = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _personality,
              decoration: const InputDecoration(
                labelText: 'Your Personality',
                hintText: 'e.g., introverted, creative, analytical',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _personality = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Bio with AI'),
              onPressed: _isGeneratingBio ? null : _generateBioSuggestion,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
