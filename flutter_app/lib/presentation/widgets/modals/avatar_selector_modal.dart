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
    with TickerProviderStateMixin {
  // Rotación 3D continua (0 a 360)
  double _rotationDegrees = 0.0;
  late AnimationController _autoSpinController;
  bool _isAutoSpinning = false;

  // Animación idle de respiración / flotación
  late AnimationController _idleController;

  // Animación de parpadeo natural de ojos
  late AnimationController _blinkController;
  bool _isBlinking = false;

  // Animación de saludo y rebote al tocar a SAMI
  late AnimationController _tapBounceController;
  late AnimationController _waveController;
  bool _isWaving = false;
  String? _speechMessage;

  // Categoría activa de armario (Ropa, Zapatos, Accesorios)
  WardrobeCategory _activeCategory = WardrobeCategory.clothing;

  // Equipamiento actual en vista previa (Simulación en vivo)
  late SamiEquipment _currentEquipment;

  // Ítem seleccionado en la cuadrícula
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  final List<String> _greetingPhrases = [
    '¡Hola! 👋 ¡Qué bien me veo con este estilo!',
    '¡Me encanta cómo me queda! ✨',
    '¡Mira cómo luce de espaldas! 🔄',
    '¡Listo para ahorrar juntos! 🚀',
    '¡Cada centavo cuenta para tu libertad! 🪙',
  ];

  @override
  void initState() {
    super.initState();
    _currentEquipment = SamiEquipment.fromStorage(widget.currentAvatarId);
    _selectedItem = WardrobeItem.getItem(_currentEquipment.clothingId);

    // Giro automático continuo
    _autoSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (_isAutoSpinning) {
          setState(() {
            _rotationDegrees = (_autoSpinController.value * 360.0) % 360.0;
          });
        }
      });

    // Respiración orgánica / flotación (2.4s)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Parpadeo natural de ojos cada 3.5 segundos
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isBlinking = true);
          Future.delayed(const Duration(milliseconds: 140), () {
            if (mounted) {
              setState(() => _isBlinking = false);
              _blinkController.forward(from: 0.0);
            }
          });
        }
      });
    _blinkController.forward();

    // Rebote y squash al tocar
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Movimiento de saludo de la mano
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _autoSpinController.dispose();
    _idleController.dispose();
    _blinkController.dispose();
    _tapBounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapSami() {
    AppHaptics.success();
    _tapBounceController.forward(from: 0.0);
    _waveController.forward(from: 0.0);

    final randomPhrase =
        _greetingPhrases[math.Random().nextInt(_greetingPhrases.length)];

    setState(() {
      _isWaving = true;
      _speechMessage = randomPhrase;
    });

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        setState(() {
          _isWaving = false;
          _speechMessage = null;
        });
      }
    });
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
        // Retrocompatibilidad con antiguos IDs de la tienda
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
    final equipped = SamiEquipment.fromStorage(widget.currentAvatarId);
    switch (item.category) {
      case WardrobeCategory.clothing:
        return equipped.clothingId == item.id;
      case WardrobeCategory.shoes:
        return equipped.shoesId == item.id;
      case WardrobeCategory.accessories:
        return equipped.accessoryId == item.id;
    }
  }

  /// Al tocar CUALQUIER prenda (incluso si no está comprada), SAMI se la pone inmediatamente para simular cómo se ve!
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
              const Text(
                'Monedas Insuficientes',
                style: TextStyle(
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
                        '¡Registra tus transacciones diarias y mantén tu racha para ganar más monedas!',
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

  /// Retorna el asset base con ojos abiertos para frente, o wink si está saludando
  String _getCurrentSamiAsset(double deg) {
    final d = (deg % 360.0 + 360.0) % 360.0;
    if (d >= 315.0 || d < 45.0) {
      if (_isBlinking) {
        return 'assets/images/sami_3d_front.png'; // Guiño/Parpadeo rápido
      }
      return 'assets/images/sami_3d_front_open.png'; // Ojos abiertos naturales
    } else if (d >= 45.0 && d < 135.0) {
      return 'assets/images/sami_3d_facing_right.png';
    } else if (d >= 135.0 && d < 225.0) {
      return 'assets/images/sami_3d_back.png';
    } else {
      return 'assets/images/sami_3d_facing_left.png';
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

    // Perspectiva continua suave para el giro 3D orgánico
    final perspectiveAngle =
        (normalizedDeg % 90.0 - 45.0) * (math.pi / 180.0) * 0.35;

    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    // Floating bobbing value
    final floatY = math.sin(_idleController.value * math.pi) * 4.0;

    // Bounce tap scale
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.12)
        : 1.0;

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
                    const Text(
                      'Prueba y personaliza ropa, zapatos y accesorios',
                      style: TextStyle(
                        color: Color(0xFF8BA0AE),
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

          const SizedBox(height: 6),

          // =================================================================
          // ESCENARIO 3D INTERACTIVO CON SIMULACIÓN DE ROPA EN VIVO
          // =================================================================
          Container(
            height: 245,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -0.15),
                radius: 0.85,
                colors: [
                  Color(0xFF163242),
                  Color(0xFF0F1E28),
                  Color(0xFF081218),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF223A48), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
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
                  // Plataforma circular interactiva
                  Positioned(
                    bottom: 12,
                    child: CustomPaint(
                      size: const Size(220, 50),
                      painter: _TurntablePedestalPainter(
                        angleDegrees: normalizedDeg,
                      ),
                    ),
                  ),

                  // SAMI 3D INTERACTIVO (Arrastre, Animaciones y Ropa en Vivo)
                  GestureDetector(
                    onTap: _onTapSami,
                    onHorizontalDragUpdate: (details) {
                      if (_isAutoSpinning) {
                        _autoSpinController.stop();
                        _isAutoSpinning = false;
                      }
                      setState(() {
                        // Arrastre fluido y natural
                        _rotationDegrees =
                            (_rotationDegrees - details.primaryDelta! * 0.85) %
                            360.0;
                      });
                    },
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
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(perspectiveAngle),
                              child: Container(
                                width: 210,
                                height: 200,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Personaje Base SAMI (HD)
                                    Image.asset(
                                      currentAsset,
                                      fit: BoxFit.contain,
                                      width: 175,
                                      height: 175,
                                      filterQuality: FilterQuality.high,
                                    ),

                                    // 2. SIMULACIÓN DE ROPA, ZAPATOS Y ACCESORIOS EN VIVO
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _SamiApparelOverlayPainter(
                                          equipment: _currentEquipment,
                                          angleDegrees: normalizedDeg,
                                          isWaving: _isWaving,
                                          waveProgress: _waveController.value,
                                        ),
                                      ),
                                    ),

                                    // 3. Destellos de saludo si está activo
                                    if (_isWaving)
                                      Positioned(
                                        top: 15,
                                        left: 15,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF00E5FF)
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Color(0xFF00E5FF),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Globo de diálogo al tocar a SAMI
                  if (_speechMessage != null)
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _speechMessage!,
                          style: const TextStyle(
                            color: Color(0xFF092A40),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                  // Chip de Vista Previa (Simulación en vivo) si la prenda no ha sido adquirida
                  if (!isSelectedUnlocked && _speechMessage == null)
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFB300),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(
                              'Probando: ${_selectedItem.name}',
                              style: const TextStyle(
                                color: Color(0xFFFFE082),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Botones de Vistas Rápidas en la base (Sin grados de rotación)
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

          // Cuadrícula de Ítems (Ropa, Zapatos, Accesorios con Bufandas, Cascos, etc.)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
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
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.25),
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
                        // Información
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
                              Row(
                                children: [
                                  if (isEquipped) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.2),
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
                                        color: const Color(0xFF38BDF8)
                                            .withValues(alpha: 0.2),
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

          // Barra Inferior de Acción (Equipar o Desbloquear)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1A21),
              border: Border(
                top: BorderSide(color: Color(0xFF1E2E38), width: 1.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
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
            color: isSelected
                ? const Color(0xFF1CB0F6)
                : const Color(0xFF16252E),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF152530),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF243B48), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8BA0AE),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAINTER PARA SIMULACIÓN EN VIVO DE ROPA, ZAPATOS Y ACCESORIOS SOBRE SAMI
// ---------------------------------------------------------------------------
class _SamiApparelOverlayPainter extends CustomPainter {
  final SamiEquipment equipment;
  final double angleDegrees;
  final bool isWaving;
  final double waveProgress;

  _SamiApparelOverlayPainter({
    required this.equipment,
    required this.angleDegrees,
    required this.isWaving,
    required this.waveProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final norm = (angleDegrees % 360.0 + 360.0) % 360.0;
    final isFront = (norm < 65.0 || norm > 295.0);
    final isBack = (norm >= 115.0 && norm < 245.0);
    final isRight = (norm >= 65.0 && norm < 115.0);
    final isLeft = (norm >= 245.0 && norm <= 295.0);

    // 1. ZAPATOS (En la base de las patitas de SAMI)
    _paintShoes(canvas, w, h, isFront, isBack, isRight, isLeft);

    // 2. ROPA (Sobre el torso / vientre)
    _paintClothing(canvas, w, h, isFront, isBack, isRight, isLeft);

    // 3. ACCESORIOS (Bufandas, Cascos, Gorras, etc. en cuello y cabeza)
    _paintAccessories(canvas, w, h, isFront, isBack, isRight, isLeft);
  }

  void _paintShoes(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isBack,
    bool isRight,
    bool isLeft,
  ) {
    final shoeId = equipment.shoesId;
    if (shoeId == 'zap_clasicos') return;

    final feetY = h * 0.84;
    final shoeH = h * 0.085;

    Color shoeMainColor = const Color(0xFF00E5FF);
    Color shoeAccentColor = Colors.white;

    switch (shoeId) {
      case 'zap_sneakers':
        shoeMainColor = const Color(0xFF00E5FF); // Neon cyan
        shoeAccentColor = Colors.white;
        break;
      case 'zap_botas':
        shoeMainColor = const Color(0xFF8B4513); // Saddle leather
        shoeAccentColor = const Color(0xFFFFD54F);
        break;
      case 'zap_charol':
        shoeMainColor = const Color(0xFF1E293B); // Black patent
        shoeAccentColor = Colors.white70;
        break;
      case 'zap_espaciales':
        shoeMainColor = const Color(0xFF7C3AED); // Space purple
        shoeAccentColor = const Color(0xFF00E5FF);
        break;
      case 'zap_dorados':
        shoeMainColor = const Color(0xFFFFD54F); // Gold
        shoeAccentColor = const Color(0xFFFF6F00);
        break;
    }

    final shoePaint = Paint()..color = shoeMainColor;
    final accentPaint = Paint()..color = shoeAccentColor;

    if (isFront || isBack) {
      // Pie Izquierdo
      final leftRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, feetY, w * 0.17, shoeH),
        const Radius.circular(8),
      );
      canvas.drawRRect(leftRRect, shoePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.30, feetY + shoeH * 0.65, w * 0.17, shoeH * 0.35),
          const Radius.circular(4),
        ),
        accentPaint,
      );

      // Pie Derecho
      final rightRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.53, feetY, w * 0.17, shoeH),
        const Radius.circular(8),
      );
      canvas.drawRRect(rightRRect, shoePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.53, feetY + shoeH * 0.65, w * 0.17, shoeH * 0.35),
          const Radius.circular(4),
        ),
        accentPaint,
      );
    } else {
      // Perfil
      final sideX = isRight ? w * 0.45 : w * 0.35;
      final sideRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(sideX, feetY, w * 0.22, shoeH),
        const Radius.circular(8),
      );
      canvas.drawRRect(sideRRect, shoePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sideX, feetY + shoeH * 0.65, w * 0.22, shoeH * 0.35),
          const Radius.circular(4),
        ),
        accentPaint,
      );
    }
  }

  void _paintClothing(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isBack,
    bool isRight,
    bool isLeft,
  ) {
    final clothId = equipment.clothingId;
    if (clothId == 'ropa_clasica') return;

    final chestY = h * 0.58;
    final chestW = w * 0.38;

    switch (clothId) {
      case 'ropa_ejecutivo':
        if (isFront) {
          // Solapas de saco azul marino
          final suitPaint = Paint()..color = const Color(0xFF1E3A8A);
          final lapelPath = Path();
          lapelPath.moveTo(w * 0.36, chestY - 10);
          lapelPath.lineTo(w * 0.50, chestY + 28);
          lapelPath.lineTo(w * 0.64, chestY - 10);
          lapelPath.lineTo(w * 0.60, chestY + 36);
          lapelPath.lineTo(w * 0.40, chestY + 36);
          lapelPath.close();
          canvas.drawPath(lapelPath, suitPaint);

          // Cuello camisa blanca
          final shirtPaint = Paint()..color = Colors.white;
          final shirtPath = Path();
          shirtPath.moveTo(w * 0.44, chestY - 10);
          shirtPath.lineTo(w * 0.50, chestY + 6);
          shirtPath.lineTo(w * 0.56, chestY - 10);
          shirtPath.close();
          canvas.drawPath(shirtPath, shirtPaint);

          // Corbata de seda roja
          final tiePaint = Paint()..color = const Color(0xFFDC2626);
          final tiePath = Path();
          tiePath.moveTo(w * 0.48, chestY);
          tiePath.lineTo(w * 0.52, chestY);
          tiePath.lineTo(w * 0.53, chestY + 28);
          tiePath.lineTo(w * 0.50, chestY + 34);
          tiePath.lineTo(w * 0.47, chestY + 28);
          tiePath.close();
          canvas.drawPath(tiePath, tiePaint);
        } else if (isBack) {
          // Espalda del saco
          final backSuit = Paint()..color = const Color(0xFF1E3A8A);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.32, chestY - 6, chestW, h * 0.22),
              const Radius.circular(12),
            ),
            backSuit,
          );
        }
        break;

      case 'ropa_sudadera':
        // Sudadera Streetwear Cyan
        final hoodiePaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, chestY - 12, w * 0.40, h * 0.22),
            const Radius.circular(16),
          ),
          hoodiePaint,
        );
        if (isFront) {
          // Bolsillo canguro
          final pocketPaint = Paint()..color = const Color(0xFF0284C7);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.36, chestY + 14, w * 0.28, h * 0.08),
              const Radius.circular(8),
            ),
            pocketPaint,
          );
        }
        break;

      case 'ropa_superheroe':
        // Capa roja ondeante (se ve detrás y a los costados)
        final capePaint = Paint()..color = const Color(0xFFDC2626);
        final capePath = Path();
        if (isBack) {
          capePath.moveTo(w * 0.24, chestY - 15);
          capePath.lineTo(w * 0.76, chestY - 15);
          capePath.lineTo(w * 0.84, chestY + 55);
          capePath.lineTo(w * 0.16, chestY + 55);
          capePath.close();
          canvas.drawPath(capePath, capePaint);
        } else {
          // Al frente se ven las puntas de la capa a los lados
          canvas.drawOval(Rect.fromLTWH(w * 0.18, chestY - 5, w * 0.14, h * 0.24), capePaint);
          canvas.drawOval(Rect.fromLTWH(w * 0.68, chestY - 5, w * 0.14, h * 0.24), capePaint);
          // Emblema dorado en el pecho
          final crestPaint = Paint()..color = const Color(0xFFFFD54F);
          canvas.drawCircle(Offset(w * 0.50, chestY + 12), 14, crestPaint);
        }
        break;

      case 'ropa_armadura':
        // Armadura Galáctica con circuitos neón
        final armorPaint = Paint()..color = const Color(0xFF334155);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, chestY - 10, w * 0.40, h * 0.22),
            const Radius.circular(14),
          ),
          armorPaint,
        );
        final neonPaint = Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(w * 0.50, chestY + 12), 10, neonPaint);
        break;

      case 'ropa_chef':
        // Filipina blanca
        final chefPaint = Paint()..color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.32, chestY - 10, w * 0.36, h * 0.22),
            const Radius.circular(12),
          ),
          chefPaint,
        );
        if (isFront) {
          final goldBtn = Paint()..color = const Color(0xFFFFD54F);
          canvas.drawCircle(Offset(w * 0.44, chestY + 4), 3, goldBtn);
          canvas.drawCircle(Offset(w * 0.56, chestY + 4), 3, goldBtn);
          canvas.drawCircle(Offset(w * 0.44, chestY + 18), 3, goldBtn);
          canvas.drawCircle(Offset(w * 0.56, chestY + 18), 3, goldBtn);
        }
        break;

      case 'ropa_toga':
        // Toga Imperial dorada
        final togaPaint = Paint()..color = const Color(0xFFFFF8E1);
        final sashPaint = Paint()..color = const Color(0xFFFFB300);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, chestY - 10, w * 0.40, h * 0.22),
            const Radius.circular(14),
          ),
          togaPaint,
        );
        final sashPath = Path();
        sashPath.moveTo(w * 0.32, chestY - 10);
        sashPath.lineTo(w * 0.42, chestY - 10);
        sashPath.lineTo(w * 0.68, chestY + 36);
        sashPath.lineTo(w * 0.58, chestY + 36);
        sashPath.close();
        canvas.drawPath(sashPath, sashPaint);
        break;

      case 'ropa_deportiva':
        // Jersey deportivo
        final jerseyPaint = Paint()..color = const Color(0xFF0D9488);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.32, chestY - 10, w * 0.36, h * 0.20),
            const Radius.circular(12),
          ),
          jerseyPaint,
        );
        break;
    }
  }

  void _paintAccessories(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isBack,
    bool isRight,
    bool isLeft,
  ) {
    final accId = equipment.accessoryId;
    if (accId == 'acc_ninguno') return;

    final headY = h * 0.22;
    final neckY = h * 0.50;

    switch (accId) {
      // 1. BUFANDAS
      case 'acc_bufanda_nordica':
        final scarfPaint = Paint()..color = const Color(0xFF0284C7);
        final stripePaint = Paint()..color = Colors.white;
        // Aro de bufanda alrededor del cuello
        final neckRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, neckY, w * 0.44, h * 0.08),
          const Radius.circular(14),
        );
        canvas.drawRRect(neckRect, scarfPaint);
        // Franjas decorativas
        canvas.drawRect(Rect.fromLTWH(w * 0.36, neckY, 4, h * 0.08), stripePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.52, neckY, 4, h * 0.08), stripePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.62, neckY, 4, h * 0.08), stripePaint);
        // Cola de la bufanda cayendo
        if (isFront || isLeft) {
          final tailRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.32, neckY + 8, w * 0.10, h * 0.14),
            const Radius.circular(6),
          );
          canvas.drawRRect(tailRect, scarfPaint);
          canvas.drawRect(Rect.fromLTWH(w * 0.32, neckY + 16, w * 0.10, 4), stripePaint);
          canvas.drawRect(Rect.fromLTWH(w * 0.32, neckY + 26, w * 0.10, 4), stripePaint);
        }
        break;

      case 'acc_bufanda_carmesi':
        final redScarf = Paint()..color = const Color(0xFFE11D48);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.28, neckY, w * 0.44, h * 0.075),
            const Radius.circular(12),
          ),
          redScarf,
        );
        // Cola ondeante
        final tailPath = Path();
        tailPath.moveTo(w * 0.60, neckY + 6);
        tailPath.cubicTo(w * 0.72, neckY + 12, w * 0.78, neckY + 28, w * 0.74, neckY + 45);
        tailPath.lineTo(w * 0.66, neckY + 45);
        tailPath.close();
        canvas.drawPath(tailPath, redScarf);
        break;

      // 2. CASCOS
      case 'acc_casco_astronauta':
        // Casco esférico con visor reflectante
        final helmetPaint = Paint()..color = const Color(0xFFF1F5F9);
        final visorPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(w * 0.22, headY - 15, w * 0.56, h * 0.35));

        canvas.drawOval(Rect.fromLTWH(w * 0.22, headY - 15, w * 0.56, h * 0.35), helmetPaint);
        if (isFront || isRight || isLeft) {
          canvas.drawOval(Rect.fromLTWH(w * 0.28, headY + 5, w * 0.44, h * 0.20), visorPaint);
        }
        break;

      case 'acc_casco_cyberpunk':
        // Visor HUD Neón
        final hudPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.85);
        final hudRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.26, headY + 30, w * 0.48, h * 0.08),
          const Radius.circular(8),
        );
        canvas.drawRRect(hudRect, hudPaint);
        break;

      case 'acc_casco_piloto':
        // Casco aviador de cuero con gafas
        final leatherPaint = Paint()..color = const Color(0xFF78350F);
        canvas.drawArc(
          Rect.fromLTWH(w * 0.24, headY - 10, w * 0.52, h * 0.30),
          math.pi,
          math.pi,
          true,
          leatherPaint,
        );
        // Gafas en la frente
        final gogglePaint = Paint()..color = const Color(0xFF38BDF8);
        canvas.drawOval(Rect.fromLTWH(w * 0.34, headY + 8, w * 0.14, h * 0.08), gogglePaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.52, headY + 8, w * 0.14, h * 0.08), gogglePaint);
        break;

      // 3. GORRAS, CORONAS Y OTROS
      case 'acc_gorra':
        final capPaint = Paint()..color = const Color(0xFF2563EB);
        final brimPaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawArc(
          Rect.fromLTWH(w * 0.26, headY - 12, w * 0.48, h * 0.25),
          math.pi,
          math.pi,
          true,
          capPaint,
        );
        canvas.drawRect(Rect.fromLTWH(w * 0.22, headY + 18, w * 0.56, h * 0.04), brimPaint);
        break;

      case 'acc_corona':
        // Corona dorada
        final crownPaint = Paint()..color = const Color(0xFFFFD54F);
        final crownPath = Path();
        crownPath.moveTo(w * 0.34, headY + 8);
        crownPath.lineTo(w * 0.34, headY - 16);
        crownPath.lineTo(w * 0.42, headY - 4);
        crownPath.lineTo(w * 0.50, headY - 24);
        crownPath.lineTo(w * 0.58, headY - 4);
        crownPath.lineTo(w * 0.66, headY - 16);
        crownPath.lineTo(w * 0.66, headY + 8);
        crownPath.close();
        canvas.drawPath(crownPath, crownPaint);

        // Gemas de la corona
        final gemRed = Paint()..color = const Color(0xFFDC2626);
        final gemGreen = Paint()..color = const Color(0xFF10B981);
        canvas.drawCircle(Offset(w * 0.50, headY - 12), 3, gemRed);
        canvas.drawCircle(Offset(w * 0.38, headY), 2.5, gemGreen);
        canvas.drawCircle(Offset(w * 0.62, headY), 2.5, gemGreen);
        break;

      case 'acc_lentes_vip':
        // Gafas oscuras
        final lensPaint = Paint()..color = const Color(0xFF0F172A);
        final framePaint = Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        final leftLens = Rect.fromLTWH(w * 0.32, headY + 36, w * 0.16, h * 0.08);
        final rightLens = Rect.fromLTWH(w * 0.52, headY + 36, w * 0.16, h * 0.08);
        canvas.drawOval(leftLens, lensPaint);
        canvas.drawOval(rightLens, lensPaint);
        canvas.drawOval(leftLens, framePaint);
        canvas.drawOval(rightLens, framePaint);
        canvas.drawLine(Offset(w * 0.48, headY + 40), Offset(w * 0.52, headY + 40), framePaint);
        break;

      case 'acc_auriculares':
        // Auriculares DJ
        final phonePaint = Paint()..color = const Color(0xFF9333EA);
        final bandPaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;
        // Diadema
        canvas.drawArc(
          Rect.fromLTWH(w * 0.20, headY - 18, w * 0.60, h * 0.35),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );
        // Orejeras
        canvas.drawOval(Rect.fromLTWH(w * 0.18, headY + 22, w * 0.10, h * 0.16), phonePaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.72, headY + 22, w * 0.10, h * 0.16), phonePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SamiApparelOverlayPainter oldDelegate) {
    return oldDelegate.equipment != equipment ||
        oldDelegate.angleDegrees != angleDegrees ||
        oldDelegate.isWaving != isWaving ||
        oldDelegate.waveProgress != waveProgress;
  }
}

// ---------------------------------------------------------------------------
// PAINTER PARA EL PEDESTAL GIRATORIO 3D
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
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 8),
        width: w * 0.88,
        height: h * 0.65,
      ),
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

    // 4. Muesca de orientación que gira con el ángulo
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
