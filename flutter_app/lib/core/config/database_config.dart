import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuración centralizada de la base de datos Firestore para separar
/// el entorno de Desarrollo/Pruebas (`dev`) del entorno de Producción (`prod`).
///
/// Soporta dos estrategias de aislamiento dentro del proyecto `zentai-9b38a`:
/// 1. **Aislamiento por Prefijo de Colección (`prod_*`)**: Funciona de inmediato
///    en el plan gratuito (Spark) de Firebase sin requerir facturación Blaze.
///    En producción usa `prod_users`, `prod_transactions`, `prod_debts`,
///    `prod_notifications` y `prod_mail`.
/// 2. **Segunda Base de Datos con Nombre (`databaseId: 'production'`)**:
///    Al activar el plan Blaze en Firebase y crear la base de datos `production`,
///    basta con pasar `--dart-define=USE_NAMED_DB=true` o cambiar [useNamedDatabase]
///    a `true` para conectarse a `projects/zentai-9b38a/databases/production`.
class DatabaseConfig {
  DatabaseConfig._();

  /// Define el entorno actual via `--dart-define=ENV=prod` o `--dart-define=ENV=dev`.
  /// Si no se especifica, usa `'prod'` automáticamente en compilaciones Release (`kReleaseMode`)
  /// y `'dev'` en modo Debug.
  static const String _envDefine = String.fromEnvironment('ENV', defaultValue: '');

  /// Permite forzar el entorno en tiempo de ejecución si es necesario.
  static bool? _runtimeProdOverride;

  /// Si es `true`, en modo Release (`flutter build apk --release`) usa automáticamente
  /// la base de datos de producción.
  static const bool useProdInRelease = true;

  /// Si es `true`, conecta a la base de datos con nombre `'production'` de Firestore
  /// (requiere Plan Blaze en Firebase). Si es `false`, aísla producción usando
  /// colecciones prefijadas (`prod_users`, `prod_transactions`, etc.) compatible con Plan Spark.
  static const bool useNamedDatabase = bool.fromEnvironment(
    'USE_NAMED_DB',
    defaultValue: false,
  );

  /// Nombre de la base de datos de producción cuando [useNamedDatabase] es `true`.
  static const String productionDatabaseId = 'production';

  /// Indica si la app está corriendo apuntando a la base de datos de Producción.
  static bool get isProduction {
    if (_runtimeProdOverride != null) return _runtimeProdOverride!;
    if (_envDefine.isNotEmpty) {
      return _envDefine.toLowerCase() == 'prod' ||
          _envDefine.toLowerCase() == 'production';
    }
    return kReleaseMode && useProdInRelease;
  }

  /// Permite cambiar entre Desarrollo y Producción en caliente si se requiere.
  static void setEnvironment({required bool isProd}) {
    _runtimeProdOverride = isProd;
  }

  /// Etiqueta legible del entorno actual (`PRODUCCIÓN` o `DESARROLLO`).
  static String get environmentLabel => isProduction ? 'PRODUCCIÓN' : 'DESARROLLO';

  /// Instancia de [FirebaseFirestore] correspondiente al entorno actual.
  static FirebaseFirestore get firestore {
    if (isProduction && useNamedDatabase) {
      return FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: productionDatabaseId,
      );
    }
    return FirebaseFirestore.instance;
  }

  /// Resuelve el nombre de una colección raíz según el entorno activo.
  /// En producción (cuando [useNamedDatabase] es `false`), usa el prefijo `prod_`.
  static String collectionName(String baseName) {
    if (isProduction && !useNamedDatabase) {
      return 'prod_$baseName';
    }
    return baseName;
  }

  /// Obtiene la referencia a una colección raíz aplicando el aislamiento de entorno.
  static CollectionReference<Map<String, dynamic>> collection(String baseName) {
    return firestore.collection(collectionName(baseName));
  }

  /// Colección de usuarios (`users` en dev / `prod_users` en prod).
  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      collection('users');

  /// Colección de transacciones (`transactions` en dev / `prod_transactions` en prod).
  static CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      collection('transactions');

  /// Colección de deudas (`debts` en dev / `prod_debts` en prod).
  static CollectionReference<Map<String, dynamic>> get debtsCollection =>
      collection('debts');

  /// Colección de notificaciones (`notifications` en dev / `prod_notifications` en prod).
  static CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      collection('notifications');

  /// Colección de correos salientes (`mail` en dev / `prod_mail` en prod).
  static CollectionReference<Map<String, dynamic>> get mailCollection =>
      collection('mail');
}

