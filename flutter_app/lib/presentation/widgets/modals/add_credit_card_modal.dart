import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/credit_card_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class AddCreditCardModal extends ConsumerStatefulWidget {
  final CreditCard? existingCard;
  const AddCreditCardModal({super.key, this.existingCard});

  static Future<void> show(BuildContext context, {CreditCard? existingCard}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        builder: (_, scrollController) => AddCreditCardModal(
          existingCard: existingCard,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddCreditCardModal> createState() => _AddCreditCardModalState();
}

class _AddCreditCardModalState extends ConsumerState<AddCreditCardModal> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _balanceController = TextEditingController();

  int _cutOffDay = 15;
  int _paymentDay = 5;
  String _network = 'Visa';
  Color _selectedColor = const Color(0xFF1E3A8A);
  bool _isSaving = false;

  final List<Map<String, dynamic>> _cardThemes = [
    {
      'name': 'Obsidian',
      'color': const Color(0xFF0F172A),
      'c2': const Color(0xFF020617),
      'label': 'Obsidiana',
    },
    {
      'name': 'Deep Navy',
      'color': const Color(0xFF1E3A8A),
      'c2': const Color(0xFF0C1D4A),
      'label': 'Zafiro',
    },
    {
      'name': 'Royal Indigo',
      'color': const Color(0xFF312E81),
      'c2': const Color(0xFF1E1B4B),
      'label': 'Índigo',
    },
    {
      'name': 'VIP Purple',
      'color': const Color(0xFF581C87),
      'c2': const Color(0xFF3B0764),
      'label': 'Amatista',
    },
    {
      'name': 'Emerald VIP',
      'color': const Color(0xFF064E3B),
      'c2': const Color(0xFF022C22),
      'label': 'Esmeralda',
    },
    {
      'name': 'Ruby Red',
      'color': const Color(0xFF881337),
      'c2': const Color(0xFF4C0519),
      'label': 'Rubí',
    },
    {
      'name': 'Amber Sunset',
      'color': const Color(0xFF78350F),
      'c2': const Color(0xFF451A03),
      'label': 'Ámbar',
    },
    {
      'name': 'Cyber Teal',
      'color': const Color(0xFF134E4A),
      'c2': const Color(0xFF042F2E),
      'label': 'Turquesa',
    },
    {
      'name': 'Titanium',
      'color': const Color(0xFF334155),
      'c2': const Color(0xFF1E293B),
      'label': 'Titanio',
    },
  ];

  final List<String> _networks = ['Visa', 'Mastercard', 'Amex', 'Otra'];

  final List<double> _quickLimitIncrements = [
    1000,
    5000,
    10000,
    20000,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameController.text = card.name;
      _limitController.text = card.limit > 0 ? card.limit.toStringAsFixed(0) : '';
      _balanceController.text = card.currentBalance.toStringAsFixed(0);
      _cutOffDay = card.cutOffDay.clamp(1, 31);
      _paymentDay = card.paymentDay.clamp(1, 31);
      _network = card.network;
      _selectedColor = card.color;
    } else {
      _nameController.text = '';
      _limitController.text = '10000';
      _balanceController.text = '0';
      _cutOffDay = 15;
      _paymentDay = 5;
      _network = 'Visa';
      _selectedColor = const Color(0xFF1E3A8A);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final limitStr = _limitController.text.trim();

    if (name.isEmpty || limitStr.isEmpty) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre y el límite de tu tarjeta.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final limit = double.tryParse(limitStr) ?? 0.0;
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    final card = CreditCard(
      id: widget.existingCard?.id ?? '',
      name: name,
      limit: limit,
      currentBalance: balance,
      cutOffDay: _cutOffDay,
      paymentDay: _paymentDay,
      network: _network,
      color: _selectedColor,
      createdAt: widget.existingCard?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.existingCard != null) {
        await ref
            .read(creditCardControllerProvider.notifier)
            .updateCreditCard(card);
      } else {
        await ref
            .read(creditCardControllerProvider.notifier)
            .addCreditCard(card);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingCard != null
                  ? '¡Tarjeta "$name" actualizada con éxito! 💳✨'
                  : '¡Tarjeta "$name" agregada a tu billetera! 🚀💳',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar tarjeta: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency ?? 'GTQ';
    final sym = CurrencyFormatter.getSymbol(currencyCode);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4.5,
            width: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.creditCard,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingCard != null
                              ? 'Editar Tarjeta'
                              : 'Nueva Tarjeta de Crédito',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          widget.existingCard != null
                              ? 'Personaliza límites, fechas y estilo'
                              : 'Configura tu plástico y calendario de pago',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            height: 1,
          ),

          // Scrollable Form Body
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              children: [
                // 1. LIVE CARD HERO PREVIEW
                _buildLiveCardHero(currencyCode),

                const SizedBox(height: 20),

                // 2. CARD INFORMATION
                _buildSectionHeader('INFORMACIÓN DE LA TARJETA', LucideIcons.tag, isDark),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre de la Tarjeta o Banco',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Ej. Visa Clásica, BAC Oro, Tarjeta Promerica',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          prefixIcon: Icon(
                            LucideIcons.creditCard,
                            size: 18,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Franquicia / Red de Pago',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Modern Pill Segmented Control
                      Row(
                        children: _networks.map((net) {
                          final isSelected = _network.toLowerCase() == net.toLowerCase();
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _network = net);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF06B6D4)
                                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF06B6D4)
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    net,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. LIMITS & CURRENT BALANCE
                _buildSectionHeader('LÍMITE Y SALDO DEUDOR', LucideIcons.coins, isDark),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Límite de Crédito ($sym)',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _limitController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deuda Actual ($sym)',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _balanceController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Quick Limit Increment Chips
                      Wrap(
                        spacing: 8,
                        children: _quickLimitIncrements.map((inc) {
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final current = double.tryParse(_limitController.text) ?? 0.0;
                              setState(() {
                                _limitController.text = (current + inc).toStringAsFixed(0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                '+$sym${inc.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 4. BILLING CALENDAR: CORTE & PAGO
                _buildSectionHeader('CALENDARIO DE CORTE Y PAGO', LucideIcons.calendarCheck, isDark),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Día de Corte
                      _buildDayStripRow(
                        title: 'Día de Corte',
                        subtitle: 'Cierra tu periodo de compras del mes',
                        selectedDay: _cutOffDay,
                        color: const Color(0xFF38BDF8),
                        onSelect: (d) => setState(() => _cutOffDay = d),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),
                      Divider(color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),

                      // Día de Pago
                      _buildDayStripRow(
                        title: 'Día Límite de Pago',
                        subtitle: 'Último día para pagar sin intereses',
                        selectedDay: _paymentDay,
                        color: const Color(0xFF34D399),
                        onSelect: (d) => setState(() => _paymentDay = d),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 14),

                      // Financing Window Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _buildFinancingText(),
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0E7490),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. COLOR & THEME SELECTOR
                _buildSectionHeader('COLOR Y ESTILO DEL PLÁSTICO', LucideIcons.palette, isDark),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cardThemes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final theme = _cardThemes[idx];
                      final color = theme['color'] as Color;
                      final c2 = theme['c2'] as Color;
                      final isSelected = _selectedColor.value == color.value;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColor = color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: isSelected ? 56 : 48,
                          height: isSelected ? 56 : 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, c2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.25),
                              width: isSelected ? 2.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: isSelected ? 0.6 : 0.2),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(LucideIcons.check, size: 22, color: Colors.white),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // 6. SUBMIT BUTTON
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            widget.existingCard != null
                                ? 'Guardar Cambios'
                                : 'Crear Tarjeta de Crédito',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? const Color(0xFF06B6D4) : const Color(0xFF0284C7),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDayStripRow({
    required String title,
    required String subtitle,
    required int selectedDay,
    required Color color,
    required ValueChanged<int> onSelect,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Día $selectedDay',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 31,
            itemBuilder: (context, idx) {
              final day = idx + 1;
              final isSelected = selectedDay == day;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : (isDark ? const Color(0xFF0F172A) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF334155)),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCardHero(String currencyCode) {
    final theme = _cardThemes.firstWhere(
      (t) => (t['color'] as Color).value == _selectedColor.value,
      orElse: () => _cardThemes[1],
    );
    final c1 = theme['color'] as Color;
    final c2 = theme['c2'] as Color;
    final nameVal = _nameController.text.trim().isEmpty ? 'MI TARJETA' : _nameController.text.trim().toUpperCase();
    final limitVal = double.tryParse(_limitController.text) ?? 0.0;

    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: c1.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Metallic EMV Chip + Contactless + Franchise Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Metallic Gold Chip
                    Container(
                      width: 42,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFDF00), Color(0xFFD4AF37), Color(0xFFAA771C)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF5D4037).withValues(alpha: 0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      LucideIcons.wifi,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
                // Network Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _network.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Name & Masked Number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameVal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '•••• •••• •••• 8842',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Bottom: Limit & Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LÍMITE TOTAL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(limitVal, currencyCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildHeroDateBadge('CORTE', 'Día $_cutOffDay', const Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    _buildHeroDateBadge('PAGO', 'Día $_paymentDay', const Color(0xFF34D399)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroDateBadge(String tag, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            tag,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _buildFinancingText() {
    int days = _paymentDay - _cutOffDay;
    if (days <= 0) days += 30;
    return 'Cuentas con $days días entre tu corte y tu pago para liquidar sin intereses.';
  }
}
