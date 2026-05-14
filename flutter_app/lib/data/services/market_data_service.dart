import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/chat_message.dart';

class MarketDataService {
  /// Busca datos financieros en tiempo real simulando una búsqueda web.
  /// Para producción, esto se conectaría a Yahoo Finance API, Alpha Vantage, etc.
  static Future<String> fetchRealTimeData(String query, List<ChatMessage> history) async {
    final lowercaseQuery = query.toLowerCase();
    
    // Unir el historial reciente (últimos 3 mensajes) al query para inferir contexto
    final recentHistory = history.length > 3 ? history.sublist(history.length - 3) : history;
    final contextText = recentHistory.map((m) => m.text.toLowerCase()).join(" ");
    final combinedContext = "\$contextText \$lowercaseQuery";


    // Ejemplo 1: Datos Reales (API de Tasas de Cambio)
    if (lowercaseQuery.contains('dólar') || lowercaseQuery.contains('euro') || lowercaseQuery.contains('cambio')) {
      try {
        final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?from=USD&to=EUR'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rate = data['rates']['EUR'];
          final date = data['date'];
          return "Datos en vivo ($date): 1 USD equivale a $rate EUR.";
        }
      } catch (_) {
        // Ignorar error y caer en el default
      }
    }

    // Mapeo extendido de empresas a Tickers bursátiles
    String? ticker;
    if (combinedContext.contains('apple') || combinedContext.contains('aapl')) ticker = 'AAPL';
    else if (combinedContext.contains('tesla') || combinedContext.contains('tsla')) ticker = 'TSLA';
    else if (combinedContext.contains('amazon') || combinedContext.contains('amzn')) ticker = 'AMZN';
    else if (combinedContext.contains('google') || combinedContext.contains('goog') || combinedContext.contains('alphabet')) ticker = 'GOOGL';
    else if (combinedContext.contains('microsoft') || combinedContext.contains('msft')) ticker = 'MSFT';
    else if (combinedContext.contains('facebook') || combinedContext.contains('meta')) ticker = 'META';
    else if (combinedContext.contains('nintendo') || combinedContext.contains('ntdoy')) ticker = 'NTDOY';
    else if (combinedContext.contains('sony')) ticker = 'SONY';
    else if (combinedContext.contains('samsung')) ticker = 'SSNLF';
    else if (combinedContext.contains('netflix') || combinedContext.contains('nflx')) ticker = 'NFLX';
    else if (combinedContext.contains('nvidia') || combinedContext.contains('nvda')) ticker = 'NVDA';
    else if (combinedContext.contains('intel') || combinedContext.contains('intc')) ticker = 'INTC';
    else if (combinedContext.contains('amd')) ticker = 'AMD';
    
    // Si hay menciones a mercado/bolsa pero no hay un ticker específico, usamos SPY (S&P 500) como indicador general del mercado
    if (ticker == null && (lowercaseQuery.contains('bolsa') || lowercaseQuery.contains('mercado') || lowercaseQuery.contains('general'))) {
      ticker = 'SPY';
    }

    if (ticker != null) {
      try {
        final apiKey = 'LfypcStlQ2AKOxUeKtl7wCpqbuhrJXt3'; // Massive API Key
        final url = 'https://api.polygon.io/v2/aggs/ticker/$ticker/prev?adjusted=true&apiKey=$apiKey';
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final result = data['results'][0];
            final closePrice = result['c']; // Cierre previo
            final volume = result['v']; // Volumen
            
            if (ticker == 'SPY') {
               return "Resumen General del Mercado (S&P 500 - SPY): El mercado cotiza a un precio de cierre de \$$closePrice USD. Volumen operado: $volume.";
            }
            
            return "La acción de $ticker cotiza a un precio de cierre de \$$closePrice USD. Volumen operado: $volume.";
          }
        }
        return "No se encontraron datos actualizados para $ticker. Status: ${response.statusCode}";
      } catch (e) {
        return "Error de conexión con el mercado: $e";
      }
    }

    // Si no encuentra nada específico, devuelve vacío
    return "";
  }

  /// Función "Router" ligera que decide si necesitamos buscar en internet.
  static bool requiresInternetSearch(String prompt, List<ChatMessage> history) {
    final p = prompt.toLowerCase();
    
    // Unir el historial reciente (últimos 3 mensajes) al prompt para inferir contexto
    final recentHistory = history.length > 3 ? history.sublist(history.length - 3) : history;
    final contextText = recentHistory.map((m) => m.text.toLowerCase()).join(" ");
    final combinedContext = "\$contextText \$p";
    
    // Evaluar primero si hay menciones explícitas a mercado o empresas en el prompt actual o en el contexto reciente
    bool hasCompany = combinedContext.contains('apple') ||
           combinedContext.contains('tesla') ||
           combinedContext.contains('amazon') ||
           combinedContext.contains('google') ||
           combinedContext.contains('microsoft') ||
           combinedContext.contains('facebook') ||
           combinedContext.contains('meta') ||
           combinedContext.contains('nintendo') ||
           combinedContext.contains('sony') ||
           combinedContext.contains('samsung') ||
           combinedContext.contains('netflix') ||
           combinedContext.contains('nvidia') ||
           combinedContext.contains('intel') ||
           combinedContext.contains('amd');
           
    bool hasMarketTerms = combinedContext.contains('precio') || 
           combinedContext.contains('mercado') || 
           combinedContext.contains('acciones') || 
           combinedContext.contains('hoy') || 
           combinedContext.contains('cotiza') ||
           combinedContext.contains('bolsa') ||
           combinedContext.contains('invertir');
           
    // Si menciona una empresa Y hay contexto de mercado, debe buscar
    return hasCompany || hasMarketTerms;
  }
}
