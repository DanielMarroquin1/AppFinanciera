import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      return ThemeMode.values[themeIndex];
    }
    return ThemeMode.system;
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && View.of(context).platformDispatcher.platformBrightness == Brightness.dark);
    
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_themeKey, newMode.index);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
