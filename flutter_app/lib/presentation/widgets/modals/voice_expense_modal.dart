import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
import 'premium_modal.dart';

class VoiceTransactionModal extends ConsumerStatefulWidget {
  const VoiceTransactionModal({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumModal.show(context);
      return Future.value();
    }
    return showDialog(
      context: context,
      builder: (context) => const VoiceTransactionModal(),
    );
  }

  @override
  ConsumerState<VoiceTransactionModal> createState() => _VoiceTransactionModalState();
}

// Keep the old name as an alias for backwards compatibility
typedef VoiceExpenseModal = VoiceTransactionModal;

class _VoiceTransactionModalState extends ConsumerState<VoiceTransactionModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SpeechToText _speechToText = SpeechToText();
  Timer? _silenceTimer;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isDone = false;
  String _recognizedText = '';
  double _parsedAmount = 0.0;
  String _parsedCategory = 'other';
  String _parsedDescription = '';
  String _parsedType = 'expense'; // 'expense' or 'income'
  String _parsedPaymentMethod = 'efectivo'; // 'efectivo' or 'tarjeta'
  String _errorMessage = '';
  bool _showPreview = false;
  String? _selectedCreditCardId;
  final FlutterTts _flutterTts = FlutterTts();
  bool _waitingForPaymentMethod = false;

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
            _errorMessage = 'Mic error: ${errorNotification.errorMsg}';
          });
        },
      );
    } catch (e) {
      // Handle init error
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _controller.dispose();
    _speechToText.cancel();
    _flutterTts.stop();
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

  String get _ttsLocale {
    final loc = ref.read(localizationProvider);
    final String currentLang = loc.intlLocale;
    if (currentLang == 'en') return 'en-US';
    if (currentLang == 'pt') return 'pt-BR';
    if (currentLang == 'fr') return 'fr-FR';
    if (currentLang == 'it') return 'it-IT';
    return 'es-ES';
  }

  Future<void> _toggleListening() async {
    if (_isDone || _showPreview) {
      Navigator.of(context).pop();
      return;
    }

    if (_isListening) {
      _silenceTimer?.cancel();
      await _speechToText.stop();
      setState(() => _isListening = false);
      _processText();
    } else {
      // Request permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setState(() => _errorMessage = 'Microphone permission denied');
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
            _silenceTimer?.cancel();
            if (_recognizedText.trim().isNotEmpty) {
              _silenceTimer = Timer(const Duration(seconds: 3), () {
                if (_isListening) {
                  _speechToText.stop();
                  if (mounted) {
                    setState(() => _isListening = false);
                    _processText();
                  }
                }
              });
            }
            if (result.finalResult) {
              _silenceTimer?.cancel();
              setState(() => _isListening = false);
              _processText();
            }
          },
          localeId: _speechLocale,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 45),
        );
      } else {
        setState(() => _errorMessage = 'Speech recognition not available on this device');
      }
    }
  }

  void _processText() async {
    if (_isProcessing || _showPreview || _isDone) return; // Fix duplication
    if (_recognizedText.isEmpty) return;

    setState(() => _isProcessing = true);

    final loc = ref.read(localizationProvider);
    final cards = ref.read(creditCardsProvider).value ?? [];
    String cardsInfo = 'No cards registered.';
    if (cards.isNotEmpty) {
      cardsInfo = cards.map((c) => '- ID: "${c.id}", Name: "${c.name}", Network: "${c.network}"').join('\n');
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
Analyze this financial transaction spoken by the user: "$_recognizedText"
The user's preferred language is: "${loc.intlLocale}" (can be 'es', 'en', 'pt', 'fr', 'it').

Your task is to determine:
1. The transaction type: "expense" (gasto) or "income" (ingreso).
2. The transaction category: MUST be one of the standard categories listed below (in English).
3. The clean description of the transaction (short concept/name in the user's language).
4. The payment method (if expense: "efectivo" or "tarjeta", if income: "efectivo").
5. The creditCardId (if card matched from list).

--- DETECTING TYPE ---
Identify if the user is spending money (expense) or receiving money (income). Use standard rules for Spanish, English, Portuguese, French, and Italian.
For example:
- "gasté", "pagué", "compré", "spent", "paid", "bought", "gastei", "paguei", "comprei", "dépensé", "payé", "acheté", "speso", "pagato", "comprato" -> "expense"
- "recibí", "gané", "me pagaron", "received", "earned", "paid me", "recebi", "ganhei", "me pagaram", "reçu", "gagné", "pagato", "ricevuto", "guadagnato" -> "income"

--- STANDARD CATEGORIES (Use EXACTLY these English keys in the JSON category field) ---
* Expense Categories:
  - food (Comida / Food / Alimentação / Nourriture / Cibo)
  - transport (Transporte / Transport / Trasporto)
  - bills (Servicios / Bills / Contas / Factures / Bollette)
  - shopping (Compras / Shopping / Achats / Acquisti)
  - entertainment (Entretenimiento / Entertainment / Divertissement / Intrattenimento)
  - health (Salud / Health / Saúde / Santé / Salute)
  - home (Hogar / Home / Casa / Maison)
  - education (Educación / Education / Educação / Éducation / Istruzione)
  - other (Otro / Other / Outros / Autres / Altri)

* Income Categories:
  - salary (Salario / Salary / Salário / Salaire / Stipendio)
  - freelance (Freelance / Proyectos / Freelance)
  - bonus (Bonificación / Bonus / Bônus / Prime)
  - investment (Inversiones / Investment / Investimentos / Investissements / Investimenti)
  - sale (Venta / Sale / Venda / Vente / Vendita)
  - dividends (Dividendos / Dividends / Dividendos / Dividendes / Dividendi)
  - gift (Regalo / Gift / Presente / Cadeau / Regalo)
  - other (Otro Ingreso / Other Income / Outro / Autre / Altro)

Output STRICT JSON:
{
  "type": "expense" | "income",
  "amount": decimal number,
  "category": "standard_category_key_in_english",
  "description": "clean name of concept/store without verbs or numbers or currency symbols, written in the user's language",
  "paymentMethod": "efectivo" | "tarjeta",
  "creditCardId": "id_if_matched_or_null"
}

Cards available:
$cardsInfo
''';

        final response = await model.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          final data = jsonDecode(response.text!);
          _parsedAmount = (data['amount'] as num).toDouble();
          _parsedType = data['type'] ?? 'expense';
          _parsedCategory = data['category'] ?? 'other';
          
          // Validate type
          if (_parsedType != 'income' && _parsedType != 'expense') {
            _parsedType = _fallbackClassifyType(_recognizedText);
          }
          
          // Fallback for category
          if (_parsedCategory == 'other') {
            if (_parsedType == 'income') {
              final localCat = _fallbackClassifyIncomeCategory(_recognizedText);
              if (localCat != 'other') _parsedCategory = localCat;
            } else {
              final localCat = _fallbackClassifyExpenseCategory(_recognizedText);
              if (localCat != 'other') _parsedCategory = localCat;
            }
          }
          if (_parsedCategory.contains('_')) {
            _parsedCategory = _parsedCategory.split('_')[0];
          }
          
          // Only set payment method for expenses
          if (_parsedType == 'expense') {
            _parsedPaymentMethod = data['paymentMethod'] ?? 'efectivo';
            if (data['creditCardId'] != null) {
              _selectedCreditCardId = data['creditCardId'].toString();
            }
          } else {
            _parsedPaymentMethod = 'efectivo';
            _selectedCreditCardId = null;
          }
          
          if (data['description'] != null && data['description'].toString().trim().isNotEmpty) {
            _parsedDescription = _extractCleanDescription(data['description'].toString().trim());
          } else {
            _parsedDescription = _extractCleanDescription(_recognizedText);
          }
        }
      }
    } catch (e) {
      // Fallback to local processing
    }

    if (_parsedAmount == 0.0) {
      // Detect type locally first
      _parsedType = _fallbackClassifyType(_recognizedText);
      
      // Fallback for numbers
      final currencyPriceRegex = RegExp(r'(?:en|por|costó|cuesta|son|fueron|pagué|pague|gasto de|recibí|recibi|me dieron|me pagaron|cobré|cobre|gané|gane|vendí|vendi|spent|paid|received|cost|[$Q€£¥])\s*(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\s*(?:quetzales|quetzal|dólares|dolares|dólar|dolar|pesos|peso|mxn|euros|euro|eur|usd|gtq|lempiras|soles|colones|pounds|dollars|[$Q€£¥])', caseSensitive: false);
      final priceMatch = currencyPriceRegex.firstMatch(_recognizedText);
      if (priceMatch != null) {
        final valStr = priceMatch.group(1) ?? priceMatch.group(2);
        if (valStr != null) {
          _parsedAmount = double.tryParse(valStr) ?? 0.0;
        }
      }
      if (_parsedAmount == 0.0) {
        final allNumRegex = RegExp(r'\b(\d+(?:\.\d+)?)\b');
        final matches = allNumRegex.allMatches(_recognizedText);
        double maxNum = 0.0;
        for (final m in matches) {
          final str = m.group(1)!;
          final afterIdx = m.end;
          final remainder = _recognizedText.substring(afterIdx).trimLeft().toLowerCase();
          if (remainder.startsWith('lb') || remainder.startsWith('libra') || remainder.startsWith('kg') || remainder.startsWith('kilo') || remainder.startsWith('g ') || remainder.startsWith('gr') || remainder.startsWith('ml') || remainder.startsWith('litro') || remainder.startsWith('oz') || remainder.startsWith('onza') || remainder.startsWith('unidad')) {
            continue;
          }
          final val = double.tryParse(str) ?? 0.0;
          if (val > maxNum) maxNum = val;
        }
        if (maxNum > 0) {
          _parsedAmount = maxNum;
        } else {
          final amountRegex = RegExp(r'\d+(\.\d+)?');
          final match = amountRegex.firstMatch(_recognizedText);
          if (match != null) {
            _parsedAmount = double.tryParse(match.group(0)!) ?? 0.0;
          }
        }
      }
      
      // Classify category based on type
      if (_parsedType == 'income') {
        _parsedCategory = _fallbackClassifyIncomeCategory(_recognizedText);
      } else {
        _parsedCategory = _fallbackClassifyExpenseCategory(_recognizedText);
      }
      _parsedDescription = _extractCleanDescription(_recognizedText);
      
      // Only check payment method for expenses
      if (_parsedType == 'expense') {
        final textLower = _recognizedText.toLowerCase();
        if (textLower.contains('tarjeta') || textLower.contains('crédito') || textLower.contains('credito') || textLower.contains('tc') || textLower.contains('card') || textLower.contains('cartão')) {
          _parsedPaymentMethod = 'tarjeta';
        }
      }
    } else if (_parsedDescription.isEmpty || _parsedDescription == _recognizedText) {
      _parsedDescription = _extractCleanDescription(_recognizedText);
      if (_parsedCategory == 'other') {
        if (_parsedType == 'income') {
          final localCat = _fallbackClassifyIncomeCategory(_recognizedText);
          if (localCat != 'other') _parsedCategory = localCat;
        } else {
          final localCat = _fallbackClassifyExpenseCategory(_recognizedText);
          if (localCat != 'other') _parsedCategory = localCat;
        }
      }
      // Revalidate type if not set by AI
      if (_parsedType == 'expense') {
        final detectedType = _fallbackClassifyType(_recognizedText);
        if (detectedType == 'income') _parsedType = 'income';
      }
    }

    // Handle credit card for expenses
    if (_parsedType == 'expense' && _parsedPaymentMethod == 'tarjeta') {
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
      // For incomes, skip payment method question entirely
      if (_parsedType == 'income') {
        setState(() {
          _isProcessing = false;
          _showPreview = true;
        });
      } else {
        // For expenses, check if payment method was mentioned
        final txt = _recognizedText.toLowerCase();
        final hasPaymentMethod = txt.contains('tarjeta') || txt.contains('efectivo') || txt.contains('crédito') || txt.contains('credito') || txt.contains('visa') || txt.contains('mastercard') || txt.contains('cash') || txt.contains('efec') || txt.contains('card') || txt.contains('cartão') || txt.contains('argent');
        
        if (!hasPaymentMethod) {
          _askForPaymentMethod();
        } else {
          setState(() {
            _isProcessing = false;
            _showPreview = true;
          });
        }
      }
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = loc.get('voice_no_amount').replaceAll('{text}', _recognizedText);
      });
    }
  }

  /// Detects whether the voice input is an income or expense based on keywords in multiple languages
  String _fallbackClassifyType(String text) {
    final lower = text.toLowerCase();
    
    // Strong income indicators (es, en, pt, fr, it)
    if (RegExp(r'\b(me\s+regalaron|me\s+dieron|me\s+pagaron|me\s+depositaron|me\s+transfirieron|me\s+abonaron|me\s+llegó|me\s+llego|received|earned|paid\s+me|gave\s+me|recebi|ganhei|me\s+pagaram|me\s+deram|reçu|gagné|offert|ricevuto|guadagnato|pagato|donato)\b').hasMatch(lower)) {
      return 'income';
    }
    if (RegExp(r'\b(gané|gane|recibí|recibi|cobré|cobre|vendí|vendi|obtuve|ingresé|ingrese|ahorré|ahorre|win|won|get|got|sold|sell|receber|vender|vendi|ganhar|vendre|vendu|gagner|vendere|venduto|guadagnare)\b').hasMatch(lower)) {
      if (lower.contains('cobré') || lower.contains('cobre')) {
        if (lower.contains('cobrame') || lower.contains('cóbrame')) {
          return 'expense';
        }
        return 'income';
      }
      return 'income';
    }
    // Income context phrases
    if (RegExp(r'\b(de\s+salario|de\s+sueldo|mi\s+sueldo|mi\s+salario|de\s+regalo|por\s+mi\s+cumpleaños|por\s+mi\s+cumple|de\s+freelance|por\s+un\s+proyecto|de\s+dividendos|de\s+inversión|de\s+inversion|de\s+rendimiento|de\s+aguinaldo|de\s+bono|de\s+bonificación|de\s+bonificacion|de\s+propina|de\s+comisión|de\s+comision|por\s+mi\s+trabajo|de\s+nómina|de\s+nomina|de\s+quincena|salary|wage|bonus|dividends|freelance|gift|birthday|investments|salário|sueldo|cadeau|stipendio|regalo)\b').hasMatch(lower)) {
      return 'income';
    }

    // Strong expense indicators
    if (RegExp(r'\b(gasté|gaste|gasto|consumí|consumi|debítame|debitame|cóbrame|cobrame|pagué|pague|compré|compre|costó|costo|me\s+costó|me\s+costo|invertí\s+en|anota|agrega|pon|registra|spent|spent|bought|buy|purchased|cost|paid|pay|gastei|paguei|comprei|compra|dépensé|payé|acheté|speso|pagato|comprato|comprate)\b').hasMatch(lower)) {
      return 'expense';
    }

    return 'expense';
  }

  /// Classifies income category based on keywords in multiple languages
  String _fallbackClassifyIncomeCategory(String text) {
    final lower = text.toLowerCase();
    
    // Salary
    if (RegExp(r'\b(salario|sueldo|nómina|nomina|quincena|pago\s+mensual|mensualidad|del\s+trabajo|me\s+pagaron\s+del|pago\s+quincenal|salary|wage|payroll|monthly\s+pay|salário|sueldo|salaire|stipendio)\b').hasMatch(lower)) {
      return 'salary';
    }
    // Freelance
    if (RegExp(r'\b(freelance|proyecto|cliente|trabajo\s+extra|independiente|comisión|comision|consultoría|consultoria|diseño|programación|programacion|trabajo\s+independiente|project|freelancer|gig|consulting|commission|freelance|progetto|cliente)\b').hasMatch(lower)) {
      return 'freelance';
    }
    // Bonus
    if (RegExp(r'\b(bono|bonificación|bonificacion|aguinaldo|extra|premio|incentivo|propina|gratificación|gratificacion|bonus|tip|extra|prime|propine|premio)\b').hasMatch(lower)) {
      return 'bonus';
    }
    // Investment
    if (RegExp(r'\b(inversión|inversion|rendimiento|rendimientos|intereses|interés|interes|ganancia|trading|cripto|criptomoneda|bitcoin|acciones|bolsa|fondos|capitalización|capitalizacion|investment|yield|interest|profits|crypto|investimento|rendimento|interesses|investissements|dividendes)\b').hasMatch(lower)) {
      return 'investment';
    }
    // Sale
    if (RegExp(r'\b(vendí|vendi|venta|marketplace|segunda\s+mano|usado|usada|mercadolibre|facebook\s+marketplace|olx|sold|sell|sale|venda|vendre|vendu|venduto|vendere)\b').hasMatch(lower)) {
      return 'sale';
    }
    // Dividends
    if (RegExp(r'\b(dividendo|dividendos|regalías|regalias|royalties|royalty|dividends|dividende|dividendi)\b').hasMatch(lower)) {
      return 'dividends';
    }
    // Gift
    if (RegExp(r'\b(regalo|regalaron|cumpleaños|cumple|navidad|obsequio|herencia|donación|donacion|me\s+dieron|quinceañera|bautizo|boda|graduación|graduacion|gift|present|birthday|christmas|inheritance|donation|presente|cadeau|anniversaire)\b').hasMatch(lower)) {
      return 'gift';
    }
    
    return 'other';
  }

  /// Classifies expense category based on keywords in multiple languages
  String _fallbackClassifyExpenseCategory(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\b(burger|burguer|king|mcdonalds|mcdonald|mac|macs|wendys|kfc|taco|tacos|pizza|pizzas|sushi|pollo|comida|restaurante|almuerzo|cena|desayuno|café|cafe|starbucks|supermercado|súper|super|walmart|torre|paiz|coto|oxxo|panadería|postre|helado|carne|fruta|verdura|uber eats|pedidosya|rappi|grubhub|hamburguesa|hamburguesas|taquería|bebida|cerveza|vino|bar|alimentos|campero|dominos|little caesars|subway|food|grocery|restaurant|coffee|starbucks|dinner|lunch|breakfast|eat|eating|nourriture|cibo|spesa|alimentari)\b').hasMatch(lower)) {
      return 'food';
    }
    if (RegExp(r'\b(gasolina|combustible|shell|puma|texaco|uno|bp|uber|indrive|didi|cabify|lyft|taxi|bus|autobús|transporte|metro|pasaje|peaje|estacionamiento|parqueo|vuelo|avión|boleto|mecánico|llantas|aceite|carro|vehículo|transport|gasoline|flight|flight|airplane|ticket|car|metro|subway|essence|trasporto|benzina)\b').hasMatch(lower)) {
      return 'transport';
    }
    if (RegExp(r'\b(luz|electricidad|eegsa|deocsa|energuate|agua|empagua|internet|tigo|claro|movistar|teléfono|celular|saldo|recarga|gas|tambo|cilindro|propano|butano|estufa|cocina|basura|servicio|factura|recibo|bills|utilities|water|electricity|phone|recharge|facture|eau|electricite|bolletta|luce|acqua)\b').hasMatch(lower)) {
      return 'bills';
    }
    if (RegExp(r'\b(ropa|camisa|pantalón|zapatos|tenis|zapatillas|vestido|chaqueta|zara|h&m|bershka|nike|adidas|compra|compras|mall|tienda|amazon|electrónica|computadora|audífonos|cable|cargador|regalo|shopping|clothes|shoes|electronics|store|purchase|achats|vetements|acquisti|vestiti)\b').hasMatch(lower)) {
      return 'shopping';
    }
    if (RegExp(r'\b(cine|película|cinépolis|cinemark|netflix|spotify|disney|hbo|max|prime|youtube|suscripción|juego|videojuego|playstation|xbox|nintendo|steam|partido|estadio|concierto|diversión|fiesta|club|entertainment|movies|cinema|music|sports|game|videogame|subscription|party|concert|fun|divertimento|divertissement)\b').hasMatch(lower)) {
      return 'entertainment';
    }
    if (RegExp(r'\b(medicina|pastillas|farmacia|galeno|cruz verde|similares|batres|meykos|doctor|médico|hospital|clínica|dentista|odontólogo|examen|salud|terapia|psicólogo|gimnasio|gym|smart fit|health|medicine|pills|pharmacy|doctor|hospital|clinic|gym|fitness|sante|salute|farmacia|medico)\b').hasMatch(lower)) {
      return 'health';
    }
    if (RegExp(r'\b(alquiler|renta|hipoteca|casa|departamento|hogar|doméstico|mantenimiento|mueble|muebles|cama|mesa|silla|reparación|plomero|electricista|pintura|ferretería|cemaco|novex|limpieza|home|rent|mortgage|house|furniture|maintenance|repair|loyer|maison|affitto|casa)\b').hasMatch(lower)) {
      return 'home';
    }
    if (RegExp(r'\b(universidad|colegio|escuela|colegiatura|matrícula|curso|udemy|coursera|platzi|clase|clases|libro|libros|cuaderno|papelería|útiles|educación|education|school|university|tuition|course|books|classes|scolarite|livres|istruzione|scuola|libri)\b').hasMatch(lower)) {
      return 'education';
    }
    return 'other';
  }

  Future<void> _askForPaymentMethod() async {
    final loc = ref.read(localizationProvider);
    setState(() {
      _waitingForPaymentMethod = true;
      _isProcessing = false;
      _recognizedText = '';
    });
    
    await _flutterTts.setLanguage(_ttsLocale);
    await _flutterTts.speak(loc.get('voice_ask_payment_method'));
    
    await Future.delayed(const Duration(seconds: 4));
    
    final available = await _speechToText.initialize();
    if (available && mounted) {
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
          _silenceTimer?.cancel();
          if (_recognizedText.trim().isNotEmpty) {
            _silenceTimer = Timer(const Duration(seconds: 3), () {
              if (_isListening) {
                _speechToText.stop();
                if (mounted) {
                  setState(() => _isListening = false);
                  _processPaymentMethodResponse();
                }
              }
            });
          }
          if (result.finalResult) {
            _silenceTimer?.cancel();
            setState(() => _isListening = false);
            _processPaymentMethodResponse();
          }
        },
        localeId: _speechLocale,
        pauseFor: const Duration(seconds: 2),
        listenFor: const Duration(seconds: 15),
      );
    }
  }

  void _processPaymentMethodResponse() {
    final cleanText = _recognizedText.toLowerCase();
    if (cleanText.contains('tarjeta') || cleanText.contains('crédito') || cleanText.contains('credito') || cleanText.contains('visa') || cleanText.contains('mastercard') || cleanText.contains('banco') || cleanText.contains('tc') || cleanText.contains('card') || cleanText.contains('cartão') || cleanText.contains('carte') || cleanText.contains('carta')) {
      _parsedPaymentMethod = 'tarjeta';
    } else {
      _parsedPaymentMethod = 'efectivo';
    }
    
    setState(() {
      _waitingForPaymentMethod = false;
      _showPreview = true;
    });
  }

  String _extractCleanDescription(String rawText) {
    String clean = ' ' + rawText + ' ';
    
    // 1. Remove numbers/amounts (e.g. 15, 15.00, $15, Q15)
    clean = clean.replaceAll(RegExp(r'[$Q€£¥]?\s*\b\d+(\.\d+)?\b\s*[$Q€£¥]?', caseSensitive: false), ' ');
    
    // 2. Remove verbs and command words (gasté, recibí, me pagaron, vendí, spent, received, etc.)
    final verbs = [
      'gasté', 'gaste', 'gasto', 'gastamos', 'gastado',
      'consumí', 'consumi', 'consumo', 'consumimos', 'consumido',
      'debítame', 'debitame', 'debita', 'débito', 'debito', 'debitar',
      'cóbrame', 'cobrame', 'cobra', 'cobro', 'cobrar',
      'cárgame', 'cargame', 'cargo', 'cargar',
      'descúentame', 'descuentame', 'descuenta',
      'pagué', 'pague', 'pago', 'pagamos', 'pagado',
      'compré', 'compre', 'compra', 'compramos', 'comprado', 'adquirí', 'adquiri',
      'anota', 'anotar', 'anótame', 'anotame', 'apunta', 'apúntame', 'apuntame',
      'agrega', 'agregar', 'agrégame', 'agregame',
      'pon', 'poner', 'ponme', 'registra', 'registrar', 'regístrame', 'registrame',
      'metí', 'meti', 'mete', 'méteme', 'meteme',
      'hice', 'hicimos', 'realicé', 'realice',
      'fueron', 'son', 'serían', 'serian', 'salió', 'salio', 'salieron',
      'costó', 'costo', 'costaron', 'valió', 'valio', 'valieron',
      'importe', 'monto', 'valor', 'total', 'precio',
      // Income verbs
      'gané', 'gane', 'recibí', 'recibi', 'cobré', 'cobre',
      'vendí', 'vendi', 'obtuve', 'ingresé', 'ingrese',
      'ahorré', 'ahorre', 'deposité', 'deposite',
      'me pagaron', 'me dieron', 'me regalaron', 'me depositaron',
      'me transfirieron', 'me abonaron', 'me llegó', 'me llego',
      // English verbs
      'spent', 'spend', 'paid', 'pay', 'bought', 'buy', 'purchased', 'purchase',
      'received', 'receive', 'got', 'get', 'earned', 'earn', 'sold', 'sell',
      'cost', 'costs',
      // Portuguese verbs
      'gastei', 'paguei', 'comprei', 'recebi', 'ganhei', 'vendi',
      // French verbs
      'dépensé', 'payé', 'acheté', 'reçu', 'gagné', 'vendu',
      // Italian verbs
      'speso', 'pagato', 'comprato', 'ricevuto', 'guadagnato', 'venduto',
    ];
    for (final v in verbs) {
      clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + v + r'(?:\b|\s+|$|[,\.\-\_\:\;\/\!\?])', caseSensitive: false), ' ');
    }
    
    // 3. Remove currencies and prepositions/connectors
    final fillers = [
      'quetzales', 'quetzal', 'qs', 'dólares', 'dolares', 'dólar', 'dolar', 'usd', 'gtq',
      'pesos', 'peso', 'mxn', 'euros', 'euro', 'eur', 'lempiras', 'soles', 'colones',
      'en', 'de', 'por', 'para', 'a', 'con', 'sin', 'usando', 'mediante', 'sobre',
      'un gasto', 'gasto de', 'un consumo', 'consumo de', 'pago de', 'compra de',
      'un ingreso', 'ingreso de', 'una venta', 'venta de',
      'mi', 'mis', 'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'al', 'del',
      'que', 'me', 'on', 'for', 'at', 'in', 'of', 'with', 'a', 'an', 'the', 'my',
      'de', 'para', 'com', 'sem', 'um', 'uma', 'o', 'a', 'os', 'as',
      'sur', 'pour', 'avec', 'sans', 'un', 'une', 'le', 'la', 'les', 'mon',
      'su', 'per', 'con', 'senza', 'un', 'una', 'il', 'la', 'i', 'mio',
    ];
    for (final f in fillers) {
      clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + f + r'(?:\b|\s+|$|[,\.\-\_\:\;\/\!\?])', caseSensitive: false), ' ');
    }
    
    // 4. Remove payment methods and card keywords
    final payments = [
      'tarjeta', 'tarjetas', 'crédito', 'credito', 'tc', 'tcs',
      'efectivo', 'cash', 'dinero', 'billetes', 'débito', 'debito',
      'visa', 'mastercard', 'amex', 'american express', 'discover',
      'card', 'cards', 'credit', 'money', 'cash',
      'cartão', 'dinheiro', 'carte', 'espèces', 'argent', 'carta', 'contanti'
    ];
    for (final p in payments) {
      clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + p + r'(?:\b|\s+|$|[,\.\-\_\:\;\/\!\?])', caseSensitive: false), ' ');
    }
    
    // 5. Remove card names and networks from user creditCardsProvider
    final cards = ref.read(creditCardsProvider).value ?? [];
    for (final c in cards) {
      if (c.name.trim().isNotEmpty) {
        clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + RegExp.escape(c.name.trim()) + r'(?:\b|\s+|$|[,\.\-\_\:\;\/\!\?])', caseSensitive: false), ' ');
      }
      if (c.network.trim().isNotEmpty) {
        clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + RegExp.escape(c.network.trim()) + r'(?:\b|\s+|$|[,\.\-\_\:\;\/\!\?])', caseSensitive: false), ' ');
      }
    }
    
    // 6. Clean extra spaces and punctuation
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    clean = clean.replaceAll(RegExp(r'^[,\.\-\_\:\;\/\!\?]+|[,\.\-\_\:\;\/\!\?]+$'), '').trim();
    
    if (clean.isEmpty) {
      clean = rawText.replaceAll(RegExp(r'\b\d+(\.\d+)?\b', caseSensitive: false), '').trim();
      for (final v in verbs) {
        clean = clean.replaceAll(RegExp(r'(?:\b|\s+|^)' + v + r'(?:\b|\s+|$)', caseSensitive: false), ' ').trim();
      }
      clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    
    if (clean.isNotEmpty) {
      return clean[0].toUpperCase() + clean.substring(1);
    }
    return _parsedType == 'income' ? 'Income' : 'Expense';
  }

  Future<void> _saveTransaction() async {
    if (_isProcessing || _isDone) return;
    setState(() => _isProcessing = true);

    String? creditCardIdToUse;
    if (_parsedType == 'expense' && _parsedPaymentMethod == 'tarjeta') {
      final cards = ref.read(creditCardsProvider).value;
      if (_selectedCreditCardId != null) {
        creditCardIdToUse = _selectedCreditCardId;
      } else if (cards != null && cards.isNotEmpty) {
        creditCardIdToUse = cards.first.id;
      } else {
        creditCardIdToUse = 'TC';
      }
    }

    final transaction = entity.TransactionModel(
      id: '',
      userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
      amount: _parsedAmount,
      type: _parsedType,
      category: _parsedCategory,
      description: _parsedDescription,
      date: DateTime.now(),
      isFixed: false,
      creditCardId: creditCardIdToUse,
    );
    final budgetAlert = await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
    
    setState(() {
      _isProcessing = false;
      _showPreview = false;
      _isDone = true;
    });

    if (mounted) {
      if (budgetAlert != null) {
        final alert = budgetAlert;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final user = ref.read(authProvider).user;
        final sym = CurrencyFormatter.getSymbol(user?.currency);
        
        if (alert.status == BudgetAlertStatus.limitReached) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              title: Row(
                children: [
                  const Icon(LucideIcons.alertOctagon, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  const Text('Límite Excedido 🚨', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                'Has agotado el 100% de tu presupuesto mensual para la categoría "${alert.categoryName}".\n\n'
                'Límite establecido: $sym${alert.budgetLimit.toStringAsFixed(0)}\n'
                'Total consumido: $sym${alert.totalSpent.toStringAsFixed(0)}',
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else if (alert.status == BudgetAlertStatus.nearLimit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ ¡Cuidado! Has consumido el ${alert.percentage.toStringAsFixed(0)}% del presupuesto mensual para "${alert.categoryName}" '
                '($sym${alert.totalSpent.toStringAsFixed(0)} / $sym${alert.budgetLimit.toStringAsFixed(0)})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final loc = ref.watch(localizationProvider);
    final cards = ref.watch(creditCardsProvider).value ?? [];

    final isIncome = _parsedType == 'income';
    final accentColor = isIncome ? const Color(0xFF10B981) : const Color(0xFF4F46E5);
    final accentColorLight = isIncome ? const Color(0xFF34D399) : const Color(0xFF6366F1);

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
              
            if (_waitingForPaymentMethod) ...[
              const Icon(LucideIcons.volume2, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                loc.get('voice_paying_card_or_cash'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                loc.get('voice_answer_mic'),
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
              if (_recognizedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('"${_recognizedText}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue)),
              ],
            ] else if (!_isProcessing && !_isDone && !_showPreview) ...[
              Text(
                _isListening ? loc.get('voice_listening') : loc.get('voice_tap_to_speak'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.get('voice_help_text'),
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500, height: 1.5),
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
              Text(loc.get('voice_analyzing'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
            ] else if (_showPreview) ...[
              // Type indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isIncome 
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isIncome 
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                      size: 16,
                      color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncome ? loc.get('voice_ingreso').toUpperCase() : loc.get('voice_gasto').toUpperCase(),
                      style: TextStyle(
                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isIncome ? loc.get('voice_confirm_income') : loc.get('voice_confirm_expense'), 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Toggle type buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _parsedType = 'expense';
                          _parsedCategory = _fallbackClassifyExpenseCategory(_recognizedText);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isIncome
                              ? const Color(0xFFEF4444).withOpacity(0.15)
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                          border: !isIncome ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '📉 ${loc.get('voice_gasto')}',
                          style: TextStyle(
                            color: !isIncome ? const Color(0xFFEF4444) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: !isIncome ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _parsedType = 'income';
                          _parsedCategory = _fallbackClassifyIncomeCategory(_recognizedText);
                          _parsedPaymentMethod = 'efectivo';
                          _selectedCreditCardId = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isIncome
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                          border: isIncome ? Border.all(color: const Color(0xFF10B981).withOpacity(0.4)) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '📈 ${loc.get('voice_ingreso')}',
                          style: TextStyle(
                            color: isIncome ? const Color(0xFF10B981) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: isIncome ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(_parsedAmount, user?.currency)}',
                          style: TextStyle(
                            color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444), 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                          ),
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
              // Only show payment method for expenses
              if (!isIncome) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(loc.get('voice_payment_method'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
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
                          child: Text(loc.get('voice_cash'), style: TextStyle(color: _parsedPaymentMethod == 'efectivo' ? Colors.white : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
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
                          child: Text(loc.get('voice_card'), style: TextStyle(color: _parsedPaymentMethod == 'tarjeta' ? Colors.white : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_parsedPaymentMethod == 'tarjeta' && cards.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(loc.get('voice_select_card'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
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
                  Text(loc.get('voice_no_cards'), style: TextStyle(color: Colors.amber[700], fontSize: 12)),
                ],
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
                          _parsedType = 'expense';
                        });
                        _toggleListening();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                      ),
                      child: Text(loc.get('voice_try_again'), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
                      label: Text(loc.get('voice_save'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ] else if (_isDone) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isIncome 
                      ? (isDark ? const Color(0xFF14532D).withOpacity(0.3) : const Color(0xFFDCFCE7))
                      : (isDark ? const Color(0xFF14532D).withOpacity(0.3) : const Color(0xFFDCFCE7)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.check, 
                  size: 48, 
                  color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isIncome ? loc.get('voice_success_income') : loc.get('voice_success_expense'), 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Type badge in success view
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isIncome 
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isIncome ? '📈 ${loc.get('voice_ingreso')}' : '📉 ${loc.get('voice_gasto')}',
                  style: TextStyle(
                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '$_parsedDescription (${isIncome ? '+' : '-'}${CurrencyFormatter.format(_parsedAmount, user?.currency)})', 
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16), 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? accentColor : accentColorLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(loc.get('voice_accept')),
              )
            ]
          ],
        ),
      ),
    );
  }
}
