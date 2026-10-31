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
  late AnimationController _blinkController;
  late AnimationController _tapBounceController;
  late AnimationController _waveController;

  bool _isBlinking = false;
  bool _isWaving = false;
  String? _speechMessage;

  _ArmarioCategory _activeCategory = _ArmarioCategory.ropa;
  late SamiEquipment _currentEquipment;
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  final List<String> _greetingPhrases = [
    '¡Hola! 👋 ¡Este estilo me queda increíble!',
    '¡Ahorrar con estilo es otro nivel! ✨',
    '¡Listo para registrar tus metas de hoy! 🚀',
    '¡Pruébame lo que quieras del armario! 🪙',
    '¡Cada peso que ahorras te acerca a tus sueños! 📈',
  ];

  static bool isHeadItem(String id) {
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
    _currentEquipment = SamiEquipment.fromStorage(widget.currentAvatarId);
    _selectedItem = WardrobeItem.getItem(_currentEquipment.clothingId);

    // Flotación sutil y natural
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Parpadeo de ojos
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => _isBlinking = true);
          Future.delayed(const Duration(milliseconds: 130), () {
            if (mounted) {
              setState(() => _isBlinking = false);
              _blinkController.forward(from: 0.0);
            }
          });
        }
      });
    _blinkController.forward();

    // Rebote elástico al tocar
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Saludo
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => _isWaving = false);
        }
      });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _blinkController.dispose();
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
      final rand = math.Random().nextInt(_greetingPhrases.length);
      _speechMessage = _greetingPhrases[rand];
    });

    Future.delayed(const Duration(seconds: 3), () {
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
          _currentEquipment = _currentEquipment.copyWith(clothingId: item.id);
          break;
        case WardrobeCategory.shoes:
          _currentEquipment = _currentEquipment.copyWith(shoesId: item.id);
          break;
        case WardrobeCategory.accessories:
          _currentEquipment = _currentEquipment.copyWith(accessoryId: item.id);
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
        return _currentEquipment.clothingId == item.id;
      case WardrobeCategory.shoes:
        return _currentEquipment.shoesId == item.id;
      case WardrobeCategory.accessories:
        return _currentEquipment.accessoryId == item.id;
    }
  }

  Future<void> _handleEquipOrUnlock(WardrobeItem item) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isUnlocked = _isItemUnlocked(item, user.unlockedItems);

    if (isUnlocked) {
      AppHaptics.success();
      final storageString = _currentEquipment.toStorageString();
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
                Text(item.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡"${item.name}" equipado en tu perfil!',
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
        final storageString = _currentEquipment.toStorageString();
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
                  const Text('🎉', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Desbloqueaste "${item.name}" por ${item.cost} 🪙!',
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

  List<WardrobeItem> _getItemsForActiveCategory() {
    switch (_activeCategory) {
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final activeItems = _getItemsForActiveCategory();
    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 2.8;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.06)
        : 1.0;

    final samiAsset = _isWaving
        ? 'assets/images/sami_3d_waving.png'
        : (_isBlinking
            ? 'assets/images/sami_3d_front.png'
            : 'assets/images/sami_3d_front_open.png');

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFF0B141C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF263847),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Armario de SAMI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Personaliza el estilo de tu compañero financiero',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Points pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162530),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        '$userCoins pts',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF162530),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // =================================================================
          // 1. ESPACIO CENTRAL DE PRESENTACIÓN (HERO CHARACTER STUDIO)
          // =================================================================
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 0.95,
                  colors: [
                    _selectedItem.primaryColor.withValues(alpha: 0.16),
                    const Color(0xFF101B24),
                    const Color(0xFF0B141C),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1B2D3B), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floor shadow dais
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 160,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.60),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SAMI Mascot (Interactive, Scaled, Organic)
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
                                width: 220,
                                height: 205,
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Mascot base image
                                    Image.asset(
                                      samiAsset,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),

                                    // Real Molded Clothing & Accessories
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _MoldedApparelSculptor(
                                          equipment: _currentEquipment,
                                          isWaving: _isWaving,
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

                    // Speech bubble when tapped
                    if (_speechMessage != null)
                      Positioned(
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F222F),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            _speechMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Status Pill (Top Left)
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelectedEquipped
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : (isSelectedUnlocked
                                  ? const Color(0xFF06B6D4).withValues(alpha: 0.18)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.18)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelectedEquipped
                                ? const Color(0xFF10B981)
                                : (isSelectedUnlocked
                                    ? const Color(0xFF06B6D4)
                                    : const Color(0xFFF59E0B)),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelectedEquipped
                                  ? LucideIcons.checkCircle
                                  : (isSelectedUnlocked
                                      ? LucideIcons.sparkles
                                      : LucideIcons.eye),
                              size: 11,
                              color: isSelectedEquipped
                                  ? const Color(0xFF10B981)
                                  : (isSelectedUnlocked
                                      ? const Color(0xFF06B6D4)
                                      : const Color(0xFFF59E0B)),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isSelectedEquipped
                                  ? 'Equipado'
                                  : (isSelectedUnlocked
                                      ? 'Desbloqueado'
                                      : 'Probador en Vivo'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isSelectedEquipped
                                    ? const Color(0xFF6EE7B7)
                                    : (isSelectedUnlocked
                                        ? const Color(0xFF67E8F9)
                                        : const Color(0xFFFFD54F)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tap hint (Bottom right)
                    Positioned(
                      bottom: 8,
                      right: 14,
                      child: Text(
                        'Toca a SAMI 👋',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // =================================================================
          // 2. CAJÓN DE ARMARIO: CATEGORÍAS + SWATCHES + ACCIÓN
          // =================================================================
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0E1821),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Segmented Category Tabs
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14222E),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        _buildCategoryTab(
                          label: 'Ropa',
                          emoji: '👕',
                          category: _ArmarioCategory.ropa,
                        ),
                        _buildCategoryTab(
                          label: 'Zapatos',
                          emoji: '👟',
                          category: _ArmarioCategory.zapatos,
                        ),
                        _buildCategoryTab(
                          label: 'Accesorios',
                          emoji: '✨',
                          category: _ArmarioCategory.accesorios,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Horizontal Swatch Carousel
                  SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: activeItems.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = activeItems[index];
                        final isSelected = _selectedItem.id == item.id;
                        final isEquipped = _isItemEquipped(item);
                        final isUnlocked = _isItemUnlocked(item, unlockedList);

                        return _buildSwatchToken(
                          item: item,
                          isSelected: isSelected,
                          isEquipped: isEquipped,
                          isUnlocked: isUnlocked,
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Selected Item Info & Primary CTA Action
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14222E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1E3142), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedItem.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedItem.rarityColor
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _selectedItem.rarity,
                                      style: TextStyle(
                                        color: _selectedItem.rarityColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedItem.subtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Primary Action Button
                        GestureDetector(
                          onTap: _isProcessing
                              ? null
                              : () => _handleEquipOrUnlock(_selectedItem),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelectedEquipped
                                  ? const Color(0xFF1B2C3B)
                                  : (isSelectedUnlocked
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelectedEquipped
                                            ? LucideIcons.check
                                            : (isSelectedUnlocked
                                                ? LucideIcons.sparkles
                                                : LucideIcons.unlock),
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isSelectedEquipped
                                            ? 'Equipado'
                                            : (isSelectedUnlocked
                                                ? 'Equipar'
                                                : '${_selectedItem.cost} 🪙'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required String emoji,
    required _ArmarioCategory category,
  }) {
    final isSelected = _activeCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.lightImpact();
          setState(() {
            _activeCategory = category;
            final items = _getItemsForActiveCategory();
            if (items.isNotEmpty) _selectedItem = items.first;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF06B6D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwatchToken({
    required WardrobeItem item,
    required bool isSelected,
    required bool isEquipped,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: () => _selectItem(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E3344)
                  : const Color(0xFF14222E),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF06B6D4)
                    : (isEquipped
                        ? const Color(0xFF10B981)
                        : const Color(0xFF233647)),
                width: isSelected ? 2.2 : 1.2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                if (isEquipped)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.check, size: 10, color: Colors.white),
                      ),
                    ),
                  )
                else if (!isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.lock, size: 9, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 60,
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOLDED 2D APPAREL SCULPTOR (Accurate Anatomical Coordinates)
// =============================================================================
class _MoldedApparelSculptor extends CustomPainter {
  final SamiEquipment equipment;
  final bool isWaving;

  _MoldedApparelSculptor({
    required this.equipment,
    required this.isWaving,
  });

  bool get _hasHeadAccessory =>
      _AvatarSelectorModalState.isHeadItem(equipment.accessoryId);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 0. Cubrir suavemente el brote cyan si lleva sombrero/casco
    if (_hasHeadAccessory) {
      _coverHeadSprout(canvas, w, h);
    }

    // 1. Capa de superhéroe trasera
    if (equipment.clothingId == 'ropa_superheroe') {
      _paintSuperheroCape(canvas, w, h);
    }

    // 2. Calzado moldeado a las patitas frontales
    _paintShoes(canvas, w, h);

    // 3. Ropa esculpida ceñida al vientre y hombros (comienza en h * 0.605 bajo barbilla)
    _paintClothing(canvas, w, h);

    // 4. Accesorios (Gafas, Bufanda, Gorra, Corona, Auriculares)
    _paintAccessories(canvas, w, h);
  }

  // Ocultar brote cyan de la cabeza
  void _coverHeadSprout(Canvas canvas, double w, double h) {
    final sproutCenter = Offset(w * 0.50, h * 0.17);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        colors: const [
          Color(0xFF023859),
          Color(0xFF012942),
          Color(0xFF00192A),
        ],
      ).createShader(Rect.fromCircle(center: sproutCenter, radius: w * 0.18));

    canvas.drawOval(
      Rect.fromCenter(center: sproutCenter, width: w * 0.28, height: h * 0.15),
      domePaint,
    );
  }

  // Capa trasera
  void _paintSuperheroCape(Canvas canvas, double w, double h) {
    final capePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(0, h * 0.50, w, h * 0.40));

    final leftWing = Path();
    leftWing.moveTo(w * 0.22, h * 0.60);
    leftWing.quadraticBezierTo(w * 0.10, h * 0.70, w * 0.13, h * 0.82);
    leftWing.quadraticBezierTo(w * 0.18, h * 0.76, w * 0.25, h * 0.68);
    leftWing.close();
    canvas.drawPath(leftWing, capePaint);

    final rightWing = Path();
    rightWing.moveTo(w * 0.78, h * 0.60);
    rightWing.quadraticBezierTo(w * 0.90, h * 0.70, w * 0.87, h * 0.82);
    rightWing.quadraticBezierTo(w * 0.82, h * 0.76, w * 0.75, h * 0.68);
    rightWing.close();
    canvas.drawPath(rightWing, capePaint);
  }

  // Calzado (patitas en w * 0.36 y w * 0.64, h * 0.88)
  void _paintShoes(Canvas canvas, double w, double h) {
    switch (equipment.shoesId) {
      case 'zap_sneakers':
        _drawSneaker(canvas, w * 0.36, h * 0.88, w * 0.15, h * 0.07, isLeft: true);
        _drawSneaker(canvas, w * 0.64, h * 0.88, w * 0.15, h * 0.07, isLeft: false);
        break;
      case 'zap_botas':
        _drawBoot(canvas, w * 0.36, h * 0.88, w * 0.15, h * 0.075);
        _drawBoot(canvas, w * 0.64, h * 0.88, w * 0.15, h * 0.075);
        break;
      case 'zap_charol':
        _drawDressShoe(canvas, w * 0.36, h * 0.88, w * 0.15, h * 0.07);
        _drawDressShoe(canvas, w * 0.64, h * 0.88, w * 0.15, h * 0.07);
        break;
      case 'zap_espaciales':
        _drawAntiGravShoe(canvas, w * 0.36, h * 0.88, w * 0.15, h * 0.075);
        _drawAntiGravShoe(canvas, w * 0.64, h * 0.88, w * 0.15, h * 0.075);
        break;
      case 'zap_dorados':
        _drawGoldSlippers(canvas, w * 0.36, h * 0.88, w * 0.15, h * 0.075);
        _drawGoldSlippers(canvas, w * 0.64, h * 0.88, w * 0.15, h * 0.075);
        break;
      case 'zap_clasicos':
      default:
        break;
    }
  }

  void _drawSneaker(Canvas canvas, double cx, double cy, double sw, double sh, {required bool isLeft}) {
    final shoeRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final upperPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(8)), upperPaint);

    final solePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shoeRect.left, shoeRect.bottom - sh * 0.35, sw, sh * 0.35),
        const Radius.circular(4),
      ),
      solePaint,
    );
  }

  void _drawBoot(Canvas canvas, double cx, double cy, double sw, double sh) {
    final bootRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final leatherPaint = Paint()..color = const Color(0xFF92400E);
    canvas.drawRRect(RRect.fromRectAndRadius(bootRect, const Radius.circular(8)), leatherPaint);

    final solePaint = Paint()..color = const Color(0xFF1E1B18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bootRect.left, bootRect.bottom - sh * 0.35, sw, sh * 0.35),
        const Radius.circular(4),
      ),
      solePaint,
    );
  }

  void _drawDressShoe(Canvas canvas, double cx, double cy, double sw, double sh) {
    final shoeRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final patentPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(8)), patentPaint);

    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(shoeRect.left + 4, shoeRect.top + 3),
      Offset(shoeRect.right - 4, shoeRect.top + 3),
      shinePaint,
    );
  }

  void _drawAntiGravShoe(Canvas canvas, double cx, double cy, double sw, double sh) {
    final shoeRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final shoePaint = Paint()..color = const Color(0xFF7C3AED);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(8)), shoePaint);

    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(shoeRect.left + 2, shoeRect.bottom - 1),
      Offset(shoeRect.right - 2, shoeRect.bottom - 1),
      glowPaint,
    );
  }

  void _drawGoldSlippers(Canvas canvas, double cx, double cy, double sw, double sh) {
    final shoeRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final goldPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(8)), goldPaint);
  }

  // Ropa (empieza naturalmente en h * 0.605 bajo barbilla sin tapar el rostro)
  void _paintClothing(Canvas canvas, double w, double h) {
    switch (equipment.clothingId) {
      case 'ropa_ejecutivo':
        _paintExecutiveSuit(canvas, w, h);
        break;
      case 'ropa_sudadera':
        _paintStreetwearHoodie(canvas, w, h);
        break;
      case 'ropa_superheroe':
        _paintSuperheroSuit(canvas, w, h);
        break;
      case 'ropa_chef':
        _paintChefCoat(canvas, w, h);
        break;
      case 'ropa_armadura':
        _paintGalacticArmor(canvas, w, h);
        break;
      case 'ropa_deportiva':
        _paintAthleticJersey(canvas, w, h);
        break;
      case 'ropa_toga':
        _paintImperialToga(canvas, w, h);
        break;
      case 'ropa_clasica':
      default:
        break;
    }
  }

  void _paintExecutiveSuit(Canvas canvas, double w, double h) {
    final suitPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.605, w * 0.50, h * 0.24));

    final suitPath = Path();
    suitPath.moveTo(w * 0.30, h * 0.605);
    suitPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    suitPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    suitPath.close();
    canvas.drawPath(suitPath, suitPaint);

    // Camisa blanca
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path();
    shirtPath.moveTo(w * 0.42, h * 0.61);
    shirtPath.lineTo(w * 0.50, h * 0.72);
    shirtPath.lineTo(w * 0.58, h * 0.61);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Corbata roja
    final tiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.47, h * 0.62, w * 0.06, h * 0.16));

    final tiePath = Path();
    tiePath.moveTo(w * 0.48, h * 0.62);
    tiePath.lineTo(w * 0.52, h * 0.62);
    tiePath.lineTo(w * 0.53, h * 0.75);
    tiePath.lineTo(w * 0.50, h * 0.79);
    tiePath.lineTo(w * 0.47, h * 0.75);
    tiePath.close();
    canvas.drawPath(tiePath, tiePaint);

    // Clip dorado
    final clipPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.475, h * 0.69, w * 0.05, h * 0.012),
        const Radius.circular(2),
      ),
      clipPaint,
    );
  }

  void _paintStreetwearHoodie(Canvas canvas, double w, double h) {
    final hoodiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.605, w * 0.50, h * 0.24));

    final hoodiePath = Path();
    hoodiePath.moveTo(w * 0.30, h * 0.605);
    hoodiePath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    hoodiePath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    hoodiePath.close();
    canvas.drawPath(hoodiePath, hoodiePaint);

    // Bolsillo canguro
    final pocketPaint = Paint()..color = const Color(0xFF075985);
    final pocketPath = Path();
    pocketPath.moveTo(w * 0.36, h * 0.73);
    pocketPath.lineTo(w * 0.64, h * 0.73);
    pocketPath.lineTo(w * 0.66, h * 0.82);
    pocketPath.lineTo(w * 0.34, h * 0.82);
    pocketPath.close();
    canvas.drawPath(pocketPath, pocketPaint);

    // Cordones
    final stringPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.63), Offset(w * 0.43, h * 0.70), stringPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.63), Offset(w * 0.57, h * 0.70), stringPaint);
  }

  void _paintSuperheroSuit(Canvas canvas, double w, double h) {
    final heroPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.605, w * 0.50, h * 0.24));

    final heroPath = Path();
    heroPath.moveTo(w * 0.30, h * 0.605);
    heroPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    heroPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    heroPath.close();
    canvas.drawPath(heroPath, heroPaint);

    // Cinturón dorado
    final beltPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.76, w * 0.32, h * 0.04),
        const Radius.circular(4),
      ),
      beltPaint,
    );
  }

  void _paintChefCoat(Canvas canvas, double w, double h) {
    final coatPaint = Paint()..color = Colors.white;
    final coatPath = Path();
    coatPath.moveTo(w * 0.30, h * 0.605);
    coatPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    coatPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    coatPath.close();
    canvas.drawPath(coatPath, coatPaint);

    // Botones dorados de chef
    final buttonPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(Offset(w * 0.44, h * 0.67), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.67), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.44, h * 0.73), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.73), 2.5, buttonPaint);
  }

  void _paintGalacticArmor(Canvas canvas, double w, double h) {
    final armorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF475569), Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.605, w * 0.50, h * 0.24));

    final armorPath = Path();
    armorPath.moveTo(w * 0.30, h * 0.605);
    armorPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    armorPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    armorPath.close();
    canvas.drawPath(armorPath, armorPaint);

    // Reactor central cyan
    final corePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(w * 0.50, h * 0.71), 4.5, corePaint);
  }

  void _paintAthleticJersey(Canvas canvas, double w, double h) {
    final jerseyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D9488), Color(0xFF115E59)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.605, w * 0.50, h * 0.24));

    final jerseyPath = Path();
    jerseyPath.moveTo(w * 0.30, h * 0.605);
    jerseyPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.84);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.75, h * 0.84);
    jerseyPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.605);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.64, w * 0.30, h * 0.605);
    jerseyPath.close();
    canvas.drawPath(jerseyPath, jerseyPaint);

    // Rayas blancas deportivas
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.34, h * 0.65), Offset(w * 0.33, h * 0.82), stripePaint);
    canvas.drawLine(Offset(w * 0.66, h * 0.65), Offset(w * 0.67, h * 0.82), stripePaint);
  }

  void _paintImperialToga(Canvas canvas, double w, double h) {
    final togaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD97706), Color(0xFF78350F)],
      ).createShader(Rect.fromLTWH(w * 0.26, h * 0.605, w * 0.48, h * 0.24));

    final togaPath = Path();
    togaPath.moveTo(w * 0.30, h * 0.605);
    togaPath.lineTo(w * 0.70, h * 0.74);
    togaPath.quadraticBezierTo(w * 0.65, h * 0.85, w * 0.50, h * 0.87);
    togaPath.quadraticBezierTo(w * 0.28, h * 0.84, w * 0.26, h * 0.73);
    togaPath.close();
    canvas.drawPath(togaPath, togaPaint);
  }

  // Accesorios
  void _paintAccessories(Canvas canvas, double w, double h) {
    switch (equipment.accessoryId) {
      case 'acc_bufanda_nordica':
        _paintScarf(canvas, w, h, const Color(0xFF0284C7));
        break;
      case 'acc_bufanda_carmesi':
        _paintScarf(canvas, w, h, const Color(0xFFDC2626));
        break;
      case 'acc_gorra':
        _paintSnapbackCap(canvas, w, h);
        break;
      case 'acc_corona':
        _paintCrown(canvas, w, h);
        break;
      case 'acc_auriculares':
        _paintHeadphones(canvas, w, h);
        break;
      case 'acc_lentes_vip':
        _paintSunglasses(canvas, w, h);
        break;
      case 'acc_casco_astronauta':
        _paintAstronautHelmet(canvas, w, h);
        break;
      case 'acc_casco_cyberpunk':
        _paintCyberpunkVisor(canvas, w, h);
        break;
      case 'acc_casco_piloto':
        _paintPilotHelmet(canvas, w, h);
        break;
      case 'acc_ninguno':
      default:
        break;
    }
  }

  void _paintScarf(Canvas canvas, double w, double h, Color scarfColor) {
    final scarfPaint = Paint()..color = scarfColor;
    final neckRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.61),
      width: w * 0.44,
      height: h * 0.075,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, const Radius.circular(10)), scarfPaint);

    final tailPath = Path();
    tailPath.moveTo(w * 0.36, h * 0.63);
    tailPath.lineTo(w * 0.33, h * 0.76);
    tailPath.lineTo(w * 0.41, h * 0.76);
    tailPath.lineTo(w * 0.42, h * 0.63);
    tailPath.close();
    canvas.drawPath(tailPath, scarfPaint);
  }

  void _paintSnapbackCap(Canvas canvas, double w, double h) {
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.16, w * 0.36, h * 0.14));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.20), width: w * 0.36, height: h * 0.12),
      capPaint,
    );

    final visorPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.36, h * 0.035),
        const Radius.circular(6),
      ),
      visorPaint,
    );

    final buttonPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawCircle(Offset(w * 0.50, h * 0.15), 3.0, buttonPaint);
  }

  void _paintCrown(Canvas canvas, double w, double h) {
    final crownPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD54F), Color(0xFFF59E0B)],
      ).createShader(Rect.fromLTWH(w * 0.36, h * 0.14, w * 0.28, h * 0.12));

    final crownPath = Path();
    crownPath.moveTo(w * 0.36, h * 0.23);
    crownPath.lineTo(w * 0.36, h * 0.14);
    crownPath.lineTo(w * 0.43, h * 0.19);
    crownPath.lineTo(w * 0.50, h * 0.12);
    crownPath.lineTo(w * 0.57, h * 0.19);
    crownPath.lineTo(w * 0.64, h * 0.14);
    crownPath.lineTo(w * 0.64, h * 0.23);
    crownPath.close();
    canvas.drawPath(crownPath, crownPaint);

    final gemPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.36, h * 0.14), 2.5, gemPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), 3.0, gemPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.14), 2.5, gemPaint);
  }

  void _paintHeadphones(Canvas canvas, double w, double h) {
    final bandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final bandPath = Path();
    bandPath.moveTo(w * 0.26, h * 0.40);
    bandPath.quadraticBezierTo(w * 0.50, h * 0.14, w * 0.74, h * 0.40);
    canvas.drawPath(bandPath, bandPaint);

    final padPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.25, h * 0.42), width: w * 0.08, height: h * 0.10),
        const Radius.circular(6),
      ),
      padPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.75, h * 0.42), width: w * 0.08, height: h * 0.10),
        const Radius.circular(6),
      ),
      padPaint,
    );
  }

  void _paintSunglasses(Canvas canvas, double w, double h) {
    final glassesPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(w * 0.33, h * 0.44, w * 0.34, h * 0.08));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.44, w * 0.14, h * 0.075),
        const Radius.circular(6),
      ),
      glassesPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.52, h * 0.44, w * 0.14, h * 0.075),
        const Radius.circular(6),
      ),
      glassesPaint,
    );

    final bridgePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.48, h * 0.46), Offset(w * 0.52, h * 0.46), bridgePaint);
  }

  void _paintAstronautHelmet(Canvas canvas, double w, double h) {
    final helmetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.32, helmetPaint);

    final visorPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.45),
          const Color(0xFFF59E0B).withValues(alpha: 0.20),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.40), radius: w * 0.28));
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.30, visorPaint);
  }

  void _paintCyberpunkVisor(Canvas canvas, double w, double h) {
    final visorPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.46), width: w * 0.44, height: h * 0.05),
        const Radius.circular(4),
      ),
      visorPaint,
    );
  }

  void _paintPilotHelmet(Canvas canvas, double w, double h) {
    final leatherPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.20), width: w * 0.38, height: h * 0.14),
      leatherPaint,
    );

    final gogglePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(Offset(w * 0.44, h * 0.24), 6, gogglePaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.24), 6, gogglePaint);
  }

  @override
  bool shouldRepaint(covariant _MoldedApparelSculptor oldDelegate) {
    return oldDelegate.equipment != equipment || oldDelegate.isWaving != isWaving;
  }
}
