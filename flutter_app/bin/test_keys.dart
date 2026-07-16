import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final key = const String.fromEnvironment('GEMINI_API_KEY');

  // Test with gemini-3.5-flash
  print('Testing gemini-3.5-flash...');
  try {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': key,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say hello in one word'}
            ]
          }
        ]
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n-----------------------------------------\n');

  // Test with gemini-2.5-flash as fallback
  print('Testing gemini-2.5-flash...');
  try {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': key,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say hello in one word'}
            ]
          }
        ]
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
  } catch (e) {
    print('Error: $e');
  }
}
