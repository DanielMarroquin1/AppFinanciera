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
  // Animación suave de respiración / flotación de SAMI
  late AnimationController _idleController;

  // Animación de parpadeo natural de ojos
  late AnimationController _blinkController;
  bool _isBlinking = false;

  // Animación de saludo y rebote al tocar a SAMI
  late AnimationController _tapBounceController;
  late AnimationController _waveController;
  bool _isWaving = false;
  String? _speechMessage;

  // Categoría activa en el armario
  _ArmarioCategory _activeCategory = _ArmarioCategory.ropa;

  // Equipamiento actual en vista previa (Simulador en vivo)
  late SamiEquipment _currentEquipment;

  // Ítem actualmente seleccionado en la cuadrícula
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  final List<String> _greetingPhrases = [
    '¡Hola! 👋 ¡Qué bien me veo con este estilo!',
    '¡Me encanta cómo me queda! ✨',
    '¡Listo para ahorrar juntos! 🚀',
    '¡Ahorrar con estilo es otro nivel! 🪙',
    '¡Cada peso ahorrado te acerca a tus sueños! 📈',
    '¡Pruébame lo que quieras de la tienda! 🛍️',
  ];

  static bool _isHeadItem(String id) {
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

    // 1. Idle Controller: Flotación suave y natural
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 2. Blink Controller: Parpadeo de ojos cada 4 segundos
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => _isBlinking = true);
          Future.delayed(const Duration(milliseconds: 140), () {
            if (mounted) {
              setState(() => _isBlinking = false);
              _blinkController.forward(from: 0.0);
            }
          });
        }
      });
    _blinkController.forward();

    // 3. Tap Bounce Controller: Rebote elástico
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // 4. Wave Controller: Saludo interactivo
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
      final randIndex = math.Random().nextInt(_greetingPhrases.length);
      _speechMessage = _greetingPhrases[randIndex];
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
        backgroundColor: const Color(0xFF131F24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF263843), width: 1.5),
        ),
        title: const Row(
          children: [
            Text('🪙', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Text(
              'Puntos Insuficientes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Para desbloquear "${item.name}" necesitas ${item.cost} puntos.\n\nActualmente tienes $currentPoints puntos. ¡Sigue registrando tus gastos diarios y manteniendo tu racha con SAMI para ganar más!',
          style: const TextStyle(
            color: Color(0xFFD6E2E8),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFF00E5FF),
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

    final floatY = math.sin(_idleController.value * math.pi) * 3.0;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.08)
        : 1.0;

    // Asset frontal 2D de SAMI (con ojos abiertos o saludo)
    final samiFrontAsset = _isWaving
        ? 'assets/images/sami_3d_waving.png'
        : (_isBlinking
            ? 'assets/images/sami_3d_front.png'
            : 'assets/images/sami_3d_front_open.png');

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF091217),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF1B313E), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Drag handle superior
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF263D4C),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header: Título + Saldo de Puntos + Botón Cerrar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Armario de SAMI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('✨', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Prueba y personaliza ropa, calzado y accesorios',
                      style: TextStyle(
                        color: Color(0xFF869FAE),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Saldo de puntos/monedas
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162732),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '$userCoins',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16252E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Color(0xFF8BA0AE),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =================================================================
          // ESCENARIO MINIMALISTA Y REAL DE SAMI (SHOWCASE FITTING SUITE)
          // =================================================================
          Container(
            height: 210,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 0.95,
                colors: [
                  _selectedItem.primaryColor.withValues(alpha: 0.22),
                  const Color(0xFF0F1E27),
                  const Color(0xFF0A141A),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF1F3847), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient warm glow spotlight
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _selectedItem.primaryColor.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Minimalist glowing reflection pedestal
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 150,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00E5FF).withValues(alpha: 0.8),
                            _selectedItem.primaryColor.withValues(alpha: 0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.40),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 144,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF09141B),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SAMI Mascot: Interactive, Animated & Responsive
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
                              width: 175,
                              height: 165,
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // Base Character (Crisp 2D illustration)
                                  Image.asset(
                                    samiFrontAsset,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),

                                  // Beautiful, Sculpted Clothing & Accessories Layer
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _SamiApparelSculptor(
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

                  // Speech Bubble when tapped or greeting
                  if (_speechMessage != null)
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        constraints: const BoxConstraints(maxWidth: 270),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2432),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.30),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          _speechMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Top Pill: Simulation indicator or Equipped badge
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelectedEquipped
                            ? const Color(0xFF10B981).withValues(alpha: 0.20)
                            : (isSelectedUnlocked
                                ? const Color(0xFF00E5FF).withValues(alpha: 0.20)
                                : const Color(0xFFFFB300).withValues(alpha: 0.20)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelectedEquipped
                              ? const Color(0xFF10B981)
                              : (isSelectedUnlocked
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFFFFB300)),
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
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFFFFB300)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isSelectedEquipped
                                ? 'Equipado'
                                : (isSelectedUnlocked
                                    ? 'Listo'
                                    : 'Probador en Vivo'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSelectedEquipped
                                  ? const Color(0xFF6EE7B7)
                                  : (isSelectedUnlocked
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFFFFD54F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Hint: "Toca a SAMI para interactuar"
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Text(
                      'Toca a SAMI 👋',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF869FAE).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // =================================================================
          // CATEGORY SELECTOR PILLS: 👕 Ropa | 👟 Zapatos | ✨ Accesorios
          // =================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF121F28),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF223847), width: 1.2),
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
          ),

          const SizedBox(height: 12),

          // =================================================================
          // ITEMS GRID: Minimalist luxury cards
          // =================================================================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.72,
              ),
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                final isSelected = _selectedItem.id == item.id;
                final isEquipped = _isItemEquipped(item);
                final isUnlocked = _isItemUnlocked(item, unlockedList);

                return _buildWardrobeCard(
                  item: item,
                  isSelected: isSelected,
                  isEquipped: isEquipped,
                  isUnlocked: isUnlocked,
                );
              },
            ),
          ),

          // =================================================================
          // BOTTOM ACTION DOCK: Primary Action CTA
          // =================================================================
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1A22),
                border: const Border(
                  top: BorderSide(color: Color(0xFF1C313E), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Item Info Summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedItem.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedItem.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF869FAE),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Action Button: Equip / Buy / Already Equipped
                  GestureDetector(
                    onTap: _isProcessing
                        ? null
                        : () => _handleEquipOrUnlock(_selectedItem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelectedEquipped
                            ? const LinearGradient(
                                colors: [Color(0xFF162934), Color(0xFF162934)],
                              )
                            : (isSelectedUnlocked
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF06B6D4),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFF59E0B),
                                      Color(0xFFD97706),
                                    ],
                                  )),
                        borderRadius: BorderRadius.circular(18),
                        border: isSelectedEquipped
                            ? Border.all(color: const Color(0xFF264051), width: 1.2)
                            : null,
                        boxShadow: isSelectedEquipped
                            ? null
                            : [
                                BoxShadow(
                                  color: (isSelectedUnlocked
                                          ? const Color(0xFF06B6D4)
                                          : const Color(0xFFF59E0B))
                                      .withValues(alpha: 0.4),
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
                                Icon(
                                  isSelectedEquipped
                                      ? LucideIcons.check
                                      : (isSelectedUnlocked
                                          ? LucideIcons.sparkles
                                          : LucideIcons.unlock),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSelectedEquipped
                                      ? 'Equipado'
                                      : (isSelectedUnlocked
                                          ? 'Guardar Estilo'
                                          : 'Canjear ${_selectedItem.cost} 🪙'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
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
            if (items.isNotEmpty) {
              _selectedItem = items.first;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF051722) : const Color(0xFF869FAE),
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWardrobeCard({
    required WardrobeItem item,
    required bool isSelected,
    required bool isEquipped,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: () => _selectItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF162934)
              : const Color(0xFF0F1B23),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF)
                : (isEquipped
                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                    : const Color(0xFF1F3543)),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji / Icon Circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.primaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.rarityColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 9),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Price / Status Badge
                  if (isEquipped)
                    const Text(
                      '✓ Equipado',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    )
                  else if (isUnlocked)
                    const Text(
                      'Desbloqueado',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38BDF8),
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.lock,
                          size: 9,
                          color: Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.cost} 🪙',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFD54F),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SCULPTED 2D APPAREL PAINTER (Real, Organic, Minimalist, Beautiful)
// =============================================================================
class _SamiApparelSculptor extends CustomPainter {
  final SamiEquipment equipment;
  final bool isWaving;

  _SamiApparelSculptor({
    required this.equipment,
    required this.isWaving,
  });

  bool get _hasHeadAccessory =>
      _AvatarSelectorModalState._isHeadItem(equipment.accessoryId);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 0. Si tiene accesorio en la cabeza, RETIRAR EL PELO (cubriendo suavemente el brote cyan)
    if (_hasHeadAccessory) {
      _coverHeadSprout(canvas, w, h);
    }

    // 1. Capa de superhéroe trasera (si está equipada)
    if (equipment.clothingId == 'ropa_superheroe') {
      _paintSuperheroCape(canvas, w, h);
    }

    // 2. Calzado adaptado a las patitas frontales de SAMI
    _paintShoes(canvas, w, h);

    // 3. Ropa esculpida ceñida a los contornos de SAMI
    _paintClothing(canvas, w, h);

    // 4. Accesorios (Bufandas, Gafas, Cascos, Gorra, Corona, Auriculares)
    _paintAccessories(canvas, w, h);
  }

  // ---------------------------------------------------------------------------
  // 0. OCULTAR EL PELO / BROTE CYAN CON SUAVE COBERTURA DE COLOR CABEZA
  // ---------------------------------------------------------------------------
  void _coverHeadSprout(Canvas canvas, double w, double h) {
    final sproutCenter = Offset(w * 0.50, h * 0.18);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        colors: const [
          Color(0xFF023859),
          Color(0xFF012942),
          Color(0xFF00192A),
        ],
      ).createShader(Rect.fromCircle(center: sproutCenter, radius: w * 0.20));

    canvas.drawOval(
      Rect.fromCenter(center: sproutCenter, width: w * 0.32, height: h * 0.16),
      domePaint,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. CAPA DE SUPERHÉROE TRASERA
  // ---------------------------------------------------------------------------
  void _paintSuperheroCape(Canvas canvas, double w, double h) {
    final capePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(0, h * 0.50, w, h * 0.40));

    final leftWing = Path();
    leftWing.moveTo(w * 0.20, h * 0.60);
    leftWing.quadraticBezierTo(w * 0.08, h * 0.70, w * 0.12, h * 0.82);
    leftWing.quadraticBezierTo(w * 0.18, h * 0.76, w * 0.24, h * 0.68);
    leftWing.close();
    canvas.drawPath(leftWing, capePaint);

    final rightWing = Path();
    rightWing.moveTo(w * 0.80, h * 0.60);
    rightWing.quadraticBezierTo(w * 0.92, h * 0.70, w * 0.88, h * 0.82);
    rightWing.quadraticBezierTo(w * 0.82, h * 0.76, w * 0.76, h * 0.68);
    rightWing.close();
    canvas.drawPath(rightWing, capePaint);
  }

  // ---------------------------------------------------------------------------
  // 2. CALZADO (Pies de SAMI en w * 0.35 y w * 0.65, h * 0.88 a 0.96)
  // ---------------------------------------------------------------------------
  void _paintShoes(Canvas canvas, double w, double h) {
    switch (equipment.shoesId) {
      case 'zap_sneakers':
        _drawSneaker(canvas, w * 0.35, h * 0.91, w * 0.14, h * 0.07, isLeft: true);
        _drawSneaker(canvas, w * 0.65, h * 0.91, w * 0.14, h * 0.07, isLeft: false);
        break;
      case 'zap_botas':
        _drawBoot(canvas, w * 0.35, h * 0.91, w * 0.15, h * 0.075, const Color(0xFF92400E));
        _drawBoot(canvas, w * 0.65, h * 0.91, w * 0.15, h * 0.075, const Color(0xFF92400E));
        break;
      case 'zap_charol':
        _drawDressShoe(canvas, w * 0.35, h * 0.91, w * 0.15, h * 0.07);
        _drawDressShoe(canvas, w * 0.65, h * 0.91, w * 0.15, h * 0.07);
        break;
      case 'zap_espaciales':
        _drawAntiGravShoe(canvas, w * 0.35, h * 0.91, w * 0.15, h * 0.075);
        _drawAntiGravShoe(canvas, w * 0.65, h * 0.91, w * 0.15, h * 0.075);
        break;
      case 'zap_dorados':
        _drawGoldSlippers(canvas, w * 0.35, h * 0.91, w * 0.15, h * 0.075);
        _drawGoldSlippers(canvas, w * 0.65, h * 0.91, w * 0.15, h * 0.075);
        break;
      case 'zap_clasicos':
      default:
        // Patitas naturales de SAMI
        break;
    }
  }

  void _drawSneaker(Canvas canvas, double cx, double cy, double sw, double sh, {required bool isLeft}) {
    final shoeRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    // Cyan Sneaker Upper
    final upperPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(8)), upperPaint);
    // White Sole
    final solePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shoeRect.left, shoeRect.bottom - sh * 0.35, sw, sh * 0.35),
        const Radius.circular(4),
      ),
      solePaint,
    );
    // LED Glow line
    final ledPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(shoeRect.left + 2, shoeRect.bottom - 2),
      Offset(shoeRect.right - 2, shoeRect.bottom - 2),
      ledPaint,
    );
  }

  void _drawBoot(Canvas canvas, double cx, double cy, double sw, double sh, Color bootColor) {
    final bootRect = Rect.fromCenter(center: Offset(cx, cy), width: sw, height: sh);
    final leatherPaint = Paint()..color = bootColor;
    canvas.drawRRect(RRect.fromRectAndRadius(bootRect, const Radius.circular(8)), leatherPaint);
    // Dark Sole
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
    // Specular shine line
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
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
    // Anti-gravity neon glow
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
    // Star emblem
    final starPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 2.5, starPaint);
  }

  // ---------------------------------------------------------------------------
  // 3. ROPA (Ceñida al cuerpo, empieza naturalmente en h * 0.62 bajo la barbilla)
  // ---------------------------------------------------------------------------
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
        // Plumaje natural de SAMI (sin ropa)
        break;
    }
  }

  void _paintExecutiveSuit(Canvas canvas, double w, double h) {
    // Saco formal azul marino curvado con solapa
    final suitPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(w * 0.26, h * 0.62, w * 0.48, h * 0.24));

    final suitPath = Path();
    suitPath.moveTo(w * 0.32, h * 0.62);
    suitPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    suitPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.68, h * 0.62);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.66, w * 0.32, h * 0.62);
    suitPath.close();
    canvas.drawPath(suitPath, suitPaint);

    // Camisa blanca en 'V'
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path();
    shirtPath.moveTo(w * 0.42, h * 0.63);
    shirtPath.lineTo(w * 0.50, h * 0.73);
    shirtPath.lineTo(w * 0.58, h * 0.63);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Corbata de seda roja
    final tiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.47, h * 0.64, w * 0.06, h * 0.16));

    final tiePath = Path();
    tiePath.moveTo(w * 0.48, h * 0.64);
    tiePath.lineTo(w * 0.52, h * 0.64);
    tiePath.lineTo(w * 0.53, h * 0.76);
    tiePath.lineTo(w * 0.50, h * 0.80);
    tiePath.lineTo(w * 0.47, h * 0.76);
    tiePath.close();
    canvas.drawPath(tiePath, tiePaint);

    // Clip dorado
    final clipPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.475, h * 0.70, w * 0.05, h * 0.012),
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
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.62, w * 0.50, h * 0.24));

    final hoodiePath = Path();
    hoodiePath.moveTo(w * 0.30, h * 0.62);
    hoodiePath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    hoodiePath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.62);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.30, h * 0.62);
    hoodiePath.close();
    canvas.drawPath(hoodiePath, hoodiePaint);

    // Bolsillo canguro
    final pocketPaint = Paint()..color = const Color(0xFF075985);
    final pocketPath = Path();
    pocketPath.moveTo(w * 0.36, h * 0.74);
    pocketPath.lineTo(w * 0.64, h * 0.74);
    pocketPath.lineTo(w * 0.66, h * 0.83);
    pocketPath.lineTo(w * 0.34, h * 0.83);
    pocketPath.close();
    canvas.drawPath(pocketPath, pocketPaint);

    // Cordones de la sudadera
    final stringPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.64), Offset(w * 0.43, h * 0.71), stringPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.64), Offset(w * 0.57, h * 0.71), stringPaint);
  }

  void _paintSuperheroSuit(Canvas canvas, double w, double h) {
    final heroPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.26, h * 0.62, w * 0.48, h * 0.24));

    final heroPath = Path();
    heroPath.moveTo(w * 0.30, h * 0.62);
    heroPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    heroPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.62);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.30, h * 0.62);
    heroPath.close();
    canvas.drawPath(heroPath, heroPaint);

    // Cinturón dorado de superhéroe
    final beltPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.77, w * 0.32, h * 0.04),
        const Radius.circular(4),
      ),
      beltPaint,
    );
  }

  void _paintChefCoat(Canvas canvas, double w, double h) {
    final coatPaint = Paint()..color = Colors.white;
    final coatPath = Path();
    coatPath.moveTo(w * 0.30, h * 0.62);
    coatPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    coatPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.62);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.30, h * 0.62);
    coatPath.close();
    canvas.drawPath(coatPath, coatPaint);

    // Botones dobles de chef
    final buttonPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(Offset(w * 0.44, h * 0.68), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.68), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.44, h * 0.74), 2.5, buttonPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.74), 2.5, buttonPaint);
  }

  void _paintGalacticArmor(Canvas canvas, double w, double h) {
    final armorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF475569), Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.62, w * 0.50, h * 0.24));

    final armorPath = Path();
    armorPath.moveTo(w * 0.30, h * 0.62);
    armorPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    armorPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.62);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.30, h * 0.62);
    armorPath.close();
    canvas.drawPath(armorPath, armorPaint);

    // Reactor central cyan
    final corePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(w * 0.50, h * 0.72), 5.0, corePaint);
  }

  void _paintAthleticJersey(Canvas canvas, double w, double h) {
    final jerseyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D9488), Color(0xFF115E59)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.62, w * 0.50, h * 0.24));

    final jerseyPath = Path();
    jerseyPath.moveTo(w * 0.30, h * 0.62);
    jerseyPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.25, h * 0.85);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.75, h * 0.85);
    jerseyPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.70, h * 0.62);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.30, h * 0.62);
    jerseyPath.close();
    canvas.drawPath(jerseyPath, jerseyPaint);

    // Rayas blancas deportivas laterales
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.34, h * 0.66), Offset(w * 0.33, h * 0.83), stripePaint);
    canvas.drawLine(Offset(w * 0.66, h * 0.66), Offset(w * 0.67, h * 0.83), stripePaint);
  }

  void _paintImperialToga(Canvas canvas, double w, double h) {
    final togaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD97706), Color(0xFF78350F)],
      ).createShader(Rect.fromLTWH(w * 0.26, h * 0.62, w * 0.48, h * 0.24));

    final togaPath = Path();
    togaPath.moveTo(w * 0.30, h * 0.62);
    togaPath.lineTo(w * 0.70, h * 0.75);
    togaPath.quadraticBezierTo(w * 0.65, h * 0.86, w * 0.50, h * 0.88);
    togaPath.quadraticBezierTo(w * 0.28, h * 0.85, w * 0.26, h * 0.74);
    togaPath.close();
    canvas.drawPath(togaPath, togaPaint);
  }

  // ---------------------------------------------------------------------------
  // 4. ACCESORIOS (Bufandas, Gafas, Gorra, Corona, Auriculares, Cascos)
  // ---------------------------------------------------------------------------
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
    // Cuello de la bufanda
    final neckRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.62),
      width: w * 0.44,
      height: h * 0.08,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, const Radius.circular(12)), scarfPaint);

    // Caída lateral de la bufanda
    final tailPath = Path();
    tailPath.moveTo(w * 0.36, h * 0.64);
    tailPath.lineTo(w * 0.33, h * 0.78);
    tailPath.lineTo(w * 0.41, h * 0.78);
    tailPath.lineTo(w * 0.42, h * 0.64);
    tailPath.close();
    canvas.drawPath(tailPath, scarfPaint);
  }

  void _paintSnapbackCap(Canvas canvas, double w, double h) {
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.16, w * 0.36, h * 0.14));

    // Corona de la gorra
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.20), width: w * 0.36, height: h * 0.12),
      capPaint,
    );

    // Visera plana que sobresale
    final visorPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.36, h * 0.035),
        const Radius.circular(6),
      ),
      visorPaint,
    );

    // Botón superior
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

    // Gemas rojas en las puntas
    final gemPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.36, h * 0.14), 2.5, gemPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), 3.0, gemPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.14), 2.5, gemPaint);
  }

  void _paintHeadphones(Canvas canvas, double w, double h) {
    // Diadema curva superior
    final bandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final bandPath = Path();
    bandPath.moveTo(w * 0.26, h * 0.40);
    bandPath.quadraticBezierTo(w * 0.50, h * 0.14, w * 0.74, h * 0.40);
    canvas.drawPath(bandPath, bandPaint);

    // Auriculares en ambos lados de la cabeza
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

    // Lente izquierdo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.44, w * 0.14, h * 0.075),
        const Radius.circular(6),
      ),
      glassesPaint,
    );
    // Lente derecho
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.52, h * 0.44, w * 0.14, h * 0.075),
        const Radius.circular(6),
      ),
      glassesPaint,
    );
    // Puente central
    final bridgePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.48, h * 0.46), Offset(w * 0.52, h * 0.46), bridgePaint);

    // Reflejo blanco elegante
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.36, h * 0.46), Offset(w * 0.40, h * 0.49), glintPaint);
    canvas.drawLine(Offset(w * 0.54, h * 0.46), Offset(w * 0.58, h * 0.49), glintPaint);
  }

  void _paintAstronautHelmet(Canvas canvas, double w, double h) {
    // Cúpula del casco
    final helmetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.32, helmetPaint);

    // Visor dorado reflectante
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
    // Gafas de aviador
    final gogglePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(Offset(w * 0.44, h * 0.24), 6, gogglePaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.24), 6, gogglePaint);
  }

  @override
  bool shouldRepaint(covariant _SamiApparelSculptor oldDelegate) {
    return oldDelegate.equipment != equipment || oldDelegate.isWaving != isWaving;
  }
}
