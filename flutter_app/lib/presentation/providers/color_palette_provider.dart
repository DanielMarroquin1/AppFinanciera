import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class ColorPalette {
  final String name;
  final List<Color> colors; // [primary, secondary, accent]

  const ColorPalette({required this.name, required this.colors});
}

const List<ColorPalette> presetPalettes = [
  ColorPalette(
    name: 'Índigo Esmeralda',
    colors: [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFF8B5CF6)],
  ),
  ColorPalette(
    name: 'Paleta Océano',
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ),
  ColorPalette(
    name: 'Paleta Atardecer',
    colors: [Color(0xFFF97316), Color(0xFFF43F5E), Color(0xFFF59E0B)],
  ),
  ColorPalette(
    name: 'Paleta Bosque',
    colors: [Color(0xFF10B981), Color(0xFF84CC16), Color(0xFF22C55E)],
  ),
  ColorPalette(
    name: 'Paleta Lavanda',
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFD946EF)],
  ),
  ColorPalette(
    name: 'Paleta Medianoche',
    colors: [Color(0xFF64748B), Color(0xFF6366F1), Color(0xFF3B82F6)],
  ),
];

class ColorPaletteNotifier extends Notifier<ColorPalette> {
  static const _paletteKey = 'selected_palette';

  @override
  ColorPalette build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedName = prefs.getString(_paletteKey);
    if (savedName != null) {
      return presetPalettes.firstWhere(
        (p) => p.name == savedName,
        orElse: () => presetPalettes.first,
      );
    }
    return presetPalettes.first;
  }

  Future<void> setPalette(ColorPalette palette) async {
    state = palette;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_paletteKey, palette.name);
  }

  /// Get dynamic gradient colors for light/dark modes
  List<Color> getGradient(bool isDark) {
    final p = state.colors;
    if (isDark) {
      // Darken colors slightly for dark mode
      return [
        HSLColor.fromColor(p[0]).withLightness((HSLColor.fromColor(p[0]).lightness * 0.7).clamp(0.0, 1.0)).toColor(),
        HSLColor.fromColor(p[1]).withLightness((HSLColor.fromColor(p[1]).lightness * 0.7).clamp(0.0, 1.0)).toColor(),
      ];
    }
    return [p[0], p[1]];
  }
}

final colorPaletteProvider = NotifierProvider<ColorPaletteNotifier, ColorPalette>(() {
  return ColorPaletteNotifier();
});
