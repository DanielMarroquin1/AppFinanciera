import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:printing/printing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../core/utils/localization.dart';

class PDFReportModal extends ConsumerStatefulWidget {
  const PDFReportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PDFReportModal(),
    );
  }

  @override
  ConsumerState<PDFReportModal> createState() => _PDFReportModalState();
}

class _PDFReportModalState extends ConsumerState<PDFReportModal> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;
  String _reportType = 'general';
  String? _errorMessage;

  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    
    final transactions = ref.read(transactionsProvider).value ?? [];
    final user = ref.read(authProvider).user;
    final loc = ref.read(localizationProvider);
    
    if (user == null) {
      setState(() => _isGenerating = false);
      return;
    }

    try {
      var filteredTxs = transactions.where((tx) => !tx.isFixed).toList();
      if (_reportType == 'income') {
        filteredTxs = filteredTxs.where((tx) => tx.type == 'income').toList();
      } else if (_reportType == 'expense') {
        filteredTxs = filteredTxs.where((tx) => tx.type == 'expense' || tx.type == 'cc_payment').toList();
      }

      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);

      final hasRecords = filteredTxs.any((tx) => 
        tx.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
        tx.date.isBefore(endDate.add(const Duration(days: 1)))
      );

      if (!hasRecords) {
        setState(() {
          _errorMessage = 'No hay registros en el mes de ${_months[_selectedMonth - 1]} del $_selectedYear.';
          _isGenerating = false;
        });
        return;
      }

      final pdfBytes = await PdfReportService.generateFinancialReport(
        transactions: filteredTxs,
        startDate: startDate,
        endDate: endDate,
        currencyCode: user.currency ?? 'USD',
        userName: user.name,
        reportType: _reportType,
        loc: loc,
      );

      if (mounted) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Reporte_${_reportType}_${_months[_selectedMonth - 1]}_$_selectedYear.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error al generar PDF: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showSelectorModal<T>({
    required String title,
    required T currentValue,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    final item = values[index];
                    final isSelected = item == currentValue;
                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: isSelected 
                            ? (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF6366F1).withValues(alpha: 0.1))
                            : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              labelBuilder(item),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFF6366F1)
                                    : (isDark ? Colors.grey[300] : Colors.grey[800]),
                              ),
                            ),
                            if (isSelected)
                              const Icon(LucideIcons.checkCircle2, color: Color(0xFF6366F1), size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);
    
    // Softer colors for a friendly, non-tech look
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Friendly Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.fileOutput, color: Color(0xFF6366F1), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descargar Reporte',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Guarda tus movimientos en PDF',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Period Selection
          Text(
            'Elige el periodo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSelectorButton(
                  label: _months[_selectedMonth - 1],
                  icon: LucideIcons.calendarDays,
                  isDark: isDark,
                  cardColor: cardColor,
                  onTap: () {
                    _showSelectorModal<int>(
                      title: 'Seleccionar Mes',
                      currentValue: _selectedMonth,
                      values: List.generate(12, (i) => i + 1),
                      labelBuilder: (val) => _months[val - 1],
                      onSelected: (val) => setState(() => _selectedMonth = val),
                      isDark: isDark,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildSelectorButton(
                  label: _selectedYear.toString(),
                  icon: LucideIcons.calendar,
                  isDark: isDark,
                  cardColor: cardColor,
                  onTap: () {
                    _showSelectorModal<int>(
                      title: 'Seleccionar Año',
                      currentValue: _selectedYear,
                      values: years,
                      labelBuilder: (val) => val.toString(),
                      onSelected: (val) => setState(() => _selectedYear = val),
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Report Type
          Text(
            '¿Qué datos incluimos?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFriendlyCard(
                value: 'general',
                label: 'Balance General',
                icon: LucideIcons.wallet,
                baseColor: const Color(0xFF6366F1), // Indigo
                isDark: isDark,
                cardColor: cardColor,
              ),
              const SizedBox(width: 12),
              _buildFriendlyCard(
                value: 'income',
                label: 'Ingresos',
                icon: LucideIcons.arrowDownToLine,
                baseColor: const Color(0xFF10B981), // Emerald
                isDark: isDark,
                cardColor: cardColor,
              ),
              const SizedBox(width: 12),
              _buildFriendlyCard(
                value: 'expense',
                label: 'Gastos',
                icon: LucideIcons.arrowUpFromLine,
                baseColor: const Color(0xFFF43F5E), // Rose
                isDark: isDark,
                cardColor: cardColor,
              ),
            ],
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 40),
          ],
          
          // Friendly Action Button
          ElevatedButton(
            onPressed: _isGenerating ? null : _generatePdf,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
            ),
            child: _isGenerating
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.arrowDownCircle, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Generar Archivo',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(LucideIcons.chevronDown, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendlyCard({
    required String value,
    required String label,
    required IconData icon,
    required Color baseColor,
    required bool isDark,
    required Color cardColor,
  }) {
    final isSelected = _reportType == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _reportType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? baseColor : cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected 
              ? [BoxShadow(color: baseColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))] 
              : (isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : baseColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : baseColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
