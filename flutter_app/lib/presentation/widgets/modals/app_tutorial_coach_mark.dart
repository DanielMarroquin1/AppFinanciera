import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/tutorial_keys.dart';
import '../../../core/utils/localization.dart';

class AppTutorialCoachMark {
  static TutorialCoachMark? _tutorialCoachMark;

  // ─────────────────────────────────────────────────────────────────────────────
  // DICCIONARIO MULTILINGÜE COMPLETO (ES, EN, PT, FR, IT)
  // ─────────────────────────────────────────────────────────────────────────────

  static const Map<String, Map<String, String>> _translations = {
    'es': {
      'step': 'PASO',
      'of': 'DE',
      'next': 'Siguiente',
      'finish': '¡Entendido!',
      'skip': 'Saltar',
      'title_balance': 'Balance General',
      'desc_balance': 'Tu centro de mando. Aquí verás el gran total de tu dinero disponible después de descontar tus gastos.',
      'title_income': 'Registro de Ingresos',
      'desc_income': 'Toca aquí para registrar rápidamente cualquier dinero que entre a tu cuenta, como salario, bonos o ventas.',
      'title_expense': 'Registro de Gastos',
      'desc_expense': 'Anota todo lo que pagas en tu día a día, desde un café hasta el súper. ¡Mantén el control de tus finanzas!',
      'title_debts': 'Control de Deudas',
      'desc_debts': 'Registra tus préstamos o deudas pendientes. QUIVO te ayudará con un plan para pagarlas más rápido.',
      'title_cards': 'Mis Tarjetas',
      'desc_cards': 'Administra tus tarjetas de crédito y débito, fechas de corte y límites para no pagar intereses de más.',
      'title_ai': 'Acciones & Asistente IA',
      'desc_ai': 'Toca este botón central para hablar con tu asistente inteligente QUIVO, usar el simulador y atajos rápidos.',
      'title_savings': 'Ahorros y Metas',
      'desc_savings': '¡Crea metas para ese viaje o proyecto soñado! Podrás apartar dinero mes a mes y ver tu progreso en tiempo real.',
    },
    'en': {
      'step': 'STEP',
      'of': 'OF',
      'next': 'Next',
      'finish': 'Got it!',
      'skip': 'Skip',
      'title_balance': 'Total Balance',
      'desc_balance': 'Your command center. Here you see your total available money after deducting your expenses.',
      'title_income': 'Log Income',
      'desc_income': 'Tap here to quickly log any money entering your account, like salary, bonuses, or sales.',
      'title_expense': 'Log Expenses',
      'desc_expense': 'Track everything you pay day to day, from a coffee to groceries. Keep full control of your finances!',
      'title_debts': 'Debt Tracking',
      'desc_debts': 'Add your loans and pending debts. QUIVO will help you create a plan to pay them off faster.',
      'title_cards': 'My Cards',
      'desc_cards': 'Manage credit and debit cards, statement cut-off dates, and limits to avoid paying unnecessary fees.',
      'title_ai': 'Actions & AI Assistant',
      'desc_ai': 'Tap this center button to chat with your smart assistant QUIVO, use the financial simulator, and quick shortcuts.',
      'title_savings': 'Savings & Goals',
      'desc_savings': 'Create goals for that trip or dream project! Set money aside each month and track your progress in real-time.',
    },
    'pt': {
      'step': 'PASSO',
      'of': 'DE',
      'next': 'Próximo',
      'finish': 'Entendi!',
      'skip': 'Pular',
      'title_balance': 'Saldo Total',
      'desc_balance': 'Seu centro de comando. Aqui você vê o total do seu dinheiro disponível após descontar as despesas.',
      'title_income': 'Registrar Receita',
      'desc_income': 'Toque aqui para registrar rapidamente o dinheiro que entra, como salário, bônus ou vendas.',
      'title_expense': 'Registrar Despesa',
      'desc_expense': 'Anote tudo o que você gasta no dia a dia, do café ao supermercado. Mantenha o controle financeiro!',
      'title_debts': 'Controle de Dívidas',
      'desc_debts': 'Adicione seus empréstimos e dívidas pendentes. O QUIVO ajudará você a quitá-las mais rápido.',
      'title_cards': 'Meus Cartões',
      'desc_cards': 'Gerencie seus cartões de crédito e débito, datas de fechamento e limites para evitar juros.',
      'title_ai': 'Ações & Assistente IA',
      'desc_ai': 'Toque neste botão central para falar com seu assistente inteligente QUIVO e usar atalhos rápidos.',
      'title_savings': 'Metas e Poupança',
      'desc_savings': 'Crie metas para viagens ou projetos dos sonhos! Guarde dinheiro mês a mês e acompanhe seu progresso.',
    },
    'fr': {
      'step': 'ÉTAPE',
      'of': 'SUR',
      'next': 'Suivant',
      'finish': 'Compris !',
      'skip': 'Passer',
      'title_balance': 'Solde Total',
      'desc_balance': 'Votre centre de commande. Visualisez ici le total de votre argent disponible après déduction de vos dépenses.',
      'title_income': 'Ajouter un Revenu',
      'desc_income': 'Appuyez ici pour enregistrer rapidement les entrées d argent, comme le salaire ou les primes.',
      'title_expense': 'Ajouter une Dépense',
      'desc_expense': 'Notez tout ce que vous payez au quotidien, du café aux courses. Gardez le contrôle de vos finances !',
      'title_debts': 'Gestion des Dettes',
      'desc_debts': 'Ajoutez vos emprunts et dettes en cours. QUIVO vous aidera à les rembourser plus vite.',
      'title_cards': 'Mes Cartes',
      'desc_cards': 'Gérez vos cartes bancaires, dates de relevé et plafonds pour éviter les frais inutiles.',
      'title_ai': 'Actions & Assistant IA',
      'desc_ai': 'Appuyez sur ce bouton central pour échanger avec votre assistant IA QUIVO et accéder aux raccourcis.',
      'title_savings': 'Épargne et Objectifs',
      'desc_savings': 'Créez des objectifs pour vos projets de rêve ! Épargnez mois par mois et suivez vos progrès en temps réel.',
    },
    'it': {
      'step': 'PASSO',
      'of': 'DI',
      'next': 'Avanti',
      'finish': 'Ho capito!',
      'skip': 'Salta',
      'title_balance': 'Bilancio Totale',
      'desc_balance': 'Il tuo centro di controllo. Qui vedi il totale del tuo denaro disponibile dopo le spese.',
      'title_income': 'Registra Entrata',
      'desc_income': 'Tocca qui per registrare rapidamente le entrate sul tuo conto, come stipendio o vendite.',
      'title_expense': 'Registra Spesa',
      'desc_expense': 'Segna tutto ciò che paghi ogni giorno, dal caffè alla spesa. Mantieni il controllo delle tue finanze!',
      'title_debts': 'Gestione Debiti',
      'desc_debts': 'Aggiungi prestiti e debiti in sospeso. QUIVO ti aiuterà a creare un piano per estinguerli rapidamente.',
      'title_cards': 'Le Mie Carte',
      'desc_cards': 'Gestisci le tue carte di credito e debito, date di chiusura e limiti per non pagare interessi.',
      'title_ai': 'Azioni & Assistente IA',
      'desc_ai': 'Tocca questo pulsante centrale per parlare con il tuo assistente IA QUIVO e usare scorciatoie rapide.',
      'title_savings': 'Risparmi e Obiettivi',
      'desc_savings': 'Crea obiettivi per viaggi o progetti! Metti da parte denaro mese per mese e segui i tuoi progressi.',
    },
  };

  static String _str(String key, AppLocalizations loc) {
    final lang = loc.intlLocale; // 'es', 'en', 'pt', 'fr', 'it'
    return _translations[lang]?[key] ?? _translations['es']?[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CAJA DE DIÁLOGO REDISEÑADA Y RESPONSIVA PARA TELÉFONOS
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget _buildDialogBox(
    String titleKey,
    String descKey,
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
        final isLast = stepIndex >= totalSteps;
        final screenWidth = MediaQuery.of(context).size.width;

        final title = _str(titleKey, loc);
        final desc = _str(descKey, loc);
        final stepWord = _str('step', loc);
        final ofWord = _str('of', loc);
        final nextWord = isLast ? _str('finish', loc) : _str('next', loc);

        return Container(
          width: screenWidth > 420 ? 380 : screenWidth - 32,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con badge del paso e icono
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$stepWord $stepIndex $ofWord $totalSteps',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.x,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 18,
                          ),
                          onPressed: () => controller.skip(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Descripción
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Barra inferior con puntos de progreso y botón Siguiente
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Puntos de progreso
                        Row(
                          children: List.generate(totalSteps, (index) {
                            final isActive = index + 1 == stepIndex;
                            final isPassed = index + 1 < stepIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 4),
                              width: isActive ? 16 : 6,
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

                        // Botón de acción Siguiente / Entendido
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
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.85)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nextWord,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  isLast ? LucideIcons.check : LucideIcons.arrowRight,
                                  color: Colors.white,
                                  size: 14,
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

  // ─────────────────────────────────────────────────────────────────────────────
  // LANZADOR DEL TUTORIAL
  // ─────────────────────────────────────────────────────────────────────────────

  static void showTutorial(
    BuildContext context, {
    required AppLocalizations loc,
    VoidCallback? onFinish,
  }) {
    // Definir los 7 pasos clave
    final stepConfigs = [
      {
        'id': 'balance',
        'key': TutorialKeys.balanceKey,
        'align': ContentAlign.bottom,
        'shape': ShapeLightFocus.RRect,
        'radius': 22.0,
        'padding': 6.0,
        'icon': LucideIcons.wallet,
        'color': const Color(0xFF38BDF8),
        'titleKey': 'title_balance',
        'descKey': 'desc_balance',
      },
      {
        'id': 'income',
        'key': TutorialKeys.incomeKey,
        'align': ContentAlign.bottom,
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFF10B981),
        'titleKey': 'title_income',
        'descKey': 'desc_income',
      },
      {
        'id': 'expense',
        'key': TutorialKeys.expenseKey,
        'align': ContentAlign.bottom,
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.trendingDown,
        'color': const Color(0xFFEF4444),
        'titleKey': 'title_expense',
        'descKey': 'desc_expense',
      },
      {
        'id': 'debts',
        'key': TutorialKeys.debtsKey,
        'align': ContentAlign.bottom,
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.target,
        'color': const Color(0xFF3B82F6),
        'titleKey': 'title_debts',
        'descKey': 'desc_debts',
      },
      {
        'id': 'cards',
        'key': TutorialKeys.cardsKey,
        'align': ContentAlign.bottom,
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.creditCard,
        'color': const Color(0xFFF59E0B),
        'titleKey': 'title_cards',
        'descKey': 'desc_cards',
      },
      {
        'id': 'ai_actions',
        'key': TutorialKeys.aiInsightsKey,
        'align': ContentAlign.top,
        'shape': ShapeLightFocus.Circle,
        'radius': 30.0,
        'padding': 4.0,
        'icon': LucideIcons.sparkles,
        'color': const Color(0xFF8B5CF6),
        'titleKey': 'title_ai',
        'descKey': 'desc_ai',
      },
      {
        'id': 'savings',
        'key': TutorialKeys.savingsNavKey,
        'align': ContentAlign.top,
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 4.0,
        'icon': LucideIcons.piggyBank,
        'color': const Color(0xFFEC4899),
        'titleKey': 'title_savings',
        'descKey': 'desc_savings',
      },
    ];

    // FILTRO DE SEGURIDAD: Solo añadir los elementos que realmente estén montados en el árbol
    final validConfigs = stepConfigs.where((cfg) {
      final key = cfg['key'] as GlobalKey?;
      return key != null && key.currentContext != null;
    }).toList();

    if (validConfigs.isEmpty) return;

    final totalSteps = validConfigs.length;

    final List<TargetFocus> targets = [];
    for (int idx = 0; idx < validConfigs.length; idx++) {
      final cfg = validConfigs[idx];
      final stepNum = idx + 1;

      targets.add(
        TargetFocus(
          identify: cfg['id'] as String,
          keyTarget: cfg['key'] as GlobalKey,
          alignSkip: Alignment.topRight,
          shape: cfg['shape'] as ShapeLightFocus,
          radius: cfg['radius'] as double,
          paddingFocus: cfg['padding'] as double,
          contents: [
            TargetContent(
              align: cfg['align'] as ContentAlign,
              builder: (context, controller) {
                return _buildDialogBox(
                  cfg['titleKey'] as String,
                  cfg['descKey'] as String,
                  cfg['icon'] as IconData,
                  cfg['color'] as Color,
                  controller,
                  loc,
                  stepIndex: stepNum,
                  totalSteps: totalSteps,
                );
              },
            ),
          ],
        ),
      );
    }

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF030712),
      skipWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _str('skip', loc),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.x, color: Colors.white, size: 13),
          ],
        ),
      ),
      paddingFocus: 4,
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
