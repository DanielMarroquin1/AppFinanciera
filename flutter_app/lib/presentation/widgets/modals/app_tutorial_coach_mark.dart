import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/utils/tutorial_keys.dart';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Balance General",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Aquí puedes ver el total de tu dinero en todos los meses. Mantente siempre al tanto de lo que has acumulado o ahorrado.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Menú Rápido",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Toca aquí para agregar rápidamente nuevos ingresos, gastos o pedirle ayuda a tu Asistente de IA. ¡Es tu centro de mando!",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Mantén tu Racha",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Entra todos los días para mantener la llama viva. Ganarás puntos y recompensas especiales.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Analítica Inteligente",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Nuestra IA estudiará todos tus movimientos y te dará consejos accionables cada día. ¡Léelos para mejorar!",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0F172A),
      textSkip: "SALTAR",
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
