import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('QUIVO: Notificación abierta en segundo plano: ${notificationResponse.payload}');
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'finanza_high_importance_channel';
  static const String _channelName = 'Notificaciones QUIVO';
  static const String _channelDesc =
      'Alertas de presupuesto, gastos, pagos de tarjetas, metas y recordatorios.';

  /// Inicializa el servicio de notificaciones y la zona horaria del dispositivo
  static Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;

    try {
      // 1. Inicializar base de datos de zonas horarias
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final String currentTimeZone = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        debugPrint('QUIVO Notificaciones: Zona horaria configurada con éxito -> $currentTimeZone');
      } catch (tzError) {
        debugPrint('QUIVO Notificaciones: Aviso zona horaria fallback: $tzError');
      }

      // 2. Configurar icono de Android y ajustes de iOS
      // Usamos @drawable/ic_notification (monocromático compatible con Android 5 al 15)
      const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false, // Solicitado explícitamente en UI
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('QUIVO: Acción en notificación local: ${response.payload}');
        },
        onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
      );

      // 3. Crear Canal de Notificación de Alta Importancia en Android con Vibración
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final vibrationPattern = Int64List.fromList([0, 300, 200, 300]);
        final androidChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          showBadge: true,
          enableLights: true,
          ledColor: const Color(0xFF06B6D4),
        );

        await androidImplementation.createNotificationChannel(androidChannel);
      }

      _initialized = true;
      debugPrint('QUIVO Notificaciones: LocalNotificationService inicializado correctamente.');
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error al inicializar LocalNotificationService: $e');
    }
  }

  /// Solicita los permisos nativos de notificación en Android (13+) e iOS
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    if (!_initialized) await init();

    try {
      bool granted = false;

      if (Platform.isAndroid) {
        final androidImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        // Solicitar POST_NOTIFICATIONS en Android 13+ (API 33+)
        final notifGranted =
            await androidImplementation?.requestNotificationsPermission() ?? false;

        // Solicitar permisos de alarmas exactas si es necesario
        try {
          await androidImplementation?.requestExactAlarmsPermission();
        } catch (_) {}

        // Validar también con permission_handler como respaldo
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final reqStatus = await Permission.notification.request();
          granted = reqStatus.isGranted || notifGranted;
        } else {
          granted = true;
        }
      } else if (Platform.isIOS) {
        final iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        final iosGranted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = iosGranted ?? false;
      }

      debugPrint('QUIVO Notificaciones: Permiso concedido = $granted');
      return granted;
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error al solicitar permisos: $e');
      return false;
    }
  }

  /// Verifica si las notificaciones están habilitadas en el sistema nativo
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final enabled =
            await androidImplementation?.areNotificationsEnabled() ?? false;
        return enabled;
      } else if (Platform.isIOS) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error verificando permisos: $e');
      return false;
    }
  }

  /// Muestra una notificación inmediata en el sistema nativo del teléfono
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    try {
      final vibrationPattern = Int64List.fromList([0, 300, 200, 300]);

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF06B6D4), // Cyan brillante de QUIVO
        enableLights: true,
        ledColor: const Color(0xFF06B6D4),
        ledOnMs: 1000,
        ledOffMs: 500,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: '<b>$title</b>',
          htmlFormatContentTitle: true,
          summaryText: 'QUIVO Finanzas',
          htmlFormatSummaryText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details, payload: payload);
      debugPrint('QUIVO Notificaciones: Notificación enviada -> "$title"');
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error mostrando notificación nativa: $e');
    }
  }

  /// Programa notificaciones diarias múltiples (ej. 9:00 am, 2:00 pm, 8:00 pm)
  static Future<void> scheduleDailyTransactionReminders() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      // 9:00 AM - Recordatorio matutino
      await _scheduleDailyTime(
        id: 1001,
        hour: 9,
        minute: 0,
        title: '¡Buenos días! 🌅🌱',
        body:
            'Todo gran ahorro empieza como una semilla. Registra tus movimientos de hoy en QUIVO.',
      );
      // 2:00 PM - Recordatorio del mediodía
      await _scheduleDailyTime(
        id: 1002,
        hour: 14,
        minute: 0,
        title: 'Buenas tardes ☀️🥑',
        body:
            '¿Almorzaste fuera? ¡Anota tus consumos para tener tu presupuesto bajo control!',
      );
      // 8:00 PM - Cierre del día y racha
      await _scheduleDailyTime(
        id: 1003,
        hour: 20,
        minute: 0,
        title: 'Cierre del día 🌙🔥',
        body:
            'No pierdas tu racha con SAMI. Revisa tus gastos antes de dormir y mantén tu disciplina.',
      );
      debugPrint('QUIVO Notificaciones: Recordatorios diarios programados con éxito.');
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error programando recordatorios diarios: $e');
    }
  }

  static Future<void> _scheduleDailyTime({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final vibrationPattern = Int64List.fromList([0, 300, 200, 300]);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: const Color(0xFF06B6D4),
      enableLights: true,
      ledColor: const Color(0xFF06B6D4),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: 'QUIVO Finanzas',
        htmlFormatSummaryText: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Intentar primero con exactAllowWhileIdle
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (exactErr) {
      debugPrint('QUIVO Notificaciones: Fallback a modo inexacto para recordatorio ($id): $exactErr');
      // Fallback a modo inexacto si el dispositivo no permite exact alarms
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Cancela los recordatorios diarios programados
  static Future<void> cancelDailyTransactionReminders() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(1001);
      await _plugin.cancel(1002);
      await _plugin.cancel(1003);
      debugPrint('QUIVO Notificaciones: Recordatorios diarios cancelados.');
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error cancelando recordatorios diarios: $e');
    }
  }

  /// Programa un recordatorio mensual para una fecha específica (corte o pago de tarjeta, deudas)
  static Future<void> scheduleMonthlyReminder({
    required int id,
    required int dayOfMonth,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    try {
      final now = tz.TZDateTime.now(tz.local);
      // Agendar a las 9:00 AM de ese día
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        dayOfMonth.clamp(1, 31),
        9,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        final maxDaysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final finalDay = dayOfMonth > maxDaysInNextMonth
            ? maxDaysInNextMonth
            : dayOfMonth;
        scheduledDate = tz.TZDateTime(
          tz.local,
          nextYear,
          nextMonth,
          finalDay,
          9,
          0,
        );
      }

      final vibrationPattern = Int64List.fromList([0, 300, 200, 300]);

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF06B6D4),
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      }
    } catch (e) {
      debugPrint('QUIVO Notificaciones: Error programando recordatorio mensual: $e');
    }
  }

  /// Cancela todas las notificaciones
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// Envía una notificación de prueba instantánea (con sonido y vibración)
  static Future<bool> sendTestNotification() async {
    if (kIsWeb) return false;
    final granted = await requestPermissions();
    if (!granted) return false;

    await showNotification(
      id: 99999,
      title: 'QUIVO Notificaciones 🔔✨',
      body:
          '¡Las notificaciones nativas y la vibración están activas y funcionando en tu teléfono!',
    );
    return true;
  }
}
