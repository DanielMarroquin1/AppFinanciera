import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/bank_notification_listener_service.dart';
import '../../../core/services/siri_shortcuts_service.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/credit_card_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/transaction.dart';
import 'voice_expense_modal.dart';
import 'premium_modal.dart';

class PremiumSyncHubModal extends ConsumerStatefulWidget {
  const PremiumSyncHubModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumSyncHubModal(),
    );
  }

  @override
  ConsumerState<PremiumSyncHubModal> createState() => _PremiumSyncHubModalState();
}

class _PremiumSyncHubModalState extends ConsumerState<PremiumSyncHubModal> {
  bool _isAndroidPermissionGranted = false;
  List<ParsedBankCharge> _pendingCharges = [];
  bool _isLoading = true;
  final Map<String, String?> _selectedCardIds = {}; // chargeId -> cardId

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final granted = await BankNotificationListenerService.isPermissionGranted();
    final charges = await BankNotificationListenerService.getPendingCharges();
    if (mounted) {
      setState(() {
        _isAndroidPermissionGranted = granted;
        _pendingCharges = charges;
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateCreditCardCharge() async {
    final simulated = BankNotificationListenerService.parseText(
      'BBVA: Compra aprobada por \$450.00 en Walmart con tu Tarjeta de Crédito *4589',
      'Tu saldo disponible ha sido actualizado.',
      'com.bbva.bank',
    );
    if (simulated != null) {
      await BankNotificationListenerService.addPendingCharge(simulated);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📲 Simulacro recibido: Cargo de \$450 en Walmart con Tarjeta de Crédito. Elige a cuál TC asignarlo arriba 👆'),
            backgroundColor: Color(0xFF6366F1),
          ),
        );
      }
    }
  }

  Future<void> _simulateDebitCharge() async {
    final simulated = BankNotificationListenerService.parseText(
      'Santander: Pago con tarjeta de débito por \$185.50 en Oxxo Sucursal Centro',
      'Movimiento exitoso de tu cuenta de cheques.',
      'com.santander.app',
    );
    if (simulated != null) {
      await BankNotificationListenerService.addPendingCharge(simulated);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📲 Simulacro recibido: Cargo Débito de \$185.50 en Oxxo. Listo para agregar a Efectivo 👆'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _assignChargeToCard(ParsedBankCharge charge, CreditCard card) async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final expense = CreditCardExpense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: charge.merchant,
        amount: charge.amount,
        date: charge.date,
        category: charge.category,
        installments: 1,
      );

      final repo = ref.read(creditCardRepositoryProvider);
      await repo.addExpense(card.id, expense);
      await BankNotificationListenerService.removePendingCharge(charge.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💳 ¡Listo! \$${charge.amount.toStringAsFixed(2)} asignado a tu tarjeta "${card.name}" (${charge.merchant})'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      print('Error assigning to card: $e');
    }
  }

  Future<void> _assignChargeToCash(ParsedBankCharge charge) async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: user.uid,
        amount: charge.amount,
        type: 'expense',
        category: charge.category,
        subCategory: charge.merchant,
        notes: 'Sincronización bancaria automática (${charge.bankName ?? "Débito"})',
        date: charge.date,
        account: 'Efectivo',
      );

      final repo = ref.read(transactionRepositoryProvider);
      await repo.addTransaction(transaction);
      await BankNotificationListenerService.removePendingCharge(charge.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💵 ¡Gasto registrado en Efectivo/Débito! \$${charge.amount.toStringAsFixed(2)} (${charge.merchant})'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      print('Error assigning cash charge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final isPremium = user?.isPremium ?? false;
    final creditCardsAsync = ref.watch(creditCardsProvider);
    final cards = creditCardsAsync.value ?? [];

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 5, width: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(LucideIcons.zap, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Sincronización Inteligente', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        Text('Bancos en Android & Siri en iOS', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12.5)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Bloqueo si no es Premium
          if (!isPremium) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF78350F).withValues(alpha: 0.6), const Color(0xFF451A03).withValues(alpha: 0.6)]
                      : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.crown, color: Color(0xFFD97706), size: 40),
                  const SizedBox(height: 12),
                  Text('Función Exclusiva del Plan Premium', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF78350F), fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    'Conéctate en automático con tus notificaciones bancarias para clasificar compras de TC o Débito, y agrégale gastos a Siri con tu voz en iOS.',
                    style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF92400E), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PremiumModal.show(context);
                    },
                    icon: const Icon(LucideIcons.sparkles, size: 18),
                    label: const Text('Desbloquear Sincronización VIP', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Contenido Scrollable
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- CARGOS PENDIENTES DE ASIGNAR ---
                        if (_pendingCharges.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.bellRing, color: Color(0xFF6366F1), size: 18),
                                  const SizedBox(width: 8),
                                  Text('Cargos Bancarios por Asignar (${_pendingCharges.length})', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w800)),
                                ],
                              ),
                              TextButton(
                                onPressed: () async {
                                  for (var c in _pendingCharges) {
                                    await BankNotificationListenerService.removePendingCharge(c.id);
                                  }
                                  _loadData();
                                },
                                child: const Text('Limpiar todo', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._pendingCharges.map((charge) {
                            final isCardCharge = charge.paymentMethod == 'credit_card';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isCardCharge ? const Color(0xFF6366F1).withValues(alpha: 0.4) : const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.5),
                                boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isCardCharge ? const Color(0xFF6366F1).withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(isCardCharge ? LucideIcons.creditCard : LucideIcons.banknote, size: 14, color: isCardCharge ? const Color(0xFF6366F1) : const Color(0xFF10B981)),
                                            const SizedBox(width: 6),
                                            Text(isCardCharge ? 'Tarjeta de Crédito' : 'Débito / Efectivo', style: TextStyle(color: isCardCharge ? const Color(0xFF6366F1) : const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      ),
                                      Text('\$${charge.amount.toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(charge.merchant, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('Banco: ${charge.bankName ?? "Detección automática"} • Categoría: ${charge.category}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                  const SizedBox(height: 14),

                                  // Selector de tarjeta si es TC o botón de efectivo si es Débito
                                  if (isCardCharge) ...[
                                    Text('Selecciona a cuál de tus Tarjetas de Crédito agregar este cargo:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12.5, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    if (cards.isEmpty)
                                      Text('⚠️ No tienes tarjetas de crédito registradas aún en el apartado de TC.', style: TextStyle(color: Colors.orange[400], fontSize: 12))
                                    else
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: cards.map((card) {
                                          return InkWell(
                                            onTap: () => _assignChargeToCard(charge, card),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)]),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.plusCircle, color: Colors.white, size: 14),
                                                  const SizedBox(width: 6),
                                                  Text('Agregar a "${card.name}"', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _assignChargeToCash(charge),
                                            icon: const Icon(LucideIcons.check, size: 16),
                                            label: const Text('Confirmar como Gasto en Efectivo', style: TextStyle(fontWeight: FontWeight.w800)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],

                        // --- SECTION 1: ANDROID BANK SYNC ---
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                                        child: const Icon(LucideIcons.smartphone, color: Color(0xFF10B981), size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Android: Lector Bancario', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isAndroidPermissionGranted ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 8, height: 8, decoration: BoxDecoration(color: _isAndroidPermissionGranted ? const Color(0xFF10B981) : Colors.orange, shape: BoxShape.circle)),
                                        const SizedBox(width: 6),
                                        Text(_isAndroidPermissionGranted ? 'ACTIVO' : 'PERMISO REQUERIDO', style: TextStyle(color: _isAndroidPermissionGranted ? const Color(0xFF10B981) : Colors.orange, fontSize: 11, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Cuando realices compras o pagos, la app leerá en tiempo real las alertas que te envíe BBVA, Santander, Nu, BAC, Banco Industrial y otros. Clasifica en automático Débito y Crédito.',
                                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              if (Platform.isAndroid) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await BankNotificationListenerService.requestPermission();
                                      await Future.delayed(const Duration(seconds: 1));
                                      _loadData();
                                    },
                                    icon: Icon(_isAndroidPermissionGranted ? LucideIcons.checkCircle : LucideIcons.shieldCheck, size: 18),
                                    label: Text(_isAndroidPermissionGranted ? 'Permiso de Lectura Habilitado' : 'Habilitar Permiso Lector en Android', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isAndroidPermissionGranted ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text('ℹ️ Estás en un dispositivo iOS. La lectura directa en segundo plano se usa mediante Siri en la sección inferior.', style: TextStyle(color: Colors.grey[500], fontSize: 12.5, fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 16),
                              Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              const SizedBox(height: 10),
                              Text('🚀 Simuladores en vivo (Para Probar Ahora Mismo):', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _simulateCreditCardCharge,
                                      icon: const Icon(LucideIcons.creditCard, size: 15, color: Color(0xFF6366F1)),
                                      label: const Text('Simular Cargo TC (\$450)', style: TextStyle(color: Color(0xFF6366F1), fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        side: const BorderSide(color: Color(0xFF6366F1)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _simulateDebitCharge,
                                      icon: const Icon(LucideIcons.banknote, size: 15, color: Color(0xFF10B981)),
                                      label: const Text('Simular Débito (\$185)', style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        side: const BorderSide(color: Color(0xFF10B981)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- SECTION 2: SIRI & APPLE SHORTCUTS ---
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                                    child: const Icon(LucideIcons.mic, color: Color(0xFF3B82F6), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('iOS: Siri & Atajos por Voz', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Dile a tu iPhone, iPad o Apple Watch frases como "Oye Siri, registrar gasto en Finanzas" para agregar al instante compras con tu tarjeta o en efectivo con tu voz.',
                                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final res = await SiriShortcutsService.registerSiriShortcuts();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res ? '🍏 Atajos de Siri registrados y listos. Di "Oye Siri, Registrar Gasto en Finanzas".' : 'Atajo configurado para comandos rápidos.'),
                                          backgroundColor: const Color(0xFF3B82F6),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(LucideIcons.plusSquare, size: 18),
                                  label: const Text('Configurar Atajo Rápido en Siri', style: TextStyle(fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    VoiceExpenseModal.show(context);
                                  },
                                  icon: const Icon(LucideIcons.volume2, size: 17, color: Color(0xFF8B5CF6)),
                                  label: const Text('Abrir Asistente de Voz IA (Simulador Siri)', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w800)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
