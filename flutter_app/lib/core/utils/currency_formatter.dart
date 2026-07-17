import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String? currencyCode) {
    String symbol = '\$';
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
      } else if (codeUpper.contains('CAD')) {
        symbol = 'CA\$';
        locale = 'en_CA';
      } else if (codeUpper.contains('BRL')) {
        symbol = 'R\$';
        locale = 'pt_BR';
      } else if (codeUpper.contains('CHF')) {
        symbol = 'CHF';
        locale = 'de_CH';
      } else if (codeUpper.contains('JPY')) {
        symbol = '¥';
        locale = 'ja_JP';
      } else if (codeUpper.contains('CNY')) {
        symbol = '¥';
        locale = 'zh_CN';
      } else if (codeUpper.contains('AUD')) {
        symbol = 'A\$';
        locale = 'en_AU';
      } else if (codeUpper.contains('BOB')) {
        symbol = 'Bs.';
        locale = 'es_BO';
      } else if (codeUpper.contains('UYU')) {
        symbol = '\$U';
        locale = 'es_UY';
      } else if (codeUpper.contains('PAB')) {
        symbol = 'B/.';
        locale = 'es_PA';
      } else if (codeUpper.contains('CRC')) {
        symbol = '₡';
        locale = 'es_CR';
      } else if (codeUpper.contains('DOP')) {
        symbol = 'RD\$';
        locale = 'es_DO';
      } else {
        symbol = '\$';
        locale = 'en_US';
      }
    }

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      customPattern: '#,##0.00',
    );
    
    return '$symbol ${formatter.format(amount).trim()}';
  }

  static String getSymbol(String? currencyCode) {
    if (currencyCode != null) {
      final codeUpper = currencyCode.toUpperCase();
      if (codeUpper.contains('EUR')) return '€';
      if (codeUpper.contains('GTQ')) return 'Q';
      if (codeUpper.contains('GBP')) return '£';
      if (codeUpper.contains('PEN')) return 'S/';
      if (codeUpper.contains('CAD')) return 'CA\$';
      if (codeUpper.contains('BRL')) return 'R\$';
      if (codeUpper.contains('CHF')) return 'CHF';
      if (codeUpper.contains('JPY')) return '¥';
      if (codeUpper.contains('CNY')) return '¥';
      if (codeUpper.contains('AUD')) return 'A\$';
      if (codeUpper.contains('BOB')) return 'Bs.';
      if (codeUpper.contains('UYU')) return '\$U';
      if (codeUpper.contains('PAB')) return 'B/.';
      if (codeUpper.contains('CRC')) return '₡';
      if (codeUpper.contains('DOP')) return 'RD\$';
      if (codeUpper.contains('MXN') || codeUpper.contains('ARS') || codeUpper.contains('COP') || codeUpper.contains('CLP') || codeUpper.contains('USD')) return '\$';
    }
    return '\$';
  }
}

