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
  int _selectedTab = 0; // 0: Todas, 1: Desbloqueadas, 2: Pendientes

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
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final user = ref.watch(authProvider).user;

    if (user == null) return const SizedBox.shrink();

    // Define all badges and progress
    final badges = [
      {
        'id': 'profile',
        'title': 'Pionero Antigravity',
        'description': 'Completa tu perfil e identidad',
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF3B82F6), // Blue
        'current': user.profileComplete ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'streak_7',
        'title': 'Fuego Constante',
        'description': 'Mantén una racha de 7 días continuos',
        'icon': LucideIcons.flame,
        'color': const Color(0xFFF97316), // Orange
        'current': user.currentStreak > 7 ? 7 : user.currentStreak,
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': 'Maestro del Hábito',
        'description': '30 días ininterrumpidos en la app',
        'icon': LucideIcons.award,
        'color': const Color(0xFFEAB308), // Yellow
        'current': user.currentStreak > 30 ? 30 : user.currentStreak,
        'target': 30,
      },
      {
        'id': 'shopper_1',
        'title': 'Comprador VIP',
        'description': 'Canjea tu primer ítem en la tienda',
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFF8B5CF6), // Purple
        'current': user.unlockedItems.isNotEmpty ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'shopper_5',
        'title': 'Coleccionista Supremo',
        'description': 'Adquiere 5 ítems o temas exclusivos',
        'icon': LucideIcons.crown,
        'color': const Color(0xFFEC4899), // Pink
        'current': user.unlockedItems.length > 5 ? 5 : user.unlockedItems.length,
        'target': 5,
      },
      {
        'id': 'saver_100',
        'title': 'Mente Financiera',
        'description': 'Acumula 100 puntos de experiencia',
        'icon': LucideIcons.piggyBank,
        'color': const Color(0xFF06B6D4), // Cyan
        'current': user.points > 100 ? 100 : user.points,
        'target': 100,
      },
    ];

    final unlockedCount = badges.where((b) => (b['current'] as int) >= (b['target'] as int)).length;
    final pendingCount = badges.length - unlockedCount;

    final filteredBadges = badges.where((b) {
      final isUnlocked = (b['current'] as int) >= (b['target'] as int);
      if (_selectedTab == 1) return isUnlocked;
      if (_selectedTab == 2) return !isUnlocked;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        children: [
          // Elegant Handle
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 16),
            height: 5, width: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(LucideIcons.trophy, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salón de Trofeos', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text('$unlockedCount de ${badges.length} desbloqueados (${((unlockedCount/badges.length)*100).toInt()}%)', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[300] : Colors.grey[700], size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildTabChip(isDark, 0, '🌟 Todas', badges.length),
                const SizedBox(width: 10),
                _buildTabChip(isDark, 1, '🏆 Obtenidas', unlockedCount),
                const SizedBox(width: 10),
                _buildTabChip(isDark, 2, '🔒 Pendientes', pendingCount),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 1),

          // Badges List
          Expanded(
            child: filteredBadges.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.award, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _selectedTab == 1 ? 'Aún no has desbloqueado insignias en esta categoría' : '¡Excelente! Has completado todas las insignias',
                          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredBadges.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final badge = filteredBadges[index];
                      final current = badge['current'] as int;
                      final target = badge['target'] as int;
                      final isUnlocked = current >= target;
                      final baseColor = badge['color'] as Color;

                      return AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          final delay = (index * 0.08).clamp(0.0, 0.6);
                          final fadeAnim = CurvedAnimation(
                            parent: _entranceController,
                            curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeIn),
                          );
                          return Opacity(
                            opacity: fadeAnim.value,
                            child: child,
                          );
                        },
                        child: _buildAchievementCard(
                          context,
                          badge: badge,
                          isUnlocked: isUnlocked,
                          baseColor: baseColor,
                          isDark: isDark,
                          current: current,
                          target: target,
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildTabChip(bool isDark, int tabIndex, String label, int count) {
    final isSelected = _selectedTab == tabIndex;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tabIndex),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
            color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, {
    required Map<String, dynamic> badge,
    required bool isUnlocked,
    required Color baseColor,
    required bool isDark,
    required int current,
    required int target,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
            : (isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked
              ? baseColor.withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUnlocked ? 2 : 1.5,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: baseColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(colors: [baseColor.withValues(alpha: 0.9), baseColor], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
              color: isUnlocked ? null : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnlocked ? Colors.white.withValues(alpha: 0.4) : Colors.transparent,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [BoxShadow(color: baseColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(
              isUnlocked ? (badge['icon'] as IconData) : LucideIcons.lock,
              color: isUnlocked ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[400]),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Details & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        badge['title'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: baseColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles, color: baseColor, size: 12),
                            const SizedBox(width: 4),
                            Text('OBTENIDA', style: TextStyle(color: baseColor, fontSize: 10, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge['description'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isUnlocked
                                    ? [baseColor.withValues(alpha: 0.8), baseColor]
                                    : [const Color(0xFF6366F1), const Color(0xFF818CF8)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isUnlocked
                                  ? [BoxShadow(color: baseColor.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 1))]
                                  : [],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$current/$target',
                      style: TextStyle(
                        color: isUnlocked ? baseColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
