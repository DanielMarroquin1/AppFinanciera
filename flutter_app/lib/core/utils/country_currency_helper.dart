import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'localization.dart';

/// Catálogo y selectores estandarizados de País y Moneda para toda la aplicación QUIVO.
class CountryCurrencyHelper {
  CountryCurrencyHelper._();

  static const Map<String, List<Map<String, String>>> regions = {
    'Norte': [
      {
        'code': 'US',
        'name': 'Estados Unidos',
        'flag': '🇺🇸',
        'currencyName': 'Dólares (USD)',
        'currencyCode': 'USD',
        'currencySymbol': '\$',
      },
      {
        'code': 'MX',
        'name': 'México',
        'flag': '🇲🇽',
        'currencyName': 'Pesos Mexicanos (MXN)',
        'currencyCode': 'MXN',
        'currencySymbol': '\$',
      },
    ],
    'Centro': [
      {
        'code': 'GT',
        'name': 'Guatemala',
        'flag': '🇬🇹',
        'currencyName': 'Quetzales (GTQ)',
        'currencyCode': 'GTQ',
        'currencySymbol': 'Q',
      },
      {
        'code': 'CR',
        'name': 'Costa Rica',
        'flag': '🇨🇷',
        'currencyName': 'Colones (CRC)',
        'currencyCode': 'CRC',
        'currencySymbol': '₡',
      },
      {
        'code': 'SV',
        'name': 'El Salvador',
        'flag': '🇸🇻',
        'currencyName': 'Dólares (USD)',
        'currencyCode': 'USD',
        'currencySymbol': '\$',
      },
      {
        'code': 'HN',
        'name': 'Honduras',
        'flag': '🇭🇳',
        'currencyName': 'Lempiras (HNL)',
        'currencyCode': 'HNL',
        'currencySymbol': 'L',
      },
      {
        'code': 'NI',
        'name': 'Nicaragua',
        'flag': '🇳🇮',
        'currencyName': 'Córdobas (NIO)',
        'currencyCode': 'NIO',
        'currencySymbol': 'C\$',
      },
      {
        'code': 'PA',
        'name': 'Panamá',
        'flag': '🇵🇦',
        'currencyName': 'Balboas/Dólares (PAB/USD)',
        'currencyCode': 'USD',
        'currencySymbol': 'B/.',
      },
      {
        'code': 'BZ',
        'name': 'Belice',
        'flag': '🇧🇿',
        'currencyName': 'Dólares Beliceños (BZD)',
        'currencyCode': 'BZD',
        'currencySymbol': '\$',
      },
    ],
    'Sur': [
      {
        'code': 'CO',
        'name': 'Colombia',
        'flag': '🇨🇴',
        'currencyName': 'Pesos Colombianos (COP)',
        'currencyCode': 'COP',
        'currencySymbol': '\$',
      },
      {
        'code': 'CL',
        'name': 'Chile',
        'flag': '🇨🇱',
        'currencyName': 'Pesos Chilenos (CLP)',
        'currencyCode': 'CLP',
        'currencySymbol': '\$',
      },
      {
        'code': 'PE',
        'name': 'Perú',
        'flag': '🇵🇪',
        'currencyName': 'Soles (PEN)',
        'currencyCode': 'PEN',
        'currencySymbol': 'S/',
      },
      {
        'code': 'AR',
        'name': 'Argentina',
        'flag': '🇦🇷',
        'currencyName': 'Pesos Argentinos (ARS)',
        'currencyCode': 'ARS',
        'currencySymbol': '\$',
      },
    ],
    'Europa': [
      {
        'code': 'ES',
        'name': 'España',
        'flag': '🇪🇸',
        'currencyName': 'Euros (EUR)',
        'currencyCode': 'EUR',
        'currencySymbol': '€',
      },
      {
        'code': 'GB',
        'name': 'Reino Unido',
        'flag': '🇬🇧',
        'currencyName': 'Libras (GBP)',
        'currencyCode': 'GBP',
        'currencySymbol': '£',
      },
    ],
  };

  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'name': 'Dólares (USD)', 'flag': '🇺🇸', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euros (EUR)', 'flag': '🇪🇺', 'symbol': '€'},
    {'code': 'GTQ', 'name': 'Quetzales (GTQ)', 'flag': '🇬🇹', 'symbol': 'Q'},
    {'code': 'CRC', 'name': 'Colones (CRC)', 'flag': '🇨🇷', 'symbol': '₡'},
    {'code': 'HNL', 'name': 'Lempiras (HNL)', 'flag': '🇭🇳', 'symbol': 'L'},
    {'code': 'NIO', 'name': 'Córdobas (NIO)', 'flag': '🇳🇮', 'symbol': 'C\$'},
    {'code': 'PAB', 'name': 'Balboas (PAB)', 'flag': '🇵🇦', 'symbol': 'B/.'},
    {'code': 'BZD', 'name': 'Dólares Beliceños (BZD)', 'flag': '🇧🇿', 'symbol': '\$'},
    {'code': 'MXN', 'name': 'Pesos Mexicanos (MXN)', 'flag': '🇲🇽', 'symbol': '\$'},
    {'code': 'GBP', 'name': 'Libras (GBP)', 'flag': '🇬🇧', 'symbol': '£'},
    {'code': 'ARS', 'name': 'Pesos Argentinos (ARS)', 'flag': '🇦🇷', 'symbol': '\$'},
    {'code': 'COP', 'name': 'Pesos Colombianos (COP)', 'flag': '🇨🇴', 'symbol': '\$'},
    {'code': 'CLP', 'name': 'Pesos Chilenos (CLP)', 'flag': '🇨🇱', 'symbol': '\$'},
    {'code': 'PEN', 'name': 'Soles (PEN)', 'flag': '🇵🇪', 'symbol': 'S/'},
  ];

  /// Busca la información completa de un país por nombre o código
  static Map<String, String>? findCountry(String? countryNameOrCode) {
    if (countryNameOrCode == null || countryNameOrCode.isEmpty) return null;
    final query = countryNameOrCode.trim().toLowerCase();
    for (final list in regions.values) {
      for (final item in list) {
        if (item['name']?.toLowerCase() == query ||
            item['code']?.toLowerCase() == query) {
          return item;
        }
      }
    }
    return null;
  }

  /// Busca la información completa de una moneda por código o nombre
  static Map<String, String>? findCurrency(String? currencyStr) {
    if (currencyStr == null || currencyStr.isEmpty) return null;
    final query = currencyStr.trim().toLowerCase();
    for (final item in currencies) {
      if (item['code']?.toLowerCase() == query ||
          item['name']?.toLowerCase() == query ||
          (query.contains(item['code']!.toLowerCase())) ||
          (item['name']!.toLowerCase().contains(query))) {
        return item;
      }
    }
    return null;
  }

  /// Muestra el modal estandarizado de selección de país organizado por regiones
  static void showCountryModal({
    required BuildContext context,
    required bool isDark,
    required String currentCountry,
    required AppLocalizations loc,
    required void Function(Map<String, String> country) onCountrySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DefaultTabController(
        length: regions.keys.length,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text('🌎', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.get('select_country'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.get('select_country_desc'),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TabBar(
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorColor: const Color(0xFF10B981),
                indicatorWeight: 3,
                labelColor: const Color(0xFF10B981),
                unselectedLabelColor:
                    isDark ? Colors.grey[500] : Colors.grey[400],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: regions.keys
                    .map((r) => Tab(text: r.toUpperCase()))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: regions.keys.map((regionName) {
                    final countries = regions[regionName]!;
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        final isSelected =
                            currentCountry == country['name'] ||
                            currentCountry == country['code'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            onCountrySelected(country);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF10B981)
                                                  .withValues(alpha: 0.2),
                                              const Color(0xFF059669)
                                                  .withValues(alpha: 0.1),
                                            ]
                                          : [
                                              const Color(0xFFD1FAE5),
                                              const Color(0xFFA7F3D0),
                                            ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.25),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(
                                            alpha: isDark ? 0.1 : 0.5,
                                          )
                                        : (isDark
                                              ? Colors.black.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.grey[100]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      country['flag']!,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        country['name']!,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : (isSelected
                                                    ? const Color(0xFF064E3B)
                                                    : Colors.black),
                                          fontSize: 17,
                                          fontWeight: isSelected
                                              ? FontWeight.w900
                                              : FontWeight.w600,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        country['currencyName']!,
                                        style: TextStyle(
                                          color: isDark
                                              ? (isSelected
                                                    ? const Color(0xFF6EE7B7)
                                                    : Colors.grey[400])
                                              : (isSelected
                                                    ? const Color(0xFF059669)
                                                    : Colors.grey[500]),
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF10B981),
                                          Color(0xFF059669),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra el modal estandarizado de selección de moneda
  static void showCurrencyModal({
    required BuildContext context,
    required bool isDark,
    required String currentCurrency,
    required AppLocalizations loc,
    required void Function(Map<String, String> currency) onCurrencySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text('💰', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.get('select_currency'),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.get('select_currency_desc'),
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected =
                      currentCurrency == currency['code'] ||
                      currentCurrency == currency['name'] ||
                      currentCurrency.contains(currency['name']!) ||
                      currentCurrency.contains(currency['code']!);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      onCurrencySelected(currency);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.2),
                                        const Color(0xFFD97706)
                                            .withValues(alpha: 0.1),
                                      ]
                                    : [
                                        const Color(0xFFFEF3C7),
                                        const Color(0xFFFDE68A),
                                      ],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0)),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(
                                      alpha: isDark ? 0.1 : 0.5,
                                    )
                                  : (isDark
                                        ? Colors.black.withValues(alpha: 0.2)
                                        : Colors.grey[100]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                currency['flag']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency['code']!,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : (isSelected
                                              ? const Color(0xFF78350F)
                                              : Colors.black),
                                    fontSize: 17,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currency['name']!,
                                  style: TextStyle(
                                    color: isDark
                                        ? (isSelected
                                              ? const Color(0xFFFDE68A)
                                              : Colors.grey[400])
                                        : (isSelected
                                              ? const Color(0xFFB45309)
                                              : Colors.grey[500]),
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              currency['symbol']!,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700]),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
