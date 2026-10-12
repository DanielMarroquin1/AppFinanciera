import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/tutorial_keys.dart';
import '../../../core/utils/localization.dart';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

  static Widget _buildDialogBox(
    String title,
    String description,
    IconData icon,
    Color color,
    TutorialCoachMarkController controller,
    AppLocalizations loc, {
    required int stepIndex,
    required int totalSteps,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLast = stepIndex == totalSteps;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Icon badge, Title, Step Pill, and Skip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'PASO  DE ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.skip(),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                LucideIcons.x,
                                color: isDark ? Colors.white38 : Colors.black38,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Description text
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bottom progress indicator and Next button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots progress indicator
                        Row(
                          children: List.generate(totalSteps, (index) {
                            final isActive = index + 1 == stepIndex;
                            final isPassed = index + 1 < stepIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 5),
                              width: isActive ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? color
                                    : (isPassed
                                        ? color.withValues(alpha: 0.4)
                                        : (isDark ? Colors.white12 : Colors.black12)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),

                        // Action button
                        GestureDetector(
                          onTap: () {
                            if (isLast) {
                              controller.skip();
                            } else {
                              controller.next();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.85)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLast
                                      ? (loc.langCode.startsWith('en') ? 'Get Started' : '¡Entendido!')
                                      : (loc.get('next') ?? (loc.langCode.startsWith('en') ? 'Next' : 'Siguiente')),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  isLast ? LucideIcons.check : LucideIcons.arrowRight,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _translate(String es, String en, AppLocalizations loc) {
    return loc.langCode.startsWith('en') ? en : es;
  }

  static void showTutorial(
    BuildContext context, {
    required AppLocalizations loc,
    VoidCallback? onFinish,
  }) {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "balance",
        keyTarget: TutorialKeys.balanceKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Balance General", "Total Balance", loc),
                _translate(
                  "Este es tu centro de mando. Aquí verás el gran total de tu dinero disponible después de descontar tus gastos. ¡Tu salud financiera de un vistazo!",
                  "This is your command center. Here you'll see your total available money after deducting expenses. Your financial health at a glance!",
                  loc,
                ),
                LucideIcons.wallet,
                const Color(0xFF38BDF8),
                controller,
                loc,
                stepIndex: 1,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "ingresos",
        keyTarget: TutorialKeys.incomeKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Ingresos", "Incomes", loc),
                _translate(
                  "Toca aquí para registrar rápidamente cualquier dinero que entre a tu cuenta, como tu salario, bonos o regalos.",
                  "Tap here to quickly log any money entering your account, like your salary, bonuses, or gifts.",
                  loc,
                ),
                LucideIcons.trendingUp,
                const Color(0xFF10B981),
                controller,
                loc,
                stepIndex: 2,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "gastos",
        keyTarget: TutorialKeys.expenseKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Gastos", "Expenses", loc),
                _translate(
                  "Registra aquí todo lo que pagas, desde un café hasta el súper. Puedes ponerle categorías y recibos.",
                  "Log everything you pay here, from a coffee to groceries. You can add categories and receipts.",
                  loc,
                ),
                LucideIcons.trendingDown,
                const Color(0xFFEF4444),
                controller,
                loc,
                stepIndex: 3,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "deudas",
        keyTarget: TutorialKeys.debtsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Control de Deudas", "Debt Tracking", loc),
                _translate(
                  "Agrega tus préstamos o deudas pendientes. QUIVO te ayudará a crear un plan para pagarlas más rápido.",
                  "Add your loans or pending debts. QUIVO will help you create a plan to pay them off faster.",
                  loc,
                ),
                LucideIcons.target,
                const Color(0xFFF59E0B),
                controller,
                loc,
                stepIndex: 4,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "ahorros",
        keyTarget: TutorialKeys.savingsNavKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Ahorros y Metas", "Savings & Goals", loc),
                _translate(
                  "¡Crea metas de ahorro para ese viaje o coche nuevo! Podrás apartar el dinero mes a mes y ver tu progreso en tiempo real.",
                  "Create savings goals for that trip or new car! You can set aside money month by month and see your progress in real-time.",
                  loc,
                ),
                LucideIcons.piggyBank,
                const Color(0xFFEC4899),
                controller,
                loc,
                stepIndex: 5,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "ia",
        keyTarget: TutorialKeys.aiInsightsKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        radius: 38,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Tu Asesor IA", "Your AI Assistant", loc),
                _translate(
                  "Toca este botón para hablar con tu asistente inteligente. Puedes pedirle que analice tus gastos o te dé consejos personalizados.",
                  "Tap this button to talk to your smart assistant. You can ask it to analyze your expenses or give you personalized advice.",
                  loc,
                ),
                LucideIcons.bot,
                const Color(0xFF6366F1),
                controller,
                loc,
                stepIndex: 6,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "tarjetas",
        keyTarget: TutorialKeys.cardsKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Mis Tarjetas", "My Cards", loc),
                _translate(
                  "Administra todas tus tarjetas desde aquí. Podrás ver tus fechas de corte y límites de crédito.",
                  "Manage all your cards from here. You can check your statement dates and credit limits.",
                  loc,
                ),
                LucideIcons.creditCard,
                const Color(0xFF8B5CF6),
                controller,
                loc,
                stepIndex: 7,
                totalSteps: 7,
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF030712),
      skipWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.get('skip') ?? (loc.langCode.startsWith('en') ? "Skip" : "Saltar"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(LucideIcons.x, color: Colors.white, size: 14),
          ],
        ),
      ),
      paddingFocus: 12,
      opacityShadow: 0.85,
      pulseEnable: true,
      onFinish: () {
        if (onFinish != null) onFinish();
      },
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onSkip: () {
        if (onFinish != null) onFinish();
        return true;
      },
    )..show(context: context);
  }
}
