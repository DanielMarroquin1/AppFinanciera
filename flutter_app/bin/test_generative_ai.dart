import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final key = const String.fromEnvironment('GEMINI_API_KEY');
  
  print('Testing google_generative_ai package with gemini-3.5-flash...');
  try {
    final model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: key,
    );
    final chat = model.startChat();
    final response = await chat.sendMessage(Content.text('Say hello'));
    print('SUCCESS! Response: ' + (response.text ?? 'null'));
  } catch (e) {
    print('ERROR with gemini-3.5-flash: ' + e.toString());
  }
  
  print('\n---\n');
  
  print('Testing google_generative_ai package with gemini-2.5-flash...');
  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
    );
    final chat = model.startChat();
    final response = await chat.sendMessage(Content.text('Say hello'));
    print('SUCCESS! Response: ' + (response.text ?? 'null'));
  } catch (e) {
    print('ERROR with gemini-2.5-flash: ' + e.toString());
  }
}
