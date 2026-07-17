import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/color_palette_provider.dart';
import 'premium_modal.dart';
import '../rewards_shop_modal.dart';

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
  late String selectedPaletteId;

  @override
  void initState() {
    super.initState();
    selectedPaletteId = ref.read(colorPaletteProvider).id;
  }

  int _getCostForPalette(String id) {
    switch (id) {
      case 'theme1':
      case 'theme2':
        return 100;
      case 'theme3':
      case 'theme4':
        return 150;
      case 'theme5':
      case 'theme6':
        return 200;
      case 'theme7':
      case 'theme8':
        return 250;
      default:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final currentPalette = ref.watch(colorPaletteProvider);
    final selectedPalette = presetPalettes.firstWhere(
      (p) => p.id == selectedPaletteId,
      orElse: () => presetPalettes.first,
    );

    final isPremium = user?.isPremium ?? false;
    final unlockedItems = user?.unlockedItems ?? [];

    bool isUnlocked(ColorPalette p) {
      if (p.id == 'theme_default') return true;
      return unlockedItems.contains(p.id);
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: 540,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(24).copyWith(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedPalette.colors[0].withValues(alpha: 0.15),
                      selectedPalette.colors[1].withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(
                    bottom: BorderSide(
                      color: selectedPalette.colors[0].withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: selectedPalette.colors),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedPalette.colors[0].withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(LucideIcons.palette, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paleta & Apariencia visual 🎨',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Personaliza los colores y gradientes de tu app',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    if (isPremium) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.crown, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              '⭐ MEMBRESÍA PREMIUM ACTIVA: Puedes aplicar todos los temas canjeados',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // SCROLLABLE CONTENT
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LIVE SHOWCASE PREVIEW
                      Text(
                        'VISTA PREVIA EN VIVO DE "${selectedPalette.name.toUpperCase()}"',
                        style: TextStyle(
                          color: selectedPalette.colors[0],
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              selectedPalette.colors[0],
                              selectedPalette.colors[1],
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: selectedPalette.colors[0].withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(selectedPalette.icon, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedPalette.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('ESTILO ACTIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Balance Total Estimado',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$14,850.00 USD',
                              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+ Agregar Ingreso',
                                        style: TextStyle(color: selectedPalette.colors[0], fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '- Registrar Gasto',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Presupuesto por categoría', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11)),
                                    const Text('75%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.75,
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'SELECCIONA TU PALETA VISUAL (${presetPalettes.length} DISPONIBLES)',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PALETTES GRID
                      ...presetPalettes.map((palette) {
                        final unlocked = isUnlocked(palette);
                        final isSelectedPreview = selectedPaletteId == palette.id;
                        final isEquipped = currentPalette.id == palette.id;
                        final cost = _getCostForPalette(palette.id);

                        return GestureDetector(
                          onTap: () {
                            if (unlocked) {
                              setState(() => selectedPaletteId = palette.id);
                            } else {
                              _showLockedOptionsDialog(context, palette, cost);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: !unlocked
                                  ? (isDark ? const Color(0xFF090D16) : const Color(0xFFE2E8F0))
                                  : isSelectedPreview
                                      ? (isDark ? palette.colors[0].withValues(alpha: 0.15) : palette.colors[0].withValues(alpha: 0.08))
                                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: !unlocked
                                    ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
                                    : isSelectedPreview
                                        ? palette.colors[0]
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: isSelectedPreview ? 2.2 : 1.2,
                              ),
                              boxShadow: isSelectedPreview
                                  ? [
                                      BoxShadow(
                                        color: palette.colors[0].withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(palette.icon, style: const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 10),
                                        Text(
                                          palette.name,
                                          style: TextStyle(
                                            color: !unlocked
                                                ? (isDark ? Colors.grey[500] : Colors.grey[600])
                                                : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (!unlocked) ...[
                                          const SizedBox(width: 6),
                                          const Icon(LucideIcons.lock, size: 14, color: Color(0xFFF59E0B)),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if (isEquipped)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFF10B981)),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 13),
                                                SizedBox(width: 4),
                                                Text('EQUIPADO', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          )
                                        else if (unlocked)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: palette.colors[0].withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text('DISPONIBLE', style: TextStyle(color: palette.colors[0], fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(LucideIcons.lock, size: 12, color: Color(0xFFEF4444)),
                                                const SizedBox(width: 4),
                                                Text('$cost PTS', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Opacity(
                                  opacity: !unlocked ? 0.35 : 1.0,
                                  child: Row(
                                    children: palette.colors.map((c) {
                                      return Expanded(
                                        child: Container(
                                          height: 36,
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          decoration: BoxDecoration(
                                            color: c,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: !unlocked
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: c.withValues(alpha: 0.35),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (!unlocked) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.lock, color: Color(0xFFFBBF24), size: 15),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'BLOQUEADO • Canjeable por $cost pts en Tienda',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('Ir a Tienda 🛒', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // ACTIONS FOOTER
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isUnlocked(selectedPalette) && currentPalette.id != selectedPalette.id
                            ? () async {
                                if (selectedPalette.id != 'theme_default' && !isPremium) {
                                  PremiumModal.show(context);
                                  return;
                                }
                                await ref.read(colorPaletteProvider.notifier).setPaletteById(selectedPalette.id);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(LucideIcons.palette, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '✨ Paleta "${selectedPalette.name}" aplicada a toda tu aplicación.',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: selectedPalette.colors[0],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPalette.colors[0],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          disabledForegroundColor: isDark ? Colors.grey[500] : Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: isUnlocked(selectedPalette) && currentPalette.id != selectedPalette.id ? 4 : 0,
                          shadowColor: selectedPalette.colors[0].withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          currentPalette.id == selectedPalette.id 
                            ? 'Ya está equipada ✔' 
                            : (selectedPalette.id != 'theme_default' && !isPremium ? '👑 APLICAR (REQUIERE PREMIUM)' : 'Equipar y Aplicar ✨'),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedOptionsDialog(BuildContext context, ColorPalette palette, int cost) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Text(palette.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Paleta Bloqueada 🔒',
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'La paleta "${palette.name}" está reservada. Puedes canjearla ahora por $cost Pts en la Tienda de Recompensas, o desbloquearla con tu membresía Premium.',
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // cerramos el modal de paletas y abrimos la tienda
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    RewardsShopModal.show(context);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.colors[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ir a la Tienda 🛒', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
