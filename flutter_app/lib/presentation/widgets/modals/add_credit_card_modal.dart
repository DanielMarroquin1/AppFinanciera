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
        initialChildSize: 0.88,
        minChildSize: 0.50,
        maxChildSize: 0.94,
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

  final List<Map<String, dynamic>> _networks = [
    {'name': 'Visa', 'icon': '💎', 'label': 'VISA'},
    {'name': 'Mastercard', 'icon': '🔴', 'label': 'MASTERCARD'},
    {'name': 'Amex', 'icon': '🛡️', 'label': 'AMEX'},
    {'name': 'Otro', 'icon': '💳', 'label': 'OTRO'},
  ];

  final List<String> _bankSuggestions = [
    'BBVA',
    'Nu',
    'Santander',
    'Citibanamex',
    'Mercado Pago',
    'Banorte',
    'Amex',
  ];

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
      _limitController.text = '15000';
      _balanceController.text = '0';
      _cutOffDay = 15;
      _paymentDay = 5;
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
                  : '¡Tarjeta "$name" agregada con éxito! 🚀💳',
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

  Widget _buildLiveCardPreview(String currencyCode) {
    final limitVal = double.tryParse(_limitController.text) ?? 0.0;
    final nameVal = _nameController.text.trim().isEmpty
        ? 'MI TARJETA'
        : _nameController.text.trim().toUpperCase();

    // Dark secondary gradient color
    final c2 = Color.lerp(_selectedColor, Colors.black, 0.45)!;

    return Container(
      width: double.infinity,
      height: 205,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedColor, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Holographic diagonal light streak
          Positioned(
            top: -40,
            right: 40,
            child: Transform.rotate(
              angle: -0.45,
              child: Container(
                width: 90,
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.09),
                      Colors.white.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Watermark icon
          Positioned(
            right: -25,
            bottom: -25,
            child: Icon(
              LucideIcons.creditCard,
              size: 160,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Gold Chip, Contactless icon & Network badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Realistic Gold EMV Chip
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDF00), Color(0xFFD4AF37), Color(0xFFAA771C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(7),
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
                              width: 32,
                              height: 22,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF5D4037).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.wifi,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 20,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _network.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Cardholder Name & Masked Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameVal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '•••• •••• •••• 8842',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        letterSpacing: 2.2,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Bottom row: Limit and Billing Days
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
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(limitVal, currencyCode),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildMiniDatePill('CORTE', 'Día $_cutOffDay', const Color(0xFF38BDF8)),
                        const SizedBox(width: 8),
                        _buildMiniDatePill('PAGO', 'Día $_paymentDay', const Color(0xFF34D399)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDatePill(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDaySelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int selectedDay,
    required ValueChanged<int> onSelect,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
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

        // Smooth horizontal inline day strip (1 to 31)
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = selectedDay == day;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                            : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency ?? 'USD';
    final currencySymbol = CurrencyFormatter.getSymbol(currencyCode);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
            // Top Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 4.5,
              width: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.existingCard != null
                                ? 'Personaliza límites, fechas y estilo'
                                : 'Configura tu plástico financiero',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

            // Form Body
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                children: [
                  // 1. LIVE CARD PREVIEW
                  _buildLiveCardPreview(currencyCode),

                  // 2. CARD NAME & BANK SUGGESTIONS
                  _buildSectionTitle('NOMBRE O IDENTIFICADOR', LucideIcons.tag, isDark),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      'Ej. BBVA Oro, Nu Débito/Crédito, Liverpool',
                      LucideIcons.creditCard,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quick Suggestions Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _bankSuggestions.map((bank) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(
                              bank,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                              ),
                            ),
                            backgroundColor: isDark
                                ? const Color(0xFF0369A1).withValues(alpha: 0.15)
                                : const Color(0xFFE0F2FE),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF0369A1).withValues(alpha: 0.4)
                                  : const Color(0xFFBAE6FD),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _nameController.text = bank;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. PAYMENT NETWORK (Visa, Mastercard, Amex, Otro)
                  _buildSectionTitle('FRANQUICIA / RED DE PAGO', LucideIcons.globe, isDark),
                  const SizedBox(height: 8),
                  Row(
                    children: _networks.map((net) {
                      final isSelected = _network == net['name'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _network = net['name']);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                                      : const Color(0xFFE0F2FE))
                                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(net['icon'], style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                  net['label'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // 4. CREDIT LIMIT & CURRENT DEBT
                  _buildSectionTitle('LÍMITE Y SALDO DEUDOR', LucideIcons.wallet, isDark),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Límite de Crédito ($currencySymbol)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _limitController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration(
                                'Ej. 15000',
                                LucideIcons.trendingUp,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deuda / Saldo Actual ($currencySymbol)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _balanceController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              decoration: _inputDecoration(
                                '0.00',
                                LucideIcons.trendingDown,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick Limit Adders
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickLimitIncrements.map((inc) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(
                              '+$currencySymbol${inc.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                              ),
                            ),
                            backgroundColor: isDark
                                ? const Color(0xFF065F46).withValues(alpha: 0.2)
                                : const Color(0xFFD1FAE5),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF059669).withValues(alpha: 0.4)
                                  : const Color(0xFFA7F3D0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              final cur = double.tryParse(_limitController.text) ?? 0.0;
                              setState(() {
                                _limitController.text = (cur + inc).toStringAsFixed(0);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. INLINE BILLING DAYS (CORTE Y PAGO - NO NESTED MODALS!)
                  _buildSectionTitle('CICLO DE FACTURACIÓN Y RECORDATORIOS', LucideIcons.calendarClock, isDark),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Día de Corte selector
                        _buildInlineDaySelector(
                          title: 'Día de Corte',
                          subtitle: 'Cierre del período mensual',
                          icon: LucideIcons.scissors,
                          color: const Color(0xFF38BDF8),
                          selectedDay: _cutOffDay,
                          onSelect: (day) => setState(() => _cutOffDay = day),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          height: 1,
                        ),
                        const SizedBox(height: 16),

                        // Día de Pago selector
                        _buildInlineDaySelector(
                          title: 'Día Límite de Pago',
                          subtitle: 'Paga a tiempo para evitar intereses',
                          icon: LucideIcons.checkCircle2,
                          color: const Color(0xFF34D399),
                          selectedDay: _paymentDay,
                          onSelect: (day) => setState(() => _paymentDay = day),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),

                        // Notification notice pill
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.bellRing, color: Color(0xFFF59E0B), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'QUIVO te notificará automáticamente 2 días antes y el mismo día de tu corte y pago.',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. COLOR THEME PRESETS
                  _buildSectionTitle('COLOR Y TEXTURA DE LA TARJETA', LucideIcons.palette, isDark),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cardThemes.length,
                      itemBuilder: (context, index) {
                        final theme = _cardThemes[index];
                        final Color color = theme['color'];
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColor = color);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, theme['c2'] as Color],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white24,
                                width: isSelected ? 3.5 : 1.0,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.7),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(LucideIcons.check, color: Colors.white, size: 22)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 7. PRIMARY ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
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
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.existingCard != null
                                        ? 'GUARDAR CAMBIOS EN TARJETA'
                                        : 'CREAR TARJETA DE CRÉDITO',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : const Color(0xFF334155),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[400],
        fontSize: 13.5,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
        size: 18,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 2),
      ),
    );
  }
}
