import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/quick_actions_menu.dart';
import '../../presentation/widgets/modals/add_expense_modal.dart';
import '../../presentation/widgets/modals/add_income_modal.dart';
import '../../presentation/widgets/modals/avatar_selector_modal.dart';
import '../../presentation/widgets/modals/ai_chat_modal.dart';
import '../../presentation/widgets/modals/notifications_modal.dart';
import '../../core/utils/app_haptics.dart';
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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isKeyboardVisible = false;
  late AnimationController _fabController;

  @override
  void initState() {
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _fabController.dispose();
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
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: paletteGradient.first.withValues(alpha: isDark ? 0.25 : 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: paletteGradient.last.withValues(alpha: isDark ? 0.2 : 0.1),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          SafeArea(child: widget.child),
        ],
      ),

      bottomNavigationBar: _isKeyboardVisible
          ? const SizedBox.shrink()
          : SafeArea(
              child: Container(
                height: 72,
                margin: const EdgeInsets.only(left: 18, right: 18, bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.40)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.80),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedNavItem(
                        context,
                        loc.get('home'),
                        LucideIcons.home,
                        currentIndex == 0,
                        '/dashboard',
                        paletteGradient[0],
                      ),
                      _buildAnimatedNavItem(
                        context,
                        loc.get('expenses'),
                        LucideIcons.trendingUp,
                        currentIndex == 1,
                        '/expenses',
                        paletteGradient[0],
                      ),

                      // Center FAB
                      BounceTap(
                        key: TutorialKeys.centerFabKey,
                        scaleDown: 0.90,
                        hapticType: HapticType.medium,
                        onTap: () async {
                          _fabController.forward();
                          bool keepMenuOpen = true;
                          while (keepMenuOpen && context.mounted) {
                            final action = await showGeneralDialog<String>(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Cerrar',
                              barrierColor: Colors.black.withValues(alpha: 0.65),
                              transitionDuration: const Duration(
                                milliseconds: 320,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                    return const QuickActionsMenu();
                                  },
                              transitionBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final curved = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                      reverseCurve: Curves.easeInCubic,
                                    );
                                    return ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.88,
                                        end: 1.0,
                                      ).animate(curved),
                                      child: FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                          reverseCurve: Curves.easeIn,
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

                            if (action == 'expense') {
                              await AddExpenseModal.show(context);
                            } else if (action == 'income') {
                              await AddIncomeModal.show(context);
                            } else if (action == 'armario-sami' || action == 'rewards-shop') {
                              final authUser = ref.read(authProvider).user;
                              await AvatarSelectorModal.show(
                                context,
                                currentAvatarId: authUser?.currentAvatar ??
                                    authUser?.avatarEmoji ??
                                    'sami_default',
                                unlockedItems: authUser?.unlockedItems ?? [],
                                onAvatarSelected: (id) {},
                              );
                            } else if (action == 'what-if') {
                              final isPremium =
                                  ref.read(authProvider).user?.isPremium ??
                                  false;
                              if (!isPremium) {
                                PremiumPaywallDialog.show(
                                  context,
                                  customMessage:
                                      loc.get('what_if_paywall_desc'),
                                );
                              } else {
                                context.push('/what-if');
                              }
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
                                      loc.get('pdf_report_paywall_desc'),
                                );
                              }
                            }
                          }
                          _fabController.reverse();
                        },
                        child: RotationTransition(
                          turns: Tween(begin: 0.0, end: 0.375).animate(
                            CurvedAnimation(parent: _fabController, curve: Curves.easeInOutCubic),
                          ),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.40 : 0.16,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      _buildAnimatedNavItem(
                        context,
                        loc.get('savings'),
                        LucideIcons.piggyBank,
                        currentIndex == 3,
                        '/savings',
                        paletteGradient[0],
                        key: TutorialKeys.savingsNavKey,
                      ),
                      _buildAnimatedNavItem(
                        context,
                        loc.get('nav_settings'),
                        LucideIcons.settings,
                        currentIndex == 4,
                        '/settings',
                        paletteGradient[0],
                      ),
                    ],
                  ),
                ),
              ),
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
    
    return BounceTap(
      key: key,
      scaleDown: 0.88,
      hapticType: HapticType.selection,
      onTap: () {
        context.go(route);
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              bottom: isSelected ? 8 : -10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              top: isSelected ? 12 : 18,
              child: Icon(
                icon,
                color: isSelected 
                    ? activeColor 
                    : (isDark ? Colors.white54 : Colors.black54),
                size: isSelected ? 26 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
