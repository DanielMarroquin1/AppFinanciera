import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/tutorial_keys.dart';
import 'dart:ui';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

  static Widget _buildDialogBox(String title, String description, IconData icon, Color color) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16.0,
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
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Toca para continuar \u279C",
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  static void showTutorial(BuildContext context, {VoidCallback? onFinish}) {
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
                "Balance General",
                "Este es tu centro de mando. Aquí verás el gran total de tu dinero disponible después de descontar tus gastos. ¡Tu salud financiera de un vistazo!",
                LucideIcons.wallet,
                const Color(0xFF38BDF8),
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
                "Ingresos",
                "Toca aquí para registrar rápidamente cualquier dinero que entre a tu cuenta, como tu salario, bonos o regalos.",
                LucideIcons.trendingUp,
                const Color(0xFF10B981),
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
                "Gastos",
                "Registra aquí todo lo que pagas, desde un café hasta el súper. Puedes ponerle categorías y recibos.",
                LucideIcons.trendingDown,
                const Color(0xFFEF4444),
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
                "Deudas",
                "Agrega préstamos personales o cuotas de tiendas. Te recordaremos cuándo pagarlos para que no caigas en mora.",
                LucideIcons.wallet,
                const Color(0xFF3B82F6),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "tarjetas",
        keyTarget: TutorialKeys.cardsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                "Tarjetas de Crédito",
                "Gestiona las fechas de corte y límites de tus tarjetas para nunca pasarte y no pagar intereses innecesarios.",
                LucideIcons.creditCard,
                const Color(0xFFF59E0B),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "ahorros",
        keyTarget: TutorialKeys.savingsNavKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                "Ahorros y Metas",
                "¡Crea metas de ahorro para ese viaje o coche nuevo! Podrás apartar el dinero mes a mes y ver tu progreso en tiempo real.",
                LucideIcons.piggyBank,
                const Color(0xFFEC4899),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "premium",
        keyTarget: TutorialKeys.premiumKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildDialogBox(
                "Plan Premium",
                "Tu presupuesto mensual, simulación de IA, y reportes en PDF se desbloquean con el Plan Premium. ¡Lleva tus finanzas al siguiente nivel!",
                LucideIcons.crown,
                const Color(0xFFD97706),
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF000000),
      textSkip: "SALTAR TUTORIAL",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 1.2,
      ),
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: onFinish,
      onSkip: () {
        if (onFinish != null) onFinish();
        return true;
      },
    )..show(context: context);
  }
}
