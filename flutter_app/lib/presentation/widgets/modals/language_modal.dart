import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/localization.dart';

class LanguageModal extends ConsumerWidget {
  const LanguageModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final user = ref.watch(authProvider).user;
    
    // We get the current language from localeProvider directly to support logged-out users
    final currentLanguage = ref.watch(localeProvider);

    final languages = [
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    ];

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24, 
        bottom: MediaQuery.of(context).padding.bottom + 24
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            loc.get('select_language') ?? 'Seleccionar Idioma', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: isDark ? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.5)
          ),
          const SizedBox(height: 8),
          Text(
            loc.get('select_language_desc') ?? 'Elige el idioma de tu preferencia para la aplicación.', 
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15)
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: languages.map((lang) {
                  final isSelected = currentLanguage == lang['name'] || currentLanguage == lang['code'];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        // Update the localeProvider (persists to SharedPreferences)
                        ref.read(localeProvider.notifier).setLanguage(lang['name']!);
                        
                        // If user is logged in, also update their profile
                        if (user != null) {
                          ref.read(authProvider.notifier).updateProfile(user.copyWith(language: lang['name']!));
                        }
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF6366F1).withValues(alpha: 0.15) : const Color(0xFFEEF2FF))
                              : (isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF8FAFC)),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                lang['name']!, 
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A), 
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 16,
                                )
                              )
                            ),
                            if (isSelected) 
                              const Icon(LucideIcons.checkCircle2, color: Color(0xFF6366F1), size: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
