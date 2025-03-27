import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.battery_full),
            label: 'Social Battery',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Connection Builder',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa),
            label: 'Wellbeing',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location;
    
    if (location.startsWith('/')) {
      if (location == '/') return 0;
      if (location.startsWith('/connection-builder')) return 1;
      if (location.startsWith('/wellbeing')) return 2;
      if (location.startsWith('/profile')) return 3;
    }
    
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/connection-builder');
        break;
      case 2:
        GoRouter.of(context).go('/wellbeing');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
