import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
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
                    Text('Notificaciones', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    if (user != null && FirebaseAuth.instance.currentUser != null)
                      TextButton(
                        onPressed: () => notifier.markAllAsRead(FirebaseAuth.instance.currentUser!.uid),
                        child: Text('Leer Todo', style: TextStyle(color: isDark ? Colors.blue[400] : Colors.blue[700], fontWeight: FontWeight.bold)),
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
                _buildFilterTab(isDark, 0, '🔔 Todas'),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 1, '💳 Deudas Cobradas'),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 2, '💰 Ingresos'),
                const SizedBox(width: 8),
                _buildFilterTab(isDark, 3, '🔄 Gastos Fijos'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), height: 1),

          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filtered = notifications.where((n) {
                  final titleLower = n.title.toLowerCase();
                  final bodyLower = n.body.toLowerCase();
                  if (_selectedFilter == 1) {
                    return n.category == 'debt' ||
                        n.category == 'loan' ||
                        n.category == 'credit_card' ||
                        titleLower.contains('deuda') ||
                        titleLower.contains('préstamo') ||
                        titleLower.contains('pago automático') ||
                        bodyLower.contains('deuda') ||
                        bodyLower.contains('cuota');
                  }
                  if (_selectedFilter == 2) {
                    return n.type == 'income' ||
                        n.category == 'salary' ||
                        n.category == 'freelance' ||
                        n.category == 'bonus' ||
                        n.category == 'investment' ||
                        n.category == 'gift' ||
                        titleLower.contains('ingreso') ||
                        bodyLower.contains('ingreso');
                  }
                  if (_selectedFilter == 3) {
                    return n.type == 'expense' && (
                        n.category == 'recurring' ||
                        n.category == 'bills' ||
                        titleLower.contains('cobro automático') ||
                        titleLower.contains('gasto fijo') ||
                        titleLower.contains('suscripción') ||
                        bodyLower.contains('cobro automático') ||
                        bodyLower.contains('gasto fijo')
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
                        Text('No tienes notificaciones en este filtro', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16)),
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
                                                notif.title, 
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
                                          notif.body,
                                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatTimeAgo(notif.createdAt),
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
                                            _getSmartActionLabel(notif.category, notif.title),
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

  String _getSmartActionLabel(String? category, String title) {
    final t = title.toLowerCase();
    if (category == 'debt' || category == 'credit_card' || t.contains('sobregiro') || t.contains('tarjeta') || t.contains('mora') || t.contains('corte') || t.contains('vence') || t.contains('pago') || t.contains('abono') || t.contains('cuota')) {
      return '💳 Ver Tarjeta / Pagar';
    }
    if (category == 'streak' || t.contains('racha')) {
      return '🔥 Activar Racha Ahora';
    }
    if (category == 'alert' || t.contains('alerta') || t.contains('presupuesto')) {
      return '⚠️ Revisar Movimientos';
    }
    if (category == 'ai' || t.contains('ia') || t.contains('consejo') || t.contains('tip') || t.contains('asesor') || t.contains('antigravity')) {
      return '🤖 Consultar Asesor IA';
    }
    return '✨ Ver Movimientos';
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
    } else if (category == 'ai' || t.contains('ia') || t.contains('consejo') || t.contains('tip') || t.contains('asesor') || t.contains('antigravity')) {
      AIChatModal.show(context);
    } else if (category == 'alert' || t.contains('alerta') || t.contains('presupuesto')) {
      TransactionsListModal.show(context);
    } else {
      TransactionsListModal.show(context);
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} m';
    return 'Justo ahora';
  }
}
