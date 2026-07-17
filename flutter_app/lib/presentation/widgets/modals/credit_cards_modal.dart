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

class _CreditCardsModalInternal extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _CreditCardsModalInternal({required this.scrollController});

  @override
  ConsumerState<_CreditCardsModalInternal> createState() => _CreditCardsModalInternalState();
}

class _CreditCardsModalInternalState extends ConsumerState<_CreditCardsModalInternal> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    RecurringTransactionService.evaluateCreditCardAlerts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final creditCardsAsync = ref.watch(computedCreditCardsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;
    final loc = ref.watch(localizationProvider);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        children: [
          // Elegant Handle
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            height: 5, width: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
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
                        color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withValues(alpha: 0.2), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Icon(LucideIcons.creditCard, color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.get('credit_cards'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text(loc.get('cc_subtitle'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
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
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // Add Card Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          AddCreditCardModal.show(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withValues(alpha: 0.1),
                            border: Border.all(color: (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)).withValues(alpha: 0.3), width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plusCircle, color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706), size: 22),
                              const SizedBox(width: 12),
                              Text(loc.get('cc_add'), style: TextStyle(color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (cards.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(LucideIcons.creditCard, size: 64, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              const SizedBox(height: 16),
                              Text(loc.get('voice_no_cards'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // GOOGLE WALLET CAROUSEL SECTION
                      _buildGoogleWalletCarousel(cards, isDark, currencyCode),
                      
                      const SizedBox(height: 16),

                      // DOTS INDICATOR
                      if (cards.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(cards.length, (i) {
                            final isActive = i == (_selectedIndex < cards.length ? _selectedIndex : 0);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706))
                                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      
                      const SizedBox(height: 24),

                      // ACTIVE CARD DETAILS & ACTIONS
                      _buildActiveCardDetails(cards, isDark, currencyCode),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text(loc.get('cc_err_load'))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoogleWalletCarousel(List<CreditCard> cards, bool isDark, String? currencyCode) {
    if (cards.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => CreditCardHistoryModal.show(context, cards[0]),
          child: _buildCardItem(cards[0], isDark, currencyCode, isCenter: true),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: PageView.builder(
        clipBehavior: Clip.none,
        controller: _pageController,
        itemCount: cards.length,
        onPageChanged: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0.0;
              if (_pageController.position.haveDimensions) {
                value = index - (_pageController.page ?? 0);
              } else {
                value = (index - _selectedIndex).toDouble();
              }
              // Google Wallet depth effect:
              final double scale = (1 - (value.abs() * 0.12)).clamp(0.85, 1.0);
              final double opacity = (1 - (value.abs() * 0.35)).clamp(0.4, 1.0);
              final double translateY = (value.abs() * 12);
              final double rotateZ = value * 0.05; // slight tilt

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.rotate(
                  angle: rotateZ,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                if (_selectedIndex != index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                } else {
                  CreditCardHistoryModal.show(context, cards[index]);
                }
              },
              child: _buildCardItem(cards[index], isDark, currencyCode, isCenter: index == (_selectedIndex < cards.length ? _selectedIndex : 0)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveCardDetails(List<CreditCard> cards, bool isDark, String? currencyCode) {
    final loc = ref.watch(localizationProvider);
    final int safeIdx = _selectedIndex < cards.length ? _selectedIndex : 0;
    final card = cards[safeIdx];
    final availableBalance = card.limit - card.currentBalance;
    final double usagePercent = card.limit > 0 ? (card.currentBalance / card.limit).clamp(0.0, 1.0) : 0.0;
    final bool isOverdrawn = card.currentBalance >= card.limit && card.limit > 0;
    final bool isNearLimit = usagePercent >= 0.9 && !isOverdrawn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(card.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tap hint banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.touchpad, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.get('cc_tap_hint'),
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Visual warning tags
            if (isOverdrawn || isNearLimit)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (isOverdrawn ? Colors.red : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (isOverdrawn ? Colors.red : Colors.orange).withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, size: 20, color: isOverdrawn ? Colors.red : Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOverdrawn ? loc.get('cc_overdrawn') : loc.get('cc_near_limit'),
                            style: TextStyle(
                              color: isOverdrawn ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOverdrawn
                                ? loc.get('cc_overdrawn_desc')
                                : loc.get('cc_near_limit_desc'),
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Action Area: Limit info and Pay button side-by-side
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Limit Info (Left side)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        boxShadow: [
                          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.get('cc_avail_limit'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(isOverdrawn ? '-\$0.00' : CurrencyFormatter.format(availableBalance, currencyCode), style: TextStyle(color: isOverdrawn ? Colors.red : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w900, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(loc.get('cc_of').replaceAll('{limit}', CurrencyFormatter.format(card.limit, currencyCode)), style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 11), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Pay Button (Right side)
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showPaymentDialog(context, ref, card, currencyCode);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(LucideIcons.checkCircle, size: 22),
                      label: Text(loc.get('cc_pay_debt'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions Row - Ver Historial
            InkWell(
              onTap: () => CreditCardHistoryModal.show(context, card),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(LucideIcons.listOrdered, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.get('cc_view_history'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(loc.get('cc_view_history_sub'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Icon(LucideIcons.chevronRight, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(CreditCard card, bool isDark, String? currencyCode, {bool isCenter = false}) {
    final loc = ref.watch(localizationProvider);
    final bool isOverdrawn = card.currentBalance >= card.limit && card.limit > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: isCenter
                ? [
                    BoxShadow(
                      color: (isOverdrawn ? Colors.redAccent : card.color).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: AspectRatio(
            aspectRatio: 1.586,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: isOverdrawn ? const Color(0xFF991B1B) : const Color(0xFF1E293B),
                ),
                child: Stack(
                  children: [
                    // Mesh Gradient Orbs
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isOverdrawn ? Colors.redAccent : card.color).withValues(alpha: 0.5),
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isOverdrawn ? Colors.orangeAccent : card.color.withValues(alpha: 0.3)),
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                    // Card Info
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top row: Chip and More Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sleek Silver Chip
                              Container(
                                width: 38, height: 26,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.5),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 2, offset: const Offset(0, 1))],
                                ),
                                child: CustomPaint(
                                  painter: _ChipPainter(),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20),
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
                                        Text(loc.get('cc_edit_card'), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                                        const SizedBox(width: 8),
                                        Text(loc.get('cc_delete_card'), style: const TextStyle(color: Colors.red)),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(card.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5), overflow: TextOverflow.ellipsis),
                                  Icon(LucideIcons.wifi, color: Colors.white.withValues(alpha: 0.8), size: 15),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text('•••• •••• •••• ${card.id.length >= 4 ? card.id.substring(card.id.length - 4).toUpperCase() : '0000'}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, letterSpacing: 2.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(loc.get('cc_current_debt'), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                                  Text(loc.get('cc_limit'), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (card.currentBalance <= 0)
                                    Text(loc.get('cc_up_to_date'), style: const TextStyle(color: Color(0xFF10B981), fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.0))
                                  else
                                    Text(CurrencyFormatter.format(card.currentBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                  Text(CurrencyFormatter.format(card.limit, currencyCode), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
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
                                    Text(loc.get('cc_credit_card'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(loc.get('cc_cut_off').replaceAll('{cut}', '${card.cutOffDay}').replaceAll('{pay}', '${card.paymentDay}'), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(card.network.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Premium Border Glow
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isOverdrawn)
          Positioned(
            top: 14,
            right: 48,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _showPaymentDialog(BuildContext context, WidgetRef ref, CreditCard card, String? currencyCode) async {
    final TextEditingController amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.read(localizationProvider);
    
    // Use card color
    Color cardColor1 = card.color;
    Color cardColor2 = card.color.withValues(alpha: 0.7);
    final minPayment = card.currentBalance * 0.05;
    final halfPayment = card.currentBalance * 0.5;

    int selectedChipIndex = -1;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, -10))
            ],
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 48, height: 5,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.get('cc_pay_title'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(loc.get('cc_pay_sub'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Mini Card Preview
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardColor1, cardColor2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: cardColor1.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(card.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                                child: Text(card.network.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('•••• •••• •••• ${card.id.length >= 4 ? card.id.substring(card.id.length - 4).toUpperCase() : '0000'}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, letterSpacing: 2)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.get('cc_pay_current_lbl'), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                  const SizedBox(height: 4),
                                  Text(CurrencyFormatter.format(card.currentBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                ],
                              ),
                              const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 28),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Selection Chips
                    Text(loc.get('cc_pay_quick_lbl'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickChip(
                            label: loc.get('cc_pay_min'),
                            amount: minPayment,
                            currencyCode: currencyCode,
                            isDark: isDark,
                            isHighlighted: selectedChipIndex == 0,
                            onTap: (val) {
                              setModalState(() {
                                selectedChipIndex = 0;
                                amountController.text = val.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickChip(
                            label: loc.get('cc_pay_half'),
                            amount: halfPayment,
                            currencyCode: currencyCode,
                            isDark: isDark,
                            isHighlighted: selectedChipIndex == 1,
                            onTap: (val) {
                              setModalState(() {
                                selectedChipIndex = 1;
                                amountController.text = val.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickChip(
                            label: loc.get('cc_pay_total'),
                            amount: card.currentBalance,
                            currencyCode: currencyCode,
                            isDark: isDark,
                            isHighlighted: selectedChipIndex == 2,
                            onTap: (val) {
                              setModalState(() {
                                selectedChipIndex = 2;
                                amountController.text = val.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input TextField
                    TextField(
                      controller: amountController,
                      onChanged: (val) {
                        if (selectedChipIndex != -1) {
                          setModalState(() {
                            selectedChipIndex = -1;
                          });
                        }
                      },
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        labelText: 'Ingresa o edita el monto a pagar',
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                        prefixIcon: Icon(LucideIcons.wallet, color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                            child: Text(loc.get('modal_cancel'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final double? amount = double.tryParse(amountController.text.trim());
                              if (amount == null || amount <= 0) return;
                              
                              if (amount > card.currentBalance + 0.01) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(loc.get('cc_err_amount_excess'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              try {
                                final user = firebase_auth.FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                final transaction = TransactionModel(
                                  id: '',
                                  userId: user.uid,
                                  amount: amount,
                                  type: 'cc_payment',
                                  category: 'Pago de Tarjeta',
                                  description: 'Abono a ${card.name}',
                                  date: DateTime.now(),
                                  isFixed: false,
                                  creditCardId: card.id,
                                );

                                await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                                
                                final newBalance = card.currentBalance - amount;
                                final updatedCard = card.copyWith(currentBalance: newBalance < 0 ? 0 : newBalance);
                                await ref.read(creditCardControllerProvider.notifier).updateCreditCard(updatedCard);
                                
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(loc.get('cc_snack_paid'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      backgroundColor: const Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 6,
                              shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.checkCircle2, size: 20),
                                SizedBox(width: 8),
                                Text('Confirmar Abono', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required double amount,
    required String? currencyCode,
    required bool isDark,
    bool isHighlighted = false,
    required Function(double) onTap,
  }) {
    return InkWell(
      onTap: () => onTap(amount),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isHighlighted 
              ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.15)
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9)),
          border: Border.all(
            color: isHighlighted 
                ? const Color(0xFF10B981)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
            width: isHighlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHighlighted ? [
            BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isHighlighted) ...[
                  const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 12),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(label, style: TextStyle(color: isHighlighted ? const Color(0xFF10B981) : (isDark ? Colors.grey[400] : Colors.grey[700]), fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(CurrencyFormatter.format(amount, currencyCode), style: TextStyle(color: isHighlighted ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black), fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
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
