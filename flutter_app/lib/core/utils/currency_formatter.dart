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
      } else if (codeUpper.contains('PEN')) {
        symbol = 'S/';
        locale = 'es_PE';
      } else if (codeUpper.contains('ARS')) {
        symbol = '\$';
        locale = 'es_AR';
      } else if (codeUpper.contains('COP')) {
        symbol = '\$';
        locale = 'es_CO';
      } else if (codeUpper.contains('CLP')) {
        symbol = '\$';
        locale = 'es_CL';
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
      if (codeUpper.contains('PEN')) return 'S/';
    }
    return '\$';
  }
}
