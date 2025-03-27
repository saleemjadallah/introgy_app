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
  
  // Initialize Supabase with credentials from .env file
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
