import 'localization.dart';

/// Manejador centralizado de errores para toda la aplicación.
/// Garantiza que el usuario NUNCA vea códigos de error técnicos, errores de base de datos,
/// excepciones internas de Firebase/Firestore, stack traces o detalles de servidor.
class AppErrorHandler {
  /// Devuelve un mensaje de error amigable, limpio y seguro para el usuario.
  /// Si el error corresponde a una cancelación voluntaria por parte del usuario
  /// (como cerrar la ventana emergente de Google Sign-In), devuelve `null` para evitar
  /// mostrar mensajes de error molestos e innecesarios.
  static String? getFriendlyMessage(dynamic error, [AppLocalizations? loc]) {
    if (error == null) return null;
    final errStr = error.toString().toLowerCase();

    // 1. Cancelaciones voluntarias del usuario (no mostrar ningún error en pantalla)
    if (errStr.contains('popup-closed-by-user') ||
        errStr.contains('sign-in-cancelled') ||
        errStr.contains('user-cancelled') ||
        errStr.contains('canceled') ||
        errStr.contains('cancelled') ||
        errStr.contains('popup_closed') ||
        errStr.contains('user cancelled') ||
        errStr.contains('credential-already-in-use-by-current-user')) {
      return null;
    }

    // 2. Errores de credenciales / autenticación con explicación clara
    if (errStr.contains('wrong-password') ||
        errStr.contains('invalid-credential') ||
        errStr.contains('user-not-found') ||
        errStr.contains('invalid-login-credentials') ||
        errStr.contains('wrong password')) {
      return loc?.get('err_invalid_credentials') ??
          'Correo o contraseña incorrectos. Verifica tus datos.';
    }

    if (errStr.contains('email-already-in-use') ||
        errStr.contains('email-already-exists') ||
        errStr.contains('account-exists-with-different-credential')) {
      return loc?.get('err_email_in_use') ??
          'Este correo electrónico ya está registrado. Inicia sesión.';
    }

    if (errStr.contains('invalid-email')) {
      return loc?.get('err_invalid_email') ??
          'El formato del correo electrónico no es válido.';
    }

    if (errStr.contains('weak-password')) {
      return loc?.get('err_weak_password') ??
          'La contraseña debe tener al menos 6 caracteres.';
    }

    if (errStr.contains('network-request-failed') ||
        errStr.contains('socketexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('clientexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('network') ||
        errStr.contains('timeout')) {
      return loc?.get('err_network') ??
          'Problema de conexión. Verifica tu internet e inténtalo de nuevo.';
    }

    if (errStr.contains('too-many-requests')) {
      return loc?.get('err_too_many_requests') ??
          'Demasiados intentos. Espera unos momentos antes de reintentar.';
    }

    if (errStr.contains('user-disabled')) {
      return loc?.get('err_user_disabled') ??
          'Esta cuenta ha sido inhabilitada. Contacta a soporte.';
    }

    // 3. Cualquier error de Base de Datos, Firestore, SQL, Excepciones internas o desconocidas
    return loc?.get('err_generic_server') ??
        'Ha ocurrido un inconveniente inesperado. Por favor, intenta de nuevo.';
  }

  /// Limpia y filtra cualquier texto de error para asegurar que no contenga sintaxis técnica
  /// de base de datos o excepciones antes de presentarse en la UI.
  static String sanitize(String message, [AppLocalizations? loc]) {
    final lower = message.toLowerCase();
    if (lower.contains('firebase') ||
        lower.contains('firestore') ||
        lower.contains('exception') ||
        lower.contains('error:') ||
        lower.contains('code:') ||
        lower.contains('null check') ||
        lower.contains('type \'') ||
        lower.contains('stack trace') ||
        lower.contains('unhandled') ||
        lower.contains('database') ||
        lower.contains('sql') ||
        (lower.contains('[') && lower.contains(']'))) {
      return getFriendlyMessage(message, loc) ??
          (loc?.get('err_generic_server') ??
              'Ha ocurrido un inconveniente inesperado. Por favor, intenta de nuevo.');
    }
    return message;
  }
}
