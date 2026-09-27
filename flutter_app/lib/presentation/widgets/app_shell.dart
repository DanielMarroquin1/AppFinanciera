import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../core/utils/tutorial_keys.dart';
import '../screens/settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
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
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
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
    final paletteGradient = ref
        .read(colorPaletteProvider.notifier)
        .getGradient(isDark);
    final loc = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      resizeToAvoidBottomInset: false,
      drawer: const Drawer(child: SettingsScreen()),
      body: SafeArea(child: widget.child),

      bottomNavigationBar: _isKeyboardVisible
          ? const SizedBox.shrink()
          : SafeArea(
              child: Container(
                height: 72,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFF0F172A).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedNavItem(
                      context,
                      loc.get('home') ?? 'Inicio',
                      LucideIcons.home,
                      currentIndex == 0,
                      '/dashboard',
                      paletteGradient[0],
                    ),
                    _buildAnimatedNavItem(
                      context,
                      loc.get('expenses') ?? 'Gastos',
                      LucideIcons.trendingUp,
                      currentIndex == 1,
                      '/expenses',
                      paletteGradient[0],
                    ),

                    // Center FAB
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        bool keepMenuOpen = true;
                        while (keepMenuOpen && context.mounted) {
                          final action = await showGeneralDialog<String>(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'Cerrar',
                            barrierColor: Colors.black.withOpacity(0.6),
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                                  return BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: const QuickActionsMenu(),
                                  );
                                },
                            transitionBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.9, end: 1.0)
                                          .animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
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

                          keepMenuOpen = false;

                          if (action == 'what-if') {
                            final isPremium =
                                ref.read(authProvider).user?.isPremium ?? false;
                            if (!isPremium) {
                              PremiumPaywallDialog.show(
                                context,
                                customMessage:
                                    'Desbloquea el simulador inteligente "What If?" impulsado por IA con el Plan Premium.',
                              );
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
                            if (ref.read(authProvider).user?.isPremium ==
                                true) {
                              await PDFReportModal.show(context);
                            } else {
                              await PremiumPaywallDialog.show(
                                context,
                                customMessage:
                                    'Obtén Premium para generar reportes avanzados en PDF.',
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [paletteGradient[0], paletteGradient[1]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: paletteGradient[0].withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.plus,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    _buildAnimatedNavItem(
                      context,
                      loc.get('savings') ?? 'Metas',
                      LucideIcons.piggyBank,
                      currentIndex == 3,
                      '/savings',
                      paletteGradient[0],
                      key: TutorialKeys.savingsNavKey,
                    ),
                    _buildAnimatedNavItem(
                      context,
                      loc.get('nav_settings') ?? 'Ajustes',
                      LucideIcons.settings,
                      currentIndex == 4,
                      '/settings',
                      paletteGradient[0],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAnimatedNavItem(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    String route,
    Color activeColor, {
    Key? key,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isSelected) HapticFeedback.lightImpact();
        context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.grey[500] : const Color(0xFF64748B)),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
