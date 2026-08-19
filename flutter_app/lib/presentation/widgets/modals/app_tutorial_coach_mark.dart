import 'package:flutter/material.dart';
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
        final bgColor = isDark ? const Color(0xFF131C2D) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              fontSize: 18.0,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => controller.next(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.get('next') ?? (loc.langCode.startsWith('en') ? 'Next' : 'Siguiente'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.arrowRight, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
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
