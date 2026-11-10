import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseOutcome {
  final bool success;
  final bool cancelled;
  final bool isSimulated;
  final String? errorMessage;

  const PurchaseOutcome({
    required this.success,
    this.cancelled = false,
    this.isSimulated = false,
    this.errorMessage,
  });
}

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  /// Claves públicas de RevenueCat (pueden pasarse por `--dart-define` o reemplazarse aquí).
  static const String _appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'appl_YOUR_APPLE_API_KEY',
  );
  static const String _googleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: 'goog_YOUR_GOOGLE_API_KEY',
  );

  /// Identificador del Entitlement configurado en el panel de RevenueCat.
  static const String entitlementId = 'premium';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Verifica si la plataforma actual es móvil nativa (Android / iOS) y tiene una API Key real.
  bool get hasConfiguredNativeStore {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return _googleApiKey.isNotEmpty &&
          !_googleApiKey.contains('YOUR_GOOGLE_API_KEY');
    }
    if (Platform.isIOS) {
      return _appleApiKey.isNotEmpty &&
          !_appleApiKey.contains('YOUR_APPLE_API_KEY');
    }
    return false;
  }

  Future<void> initialize({String? appUserId}) async {
    if (kIsWeb || _isInitialized) return;
    if (!hasConfiguredNativeStore) {
      debugPrint(
        '[RevenueCat] Usando modo sandbox/simulado (claves de tienda aún no configuradas).',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey)
          ..appUserID = appUserId;
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey)
          ..appUserID = appUserId;
      } else {
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('[RevenueCat] Inicializado correctamente.');
    } catch (e) {
      debugPrint('[RevenueCat] Error inicializando RevenueCat: $e');
    }
  }

  /// Vincula el UID de Firebase Auth con el cliente de RevenueCat.
  Future<bool> logIn(String uid) async {
    if (!_isInitialized || kIsWeb) return false;
    try {
      final result = await Purchases.logIn(uid);
      return result.customerInfo.entitlements.all[entitlementId]?.isActive ??
          false;
    } catch (e) {
      debugPrint('[RevenueCat] Error en logIn: $e');
      return false;
    }
  }

  /// Cierra la sesión de RevenueCat al cerrar sesión en la app.
  Future<void> logOut() async {
    if (!_isInitialized || kIsWeb) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[RevenueCat] Error en logOut: $e');
    }
  }

  /// Verifica si el usuario tiene una suscripción activa en Google Play / App Store.
  Future<bool> hasActiveSubscription() async {
    if (!_isInitialized || kIsWeb) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('[RevenueCat] Error consultando suscripción activa: $e');
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_isInitialized || kIsWeb) return [];
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('[RevenueCat] Error obteniendo paquetes: $e');
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized || kIsWeb) return false;
    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      final isPro =
          purchaseResult
              .customerInfo
              .entitlements
              .all[entitlementId]
              ?.isActive ??
          false;
      return isPro;
    } catch (e) {
      debugPrint('[RevenueCat] Error realizando compra: $e');
      return false;
    }
  }

  /// Flujo completo de compra de QUIVO Premium ($0.99/mes):
  /// - En Android/iOS con claves configuradas: abre la pasarela nativa de Google Play / App Store.
  /// - En Web / Desktop o modo Debug sin claves de tienda: simula la pasarela para pruebas.
  Future<PurchaseOutcome> purchasePremium() async {
    if (_isInitialized && !kIsWeb) {
      try {
        final packages = await getOfferings();
        if (packages.isEmpty) {
          return const PurchaseOutcome(
            success: false,
            errorMessage:
                'No se encontraron planes disponibles en la tienda en este momento.',
          );
        }

        // Priorizar paquete mensual ($rc_monthly) o tomar el primero disponible
        final monthlyPackage = packages.firstWhere(
          (p) => p.packageType == PackageType.monthly,
          orElse: () => packages.first,
        );

        final purchaseResult = await Purchases.purchase(
          PurchaseParams.package(monthlyPackage),
        );
        final isPro =
            purchaseResult
                .customerInfo
                .entitlements
                .all[entitlementId]
                ?.isActive ??
            false;

        return PurchaseOutcome(
          success: isPro,
          errorMessage: isPro
              ? null
              : 'La compra no activó el plan Premium. Intenta restaurar tus compras.',
        );
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('cancel') ||
            errStr.contains('purchasecancellederror')) {
          return const PurchaseOutcome(success: false, cancelled: true);
        }
        return PurchaseOutcome(
          success: false,
          errorMessage: 'Error al procesar el pago en la tienda: $e',
        );
      }
    }

    // Modo Simulado (Web / Windows / Debug sin claves de RevenueCat aún)
    await Future.delayed(const Duration(milliseconds: 900));
    return const PurchaseOutcome(success: true, isSimulated: true);
  }

  Future<bool> restorePurchases() async {
    if (!_isInitialized || kIsWeb) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('[RevenueCat] Error restaurando compras: $e');
      return false;
    }
  }
}
