import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '¡Hola, María! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí está tu resumen financiero',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.cardGradientDark
                  : AppGradients.cardGradientLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.blue900 : AppColors.blue600)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$12,450.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$15,000',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Gastos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$2,550',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Alert Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.amber900.withOpacity(0.3)
                  : AppColors.amber50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.amber800 : AppColors.amber200,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: isDark ? AppColors.amber400 : AppColors.amber600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color:
                            isDark ? AppColors.amber200 : AppColors.amber900,
                        fontSize: 14,
                        fontFamily: 'Roboto', // Default flutter font
                      ),
                      children: const [
                        TextSpan(
                          text: '¡Cuidado! ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Estás cerca del límite de tu presupuesto mensual.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(
                context,
                icon: Icons.trending_up,
                label: 'Ingreso',
                color: AppColors.green600,
                bgColor: AppColors.green50,
                darkBgColor: AppColors.green900,
                borderColor: AppColors.green200,
                darkBorderColor: AppColors.green800,
                textColor: AppColors.green900,
                darkTextColor: AppColors.green200,
                iconColor: AppColors.green600,
                darkIconColor: AppColors.green400,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                icon: Icons.trending_down,
                label: 'Gasto',
                color: AppColors.red600,
                bgColor: AppColors.red50,
                darkBgColor: AppColors.red900,
                borderColor: AppColors.red200,
                darkBorderColor: AppColors.red800,
                textColor: AppColors.red900,
                darkTextColor: AppColors.red200,
                iconColor: AppColors.red600,
                darkIconColor: AppColors.red400,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Transferir',
                color: AppColors.blue600,
                bgColor: AppColors.blue50,
                darkBgColor: AppColors.blue900,
                borderColor: AppColors.blue200,
                darkBorderColor: AppColors.blue800,
                textColor: AppColors.blue900,
                darkTextColor: AppColors.blue200,
                iconColor: AppColors.blue600,
                darkIconColor: AppColors.blue400,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transacciones Recientes',
                style: TextStyle(
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.purple600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            context,
            icon: '🛒',
            title: 'Supermercado',
            date: 'Hoy, 10:30 AM',
            amount: '-\$45.50',
            bgIconColor: AppColors.red50,
            darkBgIconColor: AppColors.red900,
            amountColor: AppColors.red600,
            darkAmountColor: AppColors.red400,
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            context,
            icon: '🚕',
            title: 'Uber',
            date: 'Ayer, 6:15 PM',
            amount: '-\$12.00',
            bgIconColor: AppColors.blue50,
            darkBgIconColor: AppColors.blue900,
            amountColor: AppColors.red600,
            darkAmountColor: AppColors.red400,
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            context,
            icon: '💼',
            title: 'Salario',
            date: '15 Ene, 2026',
            amount: '+\$3,500.00',
            bgIconColor: AppColors.green50,
            darkBgIconColor: AppColors.green900,
            amountColor: AppColors.green600,
            darkAmountColor: AppColors.green400,
          ),

          const SizedBox(height: 24),

          // Achievements
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.achievementGradientDark
                  : AppGradients.achievementGradientLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                     Icon(Icons.card_giftcard, color: Colors.white),
                     SizedBox(width: 12),
                     Text(
                      '¡Logro Desbloqueado!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Has ahorrado por 7 días consecutivos. ¡Sigue así! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5, // Approx 75% relative to card width
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '75% para el próximo nivel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
           const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color darkBgColor,
    required Color borderColor,
    required Color darkBorderColor,
    required Color textColor,
    required Color darkTextColor,
    required Color iconColor,
    required Color darkIconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? darkBgColor.withOpacity(0.3) : bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? darkBorderColor : borderColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDark ? darkIconColor : iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? darkTextColor : textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String date,
    required String amount,
    required Color bgIconColor,
    required Color darkBgIconColor,
    required Color amountColor,
    required Color darkAmountColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.gray600.withOpacity(0.5) : AppColors.gray100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? darkBgIconColor.withOpacity(0.3) : bgIconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black, // Explicitly set black for light mode
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isDark ? darkAmountColor : amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
