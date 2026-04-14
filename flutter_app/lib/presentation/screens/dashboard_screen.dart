import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/rewards_shop_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by AppShell
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, María! 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¡Increíble! Estás en racha 🔥',
                      style: TextStyle(
                        color: isDark ? Colors.orange[400] : Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Aquí está tu resumen financiero',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Streak Badge & Rewards
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isDark 
                            ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF7F1D1D)]) 
                            : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)]),
                        border: Border.all(
                          color: isDark ? const Color(0xFFC2410C) : const Color(0xFFFDBA74),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.flame, 
                            color: isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => RewardsShopModal.show(context, points: 150),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.amber[900]?.withValues(alpha: 0.3) : Colors.amber[100],
                          border: Border.all(
                            color: Colors.amber,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          LucideIcons.shoppingBag,
                          color: isDark ? Colors.amber[400] : Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF312E81), const Color(0xFF065F46)] // indigo-900 to emerald-800
                      : [const Color(0xFF4338CA), const Color(0xFF059669)], // indigo-700 to emerald-600
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Balance Total', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('\$12,450.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ingresos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                              const SizedBox(height: 4),
                              const Text('\$15,000', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gastos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                              const SizedBox(height: 4),
                              const Text('\$2,550', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alert Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFFFBEB),
                border: Border.all(
                  color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '¡Cuidado! ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'Estás cerca del límite de tu presupuesto mensual.'),
                        ],
                      ),
                      style: TextStyle(color: Color(0xFF92400E)), // Matches amber-900
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions inline
            Text('Acciones Rápidas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                      border: Border.all(color: isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(LucideIcons.trendingUp, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
                        const SizedBox(height: 8),
                        Text('Ingreso', style: TextStyle(color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF14532D), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
                      border: Border.all(color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(LucideIcons.trendingDown, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                        const SizedBox(height: 8),
                        Text('Gasto', style: TextStyle(color: isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Investment Assistant
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF15803D), const Color(0xFF047857)] // green-700 to emerald-700
                      : [const Color(0xFF16A34A), const Color(0xFF059669)], // green-600 to emerald-600
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B), // amber-500
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.crown, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Asistente de Inversión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('Descubre cómo invertir tu dinero basado en tu negocio 💰', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions (simulated)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transacciones Recientes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () {},
                  child: Text('Ver todas', style: TextStyle(color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5), fontSize: 12)),
                )
              ],
            ),
            _buildTransactionItem(
              isDark,
              icon: '🛒',
              bgColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
              title: 'Supermercado',
              subtitle: 'Hoy, 10:30 AM',
              amount: '-\$45.50',
              amountColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              isDark,
              icon: '🚕',
              bgColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF), // blue colors
              title: 'Uber',
              subtitle: 'Ayer, 6:15 PM',
              amount: '-\$12.00',
              amountColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              isDark,
              icon: '💼',
              bgColor: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
              title: 'Salario',
              subtitle: '15 Ene, 2026',
              amount: '+\$3,500.00',
              amountColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
            ),
            const SizedBox(height: 80), // for bottom nav padding
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(bool isDark, {required String icon, required Color bgColor, required String title, required String subtitle, required String amount, required Color amountColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
