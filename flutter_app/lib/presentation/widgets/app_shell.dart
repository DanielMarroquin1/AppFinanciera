import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/quick_actions_menu.dart';
import '../../presentation/widgets/modals/ai_chat_modal.dart';
import '../../presentation/widgets/modals/add_saving_goal_modal.dart';
import '../../presentation/widgets/rewards_shop_modal.dart';
import '../../presentation/widgets/modals/notifications_modal.dart';
import '../../presentation/widgets/modals/category_budget_modal.dart';
import '../../presentation/widgets/modals/premium_paywall_dialog.dart';
import '../../presentation/widgets/modals/pdf_report_modal.dart';
import '../../presentation/providers/color_palette_provider.dart';
import '../../core/utils/localization.dart';
import '../screens/settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newValue = bottomInset > 0;
    if (newValue != _isKeyboardVisible) {
      setState(() => _isKeyboardVisible = newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current route using go_router inside GoRouterState
    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = -1;
    if (location == '/dashboard') currentIndex = 0;
    if (location == '/expenses') currentIndex = 1;
    if (location == '/savings') currentIndex = 3;
    if (location == '/settings') currentIndex = 4;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    final loc = ref.watch(localizationProvider);
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.backgroundDark 
          : AppColors.backgroundLight,
      resizeToAvoidBottomInset: false,
      drawer: const Drawer(
        child: SettingsScreen(),
      ),
      body: SafeArea(
        child: widget.child,
      ),
      floatingActionButton: _isKeyboardVisible
          ? null
          : FloatingActionButton(
              onPressed: () async {
                bool keepMenuOpen = true;
                while (keepMenuOpen && context.mounted) {
                  final action = await showGeneralDialog<String>(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Cerrar',
                    barrierColor: Colors.black.withOpacity(0.6),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: const QuickActionsMenu(),
                      );
                    },
                    transitionBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                          ),
                          child: child,
                        ),
                      );
                    },
                  );
                  
                  if (action == null) {
                    keepMenuOpen = false;
                    break;
                  }
                  
                  if (!context.mounted) break;
                  
                  keepMenuOpen = false; // Always close the menu after an action is selected
                  
                  if (action == 'what-if') {
                    final isPremium = ref.read(authProvider).user?.isPremium ?? false;
                    if (!isPremium) {
                      PremiumPaywallDialog.show(context, customMessage: 'Desbloquea el simulador inteligente "What If?" impulsado por IA con el Plan Premium.');
                    } else {
                      context.push('/what-if');
                    }
                  } else if (action == 'rewards-shop') {
                    await RewardsShopModal.show(context);
                  } else if (action == 'ai-chat') {
                    await AIChatModal.show(context);
                  } else if (action == 'notifications') {
                    await NotificationsModal.show(context);
                  } else if (action == 'category-budget') {
                    await CategoryBudgetModal.show(context);
                  } else if (action == 'pdf-report') {
                    if (ref.read(authProvider).user?.isPremium == true) {
                      await PDFReportModal.show(context);
                    } else {
                      await PremiumPaywallDialog.show(context, customMessage: 'Obtén Premium para generar reportes avanzados en PDF.');
                    }
                  }
                }
              },
              backgroundColor: paletteGradient[0],
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
      bottomNavigationBar: _isKeyboardVisible
          ? const SizedBox.shrink()
          : Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomAppBar(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, loc.get('home'), LucideIcons.home, currentIndex == 0, '/dashboard', palette.colors[0]),
                _buildNavItem(context, loc.get('expenses'), LucideIcons.trendingUp, currentIndex == 1, '/expenses', palette.colors[0]),
                const SizedBox(width: 48), // Space for FAB
                _buildNavItem(context, loc.get('savings'), LucideIcons.piggyBank, currentIndex == 3, '/savings', palette.colors[0]),
                _buildNavItem(context, loc.get('nav_settings'), LucideIcons.settings, currentIndex == 4, '/settings', palette.colors[0]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon, bool isSelected, String route, Color activeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? activeColor
        : (isDark ? Colors.grey[500] : const Color(0xFF64748B));

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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
