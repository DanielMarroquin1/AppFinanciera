import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AIChatModal extends StatefulWidget {
  const AIChatModal({super.key});

  @override
  State<AIChatModal> createState() => _AIChatModalState();
}

class _AIChatModalState extends State<AIChatModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> messages = [
    {
      'id': '1',
      'text': '¡Hola! 👋 Soy tu asistente financiero con IA. Estoy aquí para ayudarte con consejos de ahorro, análisis de gastos y planificación financiera. ¿En qué puedo ayudarte hoy?',
      'sender': 'ai',
      'timestamp': DateTime.now(),
    }
  ];
  
  bool isTyping = false;

  final quickQuestions = [
    {'icon': LucideIcons.piggyBank, 'text': '¿Cómo puedo ahorrar más?'},
    {'icon': LucideIcons.trendingUp, 'text': 'Analiza mis gastos'},
    {'icon': LucideIcons.target, 'text': 'Tips para mis metas'},
  ];

  final Map<String, String> aiResponses = {
    '¿Cómo puedo ahorrar más?': '¡Excelente pregunta! 💰 Basándome en tus datos, te recomiendo:\n\n1. Aplica la regla 50/30/20: 50% necesidades, 30% gustos, 20% ahorros\n2. Automatiza tus ahorros - transfiere automáticamente al inicio del mes\n3. Revisa tus suscripciones - cancela las que no uses\n4. Compra inteligente - usa listas y evita compras impulsivas\n\n¿Quieres que profundice en alguno de estos puntos?',
    'Analiza mis gastos': '📊 He analizado tus gastos del último mes:\n\n🍔 Comida: \$850 (33%)\n🚗 Transporte: \$450 (18%)\n🎮 Ocio: \$420 (16%)\n📱 Servicios: \$500 (20%)\n🏠 Hogar: \$330 (13%)\n\nObservo que gastas más en comida. Te sugiero:\n• Planear comidas semanales\n• Cocinar en casa más seguido\n• Usar apps de descuentos\n\nPodrías ahorrar hasta \$200/mes optimizando estos gastos. ¿Te gustaría un plan personalizado?',
    'Tips para mis metas': '🎯 Consejos para tus metas de ahorro:\n\n1. Meta de Vacaciones (\$2,000)\n   • Faltan 6 meses\n   • Ahorra \$333/mes\n   • Consejo: Crea una cuenta separada\n\n2. Fondo de Emergencia (\$5,000)\n   • Prioridad alta ⚠️\n   • Meta: 3-6 meses de gastos\n   • Empieza con \$100/semana\n\n💡 Tip PRO: Ahorra cada aumento o bono que recibas. ¿Necesitas ajustar tus metas?',
  };

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, // overshoot slightly
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'id': DateTime.now().toString(),
        'text': text,
        'sender': 'user',
        'timestamp': DateTime.now(),
      });
      _controller.clear();
      isTyping = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final responseText = aiResponses[text] ?? 
          "Entiendo tu pregunta. 🤔 Basándome en tu perfil financiero, te recomiendo establecer metas claras, hacer un presupuesto realista y revisar tus gastos semanalmente. ¿Hay algo más específico en lo que pueda ayudarte?";
      
      setState(() {
        messages.add({
          'id': DateTime.now().toString(),
          'text': responseText,
          'sender': 'ai',
          'timestamp': DateTime.now(),
        });
        isTyping = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  ? const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFDB2777)]) // purple-600 to pink-600
                  : const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]), // purple-500 to pink-500
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
                        const Text('Asistente IA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
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
                          Text(' Escribiendo...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? (isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA)) // purple text bubbles
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
                              Text('Asistente IA', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          msg['text'] as String,
                          style: TextStyle(color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(msg['timestamp'] as DateTime).hour.toString().padLeft(2, '0')}:${(msg['timestamp'] as DateTime).minute.toString().padLeft(2, '0')}',
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
          if (messages.length == 1)
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
