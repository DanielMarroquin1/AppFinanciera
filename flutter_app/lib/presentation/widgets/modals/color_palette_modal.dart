import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ColorPaletteModal extends StatefulWidget {
  const ColorPaletteModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ColorPaletteModal(),
    );
  }

  @override
  State<ColorPaletteModal> createState() => _ColorPaletteModalState();
}

class _ColorPaletteModalState extends State<ColorPaletteModal> {
  String selectedPalette = 'Índigo Esmeralda';

  final List<String> unlockedPalettes = ['Índigo Esmeralda', 'Paleta Océano'];

  final presetPalettes = [
    {
      'name': 'Índigo Esmeralda',
      'colors': [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFF8B5CF6)],
    },
    {
      'name': 'Paleta Océano',
      'colors': [const Color(0xFF0EA5E9), const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
    },
    {
      'name': 'Paleta Atardecer',
      'colors': [const Color(0xFFF97316), const Color(0xFFF43F5E), const Color(0xFFF59E0B)],
    },
    {
      'name': 'Paleta Bosque',
      'colors': [const Color(0xFF10B981), const Color(0xFF84CC16), const Color(0xFF22C55E)],
    },
    {
      'name': 'Paleta Lavanda',
      'colors': [const Color(0xFF8B5CF6), const Color(0xFFA855F7), const Color(0xFFD946EF)],
    },
    {
      'name': 'Paleta Medianoche',
      'colors': [const Color(0xFF64748B), const Color(0xFF6366F1), const Color(0xFF3B82F6)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paleta de Colores 🎨', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Personaliza los colores de tu app', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                    ],
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
                      final name = palette['name'] as String;
                      final colors = palette['colors'] as List<Color>;
                      final isUnlocked = unlockedPalettes.contains(name);
                      final isSelected = selectedPalette == name;

                      return GestureDetector(
                        onTap: () {
                          if (isUnlocked) {
                            setState(() => selectedPalette = name);
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
                    }).toList(),

                    if (unlockedPalettes.contains(selectedPalette)) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vista Previa', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                            const SizedBox(height: 12),
                            Builder(builder: (context) {
                              final activeColors = presetPalettes.firstWhere((p) => p['name'] == selectedPalette)['colors'] as List<Color>;
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [activeColors[0], activeColors[1], activeColors[2]], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
              padding: const EdgeInsets.all(24).copyWith(top: 0),
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
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: isDark 
                            ? const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF047857)]) // indigo-700 to emerald-700 
                            : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]), // indigo-600 to emerald-500
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: unlockedPalettes.contains(selectedPalette) ? () {
                          Navigator.of(context).pop();
                          // Would normally save palette
                        } : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('Guardar', style: TextStyle(color: unlockedPalettes.contains(selectedPalette) ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
