import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class MarketDataService {
  // API Key se pasa por variable de entorno al compilar:
  // flutter run --dart-define=MASSIVE_API_KEY=tu_clave_aqui
  static const String _envApiKey = String.fromEnvironment('MASSIVE_API_KEY');
  static final RegExp _validTickerRegex = RegExp(r'^[A-Z0-9.\-]{1,10}$');
  static String get _apiKey => _envApiKey.trim().isEmpty
      ? 'TWKMI7RFpjlcuPpUM1nOplhKrByQ0swf'
      : _envApiKey.trim();

  /// Busca datos financieros en tiempo real consultando la API de Massive (antes Polygon)
  static Future<Map<String, dynamic>> getStockData(String ticker) async {
    final uppercaseTicker = ticker.toUpperCase().trim();

    if (!_validTickerRegex.hasMatch(uppercaseTicker)) {
      return {
        'status': 'error',
        'message':
            'El código bursátil proporcionado no tiene un formato válido.',
      };
    }

    try {
      // Construir URI segura sin interpolación directa de ruta
      final baseUri = Uri.https(
        'api.massive.com',
        '/v2/aggs/ticker/$uppercaseTicker/prev',
        {'adjusted': 'true', 'apiKey': _apiKey},
      );

      // En Flutter Web, el navegador bloquea llamadas directas a APIs externas
      // por política CORS. Usamos un proxy CORS para evitar esto.
      final uri = kIsWeb
          ? Uri.parse(
              'https://corsproxy.io/?${Uri.encodeComponent(baseUri.toString())}',
            )
          : baseUri;

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return {
            'status': 'success',
            'ticker': uppercaseTicker,
            'close_price': result['c'],
            'open_price': result['o'],
            'high': result['h'],
            'low': result['l'],
            'volume': result['v'],
            'volume_weighted_avg_price': result['vw'],
            'number_of_trades': result['n'],
          };
        } else {
          return {
            'status': 'error',
            'message':
                'No se encontraron datos recientes para el ticker $uppercaseTicker. Puede que no sea un ticker válido.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message':
              'Error HTTP ${response.statusCode} al consultar datos de $uppercaseTicker.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión al obtener datos de $uppercaseTicker: $e',
      };
    }
  }
}
