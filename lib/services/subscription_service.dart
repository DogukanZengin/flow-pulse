import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance => _instance ??= SubscriptionService._();
  
  SubscriptionService._();

  static const String _premiumKey = 'is_premium_user';
  bool _isPremium = false;
  SharedPreferences? _prefs;

  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs?.getBool(_premiumKey) ?? false;
    
    // Initialize RevenueCat (in production, you'd use real API keys)
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      // In production: await Purchases.configure(PurchasesConfiguration(apiKey));
      // For demo, we'll just use the local flag
    } catch (e) {
      // Handle RevenueCat initialization error
    }
  }

  Future<bool> checkPremiumStatus() async {
    try {
      // In production, you'd check with RevenueCat:
      // final customerInfo = await Purchases.getCustomerInfo();
      // final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
      
      // For demo, we'll use local storage
      return _isPremium;
    } catch (e) {
      return false;
    }
  }

  Future<bool> purchasePremium() async {
    try {
      // In production, you'd make the actual purchase:
      // final offerings = await Purchases.getOfferings();
      // final package = offerings.current?.monthly;
      // if (package != null) {
      //   await Purchases.purchasePackage(package);
      //   return await checkPremiumStatus();
      // }
      
      // For demo, we'll simulate a successful purchase
      _isPremium = true;
      await _prefs?.setBool(_premiumKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      // In production:
      // await Purchases.restorePurchases();
      // return await checkPremiumStatus();
      
      // For demo
      return _isPremium;
    } catch (e) {
      return false;
    }
  }

  // Demo method to toggle premium status for testing
  Future<void> togglePremiumForDemo() async {
    _isPremium = !_isPremium;
    await _prefs?.setBool(_premiumKey, _isPremium);
  }

  bool canAccessPremiumSound(String soundType) {
    // In production, you'd check against actual premium sound types
    return _isPremium || _isFreeSoundType(soundType);
  }

  bool _isFreeSoundType(String soundType) {
    const freeSounds = ['rain', 'forest', 'ocean', 'white_noise', 'brown_noise'];
    return freeSounds.contains(soundType);
  }

  String get premiumBenefitsText => '''
Premium Features:
• 25+ premium ambient sounds
• Advanced sound mixing & layering
• Premium animated themes
• Custom backgrounds
• Breathing exercises
• Enhanced achievements
• Priority support
''';

  String get pricingText => '''
Monthly: \$2.99/month
Yearly: \$19.99/year (Save 44%)
''';
}