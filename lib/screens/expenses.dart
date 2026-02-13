import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

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
            'Mis Gastos 💸',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Febrero 2026',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Search and Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: isDark ? AppColors.gray500 : AppColors.gray400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar gastos...',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.gray500 : AppColors.gray400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF7E22CE) : AppColors.purple600, // purple-700 / purple-600
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Month Selector
          Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back, size: 20, color: isDark ? AppColors.gray500 : AppColors.gray400),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: isDark ? AppColors.purple400 : AppColors.purple600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Febrero 2026',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 20, color: isDark ? AppColors.gray500 : AppColors.gray400),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Total Expenses Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.red900, const Color(0xFF831843)] // red-900 to pink-900
                    : [AppColors.red600, const Color(0xFFDB2777)], // red-500 to pink-600
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                 BoxShadow(
                  color: (isDark ? AppColors.red900 : AppColors.red600).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total de Gastos',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$2,550.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.67,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  '67% de tu presupuesto mensual (\$3,800)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Expenses by Category
          Text(
            'Gastos por Categoría',
             style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildCategoryItem(context, '🍔 Comida', 450.50, 0.35, Colors.red),
              _buildCategoryItem(context, '🚗 Transporte', 280.00, 0.22, Colors.blue),
              _buildCategoryItem(context, '🏠 Hogar', 520.00, 0.40, Colors.purple),
              _buildCategoryItem(context, '🎮 Entretenimiento', 150.00, 0.12, Colors.pink),
              _buildCategoryItem(context, '💊 Salud', 95.00, 0.07, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          // Recent History (Reusing similar style to Dashboard transactions but simplified)
           Text(
            'Historial de Gastos',
             style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
           Column(
            children: [
              _buildExpenseHistoryItem(context, '🛒', 'Walmart', 'Hoy', 45.50),
              _buildExpenseHistoryItem(context, '🚕', 'Uber', 'Ayer', 12.00),
              _buildExpenseHistoryItem(context, '☕', 'Starbucks', 'Ayer', 8.50),
              _buildExpenseHistoryItem(context, '🍕', 'Pizza Hut', '2 Ene', 32.00),
              _buildExpenseHistoryItem(context, '⚡', 'Luz (CFE)', '1 Ene', 245.00),
              _buildExpenseHistoryItem(context, '🎬', 'Netflix', '1 Ene', 139.00),
            ],
           ),
           const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, double amount, double percentage, MaterialColor color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Tailwind shade 500 mapping approximation
    final barColor = color[500]!; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                 style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray600 : AppColors.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${(percentage * 100).toStringAsFixed(0)}% del total',
               style: TextStyle(
                color: isDark ? AppColors.gray500 : AppColors.gray500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseHistoryItem(BuildContext context, String icon, String name, String date, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
       margin: const EdgeInsets.only(bottom: 8),
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
              color: isDark ? AppColors.gray600 : AppColors.gray100, // approximated gray-700/gray-50
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
            '-\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDark ? AppColors.red400 : AppColors.red600,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
