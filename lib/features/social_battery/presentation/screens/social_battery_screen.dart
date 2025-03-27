import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/battery_level_indicator.dart';
import '../widgets/upcoming_events_list.dart';
import '../widgets/quick_actions.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/presentation/widgets/premium_feature_widget.dart';

class SocialBatteryScreen extends ConsumerWidget {
  const SocialBatteryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Battery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
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
                  'How\'s your energy today?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                
                // Battery level indicator
                const BatteryLevelIndicator(
                  level: 0.7, // 70% battery
                ),
                const SizedBox(height: 32),
                
                // Quick actions
                const QuickActions(),
                const SizedBox(height: 32),
                
                // Upcoming events section - Premium feature
                Text(
                  'Upcoming Social Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final premiumStatusAsync = ref.watch(premiumStatusProvider);
                    
                    return premiumStatusAsync.when(
                      data: (isPremium) {
                        return PremiumFeatureWidget(
                          featureName: 'Calendar Integration',
                          description: 'Connect your calendar to track social events and get personalized energy forecasts.',
                          showPremiumBadge: true,
                          placeholderWidget: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 48,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Calendar Integration'),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      context.push('/premium');
                                    },
                                    icon: const Icon(Icons.star, size: 16),
                                    label: const Text('Upgrade to Premium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: const UpcomingEventsList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const UpcomingEventsList(),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Tips section - Premium feature
                Consumer(
                  builder: (context, ref, _) {
                    final premiumStatusAsync = ref.watch(premiumStatusProvider);
                    
                    return premiumStatusAsync.when(
                      data: (isPremium) {
                        return PremiumFeatureWidget(
                          featureName: 'Personalized Tips',
                          description: 'Get AI-powered tips based on your social battery patterns and upcoming events.',
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
                                      Icons.lightbulb_outline,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isPremium ? 'AI-Powered Tip' : 'Daily Tip',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    if (isPremium) ...[  
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'AI',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isPremium
                                      ? 'Based on your patterns, you tend to feel more energized in the morning. Consider scheduling important social interactions before 2pm when possible.'
                                      : 'Taking 5 minutes of quiet time before a social event can help preserve your energy throughout the interaction.',
                                ),
                                if (!isPremium) ...[  
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: () {
                                      context.push('/premium');
                                    },
                                    icon: const Icon(Icons.star, size: 16),
                                    label: const Text('Get personalized AI tips with Premium'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline),
                                SizedBox(width: 8),
                                Text('Daily Tip'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Taking 5 minutes of quiet time before a social event can help preserve your energy throughout the interaction.'),
                          ],
                        ),
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
                                    'Upgrade Your Social Battery',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Get AI-powered insights, calendar integration, personalized recommendations, and more with Premium.',
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
