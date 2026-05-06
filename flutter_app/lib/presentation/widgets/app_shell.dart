import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/widgets/quick_actions_menu.dart';
import '../../presentation/widgets/modals/ai_chat_modal.dart';
import '../../presentation/widgets/modals/add_saving_goal_modal.dart';
import '../../presentation/widgets/rewards_shop_modal.dart';
import '../../presentation/providers/color_palette_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine current route using go_router inside GoRouterState
    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = -1;
    if (location == '/dashboard') currentIndex = 0;
    if (location == '/expenses') currentIndex = 1;
    if (location == '/debts') currentIndex = 3;
    if (location == '/settings') currentIndex = 4;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.backgroundDark 
          : AppColors.backgroundLight,
      body: SafeArea(
        child: child,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final action = await showDialog<String>(
            context: context,
            builder: (context) => const QuickActionsMenu(),
          );
          if (action != null) {
            if (!context.mounted) return;
            if (action == 'savings-goal') {
              AddSavingGoalModal.show(context);
            } else if (action == 'my-savings') {
              context.go('/savings');
            } else if (action == 'rewards-shop') {
              RewardsShopModal.show(context, points: 150);
            } else if (action == 'ai-chat') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AIChatModal(),
              );
            }
          }
        },
        backgroundColor: AppColors.primaryLight,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: paletteGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: paletteGradient[0].withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 'Inicio', LucideIcons.home, currentIndex == 0, '/dashboard', palette.colors[0]),
              _buildNavItem(context, 'Gastos', LucideIcons.trendingUp, currentIndex == 1, '/expenses', palette.colors[0]),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(context, 'Deudas', LucideIcons.creditCard, currentIndex == 3, '/debts', palette.colors[0]),
              _buildNavItem(context, 'Ajustes', LucideIcons.settings, currentIndex == 4, '/settings', palette.colors[0]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon, bool isSelected, String route, Color activeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? activeColor
        : (isDark ? Colors.grey[500] : Colors.grey[400]);

    return InkWell(
      onTap: () {
        context.go(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
