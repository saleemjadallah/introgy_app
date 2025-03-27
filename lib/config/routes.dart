import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/auth_callback_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/social_battery/presentation/screens/social_battery_screen.dart';
import '../features/wellbeing/presentation/screens/wellbeing_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/profile_edit_screen.dart';
import '../features/connection_builder/presentation/screens/connection_builder_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../shared/presentation/screens/not_found_screen.dart';
import '../shared/presentation/widgets/main_scaffold.dart';

/// Router provider used to access the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirect logic based on authentication state
      final isAuthenticated = authState.user != null;
      final isAuthRoute = state.uri.path == '/auth';
      final isCallbackRoute = state.uri.path == '/auth/callback';
      final isOnboardingRoute = state.uri.path == '/onboarding';
      
      // Special case for auth callback - always allow
      if (isCallbackRoute) return null;
      
      // If user is logged in but on auth screen, redirect to home
      if (isAuthenticated && isAuthRoute) return '/';
      
      // If user is logged in and needs onboarding, go to onboarding
      if (isAuthenticated && authState.needsOnboarding && !isOnboardingRoute) {
        return '/onboarding';
      }
      
      // If user is not logged in and not on auth screen, redirect to auth
      if (!isAuthenticated && !isAuthRoute) return '/auth';
      
      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => AuthCallbackScreen(
          uri: state.uri,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Premium screen
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Home (Social Battery screen)
          GoRoute(
            path: '/',
            builder: (context, state) => const SocialBatteryScreen(),
          ),
          
          // Connection Builder
          GoRoute(
            path: '/connection-builder',
            builder: (context, state) => const ConnectionBuilderScreen(),
          ),
          
          // Wellbeing
          GoRoute(
            path: '/wellbeing',
            builder: (context, state) => const WellbeingScreen(),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Profile Edit
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditScreen(),
              ),
              // Profile Notifications
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const Scaffold(
                  appBar: AppBar(title: Text('Notifications')),
                  body: Center(child: Text('Notifications settings coming soon')),
                ),
              ),
              // Profile Privacy
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const Scaffold(
                  appBar: AppBar(title: Text('Privacy')),
                  body: Center(child: Text('Privacy settings coming soon')),
                ),
              ),
              // Profile Settings
              GoRoute(
                path: 'settings',
                builder: (context, state) => const Scaffold(
                  appBar: AppBar(title: Text('Settings')),
                  body: Center(child: Text('Settings coming soon')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
