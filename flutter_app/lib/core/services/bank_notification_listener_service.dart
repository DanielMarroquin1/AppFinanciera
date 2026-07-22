import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'local_notification_service.dart';
import '../../presentation/providers/auth_provider.dart';

class ParsedBankCharge {
  final String id;
  final double amount;
  final String merchant;
  final String paymentMethod; // 'cash' (debito) or 'credit_card'
  final String category;
  final DateTime date;
  final String rawText;
  final String? bankName;

  ParsedBankCharge({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.paymentMethod,
    required this.category,
    required this.date,
    required this.rawText,
    this.bankName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'merchant': merchant,
    'paymentMethod': paymentMethod,
    'category': category,
    'date': date.toIso8601String(),
    'rawText': rawText,
    'bankName': bankName,
  };

  factory ParsedBankCharge.fromJson(Map<String, dynamic> json) => ParsedBankCharge(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    merchant: json['merchant'] ?? 'Comercio General',
    paymentMethod: json['paymentMethod'] ?? 'credit_card',
    category: json['category'] ?? 'general',
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    rawText: json['rawText'] ?? '',
    bankName: json['bankName'],
  );
}

class BankNotificationListenerService {
  static const String _prefsKey = 'pending_bank_charges_v1';

  /// Verifica si el permiso de lector de notificaciones en Android está activo
  static Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return false;
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      print('Error checking notification listener permission: $e');
      return false;
    }
  }

  /// Solicita el permiso de lectura de notificaciones (abre ajustes de Android)
  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await NotificationListenerService.requestPermission();
    } catch (e) {
      print('Error requesting notification listener permission: $e');
    }
  }

  /// Escucha notificaciones en segundo plano/primer plano si el usuario es Premium
  static void startListening(WidgetRef ref) {
    if (!Platform.isAndroid) return;
    try {
      NotificationListenerService.notificationsStream.listen((ServiceNotificationEvent event) {
        _handleIncomingEvent(event, ref);
      });
    } catch (e) {
      print('Error starting bank notification stream: $e');
    }
  }

  static Future<void> _handleIncomingEvent(ServiceNotificationEvent event, WidgetRef ref) async {
    final user = ref.read(authProvider).user;
    if (user == null || !user.isPremium) return; // Función exclusiva para Plan Premium

    final title = event.title ?? '';
    final content = event.content ?? '';
    final packageName = event.packageName ?? '';
    final fullText = '$title $content'.toLowerCase();

    // Palabras clave bancarias o financieras
    final isFinancial = fullText.contains('compra') ||
        fullText.contains('cargo') ||
        fullText.contains('pago') ||
        fullText.contains('tarjeta') ||
        fullText.contains('débito') ||
        fullText.contains('debito') ||
        fullText.contains('crédito') ||
        fullText.contains('credito') ||
        fullText.contains('aprobado') ||
        fullText.contains('\$') ||
        packageName.contains('bank') ||
        packageName.contains('bancomer') ||
        packageName.contains('bbva') ||
        packageName.contains('santander') ||
        packageName.contains('banamex') ||
        packageName.contains('nu') ||
        packageName.contains('bac') ||
        packageName.contains('bi') ||
        packageName.contains('amex') ||
        packageName.contains('paypal');

    if (!isFinancial) return;

    final parsed = parseText(title, content, packageName);
    if (parsed != null && parsed.amount > 0) {
      await addPendingCharge(parsed);

      if (parsed.paymentMethod == 'cash') {
        // Tarjeta de Débito -> Se va a efectivo
        await LocalNotificationService.showNotification(
          title: '💸 Cargo Débito detectado (\${parsed.amount.toStringAsFixed(2)})',
          body: 'En \${parsed.merchant}. Se registró como gasto en Efectivo/Débito. Toca para ver en la app.',
          payload: 'sync_bank_charge_\${parsed.id}',
        );
      } else {
        // Tarjeta de Crédito -> Notificar para elegir a qué TC agregarlo
        await LocalNotificationService.showNotification(
          title: '💳 Cargo en Tarjeta de Crédito (\${parsed.amount.toStringAsFixed(2)})',
          body: 'En \${parsed.merchant}. Toca aquí para elegir a cuál de tus Tarjetas de Crédito agregar este gasto.',
          payload: 'sync_bank_charge_\${parsed.id}',
        );
      }
    }
  }

  /// Analizador de texto de notificaciones bancarias
  static ParsedBankCharge? parseText(String title, String body, String? packageName) {
    final combined = '$title $body';
    final lower = combined.toLowerCase();

    // 1. Extraer Monto
    double amount = 0.0;
    final amountRegExp = RegExp(r'\$?\s?([0-9]{1,6}(?:[\.,][0-9]{3})*(?:[\.,][0-9]{2}))');
    final matches = amountRegExp.allMatches(combined);
    for (var m in matches) {
      final rawNum = m.group(1)?.replaceAll(',', '') ?? '0';
      final val = double.tryParse(rawNum);
      if (val != null && val > 0) {
        amount = val;
        break;
      }
    }
    if (amount <= 0) return null;

    // 2. Extraer Comercio (después de "en ", "comercio ", "compra en ", "pago a ")
    String merchant = 'Comercio General';
    final merchantRegExp = RegExp(r'(?:en|comercio|compra en|pago a|establecimiento)\s+([A-Za-z0-9\s&\.\-_]{3,25})', caseSensitive: false);
    final mMatch = merchantRegExp.firstMatch(combined);
    if (mMatch != null) {
      final found = mMatch.group(1)?.trim() ?? '';
      if (found.isNotEmpty) merchant = found;
    } else {
      // Si no hay prefijo "en", tomar las palabras más significativas del título o cuerpo
      if (title.length > 3 && !title.toLowerCase().contains('notificación')) {
        merchant = title;
      }
    }

    // 3. Determinar Débito vs Crédito
    // Daniel: "si es tarjeta de debito (se va a efectivo), si es tarjeta de credito se va al apartado de la TC"
    String paymentMethod = 'credit_card';
    if (lower.contains('débito') ||
        lower.contains('debito') ||
        lower.contains('debit') ||
        lower.contains('efectivo') ||
        lower.contains('cajero') ||
        lower.contains('cheques') ||
        lower.contains('ahorro')) {
      paymentMethod = 'cash';
    } else if (lower.contains('crédito') ||
        lower.contains('credito') ||
        lower.contains('credit') ||
        lower.contains('tc') ||
        lower.contains('visa') ||
        lower.contains('mastercard') ||
        lower.contains('amex')) {
      paymentMethod = 'credit_card';
    }

    // 4. Determinar Categoría sugerida según comercio
    String category = 'general';
    final mLower = merchant.toLowerCase();
    if (mLower.contains('super') || mLower.contains('walmart') || mLower.contains('costco') || mLower.contains('soriana') || mLower.contains('oxxo') || mLower.contains('heb') || mLower.contains('mercadona')) {
      category = 'groceries';
    } else if (mLower.contains('rest') || mLower.contains('burger') || mLower.contains('pizza') || mLower.contains('starbucks') || mLower.contains('cafe') || mLower.contains('mcdonald') || mLower.contains('taco')) {
      category = 'food';
    } else if (mLower.contains('uber') || mLower.contains('didi') || mLower.contains('gas') || mLower.contains('pemex') || mLower.contains('shell') || mLower.contains('bp') || mLower.contains('taxi')) {
      category = 'transport';
    } else if (mLower.contains('cine') || mLower.contains('netflix') || mLower.contains('spotify') || mLower.contains('disney') || mLower.contains('prime') || mLower.contains('hbo')) {
      category = 'entertainment';
    } else if (mLower.contains('farmacia') || mLower.contains('doctor') || mLower.contains('hospital') || mLower.contains('salud') || mLower.contains('med')) {
      category = 'health';
    } else if (mLower.contains('zar') || mLower.contains('hm') || mLower.contains('nike') || mLower.contains('adidas') || mLower.contains('ropa') || mLower.contains('mall')) {
      category = 'shopping';
    }

    // Identificar banco por packageName o texto
    String? bankName;
    if (packageName != null && packageName.isNotEmpty) {
      if (packageName.contains('bbva')) bankName = 'BBVA';
      else if (packageName.contains('santander')) bankName = 'Santander';
      else if (packageName.contains('banamex')) bankName = 'Citibanamex';
      else if (packageName.contains('nu')) bankName = 'Nu';
      else if (packageName.contains('bac')) bankName = 'BAC Credomatic';
      else if (packageName.contains('bi')) bankName = 'Banco Industrial';
      else if (packageName.contains('amex')) bankName = 'American Express';
    }
    if (bankName == null) {
      if (lower.contains('bbva')) bankName = 'BBVA';
      else if (lower.contains('santander')) bankName = 'Santander';
      else if (lower.contains('banamex')) bankName = 'Citibanamex';
      else if (lower.contains('nu ')) bankName = 'Nu';
      else if (lower.contains('bac')) bankName = 'BAC';
      else if (lower.contains('banco industrial') || lower.contains('bi ')) bankName = 'Banco Industrial';
    }

    return ParsedBankCharge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      merchant: merchant,
      paymentMethod: paymentMethod,
      category: category,
      date: DateTime.now(),
      rawText: combined,
      bankName: bankName ?? 'Banco / App Financiera',
    );
  }

  /// Gestiona la persistencia de cargos pendientes en SharedPreferences
  static Future<void> addPendingCharge(ParsedBankCharge charge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getStringList(_prefsKey) ?? [];
      listStr.insert(0, jsonEncode(charge.toJson()));
      await prefs.setStringList(_prefsKey, listStr);
    } catch (e) {
      print('Error saving pending bank charge: $e');
    }
  }

  static Future<List<ParsedBankCharge>> getPendingCharges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getStringList(_prefsKey) ?? [];
      return listStr.map((s) => ParsedBankCharge.fromJson(jsonDecode(s))).toList();
    } catch (e) {
      print('Error reading pending bank charges: $e');
      return [];
    }
  }

  static Future<void> removePendingCharge(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getStringList(_prefsKey) ?? [];
      listStr.removeWhere((s) {
        final map = jsonDecode(s);
        return map['id'] == id;
      });
      await prefs.setStringList(_prefsKey, listStr);
    } catch (e) {
      print('Error removing pending bank charge: $e');
    }
  }
}
