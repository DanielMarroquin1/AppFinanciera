import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_card_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/credit_card.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/utils/localization.dart';
import 'credit_card_history_modal.dart';
import 'add_credit_card_modal.dart';
import '../../../core/services/recurring_transaction_service.dart';

class CreditCardsModal extends ConsumerStatefulWidget {
  const CreditCardsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreditCardsModal(),
    );
  }

  @override
  ConsumerState<CreditCardsModal> createState() => _CreditCardsModalState();
}

class _CreditCardsModalState extends ConsumerState<CreditCardsModal> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPaymentDialog(BuildContext context, CreditCard card, String? currencyCode, WidgetRef ref) {
    final amountController = TextEditingController(text: card.currentBalance.toStringAsFixed(0));
    final loc = ref.read(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
            ],
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: const Icon(LucideIcons.wallet, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              
              Text(loc.get('cc_pay_debt'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Abonar a ${card.name}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15)),
              const SizedBox(height: 32),
              
              // Input Field
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, 
                  fontSize: 56, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -2
                ),
                decoration: InputDecoration(
                  prefixText: CurrencyFormatter.getSymbol(currencyCode) + ' ',
                  prefixStyle: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.3), 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold
                  ),
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Saldo actual: ${CurrencyFormatter.format(card.currentBalance, currencyCode)}', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(loc.get('cancel'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (amount > 0) {
                            final tx = TransactionModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              isFixed: false,
                              amount: amount,
                              category: 'cc_payment',
                              date: DateTime.now(),
                              description: 'Pago de tarjeta ${card.name}',
                              type: 'expense',
                              userId: firebase_auth.FirebaseAuth.instance.currentUser?.email ?? 'test@test.com',
                              creditCardId: card.id,
                            );
                            await ref.read(transactionNotifierProvider.notifier).addTransaction(tx);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(LucideIcons.checkCircle2, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text('Pago de ${CurrencyFormatter.format(amount, currencyCode)} registrado con éxito! 🎉', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Confirmar Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final currencyCode = ref.watch(authProvider).user?.currency;
    final cardsAsync = ref.watch(computedCreditCardsProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header Grabber & Add Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 48, height: 5,
                  decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                ),
                IconButton(
                  onPressed: () => AddCreditCardModal.show(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(LucideIcons.plus, color: isDark ? Colors.white : Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: cardsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
              data: (cards) {
                if (cards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.creditCard, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        ),
                        const SizedBox(height: 24),
                        Text(loc.get('cc_title'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        const SizedBox(height: 8),
                        Text(loc.get('cc_no_cards'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => AddCreditCardModal.show(context),
                          icon: const Icon(LucideIcons.plus),
                          label: Text(loc.get('cc_add_card'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Make sure index is valid
                if (_currentIndex >= cards.length) {
                  _currentIndex = cards.length - 1;
                }
                final activeCard = cards[_currentIndex];
                final progress = activeCard.limit > 0 ? (activeCard.currentBalance / activeCard.limit).clamp(0.0, 1.0) : 0.0;
                final availableAmount = activeCard.limit - activeCard.currentBalance;

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text('Tus Tarjetas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, letterSpacing: -0.5)),
                    const SizedBox(height: 24),
                    
                    // Cards Showcase
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final isSelected = _currentIndex == index;
                          final double scale = isSelected ? 1.0 : 0.9;
                          final double opacity = isSelected ? 1.0 : 0.6;
                          
                          Color baseColor = card.color;
                          Color accentColor = Color.lerp(card.color, Colors.white, 0.2) ?? card.color;
                          Color darkAccent = Color.lerp(card.color, Colors.black, 0.4) ?? card.color;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: scale, end: scale),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: opacity,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isSelected) {
                                        CreditCardHistoryModal.show(context, card);
                                      } else {
                                        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          if (isSelected)
                                            BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 25, offset: const Offset(0, 15))
                                        ],
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                                          colors: [accentColor, baseColor, darkAccent],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Stack(
                                          children: [
                                            // Glassmorphic Reflection (Diagonal)
                                            Positioned(
                                              top: -80, left: -40,
                                              child: Transform.rotate(
                                                angle: 0.5,
                                                child: Container(
                                                  width: 300, height: 100,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.0)],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Mesh gradients (blobs)
                                            Positioned(
                                              top: -60, right: -60,
                                              child: Container(
                                                width: 180, height: 180,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(colors: [Colors.white.withOpacity(0.15), Colors.transparent]),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -40, left: -40,
                                              child: Container(
                                                width: 150, height: 150,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(colors: [Colors.white.withOpacity(0.12), Colors.transparent]),
                                                ),
                                              ),
                                            ),
                                            
                                            // Network Background Watermark
                                            Positioned(
                                              right: -20, bottom: -20,
                                              child: Icon(LucideIcons.creditCard, size: 140, color: Colors.white.withOpacity(0.05)),
                                            ),
                                            
                                            // Content
                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      // Chip & NFC
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 44, height: 32,
                                                            decoration: BoxDecoration(
                                                              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                                              borderRadius: BorderRadius.circular(6),
                                                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                                                            ),
                                                            child: Center(
                                                              child: Container(width: 28, height: 18, decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.3), width: 1), borderRadius: BorderRadius.circular(3))),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Icon(LucideIcons.wifi, color: Colors.white.withOpacity(0.9), size: 24),
                                                        ],
                                                      ),
                                                      
                                                      if (isSelected)
                                                        PopupMenuButton<String>(
                                                          icon: Container(
                                                            padding: const EdgeInsets.all(6),
                                                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
                                                            child: const Icon(LucideIcons.moreHorizontal, color: Colors.white, size: 20),
                                                          ),
                                                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                          onSelected: (val) {
                                                            if (val == 'edit') AddCreditCardModal.show(context, existingCard: card);
                                                            if (val == 'delete') ref.read(creditCardControllerProvider.notifier).deleteCreditCard(card.id);
                                                            if (val == 'history') CreditCardHistoryModal.show(context, card);
                                                          },
                                                          itemBuilder: (ctx) => [
                                                            PopupMenuItem(value: 'history', child: Row(children: [Icon(LucideIcons.history, color: isDark ? Colors.white : Colors.black, size: 18), const SizedBox(width: 12), const Text('Ver Historial')])),
                                                            PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.pencil, color: isDark ? Colors.white : Colors.black, size: 18), const SizedBox(width: 12), Text(loc.get('cc_edit_card'))])),
                                                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, color: Colors.red, size: 18), SizedBox(width: 12), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                                                          ],
                                                        )
                                                    ],
                                                  ),
                                                  
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        card.name.toUpperCase(), 
                                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))]),
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text('•••• •••• •••• ${card.id.length >= 4 ? card.id.substring(card.id.length - 4) : '0000'}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18, letterSpacing: 3.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Glassmorphic Panel
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, spreadRadius: 5)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05), width: 1.5),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                            children: [
                              Row(
                                children: [
                                  // Circular Progress
                                  SizedBox(
                                    width: 70, height: 70,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            width: 70, height: 70,
                                            child: CircularProgressIndicator(
                                              value: progress,
                                              strokeWidth: 6,
                                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                              color: progress > 0.8 ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Icon(progress > 0.8 ? LucideIcons.alertTriangle : LucideIcons.creditCard, 
                                            color: progress > 0.8 ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black), 
                                            size: 24),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Amounts
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Deuda Actual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                                        Text(
                                          CurrencyFormatter.format(activeCard.currentBalance, currencyCode),
                                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Disponible: ${CurrencyFormatter.format(availableAmount, currencyCode)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _MiniDatePill(isDark: isDark, label: 'CORTE', value: 'Día ${activeCard.cutOffDay}'),
                                            const SizedBox(width: 8),
                                            _MiniDatePill(isDark: isDark, label: 'PAGO', value: 'Día ${activeCard.paymentDay}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showPaymentDialog(context, activeCard, currencyCode, ref),
                                        icon: const Icon(LucideIcons.checkCircle2, size: 20),
                                        label: const Text('Pagar Deuda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => CreditCardHistoryModal.show(context, activeCard),
                                      icon: const Icon(LucideIcons.history, size: 18),
                                      label: const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0), width: 2),
                                        foregroundColor: isDark ? Colors.white : Colors.black,
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
                    ),
                  ],
                );
              },
            ),
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
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
      
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.3, 0);
    
    path.moveTo(size.width, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.7, 0);
    
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniDatePill extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  
  const _MiniDatePill({required this.isDark, required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w800)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
