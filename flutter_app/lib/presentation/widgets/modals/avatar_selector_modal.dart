import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/localization.dart';

/// ARMARIO DE SAMI (REDISEÑO TOTAL BOUTIQUE - 100% PRENDAS 3D)
/// Interfaz de estudio de personalización minimalista, moderna y de lujo:
/// - Sin textos innecesarios ni probador en vivo flotante
/// - Pedestal de estudio 3D iluminado con reflejo y aura reactiva
/// - Miniaturas 3D reales de cada prenda en el carrusel
/// - Homogeneidad total de render y resolución 3D para SAMI
class AvatarSelectorModal extends ConsumerStatefulWidget {
  final String currentAvatarId;
  final List<String> unlockedItems;
  final Function(String) onAvatarSelected;

  const AvatarSelectorModal({
    super.key,
    required this.currentAvatarId,
    required this.unlockedItems,
    required this.onAvatarSelected,
  });

  @override
  ConsumerState<AvatarSelectorModal> createState() =>
      _AvatarSelectorModalState();

  static Future<void> show(
    BuildContext context, {
    required String currentAvatarId,
    required List<String> unlockedItems,
    required Function(String) onAvatarSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarSelectorModal(
        currentAvatarId: currentAvatarId,
        unlockedItems: unlockedItems,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  static String localizedOutfitName(WardrobeItem item, AppLocalizations loc) {
    final key = 'outfit_${item.id.replaceFirst('ropa_', '')}_name';
    final val = loc.get(key);
    return val == key ? item.name : val;
  }

  static String localizedOutfitDesc(WardrobeItem item, AppLocalizations loc) {
    final key = 'outfit_${item.id.replaceFirst('ropa_', '')}_desc';
    final val = loc.get(key);
    return val == key ? item.description : val;
  }

  static String localizedRarity(String rarity, AppLocalizations loc) {
    switch (rarity.toLowerCase()) {
      case 'inicial':
        return loc.get('rarity_initial');
      case 'común':
      case 'comun':
        return loc.get('rarity_common');
      case 'especial':
        return loc.get('rarity_special');
      case 'épico':
      case 'epico':
        return loc.get('rarity_epic');
      case 'legendario':
        return loc.get('rarity_legendary');
      default:
        return rarity;
    }
  }
}

class _AvatarSelectorModalState extends ConsumerState<AvatarSelectorModal>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _tapBounceController;
  late AnimationController _waveController;

  String? _speechMessage;

  late String _equippedId;
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  List<String> _getMotivationalPhrases(AppLocalizations loc) => [
    loc.get('wardrobe_sami_phrase_1'),
    loc.get('wardrobe_sami_phrase_2'),
    loc.get('wardrobe_sami_phrase_3'),
    loc.get('wardrobe_sami_phrase_4'),
    loc.get('wardrobe_sami_phrase_5'),
  ];

  static String localizedOutfitName(WardrobeItem item, AppLocalizations loc) =>
      AvatarSelectorModal.localizedOutfitName(item, loc);

  static String localizedOutfitDesc(WardrobeItem item, AppLocalizations loc) =>
      AvatarSelectorModal.localizedOutfitDesc(item, loc);

  static String localizedRarity(String rarity, AppLocalizations loc) =>
      AvatarSelectorModal.localizedRarity(rarity, loc);

  late final List<WardrobeItem> _outfitList;

  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    // Exclusivo para prendas de vestir
    _outfitList = WardrobeItem.allItems
        .where((i) => i.category == WardrobeCategory.clothing)
        .toList();

    final rawId = widget.currentAvatarId;
    final cleanId = rawId.contains('|') ? rawId.split('|')[0] : rawId;
    _equippedId = cleanId.isEmpty ? 'ropa_clasica' : cleanId;

    _selectedItem = _outfitList.firstWhere(
      (item) => item.id == _equippedId,
      orElse: () => _outfitList.first,
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapBounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapSami(AppLocalizations loc) {
    AppHaptics.mediumImpact();
    _tapBounceController.forward(from: 0.0);
    _waveController.forward(from: 0.0);
    final phrases = _getMotivationalPhrases(loc);
    setState(() {
      final rand = math.Random().nextInt(phrases.length);
      _speechMessage = phrases[rand];
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted && _speechMessage != null) {
        setState(() => _speechMessage = null);
      }
    });
  }

  void _selectOutfit(WardrobeItem item) {
    AppHaptics.selection();
    setState(() {
      _selectedItem = item;
    });
  }

  bool _isItemUnlocked(WardrobeItem item, List<String> unlockedItems) {
    if (item.isFree || item.cost == 0 || item.id == 'ropa_clasica') return true;
    return unlockedItems.contains(item.id);
  }

  bool _isItemEquipped(WardrobeItem item) {
    return _equippedId == item.id;
  }

  Future<void> _handleEquipOrUnlock(WardrobeItem item, AppLocalizations loc) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isUnlocked = _isItemUnlocked(item, user.unlockedItems);

    if (isUnlocked) {
      AppHaptics.success();
      setState(() {
        _equippedId = item.id;
      });
      widget.onAvatarSelected(item.id);
      await ref.read(authProvider.notifier).equipAvatar(item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.get('wardrobe_equipped_snack').replaceAll('{name}', localizedOutfitName(item, loc)),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (user.points < item.cost) {
      AppHaptics.error();
      _showNotEnoughCoinsDialog(item, user.points, loc);
      return;
    }

    setState(() => _isProcessing = true);
    AppHaptics.mediumImpact();

    try {
      final success = await ref
          .read(authProvider.notifier)
          .purchaseItem(item.cost, item.id);

      if (success && mounted) {
        AppHaptics.success();
        setState(() {
          _equippedId = item.id;
        });
        widget.onAvatarSelected(item.id);
        await ref.read(authProvider.notifier).equipAvatar(item.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.get('wardrobe_unlocked_snack').replaceAll('{name}', localizedOutfitName(item, loc)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (_) {
      AppHaptics.error();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showNotEnoughCoinsDialog(WardrobeItem item, int currentPoints, AppLocalizations loc) {
    final itemName = localizedOutfitName(item, loc);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF1F2937), width: 1.2),
        ),
        title: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              loc.get('wardrobe_not_enough_points_title'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          loc.get('wardrobe_not_enough_points_desc')
              .replaceAll('{name}', itemName)
              .replaceAll('{cost}', '${item.cost}')
              .replaceAll('{current}', '$currentPoints'),
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              loc.get('understood'),
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSamiHeroAsset() {
    return SamiOutfit.getAssetForEquipment(
      SamiEquipment(clothingId: _selectedItem.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationProvider);
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 4.0;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.08)
        : 1.0;

    final samiHeroAsset = _getSamiHeroAsset();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFF070B11),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // 1. Aura ambiental de iluminación de estudio reactiva al color de la prenda
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            height: 320,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _selectedItem.primaryColor.withValues(alpha: 0.30),
                      _selectedItem.primaryColor.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Contenido principal
          Column(
            children: [
              // Barra superior minimalista y elegante
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111822),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.get('wardrobe_title'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          loc.get('wardrobe_subtitle'),
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Badge pulido de Monedas / Puntos
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            '$userCoins ${loc.get("wardrobe_pts")}',
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================================
              // ESCENARIO 3D CENTRAL (SAMI FLOTANDO LIBRE Y LIMPIO)
              // =================================================================
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Globo de diálogo flotante al tocar a SAMI
                    if (_speechMessage != null)
                      Positioned(
                        top: 14,
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 260),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.40),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.60),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _speechMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // SAMI Modelando en 3D
                    GestureDetector(
                      onTap: () => _onTapSami(loc),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _idleController,
                          _tapBounceController,
                          _waveController,
                        ]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, floatY),
                            child: Transform.scale(
                              scale: bounceScale,
                              child: SizedBox(
                                width: 240,
                                height: 240,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Image.asset(
                                    samiHeroAsset,
                                    key: ValueKey(samiHeroAsset),
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================================
              // INFORMACIÓN DEL ATUENDO ACTIVO
              // =================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizedOutfitName(_selectedItem, loc),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedItem.rarityColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedItem.rarityColor.withValues(alpha: 0.45),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            localizedRarity(_selectedItem.rarity, loc),
                            style: TextStyle(
                              color: _selectedItem.rarityColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizedOutfitDesc(_selectedItem, loc),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =================================================================
              // CARRUSEL BOUTIQUE DE ATUENDOS CON MINIATURAS 3D REALES
              // =================================================================
              SizedBox(
                height: 138,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  itemCount: _outfitList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _outfitList[index];
                    final isSelected = _selectedItem.id == item.id;
                    final isEquipped = _isItemEquipped(item);
                    final isUnlocked = _isItemUnlocked(item, unlockedList);

                    return _OutfitRackCard(
                      item: item,
                      loc: loc,
                      isSelected: isSelected,
                      isEquipped: isEquipped,
                      isUnlocked: isUnlocked,
                      onTap: () => _selectOutfit(item),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // =================================================================
              // BOTÓN PRINCIPAL DE ACCIÓN
              // =================================================================
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom + 8
                      : 18,
                ),
                child: GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () => _handleEquipOrUnlock(_selectedItem, loc),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: isSelectedEquipped
                          ? const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF1E293B)],
                            )
                          : (isSelectedUnlocked
                              ? const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                )),
                      boxShadow: isSelectedEquipped
                          ? null
                          : [
                              BoxShadow(
                                color: (isSelectedUnlocked
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B))
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelectedEquipped) ...[
                                  const Icon(
                                    LucideIcons.check,
                                    color: Color(0xFF34D399),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.get('wardrobe_equipped'),
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ] else if (isSelectedUnlocked) ...[
                                  const Icon(
                                    LucideIcons.shirt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.get('wardrobe_equip_action'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ] else ...[
                                  const Text('🪙', style: TextStyle(fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.get('wardrobe_unlock_for').replaceAll('{cost}', '${_selectedItem.cost}'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// OUTFIT RACK CARD (Con Miniatura Real en 3D de cada Atuendo)
// =============================================================================
class _OutfitRackCard extends StatelessWidget {
  final WardrobeItem item;
  final AppLocalizations loc;
  final bool isSelected;
  final bool isEquipped;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _OutfitRackCard({
    required this.item,
    required this.loc,
    required this.isSelected,
    required this.isEquipped,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = SamiOutfit.getAssetForEquipment(
      SamiEquipment(clothingId: item.id),
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 128,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF131D28) : const Color(0xFF0C131B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF1A2633),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Miniatura 3D Real del Atuendo
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    item.primaryColor.withValues(alpha: 0.35),
                    item.secondaryColor.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF06B6D4).withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Nombre completo del atuendo
            Text(
              _AvatarSelectorModalState.localizedOutfitName(item, loc),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Badge de Estado
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.get('wardrobe_in_use'),
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.get('wardrobe_ready'),
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    '${item.cost} ${loc.get("wardrobe_pts")}',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
