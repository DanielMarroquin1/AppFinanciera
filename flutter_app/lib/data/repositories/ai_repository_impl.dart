import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/ai_config.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../services/knowledge_base_service.dart';
import '../services/market_data_service.dart';

class AIRepositoryImpl implements AIRepository {
  @override
  Stream<String> sendMessage(String prompt, List<ChatMessage> history, {String? context}) async* {
    // Convertir historial al formato de OpenAI / Cerebras
    final List<Map<String, String>> messages = [];
    
    // 1. Añadir el System Prompt y el contexto
    String systemMessage = AIConfig.systemPrompt;
    if (context != null) {
      systemMessage += '\n\nContexto financiero actual del usuario:\n$context';
    }

    // --- INYECCIÓN DE RAG Y MERCADO ---
    // Buscar conocimiento en "libros" locales
    final ragContext = KnowledgeBaseService.getRelevantKnowledge(prompt);
    if (ragContext.isNotEmpty) {
      systemMessage += '\n\n$ragContext';
    }

    // Buscar en Internet si es necesario
    if (MarketDataService.requiresInternetSearch(prompt, history)) {
      final marketData = await MarketDataService.fetchRealTimeData(prompt, history);
      if (marketData.isNotEmpty) {
        systemMessage += '\n\n[DATOS OBLIGATORIOS DEL MERCADO (ACTUALIZADOS A HOY)]:\n$marketData\nIgnora tu fecha de entrenamiento límite de 2023. Utiliza EXACTAMENTE estos datos para responder porque provienen de una API financiera en tiempo real.';
      }
    }
    // ----------------------------------

    messages.add({'role': 'system', 'content': systemMessage});

    // 2. Añadir el historial
    for (var msg in history) {
      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    // 3. Añadir el prompt actual
    messages.add({'role': 'user', 'content': prompt});

    // Preparar el cuerpo de la petición
    final body = jsonEncode({
      'model': AIConfig.modelName,
      'messages': messages,
      'temperature': 0.2,
      'top_p': 1,
      'stream': false, // Desactivado para simplificar la respuesta
      'max_completion_tokens': 1024,
    });

    try {
      final response = await http.post(
        Uri.parse(AIConfig.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIConfig.apiKey}',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        yield content; // Devolver toda la respuesta de una vez (Cerebras es muy rápido)
      } else {
        yield 'Error: HTTP ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      yield 'Error de conexión con Cerebras AI: $e';
    }
  }
}
