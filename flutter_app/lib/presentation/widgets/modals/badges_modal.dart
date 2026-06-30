import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class BadgesModal extends ConsumerWidget {
  const BadgesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _BadgesModalInternal(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _BadgesModalInternal extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _BadgesModalInternal({required this.scrollController});

  @override
  ConsumerState<_BadgesModalInternal> createState() => _BadgesModalInternalState();
}

class _BadgesModalInternalState extends ConsumerState<_BadgesModalInternal> with TickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC); // Deeper background
    final user = ref.watch(authProvider).user;

    if (user == null) return const SizedBox.shrink();

    // Define all badges and progress
    final badges = [
      {
        'id': 'profile',
        'title': 'Pionero',
        'description': 'Completa tu perfil',
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF3B82F6), // Blue
        'current': user.profileComplete ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'streak_7',
        'title': 'Constante',
        'description': '7 días seguidos',
        'icon': LucideIcons.flame,
        'color': const Color(0xFFF97316), // Orange
        'current': user.currentStreak > 7 ? 7 : user.currentStreak,
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': 'Maestro',
        'description': '30 días seguidos',
        'icon': LucideIcons.award,
        'color': const Color(0xFFEAB308), // Yellow
        'current': user.currentStreak > 30 ? 30 : user.currentStreak,
        'target': 30,
      },
      {
        'id': 'shopper_1',
        'title': 'Comprador',
        'description': '1 ítem en tienda',
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFF8B5CF6), // Purple
        'current': user.unlockedItems.isNotEmpty ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'shopper_5',
        'title': 'Coleccionista',
        'description': '5 ítems en tienda',
        'icon': LucideIcons.crown,
        'color': const Color(0xFFEC4899), // Pink
        'current': user.unlockedItems.length > 5 ? 5 : user.unlockedItems.length,
        'target': 5,
      },
      {
        'id': 'saver_100',
        'title': 'Ahorrador',
        'description': 'Acumula 100 puntos',
        'icon': LucideIcons.piggyBank,
        'color': const Color(0xFF06B6D4), // Cyan
        'current': user.points > 100 ? 100 : user.points,
        'target': 100,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        children: [
          // Elegant Handle
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            height: 5, width: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logros e Insignias', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Colecciona todas para demostrar tu maestría', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.white : Colors.black, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Badges Grid
          Expanded(
            child: GridView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final current = badge['current'] as int;
                final target = badge['target'] as int;
                final isUnlocked = current >= target;
                final baseColor = badge['color'] as Color;

                return AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final slideAnim = CurvedAnimation(
                      parent: _entranceController,
                      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
                    );
                    final fadeAnim = CurvedAnimation(
                      parent: _entranceController,
                      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeIn),
                    );

                    return Opacity(
                      opacity: fadeAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - slideAnim.value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildPremiumBadge(
                    context, 
                    badge: badge, 
                    isUnlocked: isUnlocked, 
                    baseColor: baseColor, 
                    isDark: isDark, 
                    current: current, 
                    target: target
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumBadge(BuildContext context, {
    required Map<String, dynamic> badge,
    required bool isUnlocked,
    required Color baseColor,
    required bool isDark,
    required int current,
    required int target,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked 
            ? (isDark ? const Color(0xFF1E293B) : Colors.white) 
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isUnlocked 
              ? baseColor.withOpacity(0.5) 
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(color: baseColor.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: baseColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ] : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow for unlocked
          if (isUnlocked)
            Positioned(
              top: 20,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
              ),
            ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Floating Icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOutSine,
                builder: (context, double val, child) {
                  return Transform.translate(
                    offset: Offset(0, isUnlocked ? (val - 0.5) * 8 : 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked ? LinearGradient(
                      colors: [baseColor.withOpacity(0.8), baseColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                    color: isUnlocked ? null : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    border: Border.all(
                      color: isUnlocked ? Colors.white.withOpacity(0.5) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isUnlocked ? [
                      BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6)),
                    ] : [],
                  ),
                  child: isUnlocked 
                      ? Icon(badge['icon'] as IconData, color: Colors.white, size: 40)
                      : Icon(LucideIcons.lock, color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8), size: 32),
                ),
              ),
              
              const Spacer(),
              
              // Texts
              Text(
                badge['title'] as String,
                style: TextStyle(
                  color: isUnlocked ? (isDark ? Colors.white : Colors.black) : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  badge['description'] as String,
                  style: TextStyle(
                    color: isUnlocked ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    fontSize: 11,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const Spacer(),
              
              // Progress Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$current / $target',
                          style: TextStyle(
                            color: isUnlocked ? baseColor : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isUnlocked)
                          Icon(LucideIcons.sparkles, color: baseColor, size: 14)
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (current / target).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnlocked ? baseColor : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isUnlocked ? [
                              BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1)),
                            ] : [],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
