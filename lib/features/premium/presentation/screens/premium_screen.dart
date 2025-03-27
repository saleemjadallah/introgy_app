import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/premium_service.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumService = ref.watch(premiumServiceProvider);
    final premiumStatusAsync = ref.watch(premiumStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: premiumStatusAsync.when(
        data: (isPremium) {
          if (isPremium) {
            return _buildPremiumActiveContent(context);
          } else {
            return _buildSubscriptionContent(context, premiumService);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildPremiumActiveContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re a Premium Member!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you for supporting Introgy.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          const Text(
            'You have access to all premium features:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._buildPremiumFeaturesList(context),
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionContent(BuildContext context, PremiumService premiumService) {
    final subscriptionOptions = premiumService.getSubscriptionOptions();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.star,
              size: 60,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Upgrade to Premium',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Unlock all features and get the most out of Introgy',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildPremiumFeaturesList(context),
          const SizedBox(height: 32),
          const Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...subscriptionOptions.map((option) => _buildSubscriptionOption(context, option)).toList(),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Subscription will automatically renew unless canceled at least 24 hours before the end of the current period.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Test button for development purposes
          const SizedBox(height: 32),
          Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                final premiumStatusNotifier = ref.read(premiumStatusProvider.notifier);
                final isPremium = await premiumService.isPremium();
                await premiumStatusNotifier.setPremiumStatus(!isPremium);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(!isPremium 
                          ? 'Premium features activated for testing' 
                          : 'Premium features deactivated'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.developer_mode),
              label: const Text('Toggle Premium (Dev Only)'),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildPremiumFeaturesList(BuildContext context) {
    final premiumFeatures = [
      'Unlimited AI-generated wellbeing tips',
      'Advanced social battery analytics',
      'Custom connection categories',
      'Personalized wellbeing insights',
      'Priority support',
      'Ad-free experience',
      'Dark theme',
      'Data export',
    ];
    
    return premiumFeatures.map((feature) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    )).toList();
  }
  
  Widget _buildSubscriptionOption(BuildContext context, Map<String, dynamic> option) {
    final isBestValue = option['isBestValue'] == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBestValue
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _handleSubscriptionSelection(context, option),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    option['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Best Value',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${option['price']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${option['period']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                option['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleSubscriptionSelection(BuildContext context, Map<String, dynamic> option) {
    // In a real app, this would initiate the payment process
    // For this demo, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Mode'),
        content: Text('In a real app, this would initiate the payment process for the ${option['name']} plan at \$${option['price']}/${option['period']}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, _) {
              return FilledButton(
                onPressed: () async {
                  // Simulate successful purchase
                  await ref.read(premiumStatusProvider.notifier).setPremiumStatus(true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Simulate Purchase'),
              );
            },
          ),
        ],
      ),
    );
  }
}
