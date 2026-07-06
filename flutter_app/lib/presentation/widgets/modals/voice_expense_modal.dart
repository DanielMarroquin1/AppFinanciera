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
import '../../providers/credit_card_provider.dart';
import '../../../core/utils/localization.dart';

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
  String _parsedPaymentMethod = 'efectivo'; // 'efectivo' or 'tarjeta'
  String _errorMessage = '';
  bool _showPreview = false;
  String? _selectedCreditCardId;

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
    if (_isDone || _showPreview) {
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
    if (_isProcessing || _showPreview || _isDone) return; // Fix duplication
    if (_recognizedText.isEmpty) return;

    setState(() => _isProcessing = true);

    final cards = ref.read(creditCardsProvider).value ?? [];
    String cardsInfo = 'No hay tarjetas registradas.';
    if (cards.isNotEmpty) {
      cardsInfo = cards.map((c) => '- ID: "${c.id}", Nombre: "${c.name}", Red: "${c.network}"').join('\n');
    }

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
  "category": "string exacto de la categoría",
  "description": "nombre corto y limpio del establecimiento o producto comprando (ej. 'Burger King', 'Supermercado Walmart', 'Gasolina Shell', 'Café Starbucks'). NUNCA incluyas la cantidad, moneda, ni el método de pago en esta descripción.",
  "paymentMethod": "efectivo" o "tarjeta",
  "creditCardId": "id_de_la_tarjeta_o_null"
}

Categorías permitidas (USA EXACTAMENTE ESTOS VALORES EN INGLÉS COMO APARECEN AQUÍ):
- Comida y Restaurantes: food (ej. hamburguesas, Burger King, McDonald's, pizza, tacos, café, restaurantes, almuerzo, cena, supermercado)
- Transporte y Gasolina: transport (ej. Uber, gasolina, taxi, pasaje, parqueo, bus, vuelos)
- Servicios y Facturas: bills (ej. luz, agua, internet, teléfono, celular, gas)
- Compras y Ropa: shopping (ej. ropa, zapatos, electrónica, centro comercial, regalos)
- Ocio y Entretenimiento: entertainment (ej. cine, películas, Netflix, Spotify, videojuegos, salidas, fiesta)
- Salud y Farmacia: health (ej. farmacia, pastillas, médico, doctor, clínica, gimnasio)
- Hogar y Alquiler: home (ej. alquiler, casa, muebles, mantenimiento, reparación, ferretería)
- Educación: education (ej. colegio, universidad, cursos, libros, útiles)
- Otro: other (SOLO si verdaderamente no encaja en ninguna de las anteriores)

Tarjetas de crédito del usuario disponibles:
$cardsInfo

Reglas para paymentMethod y creditCardId:
1. Si el usuario menciona que pagó con tarjeta (o con crédito, tc, visa, mastercard, amex, nubank, bac, o cualquier banco o tarjeta del listado anterior), pon "paymentMethod": "tarjeta". De lo contrario, pon "efectivo".
2. Si el usuario menciona detalles que coinciden con alguna tarjeta del listado (nombre del banco, titular, últimos 4 dígitos o marca), asigna el ID correspondiente en "creditCardId". Si menciona tarjeta pero no especifica cuál o hay varias y no se sabe cuál es, pon "creditCardId": null.
''';

        final response = await model.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          final data = jsonDecode(response.text!);
          _parsedAmount = (data['amount'] as num).toDouble();
          _parsedCategory = data['category'] ?? 'other';
          if (_parsedCategory == 'other') {
            final localCat = _fallbackClassifyCategory(_recognizedText);
            if (localCat != 'other') _parsedCategory = localCat;
          }
          if (_parsedCategory.contains('_')) {
            _parsedCategory = _parsedCategory.split('_')[0];
          }
          _parsedPaymentMethod = data['paymentMethod'] ?? 'efectivo';
          if (data['creditCardId'] != null) {
            _selectedCreditCardId = data['creditCardId'].toString();
          }
          if (data['description'] != null && data['description'].toString().trim().isNotEmpty) {
            _parsedDescription = data['description'].toString().trim();
          } else {
            _parsedDescription = _extractCleanDescription(_recognizedText);
          }
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
      _parsedCategory = _fallbackClassifyCategory(_recognizedText);
      _parsedDescription = _extractCleanDescription(_recognizedText);
      
      final textLower = _recognizedText.toLowerCase();
      if (textLower.contains('tarjeta') || textLower.contains('crédito') || textLower.contains('credito') || textLower.contains('tc')) {
        _parsedPaymentMethod = 'tarjeta';
      }
    } else if (_parsedDescription.isEmpty || _parsedDescription == _recognizedText) {
      _parsedDescription = _extractCleanDescription(_recognizedText);
      if (_parsedCategory == 'other') {
        final localCat = _fallbackClassifyCategory(_recognizedText);
        if (localCat != 'other') _parsedCategory = localCat;
      }
    }

    if (_parsedPaymentMethod == 'tarjeta') {
      if (_selectedCreditCardId == null && cards.isNotEmpty) {
        if (cards.length == 1) {
          _selectedCreditCardId = cards.first.id;
        } else {
          for (final c in cards) {
            if (_recognizedText.toLowerCase().contains(c.name.toLowerCase()) || _recognizedText.toLowerCase().contains(c.network.toLowerCase())) {
              _selectedCreditCardId = c.id;
              break;
            }
          }
          if (_selectedCreditCardId == null) {
            _selectedCreditCardId = cards.first.id;
          }
        }
      }
    }

    if (_parsedAmount > 0) {
      setState(() {
        _isProcessing = false;
        _showPreview = true;
      });
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'No pude detectar una cantidad válida en: "$_recognizedText". Intenta de nuevo diciendo el número.';
      });
    }
  }

  String _extractCleanDescription(String rawText) {
    String clean = rawText;
    clean = clean.replaceAll(RegExp(r'\b\d+(\.\d+)?\b', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'\b(quetzales|quetzal|dolares|dólares|usd|gtq|pesos|mxn|euros|eur|lempiras|soles|colones|gasto|gasté|gaste|pagué|pague|compre|compré|fueron|son|costó|costo|en|de|por)\b', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'\b(con|tarjeta|crédito|credito|tc|efectivo|cash|usando|pago|pagado|débito|debito|mi|la|el|los|las|un|una|unos|unas)\b', caseSensitive: false), '');
    
    final cards = ref.read(creditCardsProvider).value ?? [];
    for (final c in cards) {
      if (c.name.isNotEmpty) clean = clean.replaceAll(RegExp(r'\b' + RegExp.escape(c.name) + r'\b', caseSensitive: false), '');
      if (c.network.isNotEmpty) clean = clean.replaceAll(RegExp(r'\b' + RegExp.escape(c.network) + r'\b', caseSensitive: false), '');
    }
    
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    clean = clean.replaceAll(RegExp(r'^[,\.\s\-\_\:\;\/]+|[,\.\s\-\_\:\;\/]+$'), '').trim();
    
    if (clean.isEmpty) {
      clean = rawText.replaceAll(RegExp(r'\b\d+(\.\d+)?\b', caseSensitive: false), '').trim();
    }
    
    if (clean.isNotEmpty) {
      return clean[0].toUpperCase() + clean.substring(1);
    }
    return 'Gasto general';
  }

  String _fallbackClassifyCategory(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\b(burger|burguer|king|mcdonalds|mcdonald|wendys|kfc|taco|tacos|pizza|pizzas|sushi|pollo|comida|restaurante|almuerzo|cena|desayuno|café|cafe|starbucks|supermercado|súper|super|walmart|torre|paiz|coto|oxxo|panadería|postre|helado|carne|fruta|verdura|uber eats|pedidosya|rappi|grubhub|hamburguesa|hamburguesas|taquería|bebida|cerveza|vino|bar|alimentos)\b').hasMatch(lower)) {
      return 'food';
    }
    if (RegExp(r'\b(gasolina|combustible|shell|puma|texaco|uno|bp|uber|indrive|didi|cabify|lyft|taxi|bus|autobús|transporte|metro|pasaje|peaje|estacionamiento|parqueo|vuelo|avión|boleto|mecánico|llantas|aceite|carro|vehículo)\b').hasMatch(lower)) {
      return 'transport';
    }
    if (RegExp(r'\b(luz|electricidad|eegsa|deocsa|energuate|agua|empagua|internet|tigo|claro|movistar|teléfono|celular|saldo|recarga|gas propano|basura|servicio|factura|recibo)\b').hasMatch(lower)) {
      return 'bills';
    }
    if (RegExp(r'\b(ropa|camisa|pantalón|zapatos|tenis|zapatillas|vestido|chaqueta|zara|h&m|bershka|nike|adidas|compra|compras|mall|tienda|amazon|electrónica|computadora|audífonos|cable|cargador|regalo)\b').hasMatch(lower)) {
      return 'shopping';
    }
    if (RegExp(r'\b(cine|película|cinépolis|cinemark|netflix|spotify|disney|hbo|max|prime|youtube|suscripción|juego|videojuego|playstation|xbox|nintendo|steam|partido|estadio|concierto|diversión|fiesta|club)\b').hasMatch(lower)) {
      return 'entertainment';
    }
    if (RegExp(r'\b(medicina|pastillas|farmacia|galeno|cruz verde|similares|batres|meykos|doctor|médico|hospital|clínica|dentista|odontólogo|examen|salud|terapia|psicólogo|gimnasio|gym|smart fit)\b').hasMatch(lower)) {
      return 'health';
    }
    if (RegExp(r'\b(alquiler|renta|hipoteca|casa|departamento|mantenimiento|mueble|muebles|cama|mesa|silla|reparación|plomero|electricista|pintura|ferretería|cemaco|novex|limpieza)\b').hasMatch(lower)) {
      return 'home';
    }
    if (RegExp(r'\b(universidad|colegio|escuela|colegiatura|matrícula|curso|udemy|coursera|platzi|clase|clases|libro|libros|cuaderno|papelería|útiles|educación)\b').hasMatch(lower)) {
      return 'education';
    }
    return 'other';
  }

  Future<void> _saveTransaction() async {
    if (_isProcessing || _isDone) return;
    setState(() => _isProcessing = true);

    String? creditCardIdToUse;
    if (_parsedPaymentMethod == 'tarjeta') {
      final cards = ref.read(creditCardsProvider).value;
      if (_selectedCreditCardId != null) {
        creditCardIdToUse = _selectedCreditCardId;
      } else if (cards != null && cards.isNotEmpty) {
        creditCardIdToUse = cards.first.id;
      } else {
        creditCardIdToUse = 'TC';
      }
    }

    final expense = entity.TransactionModel(
      id: '',
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      amount: _parsedAmount,
      type: 'expense',
      category: _parsedCategory,
      description: _parsedDescription,
      date: DateTime.now(),
      isFixed: false,
      creditCardId: creditCardIdToUse,
    );
    await ref.read(transactionNotifierProvider.notifier).addTransaction(expense);
    
    setState(() {
      _isProcessing = false;
      _showPreview = false;
      _isDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final loc = ref.watch(localizationProvider);
    final cards = ref.watch(creditCardsProvider).value ?? [];

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
              
            if (!_isProcessing && !_isDone && !_showPreview) ...[
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
                'Ejemplo:\n"Gasté 15 en comida con tarjeta"\n"Pagué 20 de luz en efectivo"',
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
            ] else if (_showPreview) ...[
              Text('Confirmar Gasto', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(loc.getCategoryEmoji(_parsedCategory), style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Text(loc.translateCategory(_parsedCategory), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(
                          '-${CurrencyFormatter.format(_parsedAmount, user?.currency)}',
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_parsedDescription.isNotEmpty && _parsedDescription != _recognizedText) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_parsedDescription, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Método de pago:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _parsedPaymentMethod = 'efectivo'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _parsedPaymentMethod == 'efectivo'
                              ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1))
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('💵 Efectivo', style: TextStyle(color: _parsedPaymentMethod == 'efectivo' ? Colors.white : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _parsedPaymentMethod = 'tarjeta';
                          if (_selectedCreditCardId == null && cards.isNotEmpty) {
                            _selectedCreditCardId = cards.first.id;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _parsedPaymentMethod == 'tarjeta'
                              ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1))
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('💳 Tarjeta', style: TextStyle(color: _parsedPaymentMethod == 'tarjeta' ? Colors.white : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_parsedPaymentMethod == 'tarjeta' && cards.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Selecciona tu Tarjeta:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: cards.any((c) => c.id == _selectedCreditCardId) ? _selectedCreditCardId : cards.first.id,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      items: cards.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('${c.name} (${c.network})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCreditCardId = val);
                      },
                    ),
                  ),
                ),
              ] else if (_parsedPaymentMethod == 'tarjeta' && cards.isEmpty) ...[
                const SizedBox(height: 12),
                Text('No tienes tarjetas registradas en la app.', style: TextStyle(color: Colors.amber[700], fontSize: 12)),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showPreview = false;
                          _recognizedText = '';
                          _parsedAmount = 0.0;
                        });
                        _toggleListening();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                      ),
                      child: Text('Dictar otra vez', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(LucideIcons.check, size: 20),
                      label: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
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
