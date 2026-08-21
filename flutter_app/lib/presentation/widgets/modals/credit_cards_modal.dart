import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:math' as math;

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
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: card.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(LucideIcons.banknote, color: card.color, size: 40),
              ),
              const SizedBox(height: 24),
              Text('Pagar Deuda', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.w900)),
              Text(card.name, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(CurrencyFormatter.getSymbol(currencyCode), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Saldo adeudado: ${CurrencyFormatter.format(card.currentBalance, currencyCode)}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > card.currentBalance) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('No puedes abonar más del saldo adeudado.')));
                      return;
                    }
                    if (amount > 0) {
                      final tx = TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        isFixed: false, amount: amount, category: 'cc_payment', date: DateTime.now(),
                        description: 'Pago de tarjeta ${card.name}', type: 'cc_payment',
                        userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '', creditCardId: card.id,
                      );
                      await ref.read(transactionNotifierProvider.notifier).addTransaction(tx);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago de ${CurrencyFormatter.format(amount, currencyCode)} registrado con éxito! 🎉')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: card.color, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 10, shadowColor: card.color.withValues(alpha: 0.5),
                  ),
                  child: const Text('Confirmar Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyCode = ref.watch(authProvider).user?.currency;
    final cardsAsync = ref.watch(computedCreditCardsProvider);
    
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B0F19).withValues(alpha: 0.8) : const Color(0xFFF8FAFC).withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3))),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Billetera', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, letterSpacing: -1)),
                  GestureDetector(
                    onTap: () { HapticFeedback.mediumImpact(); AddCreditCardModal.show(context); },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.plus, color: isDark ? Colors.white : Colors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: cardsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (cards) {
                  if (cards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.creditCard, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 24),
                          const Text('Tu billetera está vacía', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Agrega una tarjeta para gestionar tus créditos.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  if (_currentIndex >= cards.length) _currentIndex = cards.length - 1;
                  final activeCard = cards[_currentIndex];
                  final progress = activeCard.limit > 0 ? (activeCard.currentBalance / activeCard.limit).clamp(0.0, 1.0) : 0.0;
                  final availableAmount = activeCard.limit - activeCard.currentBalance;
                  final isOverdrawn = activeCard.limit > 0 && activeCard.currentBalance >= activeCard.limit;

                  return Column(
                    children: [
                      // 3D CoverFlow Carousel
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) { HapticFeedback.lightImpact(); setState(() => _currentIndex = index); },
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            // Math for 3D rotation
                            double offset = index - _pageOffset;
                            double absOffset = offset.abs();
                            double scale = 1 - (absOffset * 0.15).clamp(0.0, 0.4);
                            double rotationY = offset * -0.5; // Tilt inwards
                            
                            // Sleek Card Colors
                            Color c1 = card.color;
                            Color c2 = Color.lerp(c1, Colors.black, 0.3)!;
                            if (card.limit > 0 && card.currentBalance >= card.limit) {
                              c1 = const Color(0xFFDC2626);
                              c2 = const Color(0xFF7F1D1D);
                            }

                            // Format last digits cleanly
                            String dummyNum = card.id.length >= 4 ? card.id.substring(card.id.length - 4) : '1234';

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // perspective
                                ..rotateY(rotationY)
                                ..scale(scale),
                              alignment: FractionalOffset.center,
                              child: GestureDetector(
                                onTap: () {
                                  if (_currentIndex == index) {
                                    CreditCardHistoryModal.show(context, card);
                                  } else {
                                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      if (absOffset < 0.5)
                                        BoxShadow(color: c1.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))
                                    ],
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                                      colors: [c1, c2],
                                    ),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Stack(
                                      children: [
                                        // Modern Glass Blobs
                                        Positioned(
                                          top: -50, right: -20,
                                          child: Container(
                                            width: 150, height: 150,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(alpha: 0.1),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -80, left: -40,
                                          child: Container(
                                            width: 200, height: 200,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withValues(alpha: 0.1),
                                            ),
                                          ),
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
                                                  // Clean minimalist chip (just an icon now, not a ugly box)
                                                  const Icon(LucideIcons.creditCard, color: Colors.white, size: 32),
                                                  const Icon(LucideIcons.nfc, color: Colors.white, size: 28),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '•••• •••• •••• $dummyNum',
                                                    style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(card.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                                      // Master/Visa generic indicator
                                                      Row(
                                                        children: [
                                                          Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle)),
                                                          Transform.translate(
                                                            offset: const Offset(-6, 0),
                                                            child: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), shape: BoxShape.circle)),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Dynamic Stats Panel for Active Card
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            key: ValueKey<String>(activeCard.id),
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  // Debt Header
                                  Text('Deuda Actual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  const SizedBox(height: 8),
                                  Text(
                                    CurrencyFormatter.format(activeCard.currentBalance, currencyCode),
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isOverdrawn ? const Color(0xFFEF4444).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Disponible: ${CurrencyFormatter.format(availableAmount, currencyCode)}',
                                      style: TextStyle(color: isOverdrawn ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Dates Info (Corte / Pago)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(LucideIcons.calendarClock, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 24),
                                              const SizedBox(height: 12),
                                              Text('Corte', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
                                              Text('Día ${activeCard.cutOffDay}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(LucideIcons.calendarCheck2, color: activeCard.color, size: 24),
                                              const SizedBox(height: 12),
                                              Text('Pago', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
                                              Text('Día ${activeCard.paymentDay}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          onTap: () { HapticFeedback.heavyImpact(); _showPaymentDialog(context, activeCard, currencyCode, ref); },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            decoration: BoxDecoration(
                                              color: activeCard.color,
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [BoxShadow(color: activeCard.color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                                            ),
                                            child: const Center(
                                              child: Text('Pagar Deuda', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () { HapticFeedback.selectionClick(); CreditCardHistoryModal.show(context, activeCard); },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
                                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                                            ),
                                            child: Center(
                                              child: Icon(LucideIcons.history, color: isDark ? Colors.white : Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
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
      ),
    );
  }
}
