import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';

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
    with SingleTickerProviderStateMixin {
  // Estado de rotación 3D (0 a 360 grados)
  double _rotationDegrees = 0.0;
  late AnimationController _autoSpinController;
  bool _isAutoSpinning = false;

  // Categoría activa de armario
  WardrobeCategory _activeCategory = WardrobeCategory.clothing;

  // Equipamiento actual en vista previa
  late SamiEquipment _currentEquipment;

  // Ítem seleccionado para ver detalles / comprar
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentEquipment = SamiEquipment.fromStorage(widget.currentAvatarId);
    _selectedItem = WardrobeItem.getItem(_currentEquipment.clothingId);

    _autoSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (_isAutoSpinning) {
          setState(() {
            _rotationDegrees = (_autoSpinController.value * 360.0) % 360.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _autoSpinController.dispose();
    super.dispose();
  }

  void _toggleAutoSpin() {
    AppHaptics.selection();
    setState(() {
      _isAutoSpinning = !_isAutoSpinning;
      if (_isAutoSpinning) {
        _autoSpinController.repeat();
      } else {
        _autoSpinController.stop();
      }
    });
  }

  void _snapToAngle(double targetAngle) {
    AppHaptics.selection();
    if (_isAutoSpinning) {
      _autoSpinController.stop();
      _isAutoSpinning = false;
    }
    setState(() {
      _rotationDegrees = targetAngle % 360.0;
    });
  }

  bool _isItemUnlocked(WardrobeItem item, List<String> unlocked) {
    if (item.isFree) return true;
    return unlocked.contains(item.id) ||
        // Retrocompatibilidad con antiguos IDs
        (item.id == 'ropa_superheroe' && unlocked.contains('avatar1')) ||
        (item.id == 'ropa_toga' && unlocked.contains('avatar3')) ||
        (item.id == 'ropa_armadura' && unlocked.contains('avatar5')) ||
        (item.id == 'acc_casco_astronauta' && unlocked.contains('avatar5')) ||
        (item.id == 'ropa_chef' && unlocked.contains('avatar7')) ||
        (item.id == 'acc_lentes_vip' && unlocked.contains('avatar8')) ||
        (item.id == 'ropa_sudadera' && unlocked.contains('avatar9')) ||
        (item.id == 'ropa_ejecutivo' && unlocked.contains('avatar10')) ||
        (item.id == 'acc_gorra' && unlocked.contains('sami_cap')) ||
        (item.id == 'acc_corona' && unlocked.contains('avatar3'));
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

  void _tryOnItem(WardrobeItem item) {
    AppHaptics.selection();
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

  Future<void> _handleEquipOrUnlock(WardrobeItem item) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isUnlocked = _isItemUnlocked(item, user.unlockedItems);

    if (isUnlocked) {
      // Equipar directamente
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
                    '¡"${item.name}" equipado en SAMI!',
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

    // Comprar / Desbloquear con monedas
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

  void _showNotEnoughCoinsDialog(WardrobeItem item, int userPoints) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131F24),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF263843), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Monedas Insuficientes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Necesitas ${item.cost} monedas para desbloquear "${item.name}". Actualmente tienes $userPoints 🪙.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8BA0AE), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A32),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.flame, color: Color(0xFFFF9600), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Registra tus gastos diarios y mantén tu racha para ganar más monedas!',
                        style: TextStyle(
                          color: Color(0xFFD6E2E8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB0F6),
                    foregroundColor: const Color(0xFF092A40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna el asset correspondiente al ángulo actual (0° Frente, 90° Lado Der, 180° Espalda, 270° Lado Izq)
  String _getCurrentSamiAsset(double deg) {
    final d = (deg % 360.0 + 360.0) % 360.0;
    if (d >= 315.0 || d < 45.0) {
      return 'assets/images/sami_3d_front.png';
    } else if (d >= 45.0 && d < 135.0) {
      return 'assets/images/sami_3d_facing_right.png';
    } else if (d >= 135.0 && d < 225.0) {
      return 'assets/images/sami_3d_back.png';
    } else {
      return 'assets/images/sami_3d_facing_left.png';
    }
  }

  String _getAngleDescription(double deg) {
    final d = (deg % 360.0 + 360.0) % 360.0;
    if (d >= 315.0 || d < 45.0) {
      return 'Frente';
    } else if (d >= 45.0 && d < 135.0) {
      return 'Perfil Derecho';
    } else if (d >= 135.0 && d < 225.0) {
      return 'Espalda';
    } else {
      return 'Perfil Izquierdo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final activeItems = WardrobeItem.getByCategory(_activeCategory);
    final normalizedDeg = (_rotationDegrees % 360.0 + 360.0) % 360.0;
    final currentAsset = _getCurrentSamiAsset(normalizedDeg);
    final angleDesc = _getAngleDescription(normalizedDeg);

    // Ángulo de inclinación en perspectiva 3D para la rotación suave continua
    final perspectiveAngle = (normalizedDeg % 90.0 - 45.0) * (math.pi / 180.0) * 0.4;

    final equippedClothing = WardrobeItem.getItem(_currentEquipment.clothingId);
    final equippedShoes = WardrobeItem.getItem(_currentEquipment.shoesId);
    final equippedAcc = WardrobeItem.getItem(_currentEquipment.accessoryId);

    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0C161D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF243B48), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF334B59),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header: Título + Saldo de Monedas + Botón Cerrar
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personaliza ropa, zapatos y accesorios',
                      style: TextStyle(
                        color: const Color(0xFF8BA0AE),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Saldo de monedas
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2A32),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.5),
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
                      color: Color(0xFF17252D),
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
          // ESCENARIO 3D INTERACTIVO DE SAMI (GIRATORIO CON EL DEDO)
          // =================================================================
          Container(
            height: 235,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -0.15),
                radius: 0.85,
                colors: [
                  Color(0xFF18313F),
                  Color(0xFF0F1E28),
                  Color(0xFF0A141A),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF223A48), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient glowing circular platform
                  Positioned(
                    bottom: 12,
                    child: CustomPaint(
                      size: const Size(220, 50),
                      painter: _TurntablePedestalPainter(
                        angleDegrees: normalizedDeg,
                      ),
                    ),
                  ),

                  // SAMI 3D MODEL WITH TOUCH DRAG ROTATION
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (_isAutoSpinning) {
                        _autoSpinController.stop();
                        _isAutoSpinning = false;
                      }
                      setState(() {
                        // Invertimos o ajustamos sensibilidad para que se sienta natural al arrastrar
                        _rotationDegrees = (_rotationDegrees - details.primaryDelta! * 0.9) % 360.0;
                      });
                    },
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(perspectiveAngle),
                      child: Container(
                        width: 210,
                        height: 195,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Master 3D SAMI Asset
                            Image.asset(
                              currentAsset,
                              fit: BoxFit.contain,
                              width: 175,
                              height: 175,
                              filterQuality: FilterQuality.high,
                            ),

                            // Floating accessory highlight badge if equipped
                            if (equippedAcc.id != 'acc_ninguno' &&
                                (normalizedDeg < 90 || normalizedDeg > 270))
                              Positioned(
                                top: 12,
                                right: 18,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: equippedAcc.primaryColor.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: equippedAcc.primaryColor.withValues(alpha: 0.6),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        equippedAcc.emoji,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        equippedAcc.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
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
                  ),

                  // Angle indicator pill at top
                  Positioned(
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13222B).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.rotateCcw,
                            color: Color(0xFF00E5FF),
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${normalizedDeg.toInt()}° · $angleDesc',
                            style: const TextStyle(
                              color: Color(0xFFD6F5FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating 360 Drag Hint and Quick View Buttons at bottom
                  Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAngleButton('Frente', 0.0),
                        const SizedBox(width: 6),
                        _buildAngleButton('Perfil', 90.0),
                        const SizedBox(width: 6),
                        _buildAngleButton('Espalda', 180.0),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _toggleAutoSpin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isAutoSpinning
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF1B2B35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00E5FF),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAutoSpinning
                                      ? LucideIcons.pause
                                      : LucideIcons.play,
                                  color: _isAutoSpinning
                                      ? const Color(0xFF092A40)
                                      : const Color(0xFF00E5FF),
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Girar',
                                  style: TextStyle(
                                    color: _isAutoSpinning
                                        ? const Color(0xFF092A40)
                                        : const Color(0xFF00E5FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
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

          const SizedBox(height: 10),

          // Pestañas de Armario: Ropa, Zapatos, Accesorios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryTab(
                  label: 'Ropa',
                  emoji: '👕',
                  category: WardrobeCategory.clothing,
                ),
                const SizedBox(width: 8),
                _buildCategoryTab(
                  label: 'Zapatos',
                  emoji: '👟',
                  category: WardrobeCategory.shoes,
                ),
                const SizedBox(width: 8),
                _buildCategoryTab(
                  label: 'Accesorios',
                  emoji: '✨',
                  category: WardrobeCategory.accessories,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Cuadrícula de Ítems de la Categoría Seleccionada
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                final isUnlocked = _isItemUnlocked(item, unlockedList);
                final isEquipped = _isItemEquipped(item);
                final isSelected = _selectedItem.id == item.id;

                return GestureDetector(
                  onTap: () => _tryOnItem(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E3544)
                          : const Color(0xFF14222B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00E5FF)
                            : (isEquipped
                                ? const Color(0xFF10B981)
                                : const Color(0xFF233744)),
                        width: isSelected ? 2.2 : (isEquipped ? 1.8 : 1.0),
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
                        // Icono 3D / Emoji
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                item.primaryColor,
                                item.secondaryColor,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Información de la prenda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Chip de Rareza o Precio
                              Row(
                                children: [
                                  if (isEquipped) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Equipado',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ] else if (isUnlocked) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Listo',
                                        style: TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      '🪙 ${item.cost}',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD54F),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isUnlocked)
                          const Icon(
                            LucideIcons.lock,
                            color: Color(0xFF6E8492),
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Barra Inferior de Acción (Equipar o Comprar Prenda Seleccionada)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1A21),
              border: const Border(
                top: BorderSide(color: Color(0xFF1E2E38), width: 1.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Detalle rápido de la prenda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              _selectedItem.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedItem.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _selectedItem.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8BA0AE),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botón principal
                  ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _handleEquipOrUnlock(_selectedItem),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelectedEquipped
                          ? const Color(0xFF10B981)
                          : (isSelectedUnlocked
                              ? const Color(0xFF1CB0F6)
                              : const Color(0xFFFF9600)),
                      foregroundColor: isSelectedEquipped || !isSelectedUnlocked
                          ? Colors.white
                          : const Color(0xFF092A40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
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
                        : Text(
                            isSelectedEquipped
                                ? '✓ Equipado'
                                : (isSelectedUnlocked
                                    ? 'Equipar'
                                    : '🪙 ${_selectedItem.cost}'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
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
    required WardrobeCategory category,
  }) {
    final isSelected = _activeCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          setState(() => _activeCategory = category);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFF16252E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF263B48),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF092A40) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAngleButton(String label, double angle) {
    return GestureDetector(
      onTap: () => _snapToAngle(angle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF152530),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF243B48), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8BA0AE),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAINTER PARA EL PEDESTAL GIRATORIO 3D (Reflejos Neón + Muescas Angulares)
// ---------------------------------------------------------------------------
class _TurntablePedestalPainter extends CustomPainter {
  final double angleDegrees;

  _TurntablePedestalPainter({required this.angleDegrees});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);

    // 1. Sombra base
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: w * 0.88, height: h * 0.65),
      shadowPaint,
    );

    // 2. Disco base metálico
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A3342), Color(0xFF0B1720)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.82, height: h * 0.55),
      basePaint,
    );

    // 3. Anillo exterior Neón Cyan
    final rimPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.80, height: h * 0.52),
      rimPaint,
    );

    // 4. Muescas angulares que giran con el ángulo
    final rad = angleDegrees * (math.pi / 180.0);
    final markerX = center.dx + math.sin(rad) * (w * 0.38);
    final markerY = center.dy + math.cos(rad) * (h * 0.22);

    final markerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 4.0, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _TurntablePedestalPainter oldDelegate) {
    return oldDelegate.angleDegrees != angleDegrees;
  }
}
