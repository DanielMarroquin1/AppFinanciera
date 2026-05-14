import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../services/knowledge_base_service.dart';
import '../services/market_data_service.dart';

class AIRepositoryImpl implements AIRepository {
  @override
  Stream<String> sendMessage(String prompt, List<ChatMessage> history, {String? context}) async* {
    String systemMessage = AIConfig.systemPrompt;
    if (context != null) {
      systemMessage += '\n\nContexto financiero actual del usuario:\n$context';
    }

    final ragContext = KnowledgeBaseService.getRelevantKnowledge(prompt);
    if (ragContext.isNotEmpty) {
      systemMessage += '\n\n$ragContext';
    }



    // Definir la herramienta para proponer planes de ahorro
    final proposeSavingsPlanTool = Tool(functionDeclarations: [
      FunctionDeclaration(
        'propose_savings_plan',
        'Propone un plan de ahorro estructurado al usuario basándose en su capacidad financiera.',
        Schema(
          SchemaType.object,
          properties: {
            'name': Schema(SchemaType.string, description: 'El título de la meta de ahorro (ej. Viaje a Europa, Fondo de Emergencia)'),
            'target_amount': Schema(SchemaType.number, description: 'El monto total objetivo a ahorrar'),
            'icon': Schema(SchemaType.string, description: 'Un emoji representativo para la meta de ahorro'),
            'description': Schema(SchemaType.string, description: 'Breve explicación o consejo de por qué este plan es bueno para el usuario'),
          },
          requiredProperties: ['name', 'target_amount', 'icon', 'description'],
        ),
      )
    ]);

    // Definir la herramienta para investigar mercado
    final getStockDataTool = Tool(functionDeclarations: [
      FunctionDeclaration(
        'get_stock_data',
        'Busca los datos de precio de cierre, apertura, volumen, etc. de una acción en tiempo real usando la API de Polygon. Úsalo SIEMPRE que el usuario pregunte por el precio de una empresa o el mercado.',
        Schema(
          SchemaType.object,
          properties: {
            'ticker': Schema(SchemaType.string, description: 'El código bursátil o ticker de la empresa (ej. AAPL, TSLA, NVDA). Mapea el nombre de la empresa al ticker correcto.'),
          },
          requiredProperties: ['ticker'],
        ),
      )
    ]);

    final model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.apiKey,
      systemInstruction: Content.system(systemMessage),
      tools: [proposeSavingsPlanTool, getStockDataTool],
    );

    final chatHistory = history.map((msg) {
      return Content(
        msg.role == MessageRole.user ? 'user' : 'model',
        [TextPart(msg.text)],
      );
    }).toList();

    final chat = model.startChat(history: chatHistory);

    try {
      print('[AIRepo] Sending message to Gemini...');
      final response = await chat.sendMessage(Content.text(prompt));

      // Bucle para manejar llamadas a funciones
      var functionCalls = response.functionCalls;
      var currentResponse = response;
      
      final initialText = currentResponse.text ?? '(function call, no text)';
      print('[AIRepo] Initial response - functionCalls: ${functionCalls.length}, text: ${initialText.substring(0, initialText.length > 100 ? 100 : initialText.length)}');
      
      while (functionCalls.isNotEmpty) {
        final call = functionCalls.first;
        print('[AIRepo] Function call detected: ${call.name} with args: ${call.args}');
        
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
          return; // Terminamos aquí por ahora, el usuario decidirá si acepta
        } else if (call.name == 'get_stock_data') {
          // Ejecutamos la consulta real
          final ticker = call.args['ticker'] as String? ?? 'SPY';
          print('[AIRepo] Calling MarketDataService.getStockData("$ticker")...');
          final apiResult = await MarketDataService.getStockData(ticker);
          print('[AIRepo] MarketDataService returned: $apiResult');
          
          // Enviamos el resultado de la función de vuelta a Gemini
          currentResponse = await chat.sendMessage(
            Content.functionResponse('get_stock_data', apiResult)
          );
          functionCalls = currentResponse.functionCalls;
          final afterText = currentResponse.text ?? '(function call, no text)';
          print('[AIRepo] After functionResponse - more calls: ${functionCalls.length}, text: ${afterText.substring(0, afterText.length > 100 ? 100 : afterText.length)}');
        } else {
          break; // Función no soportada
        }
      }

      if (currentResponse.text != null && currentResponse.text!.isNotEmpty) {
        print('[AIRepo] Final text response length: ${currentResponse.text!.length}');
        yield currentResponse.text!;
      } else {
        yield 'No pude generar una respuesta. Por favor, intenta de nuevo.';
      }
    } catch (e, stack) {
      print('[AIRepo] ERROR: $e');
      print('[AIRepo] Stack: $stack');
      yield 'Error de conexión con Gemini AI: $e';
    }
  }
}
