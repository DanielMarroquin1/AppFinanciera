import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/tutorial_keys.dart';
import '../../../core/utils/localization.dart';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

  static Widget _buildDialogBox(String title, String description, IconData icon, Color color, TutorialCoachMarkController controller, AppLocalizations loc) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => controller.next(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.get('next') ?? (loc.langCode.startsWith('en') ? 'Next' : 'Siguiente'),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  static String _translate(String es, String en, AppLocalizations loc) {
    return loc.langCode.startsWith('en') ? en : es;
  }

  static void showTutorial(BuildContext context, {required AppLocalizations loc, VoidCallback? onFinish}) {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "balance",
        keyTarget: TutorialKeys.balanceKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Balance General", "Total Balance", loc),
                _translate(
                  "Este es tu centro de mando. Aquí verás el gran total de tu dinero disponible después de descontar tus gastos. ¡Tu salud financiera de un vistazo!",
                  "This is your command center. Here you'll see your total available money after deducting expenses. Your financial health at a glance!",
                  loc
                ),
                LucideIcons.wallet,
                const Color(0xFF38BDF8),
                controller,
                loc,
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
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Ingresos", "Incomes", loc),
                _translate(
                  "Toca aquí para registrar rápidamente cualquier dinero que entre a tu cuenta, como tu salario, bonos o regalos.",
                  "Tap here to quickly log any money entering your account, like your salary, bonuses, or gifts.",
                  loc
                ),
                LucideIcons.trendingUp,
                const Color(0xFF10B981),
                controller,
                loc,
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
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Gastos", "Expenses", loc),
                _translate(
                  "Registra aquí todo lo que pagas, desde un café hasta el súper. Puedes ponerle categorías y recibos.",
                  "Log everything you pay here, from a coffee to groceries. You can add categories and receipts.",
                  loc
                ),
                LucideIcons.trendingDown,
                const Color(0xFFEF4444),
                controller,
                loc,
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
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Control de Deudas", "Debt Tracking", loc),
                _translate(
                  "Agrega tus préstamos o deudas pendientes. QUIVO te ayudará a crear un plan para pagarlas más rápido.",
                  "Add your loans or pending debts. QUIVO will help you create a plan to pay them off faster.",
                  loc
                ),
                LucideIcons.target,
                const Color(0xFFF59E0B),
                controller,
                loc,
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
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Ahorros y Metas", "Savings & Goals", loc),
                _translate(
                  "¡Crea metas de ahorro para ese viaje o coche nuevo! Podrás apartar el dinero mes a mes y ver tu progreso en tiempo real.",
                  "Create savings goals for that trip or new car! You can set aside money month by month and see your progress in real-time.",
                  loc
                ),
                LucideIcons.piggyBank,
                const Color(0xFFEC4899),
                controller,
                loc,
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
        radius: 35,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Tu Asesor IA", "Your AI Assistant", loc),
                _translate(
                  "Toca este botón para hablar con tu asistente inteligente. Puedes pedirle que analice tus gastos o te dé consejos personalizados.",
                  "Tap this button to talk to your smart assistant. You can ask it to analyze your expenses or give you personalized advice.",
                  loc
                ),
                LucideIcons.bot,
                const Color(0xFF6366F1),
                controller,
                loc,
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
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                _translate("Mis Tarjetas", "My Cards", loc),
                _translate(
                  "Administra todas tus tarjetas desde aquí. Podrás ver tus fechas de corte y límites de crédito.",
                  "Manage all your cards from here. You can check your statement dates and credit limits.",
                  loc
                ),
                LucideIcons.creditCard,
                const Color(0xFF8B5CF6),
                controller,
                loc,
              );
            },
          ),
        ],
      )
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFF1E293B),
      textSkip: loc.get('skip') ?? (loc.langCode.startsWith('en') ? "Skip" : "Saltar"),
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      paddingFocus: 10,
      opacityShadow: 0.85,
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
