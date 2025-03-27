import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/connection_card.dart';
import '../widgets/connection_filter.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/presentation/widgets/premium_feature_widget.dart';

class ConnectionBuilderScreen extends ConsumerStatefulWidget {
  const ConnectionBuilderScreen({super.key});

  @override
  ConsumerState<ConnectionBuilderScreen> createState() => _ConnectionBuilderScreenState();
}

class _ConnectionBuilderScreenState extends ConsumerState<ConnectionBuilderScreen> {
  String _selectedFilter = 'All';
  
  // Sample connection data - in a real app, this would come from a repository
  final List<Map<String, dynamic>> _connections = [
    {
      'name': 'Sarah Johnson',
      'relationship': 'Friend',
      'lastContact': DateTime.now().subtract(const Duration(days: 5)),
      'contactFrequency': 'Weekly',
      'priority': 'High',
      'image': null, // Would be a network image URL in a real app
    },
    {
      'name': 'Michael Chen',
      'relationship': 'Colleague',
      'lastContact': DateTime.now().subtract(const Duration(days: 12)),
      'contactFrequency': 'Bi-weekly',
      'priority': 'Medium',
      'image': null,
    },
    {
      'name': 'Emma Williams',
      'relationship': 'Family',
      'lastContact': DateTime.now().subtract(const Duration(days: 2)),
      'contactFrequency': 'Weekly',
      'priority': 'High',
      'image': null,
    },
    {
      'name': 'David Rodriguez',
      'relationship': 'Friend',
      'lastContact': DateTime.now().subtract(const Duration(days: 30)),
      'contactFrequency': 'Monthly',
      'priority': 'Low',
      'image': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredConnections {
    if (_selectedFilter == 'All') {
      return _connections;
    } else if (_selectedFilter == 'Due Soon') {
      return _connections.where((connection) {
        final lastContact = connection['lastContact'] as DateTime;
        final daysSinceLastContact = DateTime.now().difference(lastContact).inDays;
        
        // Determine if contact is due based on frequency
        switch (connection['contactFrequency']) {
          case 'Daily':
            return daysSinceLastContact >= 1;
          case 'Weekly':
            return daysSinceLastContact >= 7;
          case 'Bi-weekly':
            return daysSinceLastContact >= 14;
          case 'Monthly':
            return daysSinceLastContact >= 30;
          default:
            return false;
        }
      }).toList();
    } else if (_selectedFilter == 'High Priority') {
      return _connections.where((connection) => connection['priority'] == 'High').toList();
    } else if (_selectedFilter == 'Recent') {
      return _connections
          .where((connection) {
            final lastContact = connection['lastContact'] as DateTime;
            return DateTime.now().difference(lastContact).inDays <= 7;
          })
          .toList();
    }
    
    return _connections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConnectionFilter(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          ),
          
          // Premium banner
          Consumer(
            builder: (context, ref, _) {
              final premiumStatusAsync = ref.watch(premiumStatusProvider);
              
              return premiumStatusAsync.when(
                data: (isPremium) {
                  if (isPremium) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Free accounts limited to 3 connections',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/premium');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Upgrade'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          // Connection list
          Expanded(
            child: _filteredConnections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No connections found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your filter or add a new connection',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredConnections.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final connection = _filteredConnections[index];
                      return Consumer(
                        builder: (context, ref, _) {
                          final premiumStatusAsync = ref.watch(premiumStatusProvider);
                          
                          return premiumStatusAsync.when(
                            data: (isPremium) {
                              // Show premium badge on connections beyond the free limit
                              final showPremiumBadge = !isPremium && index >= 3;
                              
                              return Stack(
                                children: [
                                  ConnectionCard(
                                    name: connection['name'],
                                    relationship: connection['relationship'],
                                    lastContact: connection['lastContact'],
                                    contactFrequency: connection['contactFrequency'],
                                    priority: connection['priority'],
                                    image: connection['image'],
                                    onTap: () {
                                      if (showPremiumBadge) {
                                        // Show premium upgrade dialog
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Premium Feature'),
                                            content: const Text(
                                              'Upgrade to premium to manage more than 3 connections and unlock advanced relationship management features.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Maybe Later'),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
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
                                        );
                                      } else {
                                        // TODO: Navigate to connection details
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Connection details coming soon!')),
                                        );
                                      }
                                    },
                                  ),
                                  if (showPremiumBadge)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.black,
                                              size: 12,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'PREMIUM',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                            loading: () => ConnectionCard(
                              name: connection['name'],
                              relationship: connection['relationship'],
                              lastContact: connection['lastContact'],
                              contactFrequency: connection['contactFrequency'],
                              priority: connection['priority'],
                              image: connection['image'],
                              onTap: () {
                                // TODO: Navigate to connection details
                              },
                            ),
                            error: (_, __) => ConnectionCard(
                              name: connection['name'],
                              relationship: connection['relationship'],
                              lastContact: connection['lastContact'],
                              contactFrequency: connection['contactFrequency'],
                              priority: connection['priority'],
                              image: connection['image'],
                              onTap: () {
                                // TODO: Navigate to connection details
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final premiumStatusAsync = ref.watch(premiumStatusProvider);
          
          return premiumStatusAsync.when(
            data: (isPremium) {
              return FloatingActionButton(
                onPressed: () {
                  if (isPremium || _connections.length < 3) {
                    // TODO: Implement add connection
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add connection feature coming soon!')),
                    );
                  } else {
                    // Show premium upgrade dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Premium Feature'),
                        content: const Text(
                          'Free accounts are limited to 3 connections. Upgrade to premium to add unlimited connections and unlock advanced relationship management features.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Maybe Later'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
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
                    );
                  }
                },
                child: const Icon(Icons.add),
              );
            },
            loading: () => const FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
            error: (_, __) => FloatingActionButton(
              onPressed: () {
                // Default behavior if premium status can't be determined
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add connection feature coming soon!')),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
