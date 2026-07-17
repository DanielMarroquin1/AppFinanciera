import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/localization.dart';
import 'credit_cards_modal.dart';
import 'streak_modal.dart';
import 'transactions_list_modal.dart';
import 'ai_chat_modal.dart';

class NotificationsModal extends ConsumerWidget {
  const NotificationsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _NotificationsModalInternal(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _NotificationsModalInternal extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _NotificationsModalInternal({required this.scrollController});

  @override
  ConsumerState<_NotificationsModalInternal> createState() => _NotificationsModalInternalState();
}

class _NotificationsModalInternalState extends ConsumerState<_NotificationsModalInternal> {
  int _selectedFilter = 0; // 0: Todas, 1: Alertas/Deudas, 2: Racha/Consejos, 3: Otros

  String _getCategoryEmoji(String? category) {
    if (category == null || category.isEmpty) return '🔔';
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'other': '💸', 'debt': '💳', 'salary': '💼', 'freelance': '💻',
      'bonus': '🎁', 'investment': '📈', 'sale': '🏷️', 'gift': '🎉',
      'streak': '🔥', 'alert': '⚠️', 'credit_card': '💳', 'ai': '🤖'
    };
    return map[category] ?? '🔔';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationNotifierProvider);
    final user = ref.watch(authProvider).user;

    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: (isDark ? Colors.blue[900] : Colors.blue[100])?.withValues(alpha: isDark ? 0.3 : 1.0), borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.bell, color: isDark ? Colors.blue[400] : Colors.blue[700]),
                    ),
                    const SizedBox(width: 12),
                    Text(loc.get('notif_title_bar'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    if (user != null && FirebaseAuth.instance.currentUser != null)
                      TextButton(
                        onPressed: () => notifier.markAllAsRead(FirebaseAuth.instance.currentUser!.uid),
                        child: Text(loc.get('notif_read_all'), style: TextStyle(color: isDark ? Colors.blue[400] : Colors.blue[700], fontWeight: FontWeight.bold)),
                      ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Filter Tabs (Scrollable for financial categories)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildFilterTab(isDark, 0, loc.get('notif_tab_all')),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 1, loc.get('notif_tab_debts')),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 2, loc.get('notif_tab_incomes')),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 3, loc.get('notif_tab_fixed')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), height: 1),

          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filtered = notifications.where((n) {
                  final rawTitleLower = n.title.toLowerCase();
                  final rawBodyLower = n.body.toLowerCase();
                  final locTitleLower = _localizeTitle(n.title, loc).toLowerCase();
                  final locBodyLower = _localizeBody(n.body, loc).toLowerCase();
                  final titleLower = '$rawTitleLower $locTitleLower';
                  final bodyLower = '$rawBodyLower $locBodyLower';
                  if (_selectedFilter == 1) {
                    return n.category == 'debt' ||
                        n.category == 'loan' ||
                        n.category == 'credit_card' ||
                        titleLower.contains('deuda') ||
                        titleLower.contains('préstamo') ||
                        titleLower.contains('pago automático') ||
                        titleLower.contains('debt') ||
                        titleLower.contains('dívida') ||
                        titleLower.contains('dette') ||
                        titleLower.contains('debito') ||
                        bodyLower.contains('deuda') ||
                        bodyLower.contains('cuota') ||
                        bodyLower.contains('installment') ||
                        bodyLower.contains('parcela') ||
                        bodyLower.contains('mensualité') ||
                        bodyLower.contains('rata');
                  }
                  if (_selectedFilter == 2) {
                    return n.type == 'income' ||
                        n.category == 'salary' ||
                        n.category == 'freelance' ||
                        n.category == 'bonus' ||
                        n.category == 'investment' ||
                        n.category == 'gift' ||
                        titleLower.contains('ingreso') ||
                        titleLower.contains('income') ||
                        titleLower.contains('receita') ||
                        titleLower.contains('revenu') ||
                        titleLower.contains('entrata') ||
                        bodyLower.contains('ingreso') ||
                        bodyLower.contains('income') ||
                        bodyLower.contains('receita') ||
                        bodyLower.contains('revenu') ||
                        bodyLower.contains('entrata');
                  }
                  if (_selectedFilter == 3) {
                    return n.type == 'expense' && (
                        n.category == 'recurring' ||
                        n.category == 'bills' ||
                        titleLower.contains('cobro automático') ||
                        titleLower.contains('gasto fijo') ||
                        titleLower.contains('suscripción') ||
                        titleLower.contains('charge') ||
                        titleLower.contains('cobrança') ||
                        titleLower.contains('prélèvement') ||
                        titleLower.contains('addebito') ||
                        bodyLower.contains('cobro') ||
                        bodyLower.contains('charge') ||
                        bodyLower.contains('cobrança')
                    );
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.bellOff, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(loc.get('notif_empty_filter'), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notif = filtered[index];
                    final isUnread = !notif.isRead;

                    return Dismissible(
                      key: Key(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        notifier.deleteNotification(notif.id);
                      },
                      child: GestureDetector(
                        onTap: () {
                          _onNotificationTap(context, notif, isUnread, notifier);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUnread 
                                ? (isDark ? const Color(0xFF2E3A4B) : const Color(0xFFEFF6FF))
                                : (isDark ? const Color(0xFF111827) : Colors.white),
                            border: Border.all(
                              color: isUnread 
                                  ? (isDark ? Colors.blue.withValues(alpha: 0.4) : Colors.blue.withValues(alpha: 0.2))
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [if (!isDark && isUnread) BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(child: Text(_getCategoryEmoji(notif.category), style: const TextStyle(fontSize: 22))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _localizeTitle(notif.title, loc), 
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black, 
                                                  fontSize: 15, 
                                                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                                )
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                width: 8, height: 8,
                                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                              )
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _localizeBody(notif.body, loc),
                                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatTimeAgo(notif.createdAt, loc),
                                          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Smart Action Pill
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _onNotificationTap(context, notif, isUnread, notifier);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getSmartActionLabel(notif.category, notif.title, loc),
                                            style: TextStyle(color: isDark ? Colors.blue[400] : Colors.blue[600], fontSize: 11.5, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(LucideIcons.arrowRight, size: 12, color: isDark ? Colors.blue[400] : Colors.blue[600]),
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
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterTab(bool isDark, int index, String label) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
          color: isSelected ? null : (isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0))),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getSmartActionLabel(String? category, String title, AppLocalizations loc) {
    final t = title.toLowerCase();
    if (category == 'debt' || category == 'credit_card' || t.contains('sobregiro') || t.contains('tarjeta') || t.contains('mora') || t.contains('corte') || t.contains('vence') || t.contains('pago') || t.contains('abono') || t.contains('cuota')) {
      return loc.get('notif_action_card');
    }
    if (category == 'streak' || t.contains('racha')) {
      return loc.get('notif_action_streak');
    }
    if (category == 'alert' || t.contains('alerta') || t.contains('presupuesto')) {
      return loc.get('notif_action_alert');
    }
    if (category == 'ai' || t.contains('ia') || t.contains('consejo') || t.contains('tip') || t.contains('asesor')) {
      return loc.get('notif_action_ai');
    }
    return loc.get('notif_action_view');
  }

  void _onNotificationTap(BuildContext context, dynamic notif, bool isUnread, dynamic notifier) {
    if (isUnread) notifier.markAsRead(notif.id);
    Navigator.of(context).pop();
    _handleSmartAction(context, notif.category, notif.title);
  }

  void _handleSmartAction(BuildContext context, String? category, String title) {
    final t = title.toLowerCase();
    if (category == 'debt' || category == 'credit_card' || t.contains('sobregiro') || t.contains('tarjeta') || t.contains('mora') || t.contains('corte') || t.contains('vence') || t.contains('pago') || t.contains('abono') || t.contains('cuota')) {
      CreditCardsModal.show(context);
    } else if (category == 'streak' || t.contains('racha')) {
      final user = ref.read(authProvider).user;
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final isActiveToday = user?.lastActiveDate == todayStr;
      StreakModal.show(context, streak: user?.currentStreak ?? 0, isActiveToday: isActiveToday);
    } else if (category == 'ai' || t.contains('ia') || t.contains('consejo') || t.contains('tip') || t.contains('asesor')) {
      AIChatModal.show(context);
    } else if (category == 'alert' || t.contains('alerta') || t.contains('presupuesto')) {
      TransactionsListModal.show(context);
    } else {
      TransactionsListModal.show(context);
    }
  }

  String _formatTimeAgo(DateTime date, AppLocalizations loc) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return loc.get('time_ago_d').replaceAll('{n}', '${diff.inDays}');
    if (diff.inHours > 0) return loc.get('time_ago_h').replaceAll('{n}', '${diff.inHours}');
    if (diff.inMinutes > 0) return loc.get('time_ago_m').replaceAll('{n}', '${diff.inMinutes}');
    return loc.get('time_ago_now');
  }

  String _localizeTitle(String rawTitle, AppLocalizations loc) {
    if (rawTitle == 'Ingreso Automático' || rawTitle == 'Automatic Income') return loc.get('notif_auto_income_title');
    if (rawTitle == 'Cobro Automático' || rawTitle == 'Automatic Charge') return loc.get('notif_auto_charge_title');
    if (rawTitle == 'Pago Automático de Deuda' || rawTitle == 'Automatic Debt Payment') return loc.get('notif_auto_debt_title');
    if (rawTitle.contains('Presupuesto Agotado') || rawTitle.contains('Budget Exceeded')) return loc.get('notif_budget_exceeded_title');
    if (rawTitle.contains('Presupuesto al 80%') || rawTitle.contains('Budget at 80%')) return loc.get('notif_budget_warning_title');
    
    if (rawTitle.contains('Corte en 2 días:') || rawTitle.contains('Statement closing in 2 days:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_cut_2_days_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('Mañana es el corte:') || rawTitle.contains('Statement closes tomorrow:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_cut_1_day_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('Hoy corta tu tarjeta:') || rawTitle.contains('Statement closes today:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_cut_today_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('Pago de tarjeta en 2 días:') || rawTitle.contains('Card payment due in 2 days:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_pay_2_days_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('Mañana vence tu tarjeta:') || rawTitle.contains('Card payment due tomorrow:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_pay_1_day_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('HOY vence tu tarjeta:') || rawTitle.contains('Card payment due TODAY:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_pay_today_title').replaceAll('{name}', name);
    }
    if (rawTitle.contains('TARJETA EN MORA:') || rawTitle.contains('OVERDUE CARD:')) {
      final parts = rawTitle.split(':');
      final name = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      return loc.get('notif_overdue_title').replaceAll('{name}', name);
    }
    return rawTitle;
  }

  String _localizeBody(String rawBody, AppLocalizations loc) {
    final firstQuote = rawBody.indexOf('"');
    final secondQuote = rawBody.lastIndexOf('"');
    if (firstQuote != -1 && secondQuote != -1 && secondQuote > firstQuote) {
      final desc = rawBody.substring(firstQuote + 1, secondQuote);
      final afterQuote = rawBody.substring(secondQuote + 1);
      final amountMatch = RegExp(r'([\d,]+\.?\d*)').firstMatch(afterQuote);
      final amount = amountMatch != null ? afterQuote.substring(amountMatch.start).trim().replaceAll('.', '') : '';
      
      if (rawBody.contains('Se ha registrado') || rawBody.contains('has been recorded')) {
        return loc.get('notif_auto_income_body').replaceAll('{desc}', desc).replaceAll('{amount}', afterQuote.trim().replaceAll('por un monto de ', '').replaceAll('for the amount of ', '').replaceAll('.', ''));
      }
      if (rawBody.contains('Se ha cobrado la cuota') || rawBody.contains('The installment for')) {
        return loc.get('notif_auto_debt_body').replaceAll('{desc}', desc).replaceAll('{amount}', afterQuote.trim().replaceAll('por un monto de ', '').replaceAll('has been charged for ', '').replaceAll('.', ''));
      }
      if (rawBody.contains('presupuesto para la categoría') || rawBody.contains('budget for category')) {
        final nums = afterQuote.contains('(') ? afterQuote.substring(afterQuote.indexOf('(')).replaceAll('.', '') : '';
        if (rawBody.contains('100%')) {
          return loc.get('notif_budget_exceeded_body').replaceAll('{cat}', loc.translateCategory(desc)).replaceAll('{nums}', nums);
        }
        return loc.get('notif_budget_warning_body').replaceAll('{cat}', loc.translateCategory(desc)).replaceAll('{nums}', nums);
      }
    }

    if (rawBody.contains('realiza su corte el día') || rawBody.contains('statement closes on day')) {
      final dayMatch = RegExp(r'(\d+)').firstMatch(rawBody);
      final day = dayMatch?.group(1) ?? '';
      return loc.get('notif_cut_2_days_body').replaceAll('{day}', day);
    }
    if (rawBody.contains('es la fecha de corte') || rawBody.contains('is the closing date')) {
      final dayMatch = RegExp(r'(\d+)').firstMatch(rawBody);
      final day = dayMatch?.group(1) ?? '';
      return loc.get('notif_cut_1_day_body').replaceAll('{day}', day);
    }
    if (rawBody.contains('Hoy cierra tu ciclo de facturación') || rawBody.contains('billing cycle closes today')) {
      return loc.get('notif_cut_today_body');
    }
    if (rawBody.contains('Faltan 2 días para el pago') || rawBody.contains('2 days remaining to pay')) {
      final dayMatch = RegExp(r'Día (\d+)|Day (\d+)').firstMatch(rawBody);
      final day = dayMatch?.group(1) ?? dayMatch?.group(2) ?? '';
      final balIndex = rawBody.indexOf(':');
      final bal = balIndex != -1 ? rawBody.substring(balIndex + 1).trim().replaceAll('.', '') : '';
      return loc.get('notif_pay_2_days_body').replaceAll('{day}', day).replaceAll('{bal}', bal);
    }
    if (rawBody.contains('fecha límite para pagar tu tarjeta sin intereses') || rawBody.contains('deadline to pay your card without interest')) {
      final dayMatch = RegExp(r'(\d+)').firstMatch(rawBody);
      final day = dayMatch?.group(1) ?? '';
      return loc.get('notif_pay_1_day_body').replaceAll('{day}', day);
    }
    if (rawBody.contains('día límite de pago para') || rawBody.contains('payment deadline for')) {
      final parts = rawBody.split('!');
      final namePart = parts.first.replaceAll('¡Hoy es el día límite de pago para ', '').replaceAll('Today is the payment deadline for ', '').trim();
      final balIndex = rawBody.indexOf(':');
      final bal = balIndex != -1 ? rawBody.substring(balIndex + 1).split('.').first.trim() : '';
      return loc.get('notif_pay_today_body').replaceAll('{name}', namePart).replaceAll('{bal}', bal);
    }
    if (rawBody.contains('Tu tarjeta venció el día') || rawBody.contains('Your card was due on day')) {
      final dayMatch = RegExp(r'(\d+)').firstMatch(rawBody);
      final day = dayMatch?.group(1) ?? '';
      final balMatch = RegExp(r'de (\$.*?)\.|of (\$.*?)\.').firstMatch(rawBody);
      final bal = balMatch?.group(1) ?? balMatch?.group(2) ?? '';
      return loc.get('notif_overdue_body').replaceAll('{day}', day).replaceAll('{bal}', bal);
    }

    return rawBody;
  }
}
