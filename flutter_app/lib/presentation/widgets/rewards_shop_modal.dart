import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/color_palette_provider.dart';
import '../../core/utils/localization.dart';

class RewardsShopModal extends ConsumerStatefulWidget {
  const RewardsShopModal({super.key});

  static void show(BuildContext context, {int? points}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RewardsShopModal(),
    );
  }

  @override
  ConsumerState<RewardsShopModal> createState() => _RewardsShopModalState();
}

class _RewardsShopModalState extends ConsumerState<RewardsShopModal> {
  int _selectedTabIndex = 0; // 0: Todo, 1: Avatares, 2: Paletas, 3: Especiales

  List<String> _getTabs(AppLocalizations loc) => [
    loc.get('shop_tab_all'),
    loc.get('shop_tab_avatars'),
    loc.get('shop_tab_themes'),
    loc.get('shop_tab_specials'),
  ];

  List<Map<String, dynamic>> _getCategories(AppLocalizations loc) {
    return [
      {
        'id': 'avatars',
        'title': loc.get('shop_cat_avatars_title'),
        'subtitle': loc.get('shop_cat_avatars_sub'),
        'color': [const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
        'items': [
          {'id': 'avatar1', 'name': loc.get('item_avatar1_name'), 'desc': loc.get('item_avatar1_desc'), 'icon': '🦸', 'cost': 50},
          {'id': 'avatar2', 'name': loc.get('item_avatar2_name'), 'desc': loc.get('item_avatar2_desc'), 'icon': '🧙', 'cost': 50},
          {'id': 'avatar3', 'name': loc.get('item_avatar3_name'), 'desc': loc.get('item_avatar3_desc'), 'icon': '👑', 'cost': 75},
          {'id': 'avatar4', 'name': loc.get('item_avatar4_name'), 'desc': loc.get('item_avatar4_desc'), 'icon': '🥷', 'cost': 75},
          {'id': 'avatar5', 'name': loc.get('item_avatar5_name'), 'desc': loc.get('item_avatar5_desc'), 'icon': '🧑‍🚀', 'cost': 100},
          {'id': 'avatar6', 'name': loc.get('item_avatar6_name'), 'desc': loc.get('item_avatar6_desc'), 'icon': '💎', 'cost': 150},
          {'id': 'avatar7', 'name': loc.get('item_avatar7_name'), 'desc': loc.get('item_avatar7_desc'), 'icon': '🐳', 'cost': 150},
          {'id': 'avatar8', 'name': loc.get('item_avatar8_name'), 'desc': loc.get('item_avatar8_desc'), 'icon': '⚔️', 'cost': 200},
          {'id': 'avatar9', 'name': loc.get('item_avatar9_name'), 'desc': loc.get('item_avatar9_desc'), 'icon': '🐉', 'cost': 250},
          {'id': 'avatar10', 'name': loc.get('item_avatar10_name'), 'desc': loc.get('item_avatar10_desc'), 'icon': '🔥', 'cost': 300},
        ]
      },
      {
        'id': 'themes',
        'title': loc.get('shop_cat_themes_title'),
        'subtitle': loc.get('shop_cat_themes_sub'),
        'color': [const Color(0xFF3B82F6), const Color(0xFF10B981)],
        'items': [
          {'id': 'theme1', 'name': loc.get('item_theme1_name'), 'desc': loc.get('item_theme1_desc'), 'icon': '🌊', 'cost': 100, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme1').colors},
          {'id': 'theme2', 'name': loc.get('item_theme2_name'), 'desc': loc.get('item_theme2_desc'), 'icon': '🌅', 'cost': 100, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme2').colors},
          {'id': 'theme3', 'name': loc.get('item_theme3_name'), 'desc': loc.get('item_theme3_desc'), 'icon': '🕹️', 'cost': 150, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme3').colors},
          {'id': 'theme4', 'name': loc.get('item_theme4_name'), 'desc': loc.get('item_theme4_desc'), 'icon': '🌲', 'cost': 150, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme4').colors},
          {'id': 'theme5', 'name': loc.get('item_theme5_name'), 'desc': loc.get('item_theme5_desc'), 'icon': '💜', 'cost': 200, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme5').colors},
          {'id': 'theme6', 'name': loc.get('item_theme6_name'), 'desc': loc.get('item_theme6_desc'), 'icon': '🌑', 'cost': 200, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme6').colors},
          {'id': 'theme7', 'name': loc.get('item_theme7_name'), 'desc': loc.get('item_theme7_desc'), 'icon': '🔥', 'cost': 250, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme7').colors},
          {'id': 'theme8', 'name': loc.get('item_theme8_name'), 'desc': loc.get('item_theme8_desc'), 'icon': '🌸', 'cost': 250, 'colors': presetPalettes.firstWhere((p) => p.id == 'theme8').colors},
        ]
      },
      {
        'id': 'specials',
        'title': loc.get('shop_cat_specials_title'),
        'subtitle': loc.get('shop_cat_specials_sub'),
        'color': [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
        'items': [
          {'id': 'spec1', 'name': loc.get('item_spec1_name'), 'desc': loc.get('item_spec1_desc'), 'icon': '👑', 'cost': 300},
          {'id': 'spec2', 'name': loc.get('item_spec2_name'), 'desc': loc.get('item_spec2_desc'), 'icon': '❄️', 'cost': 150},
          {'id': 'spec3', 'name': loc.get('item_spec3_name'), 'desc': loc.get('item_spec3_desc'), 'icon': '🤖', 'cost': 400},
          {'id': 'spec4', 'name': loc.get('item_spec4_name'), 'desc': loc.get('item_spec4_desc'), 'icon': '✨', 'cost': 500},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getFilteredCategories(AppLocalizations loc) {
    final all = _getCategories(loc);
    if (_selectedTabIndex == 0) return all;
    if (_selectedTabIndex == 1) return all.where((c) => c['id'] == 'avatars').toList();
    if (_selectedTabIndex == 2) return all.where((c) => c['id'] == 'themes').toList();
    return all.where((c) => c['id'] == 'specials').toList();
  }

  void _showRewardActivatedDialog(BuildContext context, String name, String desc, String icon, bool isDark, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 16),
              Text(
                loc.get('shop_reward_active'),
                style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(loc.get('shop_got_it_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final user = ref.watch(authProvider).user;
    final userPoints = user?.points ?? 0;
    final unlockedItems = user?.unlockedItems ?? [];

    final filteredCategories = _getFilteredCategories(loc);
    final tabs = _getTabs(loc);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 650,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            children: [
              // HEADER LOUNGE VIP
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E1B4B)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF312E81)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                    Expanded(
                      child: Row(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.get('shop_title'),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.get('shop_subtitle_main'),
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.rotateCcw, color: Color(0xFFFCD34D), size: 18),
                      tooltip: 'Reiniciar canjes (Pruebas)',
                      onPressed: () async {
                        await ref.read(authProvider.notifier).resetUnlockedThemes();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('✨ Canjes de colores reiniciados y puntos restaurados.'),
                              backgroundColor: const Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 6),
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
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                              child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                loc.get('shop_points_avail'),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            '$userPoints',
                            style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(loc.get('shop_pts'), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
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
              itemCount: tabs.length,
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
                        tabs[idx],
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
                      final isAvatar = category['id'] == 'avatars';
                      final isTheme = category['id'] == 'themes';
                      final currentPalette = ref.watch(colorPaletteProvider);
                      final isUnlocked = unlockedItems.contains(itemId);
                      final isEquipped = isAvatar
                          ? user?.currentAvatar == itemId
                          : (isTheme ? currentPalette.id == itemId : false);
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
                                            _buildBadge(loc.get('shop_badge_equipped'), const Color(0xFF10B981))
                                          else if (isUnlocked)
                                            _buildBadge(loc.get('shop_badge_unlocked'), const Color(0xFF6366F1))
                                          else
                                            _buildBadge('${item['cost']} ${loc.get('shop_pts')}', const Color(0xFFF59E0B)),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loc.get('shop_snack_avatar_unlocked')),
                                        backgroundColor: const Color(0xFF6366F1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else if (category['id'] == 'themes') {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✨ Paleta "${item['name']}" ya desbloqueada. Ve a Ajustes > Paleta de Colores para aplicarla.'),
                                          backgroundColor: const Color(0xFF6366F1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  } else if (category['id'] == 'specials') {
                                    _showRewardActivatedDialog(
                                      context,
                                      item['name'] as String,
                                      itemId == 'spec2'
                                          ? loc.get('shop_snack_shield_active')
                                          : (item['desc'] as String),
                                      item['icon'] as String,
                                      isDark,
                                      loc,
                                    );
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.get('shop_snack_style_active').replaceAll('{name}', item['name'] as String)),
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
                                    if (category['id'] == 'avatars') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.get('shop_snack_avatar_success')),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else if (category['id'] == 'themes') {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text('🎉 ¡Paleta "${item['name']}" desbloqueada! Ve a Ajustes > Paleta de Colores para aplicarla.')),
                                              ],
                                            ),
                                            backgroundColor: (item['colors'] as List<Color>)[0],
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      }
                                    } else if (category['id'] == 'specials') {
                                      _showRewardActivatedDialog(
                                        context,
                                        item['name'] as String,
                                        itemId == 'spec2'
                                            ? loc.get('shop_snack_shield_active')
                                            : (item['desc'] as String),
                                        item['icon'] as String,
                                        isDark,
                                        loc,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.get('shop_snack_redeem_success').replaceAll('{name}', item['name'] as String)),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  final missing = (item['cost'] as int) - userPoints;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(loc.get('shop_snack_missing_pts').replaceAll('{missing}', '$missing')),
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
                                  gradient: (isEquipped || isUnlocked)
                                      ? LinearGradient(colors: [const Color(0xFF10B981).withValues(alpha: 0.15), const Color(0xFF059669).withValues(alpha: 0.05)])
                                      : canAfford
                                          ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)])
                                          : null,
                                  color: (isEquipped || isUnlocked || canAfford) ? null : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: (isEquipped || isUnlocked) ? Border.all(color: const Color(0xFF10B981), width: 1.5) : null,
                                  boxShadow: (canAfford && !isUnlocked && !isEquipped)
                                      ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      (isEquipped || isUnlocked)
                                          ? LucideIcons.checkCircle2
                                          : (canAfford ? LucideIcons.gift : LucideIcons.lock),
                                      color: (isEquipped || isUnlocked) ? const Color(0xFF10B981) : (canAfford ? Colors.white : Colors.grey),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        (isEquipped || isUnlocked)
                                            ? loc.get('shop_badge_unlocked')
                                            : loc.get('shop_btn_redeem').replaceAll('{cost}', '${item['cost']}'),
                                        style: TextStyle(
                                          color: (isEquipped || isUnlocked) ? const Color(0xFF10B981) : (canAfford ? Colors.white : Colors.grey),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
            ), // closes ListView.builder
          ), // closes Expanded
        ],
      ), // closes Column
    ), // closes ClipRRect
    ), // closes Container
    ); // closes Dialog
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
