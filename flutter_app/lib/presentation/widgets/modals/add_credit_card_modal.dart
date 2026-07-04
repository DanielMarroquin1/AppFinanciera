import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, __) => AddCreditCardModal(existingCard: existingCard),
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
  int _paymentDay = 1;
  String _network = 'Visa';
  Color _selectedColor = const Color(0xFF1E3A8A);
  bool _isSaving = false;

  final List<Color> _colors = [
    const Color(0xFF1E3A8A), // Deep Blue
    const Color(0xFF4C1D95), // Purple VIP
    const Color(0xFF047857), // Emerald Green
    const Color(0xFFB91C1C), // Crimson Red
    const Color(0xFFB45309), // Amber Gold
    const Color(0xFF0F172A), // Obsidian Black
    const Color(0xFF0284C7), // Sky Blue
    const Color(0xFFBE185D), // Magenta Rose
  ];

  final List<Map<String, dynamic>> _networks = [
    {'name': 'Visa', 'icon': '💎', 'label': 'VISA'},
    {'name': 'Mastercard', 'icon': '🔴', 'label': 'MASTERCARD'},
    {'name': 'American Express', 'icon': '🛡️', 'label': 'AMEX'},
    {'name': 'Discover', 'icon': '🌟', 'label': 'DISCOVER'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameController.text = card.name;
      _limitController.text = card.limit.toStringAsFixed(0);
      _balanceController.text = card.currentBalance.toStringAsFixed(0);
      _cutOffDay = card.cutOffDay;
      _paymentDay = card.paymentDay;
      _network = card.network;
      _selectedColor = card.color;
    } else {
      _nameController.text = 'Mi Tarjeta VIP';
      _limitController.text = '5000';
      _balanceController.text = '0';
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
    if (_nameController.text.trim().isEmpty || _limitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre y un límite para la tarjeta.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final limit = double.tryParse(_limitController.text) ?? 0.0;
    final balance = widget.existingCard != null 
        ? widget.existingCard!.currentBalance 
        : (double.tryParse(_balanceController.text) ?? 0.0);

    final card = CreditCard(
      id: widget.existingCard?.id ?? '',
      name: _nameController.text.trim(),
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
        await ref.read(creditCardControllerProvider.notifier).updateCreditCard(card);
      } else {
        await ref.read(creditCardControllerProvider.notifier).addCreditCard(card);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingCard != null ? '¡Tarjeta actualizada con éxito! 💳✨' : '¡Nueva tarjeta configurada con éxito! 🚀💳'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildLiveCardPreview(String currencyCode) {
    final limitVal = double.tryParse(_limitController.text) ?? 0.0;
    final nameVal = _nameController.text.trim().isEmpty ? 'MI TARJETA VIP' : _nameController.text.trim().toUpperCase();

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedColor,
            Color.lerp(_selectedColor, Colors.black, 0.4)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Stack(
        children: [
          // Background decorative watermark
          Positioned(
            right: -20,
            bottom: -20,
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
                // Top row: Chip and Network
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 18,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withValues(alpha: 0.3), width: 1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.wifi, color: Colors.white.withValues(alpha: 0.8), size: 20),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _network.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                ),

                // Middle: Card Name & Number mask
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameVal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '•••• •••• •••• VIP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        letterSpacing: 2.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                // Bottom row: Limit and Billing info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LÍMITE ASIGNADO',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(limitVal, currencyCode),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildMiniDatePill('CORTE', 'Día $_cutOffDay'),
                        const SizedBox(width: 8),
                        _buildMiniDatePill('PAGO', 'Día $_paymentDay'),
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

  Widget _buildMiniDatePill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 8, fontWeight: FontWeight.w800)),
          Text(value, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency ?? 'USD';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 8),
            height: 5,
            width: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingCard != null ? 'Configurar Tarjeta' : 'Nueva Tarjeta Studio',
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          widget.existingCard != null ? 'Modifica los parámetros e imagen' : 'Diseña tu tarjeta inteligente VIP',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 1),

          // Form Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // LIVE PREVIEW
                _buildLiveCardPreview(currencyCode),

                // CARD NAME
                _buildSectionTitle('IDENTIFICADOR DE LA TARJETA', LucideIcons.tag, isDark),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration('Nombre (ej. NuBank Oro, Amex Platinum)', LucideIcons.creditCard, isDark),
                ),
                const SizedBox(height: 24),

                // NETWORK SELECTOR
                _buildSectionTitle('FRANQUICIA / RED DE PAGO', LucideIcons.globe, isDark),
                const SizedBox(height: 10),
                Row(
                  children: _networks.map((net) {
                    final isSelected = _network == net['name'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _network = net['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF4F46E5).withValues(alpha: 0.25) : const Color(0xFFEEF2FF))
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
                          ),
                          child: Column(
                            children: [
                              Text(net['icon'], style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                net['label'],
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.grey[400] : Colors.grey[600]),
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
                const SizedBox(height: 24),

                // LIMIT AND BALANCE
                _buildSectionTitle('LÍMITE Y SALDO INICIAL', LucideIcons.banknote, isDark),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _limitController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration('Límite Asignado', LucideIcons.trendingUp, isDark),
                      ),
                    ),
                    if (widget.existingCard == null) ...[
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _balanceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: _inputDecoration('Deuda Actual', LucideIcons.trendingDown, isDark),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // CUT OFF AND PAYMENT DAYS
                _buildSectionTitle('CICLO DE FACTURACIÓN Y ALERTAS', LucideIcons.calendarClock, isDark),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDaySelector(
                              title: 'DÍA DE CORTE',
                              subtitle: 'Cierre del mes',
                              icon: LucideIcons.scissors,
                              color: const Color(0xFF3B82F6),
                              currentDay: _cutOffDay,
                              onChanged: (v) => setState(() => _cutOffDay = v),
                              isDark: isDark,
                            ),
                          ),
                          Container(width: 1, height: 60, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 12)),
                          Expanded(
                            child: _buildDaySelector(
                              title: 'DÍA DE PAGO',
                              subtitle: 'Límite sin interés',
                              icon: LucideIcons.checkCircle2,
                              color: const Color(0xFF10B981),
                              currentDay: _paymentDay,
                              onChanged: (v) => setState(() => _paymentDay = v),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.bellRing, color: Color(0xFFF59E0B), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Te notificaremos automáticamente 2 días antes, 1 día antes y el mismo día de corte y de pago.',
                                style: TextStyle(color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // COLOR PALETTE SWATCHES
                _buildSectionTitle('COLOR DE ESTILO STUDIO', LucideIcons.palette, isDark),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                            boxShadow: [
                              if (isSelected) BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 22) : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                widget.existingCard != null ? 'GUARDAR CAMBIOS EN TARJETA' : 'CREAR TARJETA STUDIO VIP',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
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
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : const Color(0xFF334155),
            fontSize: 12,
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
      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
    );
  }

  Widget _buildDaySelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int currentDay,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentDay,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              icon: Icon(LucideIcons.chevronDown, size: 18, color: color),
              items: List.generate(31, (i) {
                final day = i + 1;
                return DropdownMenuItem(
                  value: day,
                  child: Text('Día $day', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                );
              }),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
