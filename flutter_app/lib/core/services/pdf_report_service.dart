import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/transaction.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  
  // Helper to remove emojis and special characters that break the default PDF font
  static String _cleanText(String text) {
    var cleaned = text.replaceAll('€', 'EUR ')
                      .replaceAll('£', 'GBP ')
                      .replaceAll('¥', 'JPY ')
                      .replaceAll('₡', 'CRC ')
                      .replaceAll('Bs.', 'BOB ')
                      .replaceAll('S/', 'PEN ')
                      .replaceAll(r'R$', 'BRL ')
                      .replaceAll(r'CA$', 'CAD ')
                      .replaceAll(r'A$', 'AUD ');
    // Keeps ASCII and Latin1 Supplement (Spanish characters áéíóúñ etc)
    return cleaned.replaceAll(RegExp(r'[^\x00-\x7F\u00C0-\u017F]'), '').trim();
  }

  static pw.Text _safeText(String text, {pw.TextStyle? style, pw.TextAlign? textAlign}) {
    return pw.Text(_cleanText(text), style: style, textAlign: textAlign);
  }

  static Future<Uint8List> generateFinancialReport({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required String currencyCode,
    required String userName,
    required String reportType,
  }) async {
    final pdf = pw.Document();

    // Filtramos las transacciones por el rango de fechas
    final filteredTxs = transactions.where((tx) {
      return tx.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             tx.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Ordenamos de más reciente a más antigua
    filteredTxs.sort((a, b) => b.date.compareTo(a.date));

    // Calculamos totales
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> expensesByCategory = {};

    for (var tx in filteredTxs) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense' || tx.type == 'cc_payment') {
        totalExpense += tx.amount;
        final cat = _cleanText(tx.category);
        expensesByCategory[cat] = (expensesByCategory[cat] ?? 0) + tx.amount;
      }
    }

    final balance = totalIncome - totalExpense;
    final dateformat = DateFormat('dd MMM yyyy');

    // Modern Colors
    final primaryColor = PdfColor.fromHex('#1E3A8A'); // Dark Blue
    final accentColor = PdfColor.fromHex('#2563EB'); // Blue
    final greenColor = PdfColor.fromHex('#10B981'); // Emerald
    final redColor = PdfColor.fromHex('#EF4444'); // Red

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildModernHeader(userName, startDate, endDate, dateformat, primaryColor, accentColor, reportType),
        footer: (context) => _buildFooter(context, primaryColor),
        build: (pw.Context context) {
          List<pw.Widget> content = [];
          
          content.add(pw.SizedBox(height: 30));
          content.add(_buildModernSummaryCards(totalIncome, totalExpense, balance, currencyCode, greenColor, redColor, primaryColor));
          content.add(pw.SizedBox(height: 40));

          if (reportType == 'expense' || reportType == 'general') {
             if (totalExpense > 0) {
               content.add(_buildCategoryBreakdown(expensesByCategory, currencyCode, totalExpense, primaryColor, accentColor));
               content.add(pw.SizedBox(height: 40));
             }
          }

          content.add(_buildModernTransactionTable(filteredTxs, currencyCode, dateformat, primaryColor, greenColor, redColor));

          return content;
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildModernHeader(String userName, DateTime startDate, DateTime endDate, DateFormat format, PdfColor primary, PdfColor accent, String reportType) {
    String typeLabel = 'Financiero General';
    if (reportType == 'income') typeLabel = 'de Ingresos';
    if (reportType == 'expense') typeLabel = 'de Gastos';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _safeText('REPORTE $typeLabel'.toUpperCase(), style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: primary)),
              pw.SizedBox(height: 8),
              _safeText('Titular: ${_cleanText(userName)}', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey800, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _safeText('PERIODO', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _safeText('${format.format(startDate)} al ${format.format(endDate)}', style: pw.TextStyle(fontSize: 12, color: primary, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildModernSummaryCards(double income, double expense, double balance, String currencyCode, PdfColor green, PdfColor red, PdfColor primary) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildModernCard('INGRESOS TOTALES', income, green, currencyCode),
        _buildModernCard('GASTOS TOTALES', expense, red, currencyCode),
        _buildModernCard('BALANCE NETO', balance, balance >= 0 ? primary : red, currencyCode),
      ],
    );
  }

  static pw.Widget _buildModernCard(String title, double amount, PdfColor color, String currencyCode) {
    return pw.Container(
      width: 155,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _safeText(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _safeText(CurrencyFormatter.format(amount, currencyCode), style: pw.TextStyle(fontSize: 18, color: color, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryBreakdown(Map<String, double> expensesByCategory, String currencyCode, double totalExpense, PdfColor primary, PdfColor accent) {
    // Ordenar de mayor a menor gasto
    final sortedEntries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _safeText('DESGLOSE DE GASTOS POR CATEGORIA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 16),
          ...sortedEntries.map((entry) {
            final percentage = (entry.value / totalExpense) * 100;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: _safeText(entry.key, style: const pw.TextStyle(fontSize: 12)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      children: [
                        pw.Container(
                          height: 8,
                          width: (percentage * 2).clamp(0, 200).toDouble(), // 200 is max width approx
                          decoration: pw.BoxDecoration(
                            color: accent,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        _safeText('${percentage.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: _safeText(CurrencyFormatter.format(entry.value, currencyCode), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildModernTransactionTable(List<TransactionModel> txs, String currencyCode, DateFormat format, PdfColor primary, PdfColor green, PdfColor red) {
    if (txs.isEmpty) {
      return pw.Center(child: _safeText('No hay movimientos registrados en este periodo.', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)));
    }

    final tableHeaders = ['FECHA', 'DESCRIPCION', 'CATEGORIA', 'TIPO', 'MONTO'];

    final tableData = txs.map((tx) {
      final isIncome = tx.type == 'income';
      final formattedAmount = CurrencyFormatter.format(tx.amount, currencyCode);
      return [
        format.format(tx.date),
        _cleanText(tx.description.isEmpty ? 'Sin descripcion' : tx.description),
        _cleanText(tx.category),
        isIncome ? 'Ingreso' : 'Gasto',
        isIncome ? '+$formattedAmount' : '-$formattedAmount',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _safeText('HISTORIAL DE MOVIMIENTOS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primary)),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: tableHeaders,
          data: tableData,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: primary),
          cellHeight: 30,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.center,
            4: pw.Alignment.centerRight,
          },
          cellStyle: const pw.TextStyle(fontSize: 10),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor primary) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _safeText('Generado por App Financiera', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
          _safeText('Pagina ${context.pageNumber} de ${context.pagesCount}', style: pw.TextStyle(fontSize: 10, color: primary, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
