import '../../domain/repositories/transaction_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_analysis_service.dart';
import '../../presentation/providers/transaction_provider.dart';
import 'local_notification_service.dart';
import '../helpers/tts_helper.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../presentation/widgets/modals/voice_expense_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
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
          await TtsHelper.configureTts(tts, 'es');
          await tts.speak('Para registrar gastos con Siri, necesitas ser usuario Premium en QUIVO.');
          return;
        }
        
        final spokenText = call.arguments is String ? call.arguments as String : (call.arguments is Map ? call.arguments['text'] : null);
        
        if (spokenText != null && spokenText.isNotEmpty) {
           // Siri automatically passed the text! Let's analyze and insert.
           try {
             final tts = FlutterTts();
             await TtsHelper.configureTts(tts, 'es');
             
             final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
             final transaction = await AIAnalysisService.analyzeVoiceTransaction(spokenText, uid);
             if (transaction != null) {
                ref.read(transactionRepositoryProvider).addTransaction(transaction);
                await tts.speak('Listo, he registrado el ${transaction.type.name} de ${transaction.amount} en ${transaction.description}.');
                await LocalNotificationService.showNotification(
                  title: '✅ Transacción agregada por Siri',
                  body: 'Se añadió ${transaction.amount} en ${transaction.description}.',
                );
             } else {
                await tts.speak('No pude entender el monto o los detalles, intenta de nuevo.');
             }
           } catch (e) {
             print('Siri processing error: $e');
           }
        } else {
           // Fallback to manual UI if no text was provided
           if (context.mounted) {
             VoiceExpenseModal.show(context);
           }
        }
      }
    });
  }
}
