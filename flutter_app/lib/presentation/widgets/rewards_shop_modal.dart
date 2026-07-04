import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RewardsShopModal extends ConsumerStatefulWidget {
  const RewardsShopModal({super.key});

  static void show(BuildContext context, {int? points}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RewardsShopModal(),
    );
  }

  @override
  ConsumerState<RewardsShopModal> createState() => _RewardsShopModalState();
}

class _RewardsShopModalState extends ConsumerState<RewardsShopModal> {
  int _selectedTabIndex = 0; // 0: Todo, 1: Avatares, 2: Paletas, 3: Especiales

  final List<String> _tabs = ['🔥 Todo', '🦸‍♂️ Avatares VIP', '🎨 Paletas de Estilo', '⚡ Especiales'];

  final List<Map<String, dynamic>> _allCategories = [
    {
      'id': 'avatars',
      'title': 'Avatares Exclusivos 🦸‍♂️',
      'subtitle': 'Personaliza tu identidad en la plataforma',
      'color': [const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
      'items': [
        {'id': 'avatar1', 'name': 'Superhéroe Financiero', 'desc': 'Protector indiscutible de tu presupuesto diario', 'icon': '🦸', 'cost': 50},
        {'id': 'avatar2', 'name': 'Mago Místico', 'desc': 'Multiplica y multiplica tus ahorros con magia pura', 'icon': '🧙', 'cost': 50},
        {'id': 'avatar3', 'name': 'Rey del Ahorro', 'desc': 'Corona dorada que representa estatus imperial', 'icon': '👑', 'cost': 75},
        {'id': 'avatar4', 'name': 'Ninja de las Finanzas', 'desc': 'Recorta gastos innecesarios en absoluto silencio', 'icon': '🥷', 'cost': 75},
        {'id': 'avatar5', 'name': 'Inversionista Espacial', 'desc': 'Lleva tus portafolios e inversiones hasta la Luna 🚀', 'icon': '🧑‍🚀', 'cost': 100},
        {'id': 'avatar6', 'name': 'Magnate de Diamantes', 'desc': 'Para quienes tienen manos de diamante y visión', 'icon': '💎', 'cost': 150},
        {'id': 'avatar7', 'name': 'Ballena del Mercado', 'desc': 'Dominio absoluto del mercado y liquidez masiva', 'icon': '🐳', 'cost': 150},
        {'id': 'avatar8', 'name': 'Samurái Disciplinado', 'desc': 'Honor y control impecable de cada transacción', 'icon': '⚔️', 'cost': 200},
        {'id': 'avatar9', 'name': 'Dragón de Oro', 'desc': 'Guardián mitológico de tu riqueza ancestral', 'icon': '🐉', 'cost': 250},
        {'id': 'avatar10', 'name': 'Leyenda Antigravity AI', 'desc': 'El avatar definitivo del futuro agentico y wealth', 'icon': '🔥', 'cost': 300},
      ]
    },
    {
      'id': 'themes',
      'title': '🎨 Paletas de Colores VIP',
      'subtitle': 'Transilumina y ambienta tu interfaz financiera',
      'color': [const Color(0xFF3B82F6), const Color(0xFF10B981)],
      'items': [
        {'id': 'theme1', 'name': 'Océano Profundo', 'desc': 'Tonos relajantes azules y turquesa del mar pacífico', 'icon': '🌊', 'cost': 100, 'colors': [Colors.lightBlue, Colors.cyan, Colors.blue]},
        {'id': 'theme2', 'name': 'Atardecer de Oro', 'desc': 'Tonos cálidos vibrantes de naranja, rosa y ámbar', 'icon': '🌅', 'cost': 100, 'colors': [Colors.orange, Colors.pink, Colors.amber]},
        {'id': 'theme3', 'name': 'Cyberpunk Neón', 'desc': 'Luces futuristas de magenta, morado y cian intenso', 'icon': '🕹️', 'cost': 150, 'colors': [Colors.purpleAccent, Colors.cyanAccent, Colors.pinkAccent]},
        {'id': 'theme4', 'name': 'Bosque Esmeralda', 'desc': 'Armonía, serenidad y tranquilidad verde natural', 'icon': '🌲', 'cost': 150, 'colors': [Colors.green, Colors.teal, Colors.lightGreen]},
        {'id': 'theme5', 'name': 'Amatista Real', 'desc': 'Elegancia morada y destellos de índigo imperial', 'icon': '💜', 'cost': 200, 'colors': [Colors.deepPurple, Colors.purple, Colors.indigoAccent]},
        {'id': 'theme6', 'name': 'Obsidiana Oscura', 'desc': 'Minimalismo absoluto en tonos grafito, plomo y plata', 'icon': '🌑', 'cost': 200, 'colors': [Colors.black87, Colors.grey, Colors.blueGrey]},
        {'id': 'theme7', 'name': 'Llama Solar', 'desc': 'Energía desbordante en carmesí y oro ardiente', 'icon': '🔥', 'cost': 250, 'colors': [Colors.redAccent, Colors.deepOrange, Colors.amberAccent]},
        {'id': 'theme8', 'name': 'Sakura Japonés', 'desc': 'Delicadeza floral en tonos flor de cerezo primaveral', 'icon': '🌸', 'cost': 250, 'colors': [Colors.pinkAccent, Colors.purpleAccent, Colors.redAccent]},
      ]
    },
    {
      'id': 'specials',
      'title': '⚡ Ventajas y Especiales',
      'subtitle': 'Poderes únicos y protección para tus métricas',
      'color': [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
      'items': [
        {'id': 'spec1', 'name': 'Prueba Premium 7 Días', 'desc': 'Acceso ilimitado a herramientas pro por 1 semana', 'icon': '👑', 'cost': 300},
        {'id': 'spec2', 'name': 'Escudo Congelador de Racha', 'desc': 'Protege tu racha diaria si olvidas entrar un día', 'icon': '❄️', 'cost': 150},
        {'id': 'spec3', 'name': 'Asesor AI VIP x 1 Mes', 'desc': 'Consultas avanzadas ilimitadas con inteligencia artificial', 'icon': '🤖', 'cost': 400},
        {'id': 'spec4', 'name': 'Insignia Dorada de Mecenas', 'desc': 'Destaca tu perfil en el podio con un marco dorado', 'icon': '✨', 'cost': 500},
      ]
    }
  ];

  List<Map<String, dynamic>> _getFilteredCategories() {
    if (_selectedTabIndex == 0) return _allCategories;
    if (_selectedTabIndex == 1) return _allCategories.where((c) => c['id'] == 'avatars').toList();
    if (_selectedTabIndex == 2) return _allCategories.where((c) => c['id'] == 'themes').toList();
    return _allCategories.where((c) => c['id'] == 'specials').toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final userPoints = user?.points ?? 0;
    final unlockedItems = user?.unlockedItems ?? [];

    final filteredCategories = _getFilteredCategories();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // HEADER LOUNGE VIP
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E1B4B)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF312E81)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: const Color(0xFF312E81).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Center(child: Text('👑', style: TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TIENDA DE RECOMPENSAS VIP',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Canjea tus puntos por ventajas y estilo único',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // POINTS PILL BANNER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCD34D).withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Tus Puntos Disponibles',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '$userPoints',
                            style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(width: 4),
                          const Text('PTS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TABS FILTER
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabs.length,
              itemBuilder: (context, idx) {
                final isSel = _selectedTabIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSel ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
                      color: isSel ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? const Color(0xFF8B5CF6) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      boxShadow: isSel ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Center(
                      child: Text(
                        _tabs[idx],
                        style: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                          fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // BODY LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredCategories.length,
              itemBuilder: (context, catIdx) {
                final category = filteredCategories[catIdx];
                final gradientColors = category['color'] as List<Color>;
                final items = category['items'] as List<Map<String, dynamic>>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header Banner
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradientColors[0].withValues(alpha: 0.15), gradientColors[1].withValues(alpha: 0.05)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(left: BorderSide(color: gradientColors[0], width: 4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category['title'], style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(category['subtitle'], style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11)),
                            ],
                          ),
                          Icon(LucideIcons.chevronRight, color: gradientColors[0], size: 20),
                        ],
                      ),
                    ),

                    // Items
                    ...items.map((item) {
                      final itemId = item['id'] as String;
                      final isUnlocked = unlockedItems.contains(itemId);
                      final isEquipped = user?.currentAvatar == itemId;
                      final canAfford = userPoints >= (item['cost'] as int);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isEquipped
                                ? const Color(0xFF10B981)
                                : isUnlocked
                                    ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: isEquipped ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                            if (isEquipped) BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon Pedestal
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isEquipped
                                          ? [const Color(0xFF10B981).withValues(alpha: 0.2), const Color(0xFF059669).withValues(alpha: 0.1)]
                                          : [gradientColors[0].withValues(alpha: 0.15), gradientColors[1].withValues(alpha: 0.05)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isEquipped ? const Color(0xFF10B981).withValues(alpha: 0.4) : gradientColors[0].withValues(alpha: 0.3)),
                                  ),
                                  child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 34))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['name'] as String,
                                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 16),
                                            ),
                                          ),
                                          if (isEquipped)
                                            _buildBadge('EQUIPADO 🌟', const Color(0xFF10B981))
                                          else if (isUnlocked)
                                            _buildBadge('DESBLOQUEADO ✔️', const Color(0xFF6366F1))
                                          else
                                            _buildBadge('${item['cost']} PTS', const Color(0xFFF59E0B)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['desc'] as String,
                                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.3),
                                      ),

                                      // Color swatches preview for themes
                                      if (item['colors'] != null) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: (item['colors'] as List<Color>).map((c) {
                                            return Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 6),
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: c,
                                                  borderRadius: BorderRadius.circular(6),
                                                  boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action Button
                            InkWell(
                              onTap: () async {
                                if (isEquipped) return;
                                if (isUnlocked) {
                                  if (category['id'] == 'avatars') {
                                    await ref.read(authProvider.notifier).equipAvatar(itemId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('⚡ Avatar equipado con éxito: ${item['name']}'),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✨ Estilo activado: ${item['name']}'),
                                          backgroundColor: const Color(0xFF6366F1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                  return;
                                }

                                if (canAfford) {
                                  final success = await ref.read(authProvider.notifier).purchaseItem(item['cost'] as int, itemId);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('🎉 ¡Canje exitoso! Desbloqueaste: ${item['name']}'),
                                        backgroundColor: const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    if (category['id'] == 'avatars') {
                                      await ref.read(authProvider.notifier).equipAvatar(itemId);
                                    }
                                  }
                                } else {
                                  final missing = (item['cost'] as int) - userPoints;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🔒 Faltan $missing puntos para desbloquear esta recompensa.'),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: isEquipped
                                      ? LinearGradient(colors: [const Color(0xFF10B981).withValues(alpha: 0.15), const Color(0xFF059669).withValues(alpha: 0.05)])
                                      : isUnlocked
                                          ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                                          : canAfford
                                              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)])
                                              : null,
                                  color: (isUnlocked || canAfford) ? null : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: isEquipped ? Border.all(color: const Color(0xFF10B981), width: 1.5) : null,
                                  boxShadow: (canAfford && !isUnlocked && !isEquipped)
                                      ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEquipped
                                          ? LucideIcons.checkCircle2
                                          : isUnlocked
                                              ? LucideIcons.sparkles
                                              : (canAfford ? LucideIcons.gift : LucideIcons.lock),
                                      color: isEquipped ? const Color(0xFF10B981) : (isUnlocked || canAfford) ? Colors.white : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEquipped
                                          ? 'ACTIVO EN TU PERFIL'
                                          : isUnlocked
                                              ? 'USAR O EQUIPAR AHORA'
                                              : 'CANJEAR RECOMPENSA POR ${item['cost']} PTS',
                                      style: TextStyle(
                                        color: isEquipped ? const Color(0xFF10B981) : (isUnlocked || canAfford) ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
