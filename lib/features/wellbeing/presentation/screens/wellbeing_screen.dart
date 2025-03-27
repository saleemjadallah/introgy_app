import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/wellbeing_stats.dart';
import '../widgets/resource_card.dart';
import '../widgets/mood_tracker.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/presentation/widgets/premium_feature_widget.dart';

class WellbeingScreen extends ConsumerWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to wellbeing settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                
                // Mood tracker
                const MoodTracker(),
                const SizedBox(height: 32),
                
                // Wellbeing stats - Premium feature
                Consumer(
                  builder: (context, ref, _) {
                    final premiumStatusAsync = ref.watch(premiumStatusProvider);
                    
                    return premiumStatusAsync.when(
                      data: (isPremium) {
                        return PremiumFeatureWidget(
                          featureName: 'Advanced Wellbeing Analytics',
                          description: 'Get detailed insights into your wellbeing patterns, trends, and personalized recommendations.',
                          showPremiumBadge: true,
                          placeholderWidget: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insights,
                                    size: 48,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Advanced Wellbeing Analytics'),
                                  const SizedBox(height: 8),
                                  const Text('Upgrade to Premium'),
                                ],
                              ),
                            ),
                          ),
                          child: const WellbeingStats(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const WellbeingStats(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Resources section
                Text(
                  'Resources for You',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Resource cards
                const ResourceCard(
                  title: 'Setting Healthy Boundaries',
                  description: 'Learn how to establish and maintain boundaries that protect your energy.',
                  icon: Icons.shield_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                
                const ResourceCard(
                  title: 'Mindfulness Meditation',
                  description: '5-minute guided meditation to help you center yourself before social events.',
                  icon: Icons.self_improvement,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                
                const ResourceCard(
                  title: 'Social Energy Conservation',
                  description: 'Strategies to preserve your social battery during extended interactions.',
                  icon: Icons.battery_charging_full,
                  color: Colors.green,
                ),
                const SizedBox(height: 32),
                
                // Journal prompt - Premium feature
                Consumer(
                  builder: (context, ref, _) {
                    final premiumStatusAsync = ref.watch(premiumStatusProvider);
                    
                    return premiumStatusAsync.when(
                      data: (isPremium) {
                        return PremiumFeatureWidget(
                          featureName: 'Wellbeing Journal',
                          description: 'Track your wellbeing journey with guided journal prompts and mood tracking over time.',
                          showPremiumBadge: true,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Journal Prompt',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'What social interaction drained your energy the most this week, and what might have made it easier?',
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to journal entry screen
                                    if (isPremium) {
                                      // TODO: Navigate to journal entry screen
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Journal feature coming soon!')),
                                      );
                                    } else {
                                      context.push('/premium');
                                    }
                                  },
                                  child: const Text('Write in Journal'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Unable to load journal feature')),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Premium banner
                Consumer(
                  builder: (context, ref, _) {
                    final premiumStatusAsync = ref.watch(premiumStatusProvider);
                    
                    return premiumStatusAsync.when(
                      data: (isPremium) {
                        if (isPremium) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
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
                                    'Unlock Premium Wellbeing Features',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Get access to advanced analytics, personalized insights, wellbeing journal, and more.',
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  context.push('/premium');
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Upgrade to Premium'),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
