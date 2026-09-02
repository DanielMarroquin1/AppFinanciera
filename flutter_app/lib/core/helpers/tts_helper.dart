import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TtsHelper {
  static Future<void> configureTts(FlutterTts tts, String languageCode, {String? voicePresetOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    String voicePreset = voicePresetOverride ?? prefs.getString('ai_voice_preset') ?? 'amigable';
    
    await tts.awaitSpeakCompletion(true);
    await tts.setSpeechRate(kIsWeb ? 1.0 : 0.52);
    
    String lang = languageCode.startsWith('es') ? 'es-US' : languageCode;
    await tts.setLanguage(lang);
    
    // Attempt to pick better system voices based on preset
    try {
      final voices = await tts.getVoices;
      if (voices != null && voices is List) {
        List<Map<String, String>> voiceList = [];
        for (var v in voices) {
          if (v is Map) {
            voiceList.add(Map<String, String>.from(v.map((k, val) => MapEntry(k.toString(), val.toString()))));
          }
        }
        
        // Filter by language
        var langVoices = voiceList.where((v) => v['locale']?.startsWith(languageCode.split('_')[0]) ?? false).toList();
        
        if (langVoices.isNotEmpty) {
          // Sort or pick based on preset
          Map<String, String>? selectedVoice;
          if (voicePreset == 'amigable') {
            // Usually female high pitch voices
            selectedVoice = langVoices.firstWhere((v) => v['name']?.toLowerCase().contains('female') ?? false, orElse: () => langVoices.first);
            await tts.setPitch(1.2);
          } else if (voicePreset == 'profesional') {
            // Usually male low pitch voices
            selectedVoice = langVoices.firstWhere((v) => v['name']?.toLowerCase().contains('male') ?? false, orElse: () => langVoices.last);
            await tts.setPitch(0.85);
          } else {
            // Neutral
            selectedVoice = langVoices.firstWhere((v) => v['name']?.toLowerCase().contains('network') ?? false, orElse: () => langVoices[langVoices.length ~/ 2]);
            await tts.setPitch(1.0);
          }
          
          if (selectedVoice != null) {
            await tts.setVoice({"name": selectedVoice["name"]!, "locale": selectedVoice["locale"]!});
          }
        }
      }
    } catch (e) {
      // Fallback to pitch only if getting voices fails
      if (voicePreset == 'amigable') {
        await tts.setPitch(1.2);
      } else if (voicePreset == 'profesional') {
        await tts.setPitch(0.85);
      } else {
        await tts.setPitch(1.0);
      }
    }
  }
}
