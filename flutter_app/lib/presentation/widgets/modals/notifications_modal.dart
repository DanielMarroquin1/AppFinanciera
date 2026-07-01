import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

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

class _NotificationsModalInternal extends ConsumerWidget {
  final ScrollController scrollController;

  const _NotificationsModalInternal({required this.scrollController});

  String _getCategoryEmoji(String? category) {
    if (category == null || category.isEmpty) return '🔔';
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'other': '💸', 'debt': '💳', 'salary': '💼', 'freelance': '💻',
      'bonus': '🎁', 'investment': '📈', 'sale': '🏷️', 'gift': '🎉'
    };
    return map[category] ?? '🔔';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      decoration: BoxDecoration(color: (isDark ? Colors.blue[900] : Colors.blue[100])?.withOpacity(isDark ? 0.3 : 1.0), borderRadius: BorderRadius.circular(12)),
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
          const Divider(),

          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.bellOff, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No tienes notificaciones', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
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
                          if (isUnread) notifier.markAsRead(notif.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUnread 
                                ? (isDark ? const Color(0xFF2E3A4B) : const Color(0xFFEFF6FF))
                                : (isDark ? const Color(0xFF1F2937) : Colors.white),
                            border: Border.all(
                              color: isUnread 
                                  ? (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.1))
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [if (!isDark && isUnread) BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Text(_getCategoryEmoji(notif.category), style: const TextStyle(fontSize: 22))),
                              ),
                              const SizedBox(width: 16),
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
                                              fontSize: 16, 
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
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
                                      style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 11),
                                    ),
                                  ],
                                ),
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

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} m';
    return 'Justo ahora';
  }
}
