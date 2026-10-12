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
      'target_balance': 'Balance General',
      'target_income': 'Botón Ingresos',
      'target_expense': 'Botón Gastos',
      'target_debts': 'Botón Deudas',
      'target_cards': 'Botón Tarjetas',
      'target_quick': 'Botón Central (+)',
      'target_savings': 'Pestaña Metas',
      'title_balance': 'Balance General',
      'desc_balance': 'Tu centro de mando. Aquí verás el gran total de tu dinero disponible tras descontar tus gastos.',
      'title_income': 'Registro de Ingresos',
      'desc_income': 'Toca aquí para registrar rápidamente cualquier dinero que entre, como salario, cobros o ventas.',
      'title_expense': 'Registro de Gastos',
      'desc_expense': 'Anota todo lo que pagas en el día a día, desde un café hasta el súper. ¡Mantén el control total!',
      'title_debts': 'Control de Deudas',
      'desc_debts': 'Registra tus préstamos o deudas pendientes. QUIVO te ayudará a armar un plan para liquidarlas.',
      'title_cards': 'Mis Tarjetas',
      'desc_cards': 'Administra tus tarjetas de crédito y débito, fechas de corte y límites para no pagar intereses.',
      'title_quick': 'Menú de Acciones (+)',
      'desc_quick': 'Toca este botón central (+) para acceder al simulador financiero, presupuesto por categorías y herramientas avanzadas.',
      'title_savings': 'Ahorros y Metas',
      'desc_savings': '¡Crea metas para viajes o proyectos soñados! Aparta dinero mes a mes y monitorea tu progreso.',
    },
    'en': {
      'step': 'STEP',
      'of': 'OF',
      'next': 'Next',
      'finish': 'Got it!',
      'skip': 'Skip',
      'target_balance': 'Total Balance',
      'target_income': 'Income Button',
      'target_expense': 'Expense Button',
      'target_debts': 'Debts Button',
      'target_cards': 'Cards Button',
      'target_quick': 'Center Button (+)',
      'target_savings': 'Goals Tab',
      'title_balance': 'Total Balance',
      'desc_balance': 'Your command center. View your total available money after deducting your expenses.',
      'title_income': 'Log Income',
      'desc_income': 'Tap here to quickly log any money coming in, like salary, bonus, or sales.',
      'title_expense': 'Log Expenses',
      'desc_expense': 'Track everyday expenses, from coffee to groceries. Keep full control of your finances!',
      'title_debts': 'Debt Tracking',
      'desc_debts': 'Add your loans and debts. QUIVO will help you create a smart plan to pay them off.',
      'title_cards': 'My Cards',
      'desc_cards': 'Manage credit and debit cards, statement cut-offs, and limits to avoid excess fees.',
      'title_quick': 'Quick Actions (+)',
      'desc_quick': 'Tap this center button (+) to open the financial simulator, category budgets, and advanced tools.',
      'title_savings': 'Savings & Goals',
      'desc_savings': 'Create goals for dream trips or projects! Set money aside each month and track progress in real-time.',
    },
    'pt': {
      'step': 'PASSO',
      'of': 'DE',
      'next': 'Próximo',
      'finish': 'Entendi!',
      'skip': 'Pular',
      'target_balance': 'Saldo Total',
      'target_income': 'Botão Receitas',
      'target_expense': 'Botão Despesas',
      'target_debts': 'Botão Dívidas',
      'target_cards': 'Botão Cartões',
      'target_quick': 'Botão Central (+)',
      'target_savings': 'Aba Metas',
      'title_balance': 'Saldo Total',
      'desc_balance': 'Seu centro de comando. Veja o total do seu dinheiro disponível após descontar despesas.',
      'title_income': 'Registrar Receita',
      'desc_income': 'Toque aqui para registrar rapidamente salário, rendimentos ou vendas.',
      'title_expense': 'Registrar Despesa',
      'desc_expense': 'Anote o que você gasta no dia a dia, do cafezinho às compras. Tenha controle total!',
      'title_debts': 'Controle de Dívidas',
      'desc_debts': 'Adicione seus empréstimos e pendências. O QUIVO ajudará você a quitá-los mais rápido.',
      'title_cards': 'Meus Cartões',
      'desc_cards': 'Gerencie cartões de crédito e débito, faturas e limites para evitar cobranças de juros.',
      'title_quick': 'Menu de Ações (+)',
      'desc_quick': 'Toque no botão central (+) para abrir o simulador financeiro, orçamentos e ferramentas avançadas.',
      'title_savings': 'Metas e Poupança',
      'desc_savings': 'Crie metas para viagens ou projetos dos sonhos! Guarde dinheiro mês a mês e acompanhe o progresso.',
    },
    'fr': {
      'step': 'ÉTAPE',
      'of': 'SUR',
      'next': 'Suivant',
      'finish': 'Compris !',
      'skip': 'Passer',
      'target_balance': 'Solde Total',
      'target_income': 'Bouton Revenus',
      'target_expense': 'Bouton Dépenses',
      'target_debts': 'Bouton Dettes',
      'target_cards': 'Bouton Cartes',
      'target_quick': 'Bouton Central (+)',
      'target_savings': 'Onglet Objectifs',
      'title_balance': 'Solde Total',
      'desc_balance': 'Votre centre de commande. Visualisez le total de votre argent disponible après déduction.',
      'title_income': 'Ajouter un Revenu',
      'desc_income': 'Appuyez ici pour enregistrer rapidement salaires, primes ou rentrées d argent.',
      'title_expense': 'Ajouter une Dépense',
      'desc_expense': 'Notez vos dépenses quotidiennes pour conserver la parfaite maîtrise de votre budget.',
      'title_debts': 'Gestion des Dettes',
      'desc_debts': 'Ajoutez vos emprunts en cours. QUIVO vous aidera à établir un plan pour les solder.',
      'title_cards': 'Mes Cartes',
      'desc_cards': 'Gérez vos cartes bancaires, dates de relevé et plafonds sans payer d intérêts superflus.',
      'title_quick': 'Menu d Actions (+)',
      'desc_quick': 'Appuyez sur le bouton (+) pour ouvrir le simulateur financier, les budgets et outils avancés.',
      'title_savings': 'Épargne et Objectifs',
      'desc_savings': 'Créez des objectifs pour vos projets de rêve et observez votre progression en temps réel.',
    },
    'it': {
      'step': 'PASSO',
      'of': 'DI',
      'next': 'Avanti',
      'finish': 'Ho capito!',
      'skip': 'Salta',
      'target_balance': 'Bilancio Totale',
      'target_income': 'Pulsante Entrate',
      'target_expense': 'Pulsante Spese',
      'target_debts': 'Pulsante Debiti',
      'target_cards': 'Pulsante Carte',
      'target_quick': 'Pulsante Centrale (+)',
      'target_savings': 'Scheda Obiettivi',
      'title_balance': 'Bilancio Totale',
      'desc_balance': 'Il tuo centro di controllo. Qui vedi il totale disponibile dopo aver detratto le spese.',
      'title_income': 'Registra Entrata',
      'desc_income': 'Tocca qui per registrare rapidamente stipendi, vendite o entrate sul tuo conto.',
      'title_expense': 'Registra Spesa',
      'desc_expense': 'Segna ciò che spendi ogni giorno, dal caffè alla spesa. Mantieni il controllo totale!',
      'title_debts': 'Gestione Debiti',
      'desc_debts': 'Aggiungi prestiti e debiti in sospeso per estinguerli con un piano mirato e veloce.',
      'title_cards': 'Le Mie Carte',
      'desc_cards': 'Gestisci carte di credito e debito, date di chiusura e limiti per non pagare interessi extra.',
      'title_quick': 'Menu Azioni (+)',
      'desc_quick': 'Tocca questo pulsante (+) per aprire il simulatore finanziario, budget e strumenti avanzati.',
      'title_savings': 'Risparmi e Obiettivi',
      'desc_savings': 'Crea obiettivi per viaggi o progetti! Metti da parte denaro e segui la tua crescita.',
    },
  };

  static String _str(String key, AppLocalizations loc) {
    final lang = loc.intlLocale; // 'es', 'en', 'pt', 'fr', 'it'
    return _translations[lang]?[key] ?? _translations['es']?[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FLECHA INDICADORA CON PUNTERO PRECISO
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget _buildPointerArrow({
    required bool pointsUp,
    required double arrowAlign,
    required Color color,
    required bool isDark,
  }) {
    return Align(
      alignment: Alignment(arrowAlign, 0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        child: CustomPaint(
          size: const Size(22, 10),
          painter: _ArrowPainter(
            pointsUp: pointsUp,
            fillColor: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.98)
                : Colors.white.withValues(alpha: 0.98),
            borderColor: color,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CAJA DE DIÁLOGO REDISEÑADA, COMPACTA Y MODERNA
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget _buildDialogBox(
    String titleKey,
    String descKey,
    String targetKey,
    IconData icon,
    Color color,
    TutorialCoachMarkController controller,
    AppLocalizations loc, {
    required int stepIndex,
    required int totalSteps,
    required bool pointsUp,
    required double arrowAlign,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLast = stepIndex >= totalSteps;
        final screenWidth = MediaQuery.of(context).size.width;

        final title = _str(titleKey, loc);
        final desc = _str(descKey, loc);
        final targetName = _str(targetKey, loc);
        final stepWord = _str('step', loc);
        final ofWord = _str('of', loc);
        final nextWord = isLast ? _str('finish', loc) : _str('next', loc);

        final cardWidget = Container(
          width: screenWidth > 420 ? 380 : screenWidth - 32,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: Ícono, Paso + Target Badge, Botón Cerrar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: color, size: 19),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badges: Paso y Destino
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$stepWord $stepIndex $ofWord $totalSteps',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.25),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.crosshair, size: 9, color: color),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              targetName,
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15.5,
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
                            size: 17,
                          ),
                          onPressed: () => controller.skip(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Descripción concisa
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 11),

                    // Barra inferior: Puntos y Botón Siguiente
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
                              width: isActive ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? color
                                    : (isPassed
                                        ? color.withValues(alpha: 0.45)
                                        : (isDark ? Colors.white12 : Colors.black12)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),

                        // Botón Siguiente / Entendido
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
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.85)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
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
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isLast ? LucideIcons.check : LucideIcons.arrowRight,
                                  color: Colors.white,
                                  size: 13,
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

        // Si la flecha apunta hacia arriba (la tarjeta está abajo del elemento)
        if (pointsUp) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPointerArrow(
                pointsUp: true,
                arrowAlign: arrowAlign,
                color: color,
                isDark: isDark,
              ),
              cardWidget,
            ],
          );
        } else {
          // Si la flecha apunta hacia abajo (la tarjeta está arriba del elemento)
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              cardWidget,
              _buildPointerArrow(
                pointsUp: false,
                arrowAlign: arrowAlign,
                color: color,
                isDark: isDark,
              ),
            ],
          );
        }
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
    // Si algún Drawer está abierto, cerrarlo de inmediato
    try {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null && scaffoldState.isDrawerOpen) {
        scaffoldState.closeDrawer();
      }
    } catch (_) {}

    // Configuración precisa de los 7 pasos clave
    // Flecha con alineación horizontal calculada para coincidir con la posición del widget en pantalla
    final stepConfigs = [
      {
        'id': 'balance',
        'key': TutorialKeys.balanceKey,
        'align': ContentAlign.bottom,
        'pointsUp': true,
        'arrowAlign': 0.0, // Centro
        'shape': ShapeLightFocus.RRect,
        'radius': 20.0,
        'padding': 5.0,
        'icon': LucideIcons.wallet,
        'color': const Color(0xFF38BDF8),
        'titleKey': 'title_balance',
        'descKey': 'desc_balance',
        'targetKey': 'target_balance',
      },
      {
        'id': 'income',
        'key': TutorialKeys.incomeKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': -0.72, // Izquierda (1er botón de la fila)
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFF10B981),
        'titleKey': 'title_income',
        'descKey': 'desc_income',
        'targetKey': 'target_income',
      },
      {
        'id': 'expense',
        'key': TutorialKeys.expenseKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': -0.24, // Centro-Izquierda (2do botón)
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.trendingDown,
        'color': const Color(0xFFEF4444),
        'titleKey': 'title_expense',
        'descKey': 'desc_expense',
        'targetKey': 'target_expense',
      },
      {
        'id': 'debts',
        'key': TutorialKeys.debtsKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': 0.24, // Centro-Derecha (3er botón)
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.target,
        'color': const Color(0xFF3B82F6),
        'titleKey': 'title_debts',
        'descKey': 'desc_debts',
        'targetKey': 'target_debts',
      },
      {
        'id': 'cards',
        'key': TutorialKeys.cardsKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': 0.72, // Derecha (4to botón)
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 3.0,
        'icon': LucideIcons.creditCard,
        'color': const Color(0xFFF59E0B),
        'titleKey': 'title_cards',
        'descKey': 'desc_cards',
        'targetKey': 'target_cards',
      },
      {
        'id': 'quick_actions',
        'key': TutorialKeys.centerFabKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': 0.0, // Centro exacto (Botón FAB '+')
        'shape': ShapeLightFocus.Circle,
        'radius': 30.0,
        'padding': 4.0,
        'icon': LucideIcons.plusCircle,
        'color': const Color(0xFF6366F1), // Indigo vibrante
        'titleKey': 'title_quick',
        'descKey': 'desc_quick',
        'targetKey': 'target_quick',
      },
      {
        'id': 'savings',
        'key': TutorialKeys.savingsNavKey,
        'align': ContentAlign.top,
        'pointsUp': false,
        'arrowAlign': 0.52, // Centro-Derecha (Ícono Metas en navbar)
        'shape': ShapeLightFocus.RRect,
        'radius': 16.0,
        'padding': 4.0,
        'icon': LucideIcons.piggyBank,
        'color': const Color(0xFFEC4899),
        'titleKey': 'title_savings',
        'descKey': 'desc_savings',
        'targetKey': 'target_savings',
      },
    ];

    // Filtro de seguridad: solo elementos montados en el árbol
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
                  cfg['targetKey'] as String,
                  cfg['icon'] as IconData,
                  cfg['color'] as Color,
                  controller,
                  loc,
                  stepIndex: stepNum,
                  totalSteps: totalSteps,
                  pointsUp: cfg['pointsUp'] as bool,
                  arrowAlign: cfg['arrowAlign'] as double,
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
      onClickTarget: (target) {
        _tutorialCoachMark?.next();
      },
      onClickOverlay: (target) {},
      onSkip: () {
        if (onFinish != null) onFinish();
        return true;
      },
    )..show(context: context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PINTOR DE LA FLECHA INDICADORA CON BORDES DEFINIDOS
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowPainter extends CustomPainter {
  final bool pointsUp;
  final Color fillColor;
  final Color borderColor;

  _ArrowPainter({
    required this.pointsUp,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsUp) {
      // Triángulo apuntando hacia arriba
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      // Triángulo apuntando hacia abajo
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
      path.close();
    }

    // Relleno
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Borde brillante en el color del paso
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.75)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.pointsUp != pointsUp ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
