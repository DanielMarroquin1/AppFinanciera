import '../models/chat_message.dart';

abstract class AIRepository {
  Stream<String> sendMessage(String prompt, List<ChatMessage> history, {String? context});
}
