import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/config/ai_config.dart';
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/transaction.dart' as entity;
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';

class VoiceExpenseModal extends ConsumerStatefulWidget {
  const VoiceExpenseModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const VoiceExpenseModal(),
    );
  }

  @override
  ConsumerState<VoiceExpenseModal> createState() => _VoiceExpenseModalState();
}

class _VoiceExpenseModalState extends ConsumerState<VoiceExpenseModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isDone = false;
  String _recognizedText = '';
  double _parsedAmount = 0.0;
  String _parsedCategory = 'other';
  String _parsedDescription = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speechToText.initialize(
        onError: (errorNotification) {
          setState(() {
            _isListening = false;
            _errorMessage = 'Error de micrófono: ${errorNotification.errorMsg}';
          });
        },
      );
    } catch (e) {
      // Handle init error
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isDone) {
      Navigator.of(context).pop();
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _processText();
    } else {
      // Request permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setState(() => _errorMessage = 'Permiso de micrófono denegado');
        return;
      }

      final available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _errorMessage = '';
          _recognizedText = '';
        });
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
            if (result.finalResult) {
              setState(() => _isListening = false);
              _processText();
            }
          },
          localeId: 'es_ES',
        );
      } else {
        setState(() => _errorMessage = 'Reconocimiento de voz no disponible en este dispositivo');
      }
    }
  }

  void _processText() async {
    if (_recognizedText.isEmpty) return;

    setState(() => _isProcessing = true);

    // Try using Gemini AI for extraction
    try {
      if (AIConfig.apiKey.isNotEmpty) {
        final model = GenerativeModel(
          model: AIConfig.modelName,
          apiKey: AIConfig.apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );
        
        final prompt = '''
Analiza este gasto dictado por el usuario: "$_recognizedText"
Extrae la información en el siguiente formato JSON estricto:
{
  "amount": número decimal (ej. 15.5),
  "category": "string exacto de la categoría"
}

Categorías permitidas (USA EXACTAMENTE ESTOS VALORES EN INGLÉS COMO APARECEN AQUÍ):
- Comida: food (General), food_grocery (Supermercado), food_restaurant (Restaurante), food_coffee (Cafetería), food_delivery (Delivery)
- Transporte: transport (General), transport_gas (Gasolina), transport_public (Público), transport_taxi (Taxi/Uber), transport_flight (Vuelos)
- Servicios: bills (General), bills_water (Agua), bills_electricity (Luz), bills_internet (Internet), bills_gas (Gas)
- Compras: shopping (General), shopping_clothes (Ropa), shopping_electronics (Electrónica), shopping_gifts (Regalos)
- Ocio: entertainment (General), entertainment_movies (Cine), entertainment_sports (Deportes), entertainment_subscriptions (Suscripciones)
- Otro: other

Elige la categoría (como 'food_restaurant', 'transport_taxi', etc.) que mejor represente el gasto.
''';

        final response = await model.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          final data = jsonDecode(response.text!);
          _parsedAmount = (data['amount'] as num).toDouble();
          _parsedCategory = data['category'] ?? 'other';
        }
      }
    } catch (e) {
      // Fallback
    }

    if (_parsedAmount == 0.0) {
      // Fallback a Regex simple
      final amountRegex = RegExp(r'\d+(\.\d+)?');
      final match = amountRegex.firstMatch(_recognizedText);
      if (match != null) {
        _parsedAmount = double.parse(match.group(0)!);
      }
      
      final textLower = _recognizedText.toLowerCase();
      if (textLower.contains('comida') || textLower.contains('restaurante') || textLower.contains('starbucks') || textLower.contains('café')) {
        _parsedCategory = 'food';
      } else if (textLower.contains('transporte') || textLower.contains('uber') || textLower.contains('taxi') || textLower.contains('gasolina')) {
        _parsedCategory = 'transport';
      } else if (textLower.contains('ropa') || textLower.contains('zapatos') || textLower.contains('compra')) {
        _parsedCategory = 'shopping';
      }
      _parsedDescription = _recognizedText;
    } else {
      _parsedDescription = _recognizedText; // Use the raw text for the description in DB
    }

    if (_parsedAmount > 0) {
      final user = ref.read(authProvider).user;
      final expense = entity.TransactionModel(
        id: '',
        userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
        amount: _parsedAmount,
        type: 'expense',
        category: _parsedCategory,
        description: _parsedDescription,
        date: DateTime.now(),
        isFixed: false,
      );
      await ref.read(transactionNotifierProvider.notifier).addTransaction(expense);
      
      setState(() {
        _isProcessing = false;
        _isDone = true;
      });
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'No pude detectar una cantidad válida en: "$_recognizedText". Intenta de nuevo diciendo el número.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24, offset: const Offset(0, 12)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 14)),
              ),
              
            if (!_isProcessing && !_isDone) ...[
              Text(
                _isListening ? 'Te estoy escuchando...' : 'Toca para hablar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Di algo como: "Gasté 15 dólares en Starbucks"',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
              if (_recognizedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('"${_recognizedText}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue)),
              ],
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening 
                            ? (isDark ? const Color(0xFF4F46E5).withOpacity(0.5 + (_controller.value * 0.5)) : const Color(0xFF6366F1).withOpacity(0.5 + (_controller.value * 0.5)))
                            : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                        boxShadow: _isListening ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.4 * _controller.value),
                            blurRadius: 30 * _controller.value,
                            spreadRadius: 10 * _controller.value,
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: Icon(
                          _isListening ? LucideIcons.mic : LucideIcons.micOff,
                          size: 40,
                          color: _isListening ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (_isProcessing) ...[
              const CircularProgressIndicator(color: Color(0xFF4F46E5)),
              const SizedBox(height: 24),
              Text('Analizando tu voz...', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
            ] else if (_isDone) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14532D).withOpacity(0.3) : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.check, size: 48, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
              ),
              const SizedBox(height: 24),
              Text('¡Gasto registrado!', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('$_parsedDescription (-${CurrencyFormatter.format(_parsedAmount, user?.currency)})', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Aceptar'),
              )
            ]
          ],
        ),
      ),
    );
  }
}
