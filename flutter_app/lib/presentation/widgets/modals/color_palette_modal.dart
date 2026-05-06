import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/color_palette_provider.dart';

class ColorPaletteModal extends ConsumerStatefulWidget {
  const ColorPaletteModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ColorPaletteModal(),
    );
  }

  @override
  ConsumerState<ColorPaletteModal> createState() => _ColorPaletteModalState();
}

class _ColorPaletteModalState extends ConsumerState<ColorPaletteModal> {
  late String selectedPaletteName;

  // TODO: Revertir a solo ['Índigo Esmeralda', 'Paleta Océano'] después de probar
  final List<String> unlockedPalettes = ['Índigo Esmeralda', 'Paleta Océano', 'Paleta Atardecer', 'Paleta Bosque', 'Paleta Lavanda', 'Paleta Medianoche'];

  @override
  void initState() {
    super.initState();
    selectedPaletteName = ref.read(colorPaletteProvider).name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 500,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24).copyWith(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paleta de Colores 🎨', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Personaliza los colores de tu app', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ...presetPalettes.map((palette) {
                        final name = palette.name;
                        final colors = palette.colors;
                        final isUnlocked = unlockedPalettes.contains(name);
                        final isSelected = selectedPaletteName == name;

                        return GestureDetector(
                          onTap: () {
                            if (isUnlocked) {
                              setState(() => selectedPaletteName = name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paleta bloqueada. Canjéala en la tienda.')));
                            }
                          },
                          child: Opacity(
                            opacity: isUnlocked ? 1.0 : 0.6,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected && isUnlocked
                                    ? (isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : const Color(0xFFEEF2FF))
                                    : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
                                border: Border.all(
                                  color: isSelected && isUnlocked
                                      ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1))
                                      : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                                          if (!isUnlocked) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(color: isDark ? Colors.grey[600] : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                                              child: Row(
                                                children: [
                                                  Icon(LucideIcons.lock, size: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text('Bloqueada', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 10)),
                                                ],
                                              ),
                                            )
                                          ]
                                        ],
                                      ),
                                      if (isSelected && isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1), shape: BoxShape.circle),
                                          child: const Icon(LucideIcons.check, color: Colors.white, size: 12),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: colors.map((c) => Expanded(
                                      child: Container(
                                        height: 32,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: c,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                  if (!isUnlocked) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.shoppingBag, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text('Disponible en la tienda de puntos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 10)),
                                      ],
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // Live Preview
                      if (unlockedPalettes.contains(selectedPaletteName)) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vista Previa', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              const SizedBox(height: 12),
                              Builder(builder: (context) {
                                final selectedColors = presetPalettes.firstWhere((p) => p.name == selectedPaletteName).colors;
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [selectedColors[0], selectedColors[1]]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Tu App de Finanzas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Así se verán los elementos principales', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(24).copyWith(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final canSave = unlockedPalettes.contains(selectedPaletteName);
                          final selectedColors = presetPalettes.firstWhere((p) => p.name == selectedPaletteName).colors;
                          return ElevatedButton(
                            onPressed: canSave ? () {
                              final palette = presetPalettes.firstWhere((p) => p.name == selectedPaletteName);
                              ref.read(colorPaletteProvider.notifier).setPalette(palette);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(LucideIcons.palette, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Paleta "$selectedPaletteName" aplicada ✨'),
                                    ],
                                  ),
                                  backgroundColor: selectedColors[0],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSave ? selectedColors[0] : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                              foregroundColor: canSave ? Colors.white : (isDark ? Colors.white54 : Colors.grey[500]),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
