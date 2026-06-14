import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/credit_card_provider.dart';

class AddCreditCardModal extends ConsumerStatefulWidget {
  final CreditCard? existingCard;
  const AddCreditCardModal({super.key, this.existingCard});

  static Future<void> show(BuildContext context, {CreditCard? existingCard}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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

  final List<Color> _colors = [
    const Color(0xFF1E3A8A),
    const Color(0xFFB91C1C),
    const Color(0xFF047857),
    const Color(0xFFB45309),
    const Color(0xFF4C1D95),
    const Color(0xFF111827),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameController.text = card.name;
      _limitController.text = card.limit.toString();
      _balanceController.text = card.currentBalance.toString();
      _cutOffDay = card.cutOffDay;
      _paymentDay = card.paymentDay;
      _network = card.network;
      _selectedColor = card.color;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _limitController.text.isEmpty) return;

    final limit = double.tryParse(_limitController.text) ?? 0.0;
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    final card = CreditCard(
      id: widget.existingCard?.id ?? '', // Firestore will generate if empty
      name: _nameController.text,
      limit: limit,
      currentBalance: balance,
      cutOffDay: _cutOffDay,
      paymentDay: _paymentDay,
      network: _network,
      color: _selectedColor,
      createdAt: widget.existingCard?.createdAt ?? DateTime.now(),
    );

    if (widget.existingCard != null) {
      await ref.read(creditCardControllerProvider.notifier).updateCreditCard(card);
    } else {
      await ref.read(creditCardControllerProvider.notifier).addCreditCard(card);
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4, width: 40,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existingCard != null ? 'Editar Tarjeta' : 'Nueva Tarjeta', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Tarjeta (ej. NuBank, Amex)',
                    prefixIcon: const Icon(LucideIcons.creditCard),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _limitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Límite',
                          prefixIcon: const Icon(LucideIcons.banknote),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _balanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Deuda Actual',
                          prefixIcon: const Icon(LucideIcons.trendingDown),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _cutOffDay,
                        decoration: InputDecoration(
                          labelText: 'Día de Corte',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                        onChanged: (v) => setState(() => _cutOffDay = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _paymentDay,
                        decoration: InputDecoration(
                          labelText: 'Día de Pago',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                        onChanged: (v) => setState(() => _paymentDay = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _network,
                  decoration: InputDecoration(
                    labelText: 'Franquicia',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                    DropdownMenuItem(value: 'Mastercard', child: Text('Mastercard')),
                    DropdownMenuItem(value: 'American Express', child: Text('American Express')),
                  ],
                  onChanged: (v) => setState(() => _network = v!),
                ),
                const SizedBox(height: 16),
                const Text('Color de la Tarjeta'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _colors.map((color) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(widget.existingCard != null ? 'Actualizar Tarjeta' : 'Guardar Tarjeta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
