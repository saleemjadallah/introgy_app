import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the premium service
final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

/// Provider for the current premium status
final premiumStatusProvider = StateNotifierProvider<PremiumStatusNotifier, AsyncValue<bool>>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return PremiumStatusNotifier(premiumService);
});

/// Notifier for premium status
class PremiumStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  final PremiumService _premiumService;

  PremiumStatusNotifier(this._premiumService) : super(const AsyncValue.loading()) {
    _initPremiumStatus();
  }

  Future<void> _initPremiumStatus() async {
    try {
      final isPremium = await _premiumService.isPremium();
      state = AsyncValue.data(isPremium);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshPremiumStatus() async {
    await _initPremiumStatus();
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      await _premiumService.setPremiumStatus(isPremium);
      state = AsyncValue.data(isPremium);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Service for handling premium features
class PremiumService {
  static const String _premiumKey = 'is_premium_user';

  /// Check if the user has premium access
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  /// Set the premium status
  Future<void> setPremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
  }

  /// Get the list of premium features
  List<String> getPremiumFeatures() {
    return [
      'Unlimited AI-generated wellbeing tips',
      'Advanced social battery analytics',
      'Custom connection categories',
      'Personalized wellbeing insights',
      'Priority support',
      'Ad-free experience',
      'Dark theme',
      'Data export',
    ];
  }

  /// Get premium subscription options
  List<Map<String, dynamic>> getSubscriptionOptions() {
    return [
      {
        'id': 'monthly',
        'name': 'Monthly',
        'price': 4.99,
        'period': 'month',
        'description': 'Billed monthly',
      },
      {
        'id': 'annual',
        'name': 'Annual',
        'price': 39.99,
        'period': 'year',
        'description': 'Billed annually (Save 33%)',
        'isBestValue': true,
      },
      {
        'id': 'lifetime',
        'name': 'Lifetime',
        'price': 99.99,
        'period': 'one-time',
        'description': 'One-time payment',
      },
    ];
  }
}
