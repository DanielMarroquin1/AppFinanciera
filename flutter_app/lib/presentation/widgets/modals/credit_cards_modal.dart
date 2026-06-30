import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_card_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'credit_card_history_modal.dart';
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
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final creditCardsAsync = ref.watch(computedCreditCardsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        children: [
          // Elegant Handle
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            height: 5, width: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.2), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Icon(LucideIcons.creditCard, color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tarjetas de Crédito', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text('Administra tus plásticos y deudas', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.white : Colors.black, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                        Navigator.pop(context);
                        AddCreditCardModal.show(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.1),
                          border: Border.all(color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withOpacity(0.3), width: 2),
                          borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 32),
                    if (cards.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(LucideIcons.creditCard, size: 64, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              const SizedBox(height: 16),
                              Text('No tienes tarjetas registradas.', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...cards.map((card) {
                        final availableBalance = card.limit - card.currentBalance;
                        final double usagePercent = (card.currentBalance / card.limit).clamp(0.0, 1.0);
                        final bool isOverdrawn = card.currentBalance > card.limit;
                        final bool isNearLimit = usagePercent >= 0.9 && !isOverdrawn;
                        
                        Color usageColor = Colors.greenAccent;
                        if (isOverdrawn) usageColor = Colors.redAccent;
                        else if (usagePercent > 0.8) usageColor = Colors.orangeAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Visual warning tags
                              if (isOverdrawn || isNearLimit)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.alertTriangle, size: 16, color: isOverdrawn ? Colors.red : Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(
                                        isOverdrawn ? 'TARJETA SOBREGIRADA' : 'CERCA DEL LÍMITE',
                                        style: TextStyle(
                                          color: isOverdrawn ? Colors.red : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // The physical card representation
                              AspectRatio(
                                aspectRatio: 1.586, // Standard credit card ratio
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isOverdrawn ? const Color(0xFF991B1B) : const Color(0xFF1E293B), // Dark sleek base
                                    ),
                                    child: Stack(
                                      children: [
                                        // Mesh Gradient Orbs
                                        Positioned(
                                          top: -50,
                                          right: -50,
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (isOverdrawn ? Colors.redAccent : card.color).withOpacity(0.5),
                                            ),
                                            child: BackdropFilter(
                                              filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                                              child: Container(color: Colors.transparent),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -80,
                                          left: -20,
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (isOverdrawn ? Colors.orangeAccent : card.color).withOpacity(0.4),
                                            ),
                                            child: BackdropFilter(
                                              filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                                              child: Container(color: Colors.transparent),
                                            ),
                                          ),
                                        ),
                                        // Card Content
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Top row: Chip and More Options
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Sleek Silver Chip
                                                  Container(
                                                    width: 42, height: 30,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
                                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                                                    ),
                                                    child: CustomPaint(
                                                      painter: _ChipPainter(),
                                                    ),
                                                  ),
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 24),
                                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
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
                                                            Text('Editar Tarjeta', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                                                            SizedBox(width: 8),
                                                            Text('Eliminar Tarjeta', style: TextStyle(color: Colors.red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              
                                              // Middle: Debt amount
                                              Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('DEUDA ACTUAL', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600)),
                                                    const SizedBox(height: 4),
                                                    if (card.currentBalance <= 0)
                                                      const Text('¡AL DÍA!', style: TextStyle(color: Color(0xFF10B981), fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2))
                                                    else
                                                      Text(CurrencyFormatter.format(card.currentBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 1)),
                                                  ],
                                                ),
                                              
                                              // Bottom row: Info
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(card.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 2), overflow: TextOverflow.ellipsis),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text('Corte: ${card.cutOffDay}  •  Pago: ${card.paymentDay}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500)),
                                                        const SizedBox(height: 4),
                                                        Text(card.network.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Premium Border Glow
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Limit Progress Bar
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Límite de Crédito', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12)),
                                        Text(CurrencyFormatter.format(card.limit, currencyCode), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: usagePercent,
                                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Disponible', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12)),
                                        Text(isOverdrawn ? '-\$0.00' : CurrencyFormatter.format(availableBalance, currencyCode), style: TextStyle(color: isOverdrawn ? Colors.red : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Action Buttons (History & Pay)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        CreditCardHistoryModal.show(context, card);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(LucideIcons.history, size: 18),
                                      label: const Text('Ver Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _showPaymentDialog(context, ref, card, currencyCode);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(LucideIcons.checkCircle, size: 18),
                                      label: const Text('Abonar a Deuda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
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

  Future<void> _showPaymentDialog(BuildContext context, WidgetRef ref, card, String? currencyCode) async {
    final TextEditingController amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Abonar a ${card.name}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monto a pagar',
            prefixIcon: const Icon(LucideIcons.banknote),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) return;
              
              if (amount > card.currentBalance) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: const Text('El monto a pagar no puede ser mayor a tu deuda actual.', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                return;
              }

              final user = firebase_auth.FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final transaction = TransactionModel(
                id: '',
                userId: user.uid,
                amount: amount,
                type: 'cc_payment', // Identificador de pago de tarjeta
                category: 'Pago de Tarjeta',
                description: 'Abono a ${card.name}',
                date: DateTime.now(),
                isFixed: false,
                creditCardId: card.id,
              );

              await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
              
              // Actualizar el balance de la tarjeta al instante
              final newBalance = card.currentBalance - amount;
              final updatedCard = card.copyWith(currentBalance: newBalance < 0 ? 0 : newBalance);
              await ref.read(creditCardControllerProvider.notifier).updateCreditCard(updatedCard);
              
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Abono registrado exitosamente 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Verde
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw chip lines
    final path = Path();
    
    // Left lines
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.3, 0);

    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height);

    // Right lines
    path.moveTo(size.width, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.7, 0);

    path.moveTo(size.width, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height);

    // Center rectangle
    path.addRect(Rect.fromLTWH(size.width * 0.35, size.height * 0.25, size.width * 0.3, size.height * 0.5));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
