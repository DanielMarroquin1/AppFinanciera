import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/tutorial_keys.dart';
import 'dart:ui';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

  static Widget _buildDialogBox(String title, String description, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.5), width: 1),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Toca en cualquier parte para continuar \u279C",
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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
                "Aquí puedes ver el total de tu dinero en todos los meses. Mantente siempre al tanto de lo que has acumulado o ahorrado.",
                LucideIcons.wallet,
                const Color(0xFF38BDF8),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "quickActions",
        keyTarget: TutorialKeys.quickActionsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                "Menú Rápido",
                "Toca aquí para agregar rápidamente nuevos ingresos, gastos o pedirle ayuda a tu Asistente de IA. ¡Es tu centro de mando!",
                LucideIcons.zap,
                const Color(0xFFA855F7),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "streak",
        keyTarget: TutorialKeys.streakKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildDialogBox(
                "Mantén tu Racha",
                "Entra todos los días para mantener la llama viva. Ganarás puntos y recompensas especiales.",
                LucideIcons.flame,
                const Color(0xFFF97316),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "aiInsights",
        keyTarget: TutorialKeys.aiInsightsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 15,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildDialogBox(
                "Analítica Inteligente",
                "Nuestra IA estudiará todos tus movimientos y te dará consejos accionables cada día. ¡Léelos para mejorar!",
                LucideIcons.brain,
                const Color(0xFF10B981),
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
