import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/localization.dart';
import 'dart:ui';

class QuickActionsMenu extends ConsumerWidget {
  const QuickActionsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);

    final actions = [
      {
        'id': 'savings-goal',
        'label': loc.get('quick_actions_new_goal'),
        'icon': LucideIcons.target,
        'gradient': isDark 
            ? const [Color(0xFF1D4ED8), Color(0xFF0E7490)]
            : const [Color(0xFF2563EB), Color(0xFF0891B2)],
        'isPremium': false,
      },
      {
        'id': 'my-savings',
        'label': loc.get('my_savings').replaceAll(' 🎯', ''),
        'icon': LucideIcons.piggyBank,
        'gradient': isDark 
            ? const [Color(0xFF0E7490), Color(0xFF0369A1)]
            : const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        'isPremium': false,
      },
      {
        'id': 'rewards-shop',
        'label': loc.get('quick_actions_rewards_shop'),
        'icon': LucideIcons.shoppingBag,
        'gradient': isDark 
            ? const [Color(0xFFD97706), Color(0xFFC2410C)]
            : const [Color(0xFFFBBF24), Color(0xFFF97316)],
        'isPremium': false,
      },
      {
        'id': 'category-budget',
        'label': loc.get('category_budget'),
        'icon': LucideIcons.sliders,
        'gradient': isDark 
            ? const [Color(0xFF047857), Color(0xFF065F46)]
            : const [Color(0xFF059669), Color(0xFF10B981)],
        'isPremium': true,
      },
      {
        'id': 'ai-chat',
        'label': loc.get('ai_assistant'),
        'icon': LucideIcons.sparkles,
        'gradient': isDark 
            ? const [Color(0xFF7E22CE), Color(0xFF4338CA)]
            : const [Color(0xFF9333EA), Color(0xFF4F46E5)],
        'isPremium': true,
      },
      {
        'id': 'notifications',
        'label': 'Notificaciones',
        'icon': LucideIcons.bell,
        'gradient': isDark 
            ? const [Color(0xFFBE123C), Color(0xFF9F1239)]
            : const [Color(0xFFF43F5E), Color(0xFFE11D48)],
        'isPremium': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo oscuro difuminado (opcional, el BackdropFilter principal ya hace parte del trabajo)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: (isDark ? Colors.black : Colors.blueGrey[900])?.withValues(alpha: 0.2),
              ),
            ),
          ),
          
          // Contenido principal alineado al fondo inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          loc.get('quick_actions').toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Grid de Acciones 2x3
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: actions.map((action) {
                      final itemWidth = (MediaQuery.of(context).size.width - 48 - 16) / 2;
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, action['id']),
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: action['gradient'] as List<Color>,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (action['gradient'] as List<Color>)[0].withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Icon(action['icon'] as IconData, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      action['label'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (action['isPremium'] == true)
                                Positioned(
                                  top: -12,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 4)],
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
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón flotante para cerrar simulando el FAB
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0),
                          builder: (context, child) {
                            final val = ModalRoute.of(context)?.animation?.value ?? 1.0;
                            final angle = (val * (45 + 180)) * 3.1415927 / 180; // gira 180 + queda en 45 (X)
                            return Transform.rotate(
                              angle: angle,
                              child: Icon(LucideIcons.plus, color: isDark ? Colors.white : Colors.black, size: 32),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
