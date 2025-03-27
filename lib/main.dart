import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/routes.dart';
import 'config/theme.dart';

// Global references
final navigatorKey = GlobalKey<NavigatorState>();
late final SharedPreferences sharedPreferences;

// Entry point for the app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize SharedPreferences for local storage
  sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gnvlzzqtmxrfvkdydxet.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdudmx6enF0bXhyZnZrZHlkeGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY3OTc0MzYsImV4cCI6MjAzMjM3MzQzNn0.HQ5HBgHzL0T1PBOESlZr0KvY3R8A9fhBJsH3KNB2bH8',
    debug: true,  // Set to false in production
    authFlowType: AuthFlowType.pkce, // For secure authentication flow
  );

  // Run app wrapped with Riverpod for state management
  runApp(const ProviderScope(child: IntropyApp()));
}

class IntropyApp extends ConsumerWidget {
  const IntropyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get router configuration
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Introgy',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Default to system preference
      navigatorKey: navigatorKey,
    );
  }
}
