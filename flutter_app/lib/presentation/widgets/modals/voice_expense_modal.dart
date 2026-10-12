import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/transaction.dart' as entity;
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_card_provider.dart';
import '../../../core/utils/localization.dart';

class VoiceTransactionModal extends ConsumerStatefulWidget {
  const VoiceTransactionModal({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoiceTransactionModal()),
    );
  }

  @override
  ConsumerState<VoiceTransactionModal> createState() =>
      _VoiceTransactionModalState();
}

typedef VoiceExpenseModal = VoiceTransactionModal;

class _VoiceTransactionModalState extends ConsumerState<VoiceTransactionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final SpeechToText _speechToText = SpeechToText();
  Timer? _silenceTimer;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isDone = false;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _recognizedText = '';
  double _parsedAmount = 0.0;
  String _parsedCategory = 'food';
  String _parsedDescription = '';
  String _parsedType = 'expense'; // 'expense' or 'income'
  String _parsedPaymentMethod = 'efectivo'; // 'efectivo' or 'tarjeta'
  String _errorMessage = '';
  bool _showPreview = false;
  String? _selectedCreditCardId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speechToText.initialize(
        onError: (err) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _errorMessage = 'Mic error: ${err.errorMsg}';
            });
          }
        },
      );
      if (available && mounted) {
        _startListening();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _textController.dispose();
    _descController.dispose();
    _pulseController.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  String get _speechLocale {
    final loc = ref.read(localizationProvider);
    final String currentLang = loc.intlLocale;
    if (currentLang == 'en') return 'en_US';
    if (currentLang == 'pt') return 'pt_BR';
    if (currentLang == 'fr') return 'fr_FR';
    if (currentLang == 'it') return 'it_IT';
    return 'es_ES';
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        setState(() => _errorMessage = 'Permiso de micrófono denegado');
      }
      return;
    }

    final available = await _speechToText.initialize();
    if (available && mounted) {
      setState(() {
        _isListening = true;
        _errorMessage = '';
        _recognizedText = '';
        _textController.clear();
      });

      await _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
            _textController.text = _recognizedText;
          });

          _silenceTimer?.cancel();
          if (_recognizedText.trim().isNotEmpty) {
            _silenceTimer = Timer(const Duration(milliseconds: 1600), () {
              if (_isListening && mounted) {
                _stopAndProcess();
              }
            });
          }

          if (result.finalResult) {
            _silenceTimer?.cancel();
            _stopAndProcess();
          }
        },
        localeId: _speechLocale,
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 45),
      );
    }
  }

  Future<void> _stopAndProcess() async {
    _silenceTimer?.cancel();
    await _speechToText.stop();
    if (mounted) {
      setState(() => _isListening = false);
      _processVoiceInput();
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopAndProcess();
    } else {
      await _startListening();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PARSER DE VOZ MULTILINGÜE Y EN ESPAÑOL ROBUSTO
  // ─────────────────────────────────────────────────────────────────────────────

  double _parseSpokenAmount(String raw) {
    String text = raw.toLowerCase().trim();

    // 1. Normalizar "50 con 50" o "50 punto 50" -> "50.50"
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*(?:con|punto|coma|\.)\s*(\d+)'),
      (m) => '${m[1]}.${m[2]}',
    );

    // 2. Extraer números en dígitos explícitos (ej. Q50, $25.50, 100 quetzales)
    final digitMatch = RegExp(r'[$Q€£¥]?\s*(\d+(?:\.\d+)?)\s*(?:quetzales|quetzal|dolares|dólares|pesos|euros|usd|gtq)?')
        .allMatches(text);
    for (final m in digitMatch) {
      final valStr = m.group(1);
      if (valStr != null) {
        final val = double.tryParse(valStr);
        if (val != null && val > 0) {
          return val;
        }
      }
    }

    // 3. Diccionarios de palabras a números en español
    const units = {
      'cero': 0, 'un': 1, 'uno': 1, 'una': 1, 'dos': 2, 'tres': 3, 'cuatro': 4,
      'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9, 'diez': 10,
      'once': 11, 'doce': 12, 'trece': 13, 'catorce': 14, 'quince': 15,
      'dieciseis': 16, 'dieciséis': 16, 'diecisiete': 17, 'dieciocho': 18, 'diecinueve': 19,
      'veinte': 20, 'veintiuno': 21, 'veintiún': 21, 'veintiun': 21, 'veintidos': 22, 'veintidós': 22,
      'veintitres': 23, 'veintitrés': 23, 'veinticuatro': 24, 'veinticinco': 25,
      'veintiseis': 26, 'veintiséis': 26, 'veintisiete': 27, 'veintiocho': 28, 'veintinueve': 29,
      'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    };

    const tens = {
      'treinta': 30, 'cuarenta': 40, 'cincuenta': 50, 'sesenta': 60,
      'setenta': 70, 'ochenta': 80, 'noventa': 90,
      'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
      'seventy': 70, 'eighty': 80, 'ninety': 90,
    };

    const hundreds = {
      'cien': 100, 'ciento': 100, 'doscientos': 200, 'trescientos': 300,
      'cuatrocientos': 400, 'quinientos': 500, 'seiscientos': 600,
      'setecientos': 700, 'ochocientos': 800, 'novecientos': 900,
      'hundred': 100,
    };

    final words = RegExp(r'[a-záéíóúñ]+').allMatches(text).map((m) => m.group(0)!).toList();

    double currentTotal = 0.0;
    double currentSub = 0.0;
    int i = 0;
    bool foundAny = false;

    while (i < words.length) {
      final w = words[i];
      int? val;

      if (units.containsKey(w)) {
        val = units[w];
      } else if (tens.containsKey(w)) {
        val = tens[w];
        if (i + 2 < words.length && words[i + 1] == 'y' && units.containsKey(words[i + 2])) {
          val = (val ?? 0) + (units[words[i + 2]] ?? 0);
          i += 2;
        }
      } else if (hundreds.containsKey(w)) {
        val = hundreds[w];
      } else if (w == 'mil' || w == 'thousand') {
        if (currentSub == 0) currentSub = 1;
        currentTotal += currentSub * 1000;
        currentSub = 0;
        foundAny = true;
        i++;
        continue;
      }

      if (val != null) {
        foundAny = true;
        currentSub += val;
      } else if (foundAny) {
        if ((w == 'con' || w == 'punto') && i + 1 < words.length) {
          final centsWord = words[i + 1];
          int? cents;
          if (units.containsKey(centsWord)) {
            cents = units[centsWord];
          } else if (tens.containsKey(centsWord)) {
            cents = tens[centsWord];
            if (i + 3 < words.length && words[i + 2] == 'y' && units.containsKey(words[i + 3])) {
              cents = (cents ?? 0) + (units[words[i + 3]] ?? 0);
            }
          }
          if (cents != null) {
            currentSub += cents >= 10 ? cents / 100.0 : cents / 10.0;
          }
        }
        break;
      }
      i++;
    }

    return currentTotal + currentSub;
  }

  void _processVoiceInput() {
    if (_recognizedText.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    final text = _recognizedText.toLowerCase();

    // 1. Detectar Tipo (Ingreso o Gasto)
    final isIncome = RegExp(
      r'(recibí|recibi|me pagaron|me depositaron|gané|gane|ingreso|sueldo|salario|nómina|nomina|aguinaldo|bono|propina|vendí|vendi|received|earned|paid me)',
    ).hasMatch(text);
    _parsedType = isIncome ? 'income' : 'expense';

    // 2. Extraer Monto
    _parsedAmount = _parseSpokenAmount(_recognizedText);

    // 3. Extraer Categoría (Checar primero categorías personalizadas del usuario)
    final user = ref.read(authProvider).user;
    final customCats = (user?.unlockedItems ?? [])
        .where((item) => item.startsWith('cat_'))
        .map((item) => item.replaceFirst('cat_', ''))
        .toList();

    String matchedCategory = 'other';

    for (final cc in customCats) {
      if (text.contains(cc.toLowerCase())) {
        matchedCategory = cc;
        break;
      }
    }

    if (matchedCategory == 'other') {
      if (isIncome) {
        if (RegExp(r'(salario|sueldo|nómina|nomina|quincena|mensualidad|trabajo)').hasMatch(text)) {
          matchedCategory = 'salary';
        } else if (RegExp(r'(freelance|proyecto|cliente|extra|consultoría|diseño)').hasMatch(text)) {
          matchedCategory = 'freelance';
        } else if (RegExp(r'(bono|aguinaldo|bonificación|premio|propina)').hasMatch(text)) {
          matchedCategory = 'bonus';
        } else if (RegExp(r'(inversión|inversion|rendimiento|cripto|trading|intereses)').hasMatch(text)) {
          matchedCategory = 'investment';
        } else if (RegExp(r'(venta|vendí|vendi|marketplace|segunda mano)').hasMatch(text)) {
          matchedCategory = 'sale';
        } else if (RegExp(r'(regalo|cumpleaños|donación|me dieron)').hasMatch(text)) {
          matchedCategory = 'gift';
        } else {
          matchedCategory = 'salary';
        }
      } else {
        if (RegExp(r'(comida|restaurante|almuerzo|cena|desayuno|café|cafe|pizza|hamburguesa|tacos|super|supermercado|despensa|walmart|pan|pollo|carne|uber eats|pedidosya|rappi|cerveza|helado|snack|mcdonalds|starbucks)').hasMatch(text)) {
          matchedCategory = 'food';
        } else if (RegExp(r'(gasolina|combustible|shell|puma|texaco|uber|didi|taxi|bus|metro|pasaje|parqueo|estacionamiento|peaje|taller|mecánico|carro|auto)').hasMatch(text)) {
          matchedCategory = 'transport';
        } else if (RegExp(r'(luz|agua|internet|teléfono|telefono|celular|saldo|recarga|claro|tigo|eegsa|energuate|gas|servicio|factura|recibo)').hasMatch(text)) {
          matchedCategory = 'bills';
        } else if (RegExp(r'(ropa|zapatos|tenis|camisa|pantalón|zara|bershka|amazon|compras|mall|tienda|electrónica)').hasMatch(text)) {
          matchedCategory = 'shopping';
        } else if (RegExp(r'(cine|película|netflix|spotify|juego|videojuego|playstation|concierto|fiesta|bar|disco|salida)').hasMatch(text)) {
          matchedCategory = 'entertainment';
        } else if (RegExp(r'(medicina|farmacia|pastillas|doctor|médico|medico|hospital|clínica|dentista|salud|gimnasio|gym)').hasMatch(text)) {
          matchedCategory = 'health';
        } else if (RegExp(r'(alquiler|renta|casa|mueble|muebles|ferretería|limpieza|departamento|hogar)').hasMatch(text)) {
          matchedCategory = 'home';
        } else if (RegExp(r'(universidad|colegio|escuela|curso|libros|cuaderno|clases|educación)').hasMatch(text)) {
          matchedCategory = 'education';
        } else {
          matchedCategory = 'food'; // Default más frecuente
        }
      }
    }
    _parsedCategory = matchedCategory;

    // 4. Extraer Método de Pago
    final cards = ref.read(creditCardsProvider).value ?? [];
    if (!isIncome && RegExp(r'(tarjeta|crédito|credito|débito|debito|tc|visa|mastercard|card)').hasMatch(text)) {
      _parsedPaymentMethod = 'tarjeta';
      _selectedCreditCardId = cards.isNotEmpty ? cards.first.id : null;
      for (final c in cards) {
        if (text.contains(c.name.toLowerCase()) || text.contains(c.network.toLowerCase())) {
          _selectedCreditCardId = c.id;
          break;
        }
      }
    } else {
      _parsedPaymentMethod = 'efectivo';
      _selectedCreditCardId = null;
    }

    // 5. Extraer Concepto / Descripción limpia
    _parsedDescription = _cleanDescription(_recognizedText);
    _descController.text = _parsedDescription;

    setState(() {
      _isProcessing = false;
      if (_parsedAmount > 0) {
        _showPreview = true;
      } else {
        _errorMessage = 'No se detectó el monto. Di por ejemplo: "Gasté 50 en pizza"';
      }
    });
  }

  String _cleanDescription(String raw) {
    String clean = ' ' + raw.toLowerCase() + ' ';

    // Quitar dígitos y montos
    clean = clean.replaceAll(RegExp(r'[$Q€£¥]?\s*\d+(\.\d+)?\s*[$Q€£¥]?'), ' ');

    // Quitar verbos y palabras de orden
    final verbs = [
      'gasté', 'gaste', 'pagué', 'pague', 'compré', 'compre', 'consumí', 'consumi',
      'recibí', 'recibi', 'me pagaron', 'me depositaron', 'gané', 'gane', 'cobré', 'cobre',
      'anota', 'agrega', 'registra', 'pon', 'fueron', 'son', 'costó', 'costo',
      'quetzales', 'quetzal', 'dólares', 'dolares', 'pesos', 'euros',
      'en efectivo', 'con efectivo', 'con tarjeta', 'en tarjeta', 'con tc', 'de tarjeta',
      'por favor', 'hola', 'quivo'
    ];
    for (final v in verbs) {
      clean = clean.replaceAll(RegExp(r'(?:|\s+|^)' + v + r'(?:|\s+|$|[,\.\!])'), ' ');
    }

    // Quitar preposiciones iniciales
    final preps = ['en', 'de', 'un', 'una', 'el', 'la', 'los', 'las', 'por', 'para'];
    final words = clean.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    while (words.isNotEmpty && preps.contains(words.first)) {
      words.removeAt(0);
    }

    if (words.isEmpty) {
      return _parsedCategory.toUpperCase();
    }
    final res = words.join(' ');
    return res[0].toUpperCase() + res.substring(1);
  }

  Future<void> _saveTransaction() async {
    if (_isProcessing || _isDone || _parsedAmount <= 0) return;
    setState(() => _isProcessing = true);

    final finalDesc = _descController.text.trim().isNotEmpty
        ? _descController.text.trim()
        : _parsedDescription;

    final transaction = entity.TransactionModel(
      id: '',
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      amount: _parsedAmount,
      type: _parsedType,
      category: _parsedCategory,
      description: finalDesc,
      date: DateTime.now(),
      isFixed: false,
      creditCardId: _parsedPaymentMethod == 'tarjeta' ? (_selectedCreditCardId ?? 'TC') : null,
    );

    await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);

    setState(() {
      _isProcessing = false;
      _isDone = true;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                _parsedType == 'income' ? '¡Ingreso guardado con éxito!' : '¡Gasto guardado con éxito!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D1A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showPreview ? _buildPreviewView(isDark) : _buildListeningView(isDark),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // VISTA 1: ESCUCHANDO / DICTANDO
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildListeningView(bool isDark) {
    return Column(
      children: [
        // Top Navigation Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, color: isDark ? Colors.white70 : Colors.black87, size: 20),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.mic, color: const Color(0xFF38BDF8), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _isListening ? 'Escuchando...' : 'Dictado por Voz',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 40), // Balance spacing
            ],
          ),
        ),

        const Spacer(),

        // Dynamic Glowing Microphone Center
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _isListening ? 1.0 + (_pulseController.value * 0.12) : 1.0;
            final glowOpacity = _isListening ? 0.35 + (_pulseController.value * 0.25) : 0.15;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                if (_isListening)
                  Container(
                    width: 140 * scale,
                    height: 140 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF38BDF8).withValues(alpha: glowOpacity * 0.4),
                    ),
                  ),

                // Inner Glow Ring
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: glowOpacity),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Button itself
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFF0284C7), const Color(0xFF06B6D4)]
                            : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isListening ? LucideIcons.mic : LucideIcons.micOff,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Live Transcript or Prompt Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _textController.text.isNotEmpty
                ? Text(
                    '"${_textController.text}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  )
                : Column(
                    children: [
                      Text(
                        _isListening ? 'Habla ahora con naturalidad...' : 'Toca el micrófono para comenzar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Di el monto y en qué lo gastaste.',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Error message if any
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],

        const Spacer(),

        // Quick Examples Pill Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                'EJEMPLOS RECOMENDADOS',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExampleChip('🍕 "Gasté 50 en pizza"', isDark),
                  _buildExampleChip('⛽ "Gasolina 100 con tarjeta"', isDark),
                  _buildExampleChip('💼 "Recibí 2500 de salario"', isDark),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Manual text bar & Process button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF22324D) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'O escribe aquí tu gasto...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      _recognizedText = _textController.text;
                      _processVoiceInput();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _recognizedText = _textController.text;
                    _processVoiceInput();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _textController.text = text.replaceAll('"', '').substring(2).trim();
        _recognizedText = _textController.text;
        _processVoiceInput();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // VISTA 2: PREVIEW REDISEÑADA, MODERNA Y ELEGANTE
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPreviewView(bool isDark) {
    final isIncome = _parsedType == 'income';
    final user = ref.read(authProvider).user;
    final currency = user?.currency ?? 'USD';
    final cards = ref.read(creditCardsProvider).value ?? [];

    final categoriesList = isIncome
        ? [
            {'id': 'salary', 'label': 'Salario', 'icon': LucideIcons.briefcase, 'color': const Color(0xFF10B981)},
            {'id': 'freelance', 'label': 'Freelance', 'icon': LucideIcons.laptop, 'color': const Color(0xFF06B6D4)},
            {'id': 'bonus', 'label': 'Bono', 'icon': LucideIcons.sparkles, 'color': const Color(0xFFF59E0B)},
            {'id': 'investment', 'label': 'Inversión', 'icon': LucideIcons.trendingUp, 'color': const Color(0xFF8B5CF6)},
            {'id': 'gift', 'label': 'Regalo', 'icon': LucideIcons.gift, 'color': const Color(0xFFEC4899)},
            {'id': 'other', 'label': 'Otro', 'icon': LucideIcons.moreHorizontal, 'color': const Color(0xFF64748B)},
          ]
        : [
            {'id': 'food', 'label': 'Comida', 'icon': LucideIcons.utensils, 'color': const Color(0xFFEF4444)},
            {'id': 'transport', 'label': 'Transporte', 'icon': LucideIcons.car, 'color': const Color(0xFF3B82F6)},
            {'id': 'bills', 'label': 'Servicios', 'icon': LucideIcons.zap, 'color': const Color(0xFFF59E0B)},
            {'id': 'shopping', 'label': 'Compras', 'icon': LucideIcons.shoppingBag, 'color': const Color(0xFFEC4899)},
            {'id': 'entertainment', 'label': 'Ocio', 'icon': LucideIcons.film, 'color': const Color(0xFF8B5CF6)},
            {'id': 'health', 'label': 'Salud', 'icon': LucideIcons.heartPulse, 'color': const Color(0xFF10B981)},
            {'id': 'home', 'label': 'Hogar', 'icon': LucideIcons.home, 'color': const Color(0xFF06B6D4)},
            {'id': 'education', 'label': 'Educación', 'icon': LucideIcons.bookOpen, 'color': const Color(0xFF6366F1)},
            {'id': 'other', 'label': 'Otro', 'icon': LucideIcons.moreHorizontal, 'color': const Color(0xFF64748B)},
          ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                      size: 14,
                      color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncome ? 'INGRESO DETECTADO' : 'GASTO DETECTADO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, color: isDark ? Colors.white54 : Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Big Amount Card with Tap-To-Edit
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final ctrl = TextEditingController(text: _parsedAmount.toStringAsFixed(2));
                    final res = await showDialog<double>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        title: const Text('Editar Monto', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          decoration: const InputDecoration(hintText: '0.00'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                          ElevatedButton(
                            onPressed: () {
                              final v = double.tryParse(ctrl.text.trim());
                              if (v != null && v > 0) Navigator.pop(ctx, v);
                            },
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    );
                    if (res != null && mounted) {
                      setState(() => _parsedAmount = res);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${isIncome ? "+" : "-"}${CurrencyFormatter.format(_parsedAmount, currency)}',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: isIncome ? const Color(0xFF10B981) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.edit2, size: 18, color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ),
                Text(
                  'Toca el monto para corregirlo si es necesario',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Description Field
          Text(
            'CONCEPTO / DESCRIPCIÓN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141C2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF22324D) : const Color(0xFFCBD5E1),
              ),
            ),
            child: TextField(
              controller: _descController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: 'Ej. Pizza, Gasolina, Supermercado',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                prefixIcon: Icon(LucideIcons.fileText, color: Color(0xFF38BDF8), size: 20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories Selector
          Text(
            'CATEGORÍA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categoriesList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categoriesList[index];
                final isSelected = _parsedCategory == cat['id'];
                final catColor = cat['color'] as Color;

                return GestureDetector(
                  onTap: () => setState(() => _parsedCategory = cat['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? catColor.withValues(alpha: 0.2)
                          : (isDark ? const Color(0xFF141C2E) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? catColor : (isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat['icon'] as IconData, size: 16, color: isSelected ? catColor : (isDark ? Colors.white60 : Colors.black54)),
                        const SizedBox(width: 8),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black54),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (!isIncome) ...[
            const SizedBox(height: 24),

            // Payment Method Switcher (Efectivo vs Tarjeta)
            Text(
              'MÉTODO DE PAGO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _parsedPaymentMethod = 'efectivo';
                      _selectedCreditCardId = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _parsedPaymentMethod == 'efectivo'
                            ? const Color(0xFF10B981).withValues(alpha: 0.18)
                            : (isDark ? const Color(0xFF141C2E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _parsedPaymentMethod == 'efectivo'
                              ? const Color(0xFF10B981)
                              : (isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0)),
                          width: _parsedPaymentMethod == 'efectivo' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.banknote, color: _parsedPaymentMethod == 'efectivo' ? const Color(0xFF10B981) : Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Efectivo',
                            style: TextStyle(
                              color: _parsedPaymentMethod == 'efectivo' ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _parsedPaymentMethod = 'tarjeta';
                      if (_selectedCreditCardId == null && cards.isNotEmpty) {
                        _selectedCreditCardId = cards.first.id;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _parsedPaymentMethod == 'tarjeta'
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.18)
                            : (isDark ? const Color(0xFF141C2E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _parsedPaymentMethod == 'tarjeta'
                              ? const Color(0xFF3B82F6)
                              : (isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0)),
                          width: _parsedPaymentMethod == 'tarjeta' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.creditCard, color: _parsedPaymentMethod == 'tarjeta' ? const Color(0xFF3B82F6) : Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Tarjeta de Crédito',
                            style: TextStyle(
                              color: _parsedPaymentMethod == 'tarjeta' ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Credit card picker if 'tarjeta' is selected
            if (_parsedPaymentMethod == 'tarjeta' && cards.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF22324D) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCreditCardId ?? cards.first.id,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    items: cards.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Row(
                          children: [
                            const Icon(LucideIcons.creditCard, color: Color(0xFF38BDF8), size: 18),
                            const SizedBox(width: 10),
                            Text(
                              '${c.name} (${c.network.toUpperCase()})',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCreditCardId = val);
                    },
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 36),

          // Primary Save Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6,
                shadowColor: (isIncome ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.4),
              ),
              child: _isProcessing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      isIncome ? 'Guardar Ingreso' : 'Guardar Gasto',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Re-record button
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPreview = false;
                  _textController.clear();
                  _recognizedText = '';
                });
                _startListening();
              },
              icon: const Icon(LucideIcons.rotateCcw, size: 16, color: Color(0xFF38BDF8)),
              label: const Text('Volver a dictar', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
