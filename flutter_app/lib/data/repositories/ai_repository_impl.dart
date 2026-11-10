import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../services/knowledge_base_service.dart';
import '../services/market_data_service.dart';

class AIRepositoryImpl implements AIRepository {
  @override
  Stream<String> sendMessage(
    String prompt,
    List<ChatMessage> history, {
    String? context,
  }) async* {
    String systemMessage = AIConfig.systemPrompt;
    if (context != null) {
      systemMessage += '\n\nContexto financiero actual del usuario:\n$context';
    }

    final ragContext = KnowledgeBaseService.getRelevantKnowledge(prompt);
    if (ragContext.isNotEmpty) {
      systemMessage += '\n\n$ragContext';
    }

    if (AIConfig.apiKey.isEmpty || AIConfig.apiKey == 'tu_clave_aqui') {
      // Simulador sin API Key
      final p = prompt.toLowerCase();
      if (p.contains('opción 1') ||
          p.contains('opcion 1') ||
          p.contains('50/30/20')) {
        yield '¡Excelente elección! La regla 50/30/20 te ayudará a balancear tus gastos. He creado la meta para ti:';
        yield jsonEncode({
          "___PROPOSAL___": true,
          "name": "Plan 50/30/20",
          "targetAmount": 2000,
          "icon": "⚖️",
          "description":
              "El 50% de tus ingresos irá a necesidades, 30% a deseos y 20% a esta meta de ahorro.",
        });
      } else if (p.contains('plan de ahorro') || p.contains('ahorrar')) {
        yield '¡Hola! Soy SAMI, tu asistente financiero. He analizado tus datos. *(Nota: Modo simulación sin API Key)*.\n\nPara ayudarte a ahorrar, te propongo 3 opciones basadas en tus ingresos y gastos:\n\n1. **Regla 50/30/20**: Un enfoque balanceado. Destinas 20% al ahorro.\n2. **Plan Agresivo**: Ideal para metas a corto plazo. Destinas 40% al ahorro reduciendo lujos.\n3. **Plan Conservador**: Cómodo y seguro. Destinas 10% al ahorro sin afectar tu estilo de vida.\n\n¿Qué opción prefieres que apliquemos?';
      } else {
        yield '¡Hola! Soy SAMI, tu asistente financiero. He recibido tu solicitud: "$prompt".\n\n*(Nota: La API Key de Gemini no está configurada, esto es una respuesta simulada).*';
      }
      return;
    }

    // Definir la herramienta para proponer planes de ahorro
    final proposeSavingsPlanTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'propose_savings_plan',
          'Propone un plan de ahorro estructurado al usuario basándose en su capacidad financiera.',
          Schema(
            SchemaType.object,
            properties: {
              'name': Schema(
                SchemaType.string,
                description:
                    'El título de la meta de ahorro (ej. Viaje a Europa, Fondo de Emergencia)',
              ),
              'target_amount': Schema(
                SchemaType.number,
                description: 'El monto total objetivo a ahorrar',
              ),
              'icon': Schema(
                SchemaType.string,
                description: 'Un emoji representativo para la meta de ahorro',
              ),
              'description': Schema(
                SchemaType.string,
                description:
                    'Breve explicación o consejo de por qué este plan es bueno para el usuario',
              ),
            },
            requiredProperties: [
              'name',
              'target_amount',
              'icon',
              'description',
            ],
          ),
        ),
      ],
    );

    // Definir la herramienta para investigar mercado
    final getStockDataTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'get_stock_data',
          'Busca los datos de precio de cierre, apertura, volumen, etc. de una acción en tiempo real usando la API de Polygon. Úsalo SIEMPRE que el usuario pregunte por el precio de una empresa o el mercado.',
          Schema(
            SchemaType.object,
            properties: {
              'ticker': Schema(
                SchemaType.string,
                description:
                    'El código bursátil o ticker de la empresa (ej. AAPL, TSLA, NVDA). Mapea el nombre de la empresa al ticker correcto.',
              ),
            },
            requiredProperties: ['ticker'],
          ),
        ),
      ],
    );

    final addTransactionTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'add_transaction',
          'Registra un nuevo ingreso o gasto en el historial del usuario.',
          Schema(
            SchemaType.object,
            properties: {
              'amount': Schema(
                SchemaType.number,
                description: 'Monto de la transacción en número',
              ),
              'type': Schema(
                SchemaType.string,
                description: 'Tipo de transacción: "income" o "expense"',
              ),
              'category': Schema(
                SchemaType.string,
                description:
                    'Categoría en inglés: food, transport, bills, shopping, entertainment, health, home, education, other, salary, freelance, investments',
              ),
              'description': Schema(
                SchemaType.string,
                description: 'Breve descripción de la transacción',
              ),
            },
            requiredProperties: ['amount', 'type', 'category', 'description'],
          ),
        ),
      ],
    );

    final createSavingsGoalTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'create_savings_goal',
          'Crea una nueva meta de ahorro en el historial del usuario.',
          Schema(
            SchemaType.object,
            properties: {
              'name': Schema(
                SchemaType.string,
                description: 'Nombre o título de la meta de ahorro',
              ),
              'target_amount': Schema(
                SchemaType.number,
                description: 'Monto total objetivo a ahorrar',
              ),
              'icon': Schema(
                SchemaType.string,
                description: 'Emoji para la meta (ej. 🚗, ✈️, 🏡, 🎓)',
              ),
            },
            requiredProperties: ['name', 'target_amount', 'icon'],
          ),
        ),
      ],
    );

    final model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.apiKey,
      systemInstruction: Content.system(systemMessage),
      tools: [
        proposeSavingsPlanTool,
        getStockDataTool,
        addTransactionTool,
        createSavingsGoalTool,
      ],
    );

    final chatHistory = history.map((msg) {
      return Content(msg.role == MessageRole.user ? 'user' : 'model', [
        TextPart(msg.text),
      ]);
    }).toList();

    final chat = model.startChat(history: chatHistory);

    try {
      final response = await chat
          .sendMessage(Content.text(prompt))
          .timeout(
            Duration(seconds: AIConfig.apiTimeoutSeconds),
            onTimeout: () => throw TimeoutException(
              'La respuesta de SAMI tardó demasiado. Por favor intenta de nuevo.',
            ),
          );

      // Bucle acotado para manejar llamadas a funciones
      var functionCalls = response.functionCalls;
      var currentResponse = response;
      int toolIterations = 0;
      const int maxToolIterations = 3;

      while (functionCalls.isNotEmpty && toolIterations < maxToolIterations) {
        toolIterations++;
        final call = functionCalls.first;

        if (call.name == 'propose_savings_plan') {
          // Devolver el payload codificado para que el Provider lo identifique
          final payload = {
            '___PROPOSAL___': true,
            'name': call.args['name'],
            'targetAmount': call.args['target_amount'],
            'icon': call.args['icon'],
            'description': call.args['description'],
          };
          yield jsonEncode(payload);
          return;
        } else if (call.name == 'add_transaction') {
          final payload = {
            '___ADD_TRANSACTION___': true,
            'amount': call.args['amount'],
            'type': call.args['type'],
            'category': call.args['category'],
            'description': call.args['description'],
          };
          yield jsonEncode(payload);
          return;
        } else if (call.name == 'create_savings_goal') {
          final payload = {
            '___CREATE_SAVINGS_GOAL___': true,
            'name': call.args['name'],
            'targetAmount': call.args['target_amount'],
            'icon': call.args['icon'],
          };
          yield jsonEncode(payload);
          return;
        } else if (call.name == 'get_stock_data') {
          // Ejecutamos la consulta real con timeout
          final ticker = call.args['ticker'] as String? ?? 'SPY';
          final apiResult = await MarketDataService.getStockData(ticker);

          // Enviamos el resultado de la función de vuelta a Gemini con timeout
          currentResponse = await chat
              .sendMessage(
                Content.functionResponse('get_stock_data', apiResult),
              )
              .timeout(
                Duration(seconds: AIConfig.apiTimeoutSeconds),
                onTimeout: () => throw TimeoutException(
                  'La consulta bursátil tardó demasiado.',
                ),
              );
          functionCalls = currentResponse.functionCalls;
        } else {
          break; // Función no soportada
        }
      }

      if (currentResponse.text != null && currentResponse.text!.isNotEmpty) {
        yield currentResponse.text!;
      } else {
        yield 'No pude generar una respuesta. Por favor, intenta de nuevo.';
      }
    } catch (e) {
      if (e is TimeoutException) {
        yield '⏱️ La respuesta tardó demasiado. Verifica tu conexión e intenta de nuevo.';
      } else {
        yield '❌ Error de conexión con SAMI. Por favor intenta de nuevo en unos momentos.';
      }
    }
  }

  @override
  Stream<String> analyzeScenario({
    required String prompt,
    String? systemInstruction,
  }) async* {
    final model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.apiKey,
      systemInstruction: systemInstruction != null
          ? Content.system(systemInstruction)
          : null,
      // INTENCIONAL: Sin herramientas (tools: null) para evitar intercepciones
      // de function calls, JSON payloads o acciones de UI filtradas.
    );

    try {
      final responseStream = model.generateContentStream([
        Content.text(prompt),
      ]).timeout(
        Duration(seconds: AIConfig.apiTimeoutSeconds),
        onTimeout: (sink) => sink.addError(
          TimeoutException(
            'La simulación tardó demasiado. Por favor intenta de nuevo.',
          ),
        ),
      );

      await for (final chunk in responseStream) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      if (e is TimeoutException) {
        yield '⏱️ La simulación tardó demasiado tiempo. Verifica tu conexión e intenta de nuevo.';
      } else {
        yield '❌ Error al generar la simulación en SimLab: $e';
      }
    }
  }
}
