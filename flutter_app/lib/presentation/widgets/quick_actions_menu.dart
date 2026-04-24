import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickActionsMenu extends StatelessWidget {
  const QuickActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'id': 'savings-goal',
        'label': 'Nueva Meta de Ahorro',
        'icon': LucideIcons.target,
        'gradient': isDark 
            ? const [Color(0xFF1D4ED8), Color(0xFF0E7490)]
            : const [Color(0xFF2563EB), Color(0xFF0891B2)],
        'isPremium': false,
      },
      {
        'id': 'my-savings',
        'label': 'Mis Ahorros',
        'icon': LucideIcons.piggyBank,
        'gradient': isDark 
            ? const [Color(0xFF0E7490), Color(0xFF0369A1)]
            : const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        'isPremium': false,
      },
      {
        'id': 'rewards-shop',
        'label': 'Tienda de Recompensas',
        'icon': LucideIcons.shoppingBag,
        'gradient': isDark 
            ? const [Color(0xFFD97706), Color(0xFFC2410C)]
            : const [Color(0xFFFBBF24), Color(0xFFF97316)],
        'isPremium': false,
      },
      {
        'id': 'ai-chat',
        'label': 'Consultar IA',
        'icon': LucideIcons.messageSquare,
        'gradient': isDark 
            ? const [Color(0xFF7E22CE), Color(0xFF4338CA)]
            : const [Color(0xFF9333EA), Color(0xFF4F46E5)],
        'isPremium': true,
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(action['id']);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: action['gradient'] as List<Color>,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(action['icon'] as IconData, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  action['label'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (action['isPremium'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.crown, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una acción para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            )
          ],
        ),
      ),
    );
  }
}
