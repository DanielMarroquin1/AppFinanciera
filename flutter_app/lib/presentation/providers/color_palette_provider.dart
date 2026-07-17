import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class ColorPalette {
  final String id;
  final String name;
  final String icon;
  final List<Color> colors; // [primary, secondary, accent]

  const ColorPalette({
    required this.id,
    required this.name,
    required this.icon,
    required this.colors,
  });
}

const List<ColorPalette> presetPalettes = [
  ColorPalette(
    id: 'theme_default',
    name: 'Índigo Esmeralda',
    icon: '✨',
    colors: [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFF8B5CF6)],
  ),
  ColorPalette(
    id: 'theme1',
    name: 'Océano Profundo',
    icon: '🌊',
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ),
  ColorPalette(
    id: 'theme2',
    name: 'Atardecer de Oro',
    icon: '🌅',
    colors: [Color(0xFFF97316), Color(0xFFF43F5E), Color(0xFFF59E0B)],
  ),
  ColorPalette(
    id: 'theme3',
    name: 'Cyberpunk Neón',
    icon: '🕹️',
    colors: [Color(0xFFD946EF), Color(0xFF06B6D4), Color(0xFFA855F7)],
  ),
  ColorPalette(
    id: 'theme4',
    name: 'Bosque Esmeralda',
    icon: '🌲',
    colors: [Color(0xFF10B981), Color(0xFF84CC16), Color(0xFF059669)],
  ),
  ColorPalette(
    id: 'theme5',
    name: 'Amatista Real',
    icon: '💜',
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFFC084FC)],
  ),
  ColorPalette(
    id: 'theme6',
    name: 'Obsidiana Oscura',
    icon: '🌑',
    colors: [Color(0xFF475569), Color(0xFF64748B), Color(0xFF94A3B8)],
  ),
  ColorPalette(
    id: 'theme7',
    name: 'Llama Solar',
    icon: '🔥',
    colors: [Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFF59E0B)],
  ),
  ColorPalette(
    id: 'theme8',
    name: 'Sakura Japonés',
    icon: '🌸',
    colors: [Color(0xFFEC4899), Color(0xFFF43F5E), Color(0xFFF472B6)],
  ),
];

class ColorPaletteNotifier extends Notifier<ColorPalette> {
  static const _paletteKey = 'selected_palette';

  @override
  ColorPalette build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedKey = prefs.getString(_paletteKey);
    if (savedKey != null) {
      return presetPalettes.firstWhere(
        (p) => p.id == savedKey || p.name == savedKey,
        orElse: () => presetPalettes.first,
      );
    }
    return presetPalettes.first;
  }

  Future<void> setPalette(ColorPalette palette) async {
    state = palette;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_paletteKey, palette.id);
  }

  Future<void> setPaletteById(String id) async {
    final match = presetPalettes.firstWhere(
      (p) => p.id == id || p.name == id,
      orElse: () => presetPalettes.first,
    );
    await setPalette(match);
  }

  /// Get dynamic gradient colors for light/dark modes
  List<Color> getGradient(bool isDark) {
    final p = state.colors;
    if (isDark) {
      // Darken colors slightly for dark mode for better contrast
      return [
        HSLColor.fromColor(p[0]).withLightness((HSLColor.fromColor(p[0]).lightness * 0.75).clamp(0.0, 1.0)).toColor(),
        HSLColor.fromColor(p[1]).withLightness((HSLColor.fromColor(p[1]).lightness * 0.75).clamp(0.0, 1.0)).toColor(),
      ];
    }
    return [p[0], p[1]];
  }
}

final colorPaletteProvider = NotifierProvider<ColorPaletteNotifier, ColorPalette>(() {
  return ColorPaletteNotifier();
});
