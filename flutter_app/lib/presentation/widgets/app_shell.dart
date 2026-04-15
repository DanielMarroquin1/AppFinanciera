import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/widgets/quick_actions_menu.dart';
import '../../presentation/widgets/modals/add_income_modal.dart';
import '../../presentation/widgets/modals/add_expense_modal.dart';
import '../../presentation/widgets/modals/ai_chat_modal.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine current route using go_router inside GoRouterState
    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location == '/dashboard') currentIndex = 0;
    if (location == '/expenses') currentIndex = 1;
    if (location == '/debts') currentIndex = 3;
    if (location == '/settings') currentIndex = 4;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            if (action == 'income') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddIncomeModal(),
              );
            } else if (action == 'expense') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddExpenseModal(),
              );
            } else if (action == 'ai-chat') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AIChatModal(),
              );
            } else {
              print('Selected action: $action');
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
              colors: isDark 
                  ? [const Color(0xFF4338CA), const Color(0xFF059669)] // indigo-700 to emerald-600
                  : [const Color(0xFF4F46E5), const Color(0xFF10B981)], // indigo-600 to emerald-500
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
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
              _buildNavItem(context, 'Inicio', LucideIcons.home, currentIndex == 0, '/dashboard'),
              _buildNavItem(context, 'Gastos', LucideIcons.trendingUp, currentIndex == 1, '/expenses'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(context, 'Deudas', LucideIcons.creditCard, currentIndex == 3, '/debts'),
              _buildNavItem(context, 'Ajustes', LucideIcons.settings, currentIndex == 4, '/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon, bool isSelected, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? const Color(0xFF4F46E5) // text-indigo-600
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
