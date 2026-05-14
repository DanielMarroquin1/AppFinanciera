import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String? currencyCode) {
    String symbol = '\$'; // Default to USD symbol or generic dollar
    String locale = 'en_US';
    
    if (currencyCode != null) {
      final codeUpper = currencyCode.toUpperCase();
      if (codeUpper.contains('EUR')) {
        symbol = '€';
        locale = 'es_ES';
      } else if (codeUpper.contains('GTQ')) {
        symbol = 'Q';
        locale = 'es_GT';
      } else if (codeUpper.contains('MXN')) {
        symbol = '\$';
        locale = 'es_MX';
      } else if (codeUpper.contains('GBP')) {
        symbol = '£';
        locale = 'en_GB';
      } else {
        symbol = '\$';
        locale = 'en_US';
      }
    }

    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(amount);
  }

  static String getSymbol(String? currencyCode) {
    if (currencyCode != null) {
      final codeUpper = currencyCode.toUpperCase();
      if (codeUpper.contains('EUR')) return '€';
      if (codeUpper.contains('GTQ')) return 'Q';
      if (codeUpper.contains('GBP')) return '£';
    }
    return '\$';
  }
}
