import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../presentation/widgets/modals/voice_expense_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SiriShortcutsService {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_app/siri_shortcuts');
  static bool _initialized = false;

  static Future<bool> registerSiriShortcuts() async {
    if (!Platform.isIOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('registerShortcuts', {
        'shortcuts': [
          {'identifier': 'com.example.flutter_app.addExpense', 'title': 'Registrar Gasto', 'suggestedPhrase': 'Registrar gasto'}
        ]
      });
      return result ?? true;
    } catch (e) {
      return false;
    }
  }

  static void initialize(BuildContext context, WidgetRef ref) {
    if (_initialized) return;
    _initialized = true;
    
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'handleSiriIntent') {
        final user = ref.read(authProvider).user;
        if (user == null) return;
        
        if (!user.isPremium) {
          final tts = FlutterTts();
          await tts.setLanguage('es-US');
          await tts.speak('Para registrar gastos con Siri, necesitas ser usuario Premium en QUIVO.');
          return;
        }
        
        if (context.mounted) {
          VoiceExpenseModal.show(context);
        }
      }
    });
  }
}
