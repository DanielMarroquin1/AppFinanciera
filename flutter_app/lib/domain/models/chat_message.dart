enum MessageRole {
  user,
  assistant,
}

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isProposal;
  final Map<String, dynamic>? payload;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.isProposal = false,
    this.payload,
  }) : timestamp = timestamp ?? DateTime.now();
}
