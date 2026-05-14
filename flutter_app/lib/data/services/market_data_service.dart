import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class MarketDataService {
  static const String _apiKey = 'LfypcStlQ2AKOxUeKtl7wCpqbuhrJXt3';

  /// Busca datos financieros en tiempo real consultando la API de Massive (antes Polygon)
  static Future<Map<String, dynamic>> getStockData(String ticker) async {
    final uppercaseTicker = ticker.toUpperCase().trim();
    
    try {
      // La URL base del API de Massive
      final baseUrl = 'https://api.massive.com/v2/aggs/ticker/$uppercaseTicker/prev?adjusted=true&apiKey=$_apiKey';
      
      // En Flutter Web, el navegador bloquea llamadas directas a APIs externas
      // por política CORS. Usamos un proxy CORS para evitar esto.
      final url = kIsWeb
          ? 'https://corsproxy.io/?${Uri.encodeComponent(baseUrl)}'
          : baseUrl;

      print('[MarketDataService] Fetching data for $uppercaseTicker...');
      print('[MarketDataService] URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('[MarketDataService] Status: ${response.statusCode}');
      print('[MarketDataService] Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
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
            'message': 'No se encontraron datos recientes para el ticker $uppercaseTicker. Puede que no sea un ticker válido.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Error HTTP ${response.statusCode} al consultar datos de $uppercaseTicker.',
        };
      }
    } catch (e) {
      print('[MarketDataService] Exception: $e');
      return {
        'status': 'error',
        'message': 'Error de conexión al obtener datos de $uppercaseTicker: $e',
      };
    }
  }
}

