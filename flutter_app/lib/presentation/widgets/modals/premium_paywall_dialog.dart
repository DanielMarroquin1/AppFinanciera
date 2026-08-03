import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'premium_modal.dart';

class PremiumPaywallDialog extends StatelessWidget {
  final String? customMessage;

  const PremiumPaywallDialog({super.key, this.customMessage});

  static Future<void> show(BuildContext context, {String? customMessage}) {
    return showDialog(
      context: context,
      builder: (context) => PremiumPaywallDialog(customMessage: customMessage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.crown, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Función Premium',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Text(
        customMessage ?? 'Desbloquea el Plan Premium para acceder a esta y todas las funciones exclusivas de la aplicación.',
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          fontSize: 15,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar este dialog
                PremiumModal.show(context); // Mostrar el modal de planes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B), // amber-500
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 4,
                shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              ),
              child: const Text(
                'HAZTE PREMIUM',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
