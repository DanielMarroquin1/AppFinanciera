import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_card_provider.dart';
import 'add_credit_card_modal.dart';

class CreditCardsModal extends ConsumerWidget {
  const CreditCardsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _CreditCardsModalInternal(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _CreditCardsModalInternal extends ConsumerWidget {
  final ScrollController scrollController;

  const _CreditCardsModalInternal({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final creditCardsAsync = ref.watch(creditCardsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;

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
                      decoration: BoxDecoration(color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.creditCard, color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 12),
                    Text('Mis Tarjetas', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: creditCardsAsync.when(
              data: (cards) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    InkWell(
                      onTap: () {
                        // Show Add Modal
                        Navigator.pop(context);
                        AddCreditCardModal.show(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.1),
                          border: Border.all(color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.3), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.plusCircle, color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706), size: 24),
                            const SizedBox(width: 12),
                            Text('Agregar Tarjeta de Crédito', style: TextStyle(color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (cards.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text('No tienes tarjetas registradas.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                        ),
                      )
                    else
                      ...cards.map((card) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: card.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: card.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(card.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ),
                                    Row(
                                      children: [
                                        Text(card.network, style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                                        const SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          icon: const Icon(LucideIcons.moreVertical, color: Colors.white70, size: 20),
                                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              Navigator.pop(context);
                                              AddCreditCardModal.show(context, existingCard: card);
                                            } else if (value == 'delete') {
                                              ref.read(creditCardControllerProvider.notifier).deleteCreditCard(card.id);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(LucideIcons.pencil, color: isDark ? Colors.white : Colors.black, size: 16),
                                                  const SizedBox(width: 8),
                                                  Text('Editar', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              const Text('Deuda Actual', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(CurrencyFormatter.format(card.currentBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Límite', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      Text(CurrencyFormatter.format(card.limit, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Fecha de Pago', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      Text('Día ${card.paymentDay}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error al cargar tarjetas')),
            ),
          )
        ],
      ),
    );
  }
}
