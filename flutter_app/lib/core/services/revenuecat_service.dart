import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // TODO: Daniel debe reemplazar estas claves con sus API Keys reales de RevenueCat
  final String _appleApiKey = 'appl_YOUR_APPLE_API_KEY';
  final String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return; // RevenueCat no soporta Web oficialmente así
    
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else {
        return;
      }
      
      await Purchases.configure(configuration);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando RevenueCat: $e');
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_isInitialized) return [];
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('Error obteniendo paquetes: $e');
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      // Validar si la compra otorgó el "Entitlement" premium (ejemplo: 'premium')
      final isPro = customerInfo.entitlements.all['premium']?.isActive ?? false;
      return isPro;
    } catch (e) {
      debugPrint('Error realizando compra: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      debugPrint('Error restaurando compras: $e');
      return false;
    }
  }
}
