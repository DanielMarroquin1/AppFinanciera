import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Inicializa el servicio de notificaciones locales para Android e iOS
  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Acción en notificación local: ${response.payload}');
        },
      );

      // Crear canal de alta importancia en Android
      const androidChannel = AndroidNotificationChannel(
        'finanza_high_importance_channel',
        'Notificaciones Finanza',
        description: 'Alertas de presupuesto, rachas, recordatorios y transacciones.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(androidChannel);
      await androidImplementation?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('Error al inicializar LocalNotificationService: $e');
    }
  }

  /// Muestra una notificación inmediata en el sistema nativo del teléfono
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    if (kIsWeb) return; // En Web usamos in-app snakbars/modales
    if (!_initialized) await init();

    try {
      final androidDetails = AndroidNotificationDetails(
        'finanza_high_importance_channel',
        'Notificaciones Finanza',
        channelDescription: 'Alertas de presupuesto, rachas, recordatorios y transacciones.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF3B82F6), // Azul premium para el acento de la notificación
        enableLights: true,
        ledColor: const Color(0xFF3B82F6),
        ledOnMs: 1000,
        ledOffMs: 500,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: '<b>$title</b>',
          htmlFormatContentTitle: true,
          summaryText: 'Finanzas Personales',
          htmlFormatSummaryText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _plugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error mostrando notificación del sistema: $e');
    }
  }

  /// Programa notificaciones diarias múltiples (ej. 8am, 2pm, 8pm)
  static Future<void> scheduleDailyTransactionReminders() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      // 8 AM
      await _scheduleDailyTime(id: 1001, hour: 8, minute: 0, title: 'Buenos días 🌅', body: '¿Ya registraste tus gastos de la mañana? ¡Mantén tu presupuesto al día!');
      // 2 PM
      await _scheduleDailyTime(id: 1002, hour: 14, minute: 0, title: 'Buenas tardes ☀️', body: 'Recuerda registrar cualquier gasto del almuerzo en la app.');
      // 8 PM
      await _scheduleDailyTime(id: 1003, hour: 20, minute: 0, title: 'Buenas noches 🌙', body: 'Antes de dormir, asegúrate de que todos tus movimientos del día estén registrados.');
    } catch (e) {
      debugPrint('Error programando recordatorios diarios: $e');
    }
  }

  static Future<void> _scheduleDailyTime({required int id, required int hour, required int minute, required String title, required String body}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails('finanza_high_importance_channel', 'Notificaciones Finanza', importance: Importance.max, priority: Priority.high);
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.zonedSchedule(id, title, body, scheduledDate, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
  }

  /// Programa un recordatorio mensual para una fecha específica (ej. pago de tarjeta, deudas)
  static Future<void> scheduleMonthlyReminder({required int id, required int dayOfMonth, required String title, required String body}) async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      final now = tz.TZDateTime.now(tz.local);
      // Agendar a las 9 AM de ese día
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, dayOfMonth, 9, 0);
      if (scheduledDate.isBefore(now)) {
        // Si la fecha ya pasó este mes, pasarlo al mes siguiente
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        // Evitar días inválidos como 31 de Febrero
        final maxDaysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final finalDay = dayOfMonth > maxDaysInNextMonth ? maxDaysInNextMonth : dayOfMonth;
        scheduledDate = tz.TZDateTime(tz.local, nextYear, nextMonth, finalDay, 9, 0);
      }
      const androidDetails = AndroidNotificationDetails('finanza_high_importance_channel', 'Notificaciones Finanza', importance: Importance.max, priority: Priority.high);
      const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
      await _plugin.zonedSchedule(id, title, body, scheduledDate, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
    } catch (e) {
      debugPrint('Error programando recordatorio mensual: $e');
    }
  }

  /// Programa una notificación diaria (ej. recordatorio de racha a las 8 PM)
  static Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'finanza_high_importance_channel',
        'Notificaciones Finanza',
        importance: Importance.max,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error programando recordatorio diario: $e');
    }
  }

  /// Cancela una notificación o todas
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
