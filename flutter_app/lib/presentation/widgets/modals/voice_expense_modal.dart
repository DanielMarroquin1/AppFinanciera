import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VoiceExpenseModal extends StatefulWidget {
  const VoiceExpenseModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const VoiceExpenseModal(),
    );
  }

  @override
  State<VoiceExpenseModal> createState() => _VoiceExpenseModalState();
}

class _VoiceExpenseModalState extends State<VoiceExpenseModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() {
    if (_isDone) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isListening = !_isListening;
    });

    if (!_isListening) {
      // Stopped listening, simulate processing
      setState(() {
        _isProcessing = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isDone = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            if (!_isProcessing && !_isDone) ...[
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
                'Di algo como: "Gasté 15 dólares en Starbucks"',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
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
              Text('Comida: Starbucks (-\$15.00)', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16)),
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
