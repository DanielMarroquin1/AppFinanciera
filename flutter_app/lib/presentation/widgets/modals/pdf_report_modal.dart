import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:printing/printing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../core/utils/localization.dart';
import 'dart:ui';

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

class _PDFReportModalState extends ConsumerState<PDFReportModal> with SingleTickerProviderStateMixin {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;
  String _reportType = 'general';

  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    
    final transactions = ref.read(transactionsProvider).value ?? [];
    final user = ref.read(authProvider).user;
    final loc = ref.read(localizationProvider);
    
    if (user == null) {
      setState(() => _isGenerating = false);
      return;
    }

    try {
      // Filter out fixed templates and by report type
      var filteredTxs = transactions.where((tx) => !tx.isFixed).toList();
      if (_reportType == 'income') {
        filteredTxs = filteredTxs.where((tx) => tx.type == 'income').toList();
      } else if (_reportType == 'expense') {
        filteredTxs = filteredTxs.where((tx) => tx.type == 'expense' || tx.type == 'cc_payment').toList();
      }

      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF1E293B).withOpacity(0.95), const Color(0xFF0F172A).withOpacity(0.95)]
                : [Colors.white.withOpacity(0.95), const Color(0xFFF8FAFC).withOpacity(0.95)],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : primaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Modern Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exportar Reporte',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crea un documento financiero PDF',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.fileText, color: primaryColor, size: 28),
                ),
              ],
            ),
            
            const SizedBox(height: 36),
            
            // Period Selection - Modern Chips Style
            Text(
              'Periodo del Reporte',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildModernDropdown<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i]))),
                    onChanged: (val) => setState(() => _selectedMonth = val!),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildModernDropdown<int>(
                    value: _selectedYear,
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                    onChanged: (val) => setState(() => _selectedYear = val!),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 36),
            
            // Report Type - Big Square Cards
            Text(
              '¿Qué quieres exportar?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCardSelector('general', 'General', LucideIcons.pieChart, isDark, primaryColor),
                const SizedBox(width: 12),
                _buildCardSelector('income', 'Ingresos', LucideIcons.trendingUp, isDark, const Color(0xFF10B981)),
                const SizedBox(width: 12),
                _buildCardSelector('expense', 'Gastos', LucideIcons.trendingDown, isDark, const Color(0xFFEF4444)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Glowing Action Button
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isGenerating ? 1.0 : _pulseAnimation.value,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generatePdf,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 10,
                  shadowColor: primaryColor.withOpacity(0.6),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.download, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Generar PDF',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(LucideIcons.chevronDown, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCardSelector(String value, String label, IconData icon, bool isDark, Color accentColor) {
    final isSelected = _reportType == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _reportType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : (isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? accentColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: accentColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ] : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
