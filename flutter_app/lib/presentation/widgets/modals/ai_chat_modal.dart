import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_app/presentation/providers/chat_provider.dart';
import 'package:flutter_app/domain/models/chat_message.dart';
import 'package:flutter_app/presentation/widgets/modals/add_saving_goal_modal.dart';
import 'package:flutter_app/domain/entities/saving_goal.dart';
import 'package:flutter_app/presentation/providers/saving_goals_provider.dart';
import 'package:flutter_app/presentation/providers/auth_provider.dart';

class AIChatModal extends ConsumerStatefulWidget {
  const AIChatModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
        child: const AIChatModal(),
      ),
    );
  }

  @override
  ConsumerState<AIChatModal> createState() => _AIChatModalState();
}

class _AIChatModalState extends ConsumerState<AIChatModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final quickQuestions = [
    {'icon': LucideIcons.piggyBank, 'text': '¿Cómo puedo ahorrar más?'},
    {'icon': LucideIcons.trendingUp, 'text': 'Analiza mis gastos'},
    {'icon': LucideIcons.target, 'text': 'Tips para mis metas'},
  ];

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void handleSendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(chatProvider);

    // Initial greeting if no messages
    final messages = chatState.messages.isEmpty 
      ? [
          ChatMessage(
            text: '¡Hola! 👋 Soy Zent AI, tu asistente financiero. Estoy aquí para ayudarte con consejos de ahorro, análisis de gastos y planificación financiera basada en tus datos reales. ¿En qué puedo ayudarte hoy?',
            role: MessageRole.assistant,
          )
        ]
      : chatState.messages;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFDB2777)])
                  : const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Zent AI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Siempre disponible para ayudarte', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (chatState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && chatState.isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                        border: isDark ? Border.all(color: const Color(0xFF374151)) : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.sparkles, color: Color(0xFFC084FC), size: 16),
                          SizedBox(width: 8),
                          Text(' Zent AI está pensando...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg.role == MessageRole.user;

                if (msg.isProposal && msg.payload != null) {
                  final p = msg.payload!;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles, color: Color(0xFFC084FC), size: 16),
                              const SizedBox(width: 4),
                              Text('Zent AI ha propuesto un Plan de Ahorro', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(p['icon'] ?? '🎯', style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name'] ?? 'Meta', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('\$${p['targetAmount']}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p['description'] ?? '',
                            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    AddSavingGoalModal.show(
                                      context,
                                      initialName: p['name'],
                                      initialTargetAmount: (p['targetAmount'] as num?)?.toDouble(),
                                      initialIcon: p['icon'],
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white : Colors.black,
                                    side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Modificar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final user = ref.read(authProvider).user;
                                    if (user != null) {
                                      final goal = SavingGoal(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        name: p['name'] ?? 'Plan',
                                        targetAmount: (p['targetAmount'] as num?)?.toDouble() ?? 0.0,
                                        icon: p['icon'] ?? '🎯',
                                        userId: user.email,
                                      );
                                      await ref.read(savingGoalsProvider.notifier).addGoal(goal);
                                      ref.read(chatProvider.notifier).sendMessage("¡He aceptado el plan de ahorro! Se ha guardado en mi cuenta.");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Aceptar'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? (isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA))
                          : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
                      border: (!isUser && isDark) ? Border.all(color: const Color(0xFF374151)) : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.sparkles, color: Color(0xFFC084FC), size: 16),
                              const SizedBox(width: 4),
                              Text('Zent AI', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          msg.text,
                          style: TextStyle(color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isUser ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[500]),
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Questions
          if (messages.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickQuestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final q = quickQuestions[index];
                  return ElevatedButton.icon(
                    onPressed: () => handleSendMessage(q['text'] as String),
                    icon: Icon(q['icon'] as IconData, size: 16),
                    label: Text(q['text'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
                    ),
                  );
                },
              ),
            ),

          // Input
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    onSubmitted: handleSendMessage,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.send, color: Colors.white),
                    onPressed: () => handleSendMessage(_controller.text),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
