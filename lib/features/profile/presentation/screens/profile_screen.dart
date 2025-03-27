import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_item.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../shared/services/ai_service.dart';
import '../../../../shared/services/premium_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _wellbeingTip = 'Loading your personalized wellbeing tip...';
  bool _isLoadingTip = true;

  @override
  void initState() {
    super.initState();
    _loadWellbeingTip();
  }

  Future<void> _loadWellbeingTip() async {
    setState(() {
      _isLoadingTip = true;
    });

    try {
      final profileAsync = ref.read(profileProvider);
      final profile = await profileAsync.value;
      final authState = ref.read(authStateProvider);
      
      if (profile == null || authState.user == null) {
        setState(() {
          _wellbeingTip = 'Sign in to get personalized wellbeing tips';
          _isLoadingTip = false;
        });
        return;
      }
      
      final aiService = ref.read(aiServiceProvider);
      final userProfileInfo = 'Name: ${profile.fullName ?? authState.user?.userMetadata?['full_name'] ?? 'User'}, '
          'Email: ${authState.user?.email ?? 'No email provided'}, '
          'Bio: ${profile.bio ?? 'No bio provided'}';
      
      final tip = await aiService.generateWellbeingTip(userProfileInfo);
      
      if (mounted) {
        setState(() {
          _wellbeingTip = tip;
          _isLoadingTip = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wellbeingTip = 'Take a moment to breathe deeply and appreciate the present moment.';
          _isLoadingTip = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(profileProvider.future);
          await _loadWellbeingTip();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile header
                ProfileHeader(
                  name: authState.user?.userMetadata?['full_name'] ?? 'User',
                  email: authState.user?.email ?? '',
                  imageUrl: authState.user?.userMetadata?['avatar_url'],
                ),
                const SizedBox(height: 24),
                
                // Premium Status Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildPremiumStatusCard(),
                ),
                
                const SizedBox(height: 24),
                
                // AI Wellbeing Tip Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildWellbeingTipCard(),
                ),
                const SizedBox(height: 24),
                
                // Settings sections
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsItem(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  onTap: () {
                    context.push('/profile/edit');
                  },
                ),
                SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    context.push('/profile/notifications');
                  },
                ),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () {
                    context.push('/profile/privacy');
                  },
                ),
                
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsItem(
                  icon: Icons.battery_full,
                  title: 'Social Battery Settings',
                  onTap: () {
                    context.push('/social-battery/settings');
                  },
                ),
                SettingsItem(
                  icon: Icons.people_outline,
                  title: 'Connection Preferences',
                  onTap: () {
                    context.push('/connections/preferences');
                  },
                ),
                SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  onTap: () {
                    context.push('/settings/theme');
                  },
                ),
                
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    context.push('/support');
                  },
                ),
                SettingsItem(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  onTap: () {
                    context.push('/feedback');
                  },
                ),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    context.push('/terms');
                  },
                ),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    context.push('/privacy');
                  },
                ),
                
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true && mounted) {
                        await authNotifier.signOut();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumStatusCard() {
    return Consumer(
      builder: (context, ref, child) {
        final premiumStatusAsync = ref.watch(premiumStatusProvider);
        
        return premiumStatusAsync.when(
          data: (isPremium) {
            if (isPremium) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Premium Active',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Thank you for supporting Introgy! You have access to all premium features.',
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.push('/premium');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber.shade800,
                          side: BorderSide(color: Colors.amber.shade800),
                        ),
                        child: const Text('Manage Subscription'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_border,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Upgrade to Premium',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get unlimited AI tips, advanced analytics, and more premium features.',
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          context.push('/premium');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Upgrade Now'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          loading: () => const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade to Premium',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Get unlimited AI tips, advanced analytics, and more premium features.',
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      context.push('/premium');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWellbeingTipCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Wellbeing Tip',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (_isLoadingTip)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadWellbeingTip,
                    tooltip: 'Get a new tip',
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final premiumStatusAsync = ref.watch(premiumStatusProvider);
                return premiumStatusAsync.when(
                  data: (isPremium) {
                    if (isPremium) {
                      return Text(
                        _wellbeingTip,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    } else {
                      // Show limited tip for non-premium users
                      final limitedTip = _wellbeingTip.length > 100 
                          ? '${_wellbeingTip.substring(0, 100)}... '
                          : _wellbeingTip;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            limitedTip,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (_wellbeingTip.length > 100) ...[  
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                context.push('/premium');
                              },
                              icon: const Icon(Icons.star, size: 16),
                              label: const Text('Upgrade to see full tips'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      );
                    }
                  },
                  loading: () => Text(
                    _wellbeingTip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  error: (_, __) => Text(
                    _wellbeingTip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
