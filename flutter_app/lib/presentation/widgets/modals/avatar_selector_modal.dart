import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';

enum _ArmarioCategory {
  ropa,
  zapatos,
  accesorios,
}

/// ARMARIO DE SAMI (REDISEÑADO DESDE CERO)
/// Estudio boutique interactivo en tiempo real con prendas acopladas en 3D de alta definición,
/// simulación de compra instantánea, gestos táctiles, saludos animados y experiencia de lujo.
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
}

class _AvatarSelectorModalState extends ConsumerState<AvatarSelectorModal>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _tapBounceController;
  late AnimationController _waveController;

  bool _isWaving = false;
  String? _speechMessage;

  _ArmarioCategory _activeCategory = _ArmarioCategory.ropa;
  late SamiEquipment _equippedEquipment;
  late SamiEquipment _previewEquipment;
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  final List<String> _motivationalPhrases = [
    '¡Hola! 👋 ¡Este estilo me queda increíble!',
    '¡Ahorrar con estilo es otro nivel! ✨',
    '¡Listo para vencer cualquier gasto hormiga! 🛡️',
    '¡Cada peso que ahorras te acerca a tus sueños! 📈',
    '¡Pruébame lo que quieras del armario! 🪙',
  ];

  static bool isHeadAccessory(String id) {
    return id == 'acc_casco_astronauta' ||
        id == 'acc_gorra' ||
        id == 'acc_corona' ||
        id == 'acc_auriculares' ||
        id == 'acc_casco_cyberpunk' ||
        id == 'acc_casco_piloto';
  }

  @override
  void initState() {
    super.initState();
    _equippedEquipment = SamiEquipment.fromStorage(widget.currentAvatarId);
    _previewEquipment = _equippedEquipment;
    _selectedItem = WardrobeItem.getItem(_previewEquipment.clothingId);

    // Flotación sutil y natural
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Rebote elástico al tocar
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Saludo
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => _isWaving = false);
        }
      });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapBounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapSami() {
    AppHaptics.mediumImpact();
    _tapBounceController.forward(from: 0.0);
    _waveController.forward(from: 0.0);
    setState(() {
      _isWaving = true;
      final rand = math.Random().nextInt(_motivationalPhrases.length);
      _speechMessage = _motivationalPhrases[rand];
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted && _speechMessage != null) {
        setState(() => _speechMessage = null);
      }
    });
  }

  void _selectItem(WardrobeItem item) {
    AppHaptics.lightImpact();
    setState(() {
      _selectedItem = item;
      switch (item.category) {
        case WardrobeCategory.clothing:
          _previewEquipment = _previewEquipment.copyWith(clothingId: item.id);
          break;
        case WardrobeCategory.shoes:
          _previewEquipment = _previewEquipment.copyWith(shoesId: item.id);
          break;
        case WardrobeCategory.accessories:
          _previewEquipment = _previewEquipment.copyWith(accessoryId: item.id);
          break;
      }
    });
  }

  bool _isItemUnlocked(WardrobeItem item, List<String> unlockedItems) {
    if (item.isFree || item.cost == 0) return true;
    return unlockedItems.contains(item.id);
  }

  bool _isItemEquipped(WardrobeItem item) {
    switch (item.category) {
      case WardrobeCategory.clothing:
        return _equippedEquipment.clothingId == item.id;
      case WardrobeCategory.shoes:
        return _equippedEquipment.shoesId == item.id;
      case WardrobeCategory.accessories:
        return _equippedEquipment.accessoryId == item.id;
    }
  }

  Future<void> _handleEquipOrUnlock(WardrobeItem item) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isUnlocked = _isItemUnlocked(item, user.unlockedItems);

    if (isUnlocked) {
      AppHaptics.success();
      final storageString = _previewEquipment.toStorageString();
      setState(() {
        _equippedEquipment = _previewEquipment;
      });
      widget.onAvatarSelected(storageString);
      await ref.read(authProvider.notifier).equipAvatar(storageString);

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
                    '¡"${item.name}" equipado con éxito!',
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
      _showNotEnoughCoinsDialog(item, user.points);
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
        final storageString = _previewEquipment.toStorageString();
        setState(() {
          _equippedEquipment = _previewEquipment;
        });
        widget.onAvatarSelected(storageString);
        await ref.read(authProvider.notifier).equipAvatar(storageString);

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
                      '¡Desbloqueaste y equipaste "${item.name}"!',
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

  void _showNotEnoughCoinsDialog(WardrobeItem item, int currentPoints) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131E27),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF243645), width: 1.2),
        ),
        title: const Row(
          children: [
            Text('🪙', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              'Puntos Insuficientes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'Para desbloquear "${item.name}" necesitas ${item.cost} puntos.\n\nActualmente tienes $currentPoints puntos. ¡Sigue registrando tus gastos diarios y manteniendo tu racha con SAMI para acumular más puntos!',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<WardrobeItem> _getItemsForCategory(_ArmarioCategory cat) {
    switch (cat) {
      case _ArmarioCategory.ropa:
        return WardrobeItem.allItems
            .where((i) => i.category == WardrobeCategory.clothing)
            .toList();
      case _ArmarioCategory.zapatos:
        return WardrobeItem.allItems
            .where((i) => i.category == WardrobeCategory.shoes)
            .toList();
      case _ArmarioCategory.accesorios:
        return WardrobeItem.allItems
            .where((i) => i.category == WardrobeCategory.accessories)
            .toList();
    }
  }

  String _getSamiHeroAsset() {
    if (_isWaving && _previewEquipment.clothingId == 'ropa_clasica') {
      return 'assets/images/sami_3d_waving.png';
    }
    return SamiOutfit.getAssetForEquipment(_previewEquipment);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final activeItems = _getItemsForCategory(_activeCategory);
    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 3.2;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.08)
        : 1.0;

    final samiHeroAsset = _getSamiHeroAsset();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2D3B), width: 1.2),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF263747),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header de Lujo Boutique
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15222E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Armario de SAMI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estudio de personalización en vivo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Coins Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15222E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '$userCoins pts',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // =================================================================
          // 1. ESCENARIO CENTRAL DE PROBADOR (STUDIO MASCOT HERO STAGE)
          // =================================================================
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.95,
                  colors: [
                    _selectedItem.primaryColor.withValues(alpha: 0.20),
                    const Color(0xFF101B24),
                    const Color(0xFF0A0F15),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF1B2C3A), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spotlight Dais & Floor Reflection
                    Positioned(
                      bottom: 18,
                      child: Container(
                        width: 170,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedItem.primaryColor.withValues(alpha: 0.40),
                              blurRadius: 26,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.70),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live Simulation Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0F15).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles, color: Color(0xFF06B6D4), size: 12),
                            SizedBox(width: 5),
                            Text(
                              'Probador en Vivo',
                              style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Speech Bubble when Tapped
                    if (_speechMessage != null)
                      Positioned(
                        top: 20,
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 240),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _speechMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // SAMI Mascot Interactive Stage
                    GestureDetector(
                      onTap: _onTapSami,
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
                                width: 230,
                                height: 215,
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Real 3D Sculpted Mascot Outfit
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 220),
                                      child: Image.asset(
                                        samiHeroAsset,
                                        key: ValueKey(samiHeroAsset),
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),

                                    // 2. Seamless Tailored Accessories Overlay
                                    if (_previewEquipment.accessoryId != 'acc_ninguno' ||
                                        (_previewEquipment.clothingId == 'ropa_clasica' &&
                                            _previewEquipment.shoesId != 'zap_clasicos'))
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _TailoredAccessoryPainter(
                                            equipment: _previewEquipment,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom hint to tap
                    Positioned(
                      bottom: 8,
                      child: Text(
                        'Toca a SAMI para interactuar 👋',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.40),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =================================================================
          // 2. SELECTOR DE CATEGORÍAS (PILL BAR)
          // =================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF131D26),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E2D3B), width: 1),
              ),
              child: Row(
                children: [
                  _buildCategoryTab(
                    title: 'Ropa',
                    icon: LucideIcons.shirt,
                    category: _ArmarioCategory.ropa,
                  ),
                  _buildCategoryTab(
                    title: 'Zapatos',
                    icon: LucideIcons.footprints,
                    category: _ArmarioCategory.zapatos,
                  ),
                  _buildCategoryTab(
                    title: 'Accesorios',
                    icon: LucideIcons.sparkles,
                    category: _ArmarioCategory.accesorios,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // =================================================================
          // 3. RACK DE PRENDAS (HORIZONTAL BOUTIQUE CAROUSEL)
          // =================================================================
          Expanded(
            flex: 4,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: activeItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = activeItems[index];
                final isSelected = _selectedItem.id == item.id;
                final isEquipped = _isItemEquipped(item);
                final isUnlocked = _isItemUnlocked(item, unlockedList);

                return _BoutiqueItemCard(
                  item: item,
                  isSelected: isSelected,
                  isEquipped: isEquipped,
                  isUnlocked: isUnlocked,
                  onTap: () => _selectItem(item),
                );
              },
            ),
          ),

          // =================================================================
          // 4. BARRA DE ACCIÓN Y DETALLE (LUXURY FITTING DOCK)
          // =================================================================
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 4
                  : 18,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1722),
              border: Border(
                top: BorderSide(color: Color(0xFF1D2B38), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Info del Item Seleccionado
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedItem.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedItem.rarityColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedItem.rarityColor.withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              _selectedItem.rarity,
                              style: TextStyle(
                                color: _selectedItem.rarityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _selectedItem.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Botón Principal de Acción
                GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () => _handleEquipOrUnlock(_selectedItem),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isSelectedEquipped
                          ? const LinearGradient(
                              colors: [Color(0xFF1E2D3B), Color(0xFF1E2D3B)],
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
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Equipado',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ] else if (isSelectedUnlocked) ...[
                                const Icon(
                                  LucideIcons.shirt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Equipar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ] else ...[
                                const Text('🪙', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  '${_selectedItem.cost} pts',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String title,
    required IconData icon,
    required _ArmarioCategory category,
  }) {
    final isActive = _activeCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.lightImpact();
          setState(() {
            _activeCategory = category;
            final items = _getItemsForCategory(category);
            if (items.isNotEmpty) {
              _selectedItem = items.first;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF06B6D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BOUTIQUE ITEM CARD (Tarjetas de lujo en el rack del armario)
// =============================================================================
class _BoutiqueItemCard extends StatelessWidget {
  final WardrobeItem item;
  final bool isSelected;
  final bool isEquipped;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _BoutiqueItemCard({
    required this.item,
    required this.isSelected,
    required this.isEquipped,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF142433) : const Color(0xFF0F1821),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF1E2D3B),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji / Icon Avatar Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    item.primaryColor.withValues(alpha: 0.28),
                    item.secondaryColor.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                  color: item.rarityColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Item Name
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Badge (Equipado / Desbloqueado / Costo)
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'En uso',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Listo',
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
                    '${item.cost}',
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

// =============================================================================
// TAILORED ACCESSORY PAINTER (Para accesorios colocados con precisión sobre SAMI)
// =============================================================================
class _TailoredAccessoryPainter extends CustomPainter {
  final SamiEquipment equipment;

  _TailoredAccessoryPainter({required this.equipment});

  bool get _hasHeadItem =>
      _AvatarSelectorModalState.isHeadAccessory(equipment.accessoryId);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Si lleva casco o sombrero, ocultar limpiamente el brote cyan original de la cabeza
    if (_hasHeadItem) {
      _coverHeadSprout(canvas, w, h);
    }

    // Dibujar accesorios de cabeza y cuello
    _paintAccessory(canvas, w, h);

    // Si SAMI está en plumaje clásico y tiene calzado equipado, dibujar calzado ajustado
    if (equipment.clothingId == 'ropa_clasica' &&
        equipment.shoesId != 'zap_clasicos') {
      _paintFittedShoes(canvas, w, h);
    }
  }

  void _coverHeadSprout(Canvas canvas, double w, double h) {
    final sproutCenter = Offset(w * 0.50, h * 0.17);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        colors: const [
          Color(0xFF033554),
          Color(0xFF01243A),
          Color(0xFF001524),
        ],
      ).createShader(Rect.fromCircle(center: sproutCenter, radius: w * 0.18));

    canvas.drawOval(
      Rect.fromCenter(center: sproutCenter, width: w * 0.28, height: h * 0.15),
      domePaint,
    );
  }

  void _paintAccessory(Canvas canvas, double w, double h) {
    switch (equipment.accessoryId) {
      case 'acc_gorra':
        _drawCap(canvas, w, h);
        break;
      case 'acc_corona':
        _drawCrown(canvas, w, h);
        break;
      case 'acc_casco_astronauta':
        _drawAstronautHelmet(canvas, w, h);
        break;
      case 'acc_casco_cyberpunk':
        _drawCyberpunkVisor(canvas, w, h);
        break;
      case 'acc_bufanda_nordica':
        _drawScarf(canvas, w, h, const Color(0xFF0284C7), const Color(0xFFE0F2FE));
        break;
      case 'acc_bufanda_carmesi':
        _drawScarf(canvas, w, h, const Color(0xFFDC2626), const Color(0xFFFCA5A5));
        break;
      case 'acc_lentes_vip':
        _drawGlasses(canvas, w, h);
        break;
    }
  }

  void _drawCap(Canvas canvas, double w, double h) {
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.14));

    // Cúpula de la gorra
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.19), width: w * 0.38, height: h * 0.15),
      capPaint,
    );

    // Visera plana urbana
    final visorPath = Path();
    visorPath.moveTo(w * 0.30, h * 0.22);
    visorPath.quadraticBezierTo(w * 0.50, h * 0.19, w * 0.70, h * 0.22);
    visorPath.quadraticBezierTo(w * 0.50, h * 0.27, w * 0.30, h * 0.22);
    visorPath.close();

    final visorPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawPath(visorPath, visorPaint);
  }

  void _drawCrown(Canvas canvas, double w, double h) {
    final crownPath = Path();
    final y = h * 0.17;
    crownPath.moveTo(w * 0.36, y);
    crownPath.lineTo(w * 0.38, y - h * 0.08);
    crownPath.lineTo(w * 0.44, y - h * 0.03);
    crownPath.lineTo(w * 0.50, y - h * 0.10);
    crownPath.lineTo(w * 0.56, y - h * 0.03);
    crownPath.lineTo(w * 0.62, y - h * 0.08);
    crownPath.lineTo(w * 0.64, y);
    crownPath.close();

    final crownPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFD97706)],
      ).createShader(Rect.fromLTWH(w * 0.36, y - h * 0.10, w * 0.28, h * 0.10));

    canvas.drawPath(crownPath, crownPaint);

    // Gemas de rubí
    final rubyPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.50, y - h * 0.07), w * 0.018, rubyPaint);
  }

  void _drawAstronautHelmet(Canvas canvas, double w, double h) {
    final helmetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.62, height: h * 0.50),
      helmetPaint,
    );

    final visorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE082), Color(0xFFF59E0B), Color(0xFFB45309)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.32, w * 0.50, h * 0.26))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.52, height: h * 0.36),
      visorPaint,
    );
  }

  void _drawCyberpunkVisor(Canvas canvas, double w, double h) {
    final visorRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.46),
      width: w * 0.44,
      height: h * 0.08,
    );
    final visorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF06B6D4), Color(0xFF3B82F6)],
      ).createShader(visorRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(8)),
      visorPaint,
    );
  }

  void _drawScarf(Canvas canvas, double w, double h, Color primary, Color secondary) {
    final scarfPaint = Paint()
      ..shader = LinearGradient(
        colors: [primary, secondary],
      ).createShader(Rect.fromLTWH(w * 0.28, h * 0.57, w * 0.44, h * 0.12));

    final scarfPath = Path();
    scarfPath.moveTo(w * 0.30, h * 0.60);
    scarfPath.quadraticBezierTo(w * 0.50, h * 0.66, w * 0.70, h * 0.60);
    scarfPath.quadraticBezierTo(w * 0.73, h * 0.68, w * 0.68, h * 0.72);
    scarfPath.quadraticBezierTo(w * 0.50, h * 0.76, w * 0.32, h * 0.72);
    scarfPath.close();

    canvas.drawPath(scarfPath, scarfPaint);

    final tailPath = Path();
    tailPath.moveTo(w * 0.54, h * 0.70);
    tailPath.lineTo(w * 0.60, h * 0.84);
    tailPath.lineTo(w * 0.67, h * 0.83);
    tailPath.lineTo(w * 0.62, h * 0.69);
    tailPath.close();
    canvas.drawPath(tailPath, scarfPaint);
  }

  void _drawGlasses(Canvas canvas, double w, double h) {
    final glassesPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.41, h * 0.46), width: w * 0.13, height: h * 0.08),
        const Radius.circular(6),
      ),
      glassesPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.59, h * 0.46), width: w * 0.13, height: h * 0.08),
        const Radius.circular(6),
      ),
      glassesPaint,
    );

    final bridgePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.47, h * 0.46), Offset(w * 0.53, h * 0.46), bridgePaint);
  }

  void _paintFittedShoes(Canvas canvas, double w, double h) {
    final shoePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
      ).createShader(Rect.fromLTWH(0, h * 0.85, w, h * 0.10));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.36, h * 0.89), width: w * 0.16, height: h * 0.06),
        const Radius.circular(10),
      ),
      shoePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.64, h * 0.89), width: w * 0.16, height: h * 0.06),
        const Radius.circular(10),
      ),
      shoePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TailoredAccessoryPainter oldDelegate) {
    return oldDelegate.equipment != equipment;
  }
}
