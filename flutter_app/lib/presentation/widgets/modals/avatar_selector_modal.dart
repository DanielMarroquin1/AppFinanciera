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

                  // Floating 360 Touch Gesture Bar at bottom (Cleaner interaction without static buttons)
                  Positioned(
                    bottom: 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Touch hint
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13222B).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF243B48),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.moveHorizontal,
                                color: Color(0xFF00E5FF),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Desliza para girar 360°',
                                style: TextStyle(
                                  color: Color(0xFFD6F5FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Auto-spin button
                        GestureDetector(
                          onTap: _toggleAutoSpin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _isAutoSpinning
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF1B2B35),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF00E5FF),
                                width: 1.2,
                              ),
                              boxShadow: _isAutoSpinning
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAutoSpinning
                                      ? LucideIcons.pause
                                      : LucideIcons.rotateCw,
                                  color: _isAutoSpinning
                                      ? const Color(0xFF092A40)
                                      : const Color(0xFF00E5FF),
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isAutoSpinning ? 'Pausar' : 'Girar Auto',
                                  style: TextStyle(
                                    color: _isAutoSpinning
                                        ? const Color(0xFF092A40)
                                        : const Color(0xFF00E5FF),
                                    fontSize: 11,
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
}

// ---------------------------------------------------------------------------
// PAINTER PARA SIMULACIÓN EN VIVO DE ROPA, ZAPATOS Y ACCESORIOS MOLDEADOS
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

    // 3D Trigonometric perspective angles (0 = front, 90 = right profile, 180 = back, 270 = left profile)
    final norm = (angleDegrees % 360.0 + 360.0) % 360.0;
    final rad = norm * math.pi / 180.0;
    final cosVal = math.cos(rad);
    final sinVal = math.sin(rad);

    // Front/Back visibility factors (Continuous smooth transition, no jumps!)
    final double frontWeight = math.max(0.0, cosVal);
    final double backWeight = math.max(0.0, -cosVal);

    // 3D Horizontal displacement of the belly center as SAMI rotates
    final double shiftX = sinVal * (w * 0.16);

    // Foreshortening factor (compresses features when turning into profile)
    final double foreshorten = 0.52 + 0.48 * cosVal.abs();

    // Depth-sorted rendering:
    // 1. Back items (cape from front view, etc.)
    _paintBackElements(canvas, w, h, frontWeight, backWeight, shiftX, foreshorten);

    // 2. Shoes (sculpted to SAMI's feet)
    _paintSculptedShoes(canvas, w, h, frontWeight, backWeight, shiftX, sinVal);

    // 3. Clothing (molded smoothly to SAMI's pear body)
    _paintSculptedClothing(canvas, w, h, frontWeight, backWeight, shiftX, foreshorten);

    // 4. Accessories (toroidal scarf, helmets, crown, glasses)
    _paintSculptedAccessories(canvas, w, h, frontWeight, backWeight, shiftX, foreshorten);
  }

  // -------------------------------------------------------------------------
  // CAPE / BACK ELEMENTS (Rendered behind body when front, in front when back)
  // -------------------------------------------------------------------------
  void _paintBackElements(
    Canvas canvas,
    double w,
    double h,
    double frontWeight,
    double backWeight,
    double shiftX,
    double foreshorten,
  ) {
    if (equipment.clothingId == 'ropa_superheroe') {
      final capePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE11D48), Color(0xFF9F1239), Color(0xFF4C0519)],
        ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.45));

      final capePath = Path();
      if (backWeight > 0.05) {
        // Full cape covering the back
        final alpha = (backWeight * 255).clamp(0, 255).toInt();
        capePaint.color = capePaint.color.withAlpha(alpha);

        capePath.moveTo(w * 0.32 + shiftX, h * 0.46);
        capePath.quadraticBezierTo(w * 0.50 + shiftX, h * 0.44, w * 0.68 + shiftX, h * 0.46);
        capePath.quadraticBezierTo(w * 0.82 + shiftX * 0.6, h * 0.68, w * 0.80 + shiftX * 0.5, h * 0.86);
        capePath.quadraticBezierTo(w * 0.50 + shiftX * 0.5, h * 0.90, w * 0.20 + shiftX * 0.5, h * 0.86);
        capePath.quadraticBezierTo(w * 0.18 + shiftX * 0.6, h * 0.68, w * 0.32 + shiftX, h * 0.46);
        capePath.close();
        canvas.drawPath(capePath, capePaint);

        // Gold clasp at back of neck
        final claspPaint = Paint()..color = const Color(0xFFFFD54F);
        canvas.drawCircle(Offset(w * 0.50 + shiftX, h * 0.46), 4.5, claspPaint);
      } else if (frontWeight > 0.1) {
        // Cape wings peeking from behind shoulders
        final wingPath = Path();
        // Left wing
        wingPath.moveTo(w * 0.24, h * 0.52);
        wingPath.quadraticBezierTo(w * 0.12, h * 0.62, w * 0.15, h * 0.76);
        wingPath.quadraticBezierTo(w * 0.22, h * 0.70, w * 0.26, h * 0.58);
        wingPath.close();
        // Right wing
        wingPath.moveTo(w * 0.76, h * 0.52);
        wingPath.quadraticBezierTo(w * 0.88, h * 0.62, w * 0.85, h * 0.76);
        wingPath.quadraticBezierTo(w * 0.78, h * 0.70, w * 0.74, h * 0.58);
        wingPath.close();
        canvas.drawPath(wingPath, capePaint);
      }
    }
  }

  // -------------------------------------------------------------------------
  // SCULPTED SHOES (Molded to SAMI's round flipper paws)
  // -------------------------------------------------------------------------
  void _paintSculptedShoes(
    Canvas canvas,
    double w,
    double h,
    double frontWeight,
    double backWeight,
    double shiftX,
    double sinVal,
  ) {
    final shoeId = equipment.shoesId;
    if (shoeId == 'zap_clasicos') return;

    Color upperColor;
    Color soleColor;
    Color detailColor;

    switch (shoeId) {
      case 'zap_sneakers':
        upperColor = const Color(0xFF00E5FF); // Electric cyan
        soleColor = Colors.white;
        detailColor = const Color(0xFF0284C7);
        break;
      case 'zap_botas':
        upperColor = const Color(0xFF8B4513); // Leather brown
        soleColor = const Color(0xFF5D2E0C);
        detailColor = const Color(0xFFFFD54F);
        break;
      case 'zap_charol':
        upperColor = const Color(0xFF0F172A); // High-gloss tuxedo black
        soleColor = const Color(0xFF334155);
        detailColor = Colors.white;
        break;
      case 'zap_espaciales':
        upperColor = const Color(0xFF7C3AED); // Space purple
        soleColor = const Color(0xFF00E5FF);
        detailColor = const Color(0xFFA78BFA);
        break;
      case 'zap_dorados':
        upperColor = const Color(0xFFFFD54F); // Royal gold
        soleColor = const Color(0xFFB45309);
        detailColor = const Color(0xFFFFF9C4);
        break;
      default:
        upperColor = const Color(0xFF00E5FF);
        soleColor = Colors.white;
        detailColor = Colors.cyan;
    }

    final feetY = h * 0.84;
    final pawWidth = w * 0.17;
    final pawHeight = h * 0.085;

    // Shift feet naturally with 3D rotation
    final leftX = w * 0.32 + shiftX * 0.6;
    final rightX = w * 0.53 + shiftX * 0.6;

    final upperPaint = Paint()..color = upperColor;
    final solePaint = Paint()..color = soleColor;
    final detailPaint = Paint()..color = detailColor;

    // Left Foot
    _drawCurvedPawShoe(canvas, leftX, feetY, pawWidth, pawHeight, upperPaint, solePaint, detailPaint, sinVal);
    // Right Foot
    _drawCurvedPawShoe(canvas, rightX, feetY, pawWidth, pawHeight, upperPaint, solePaint, detailPaint, sinVal);
  }

  void _drawCurvedPawShoe(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Paint upperPaint,
    Paint solePaint,
    Paint detailPaint,
    double sinVal,
  ) {
    // Upper shoe contoured to flipper
    final shoeRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, width, height),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(shoeRect, upperPaint);

    // Rubber sole rim along bottom
    final soleRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x - 1, y + height * 0.68, width + 2, height * 0.35),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(soleRect, solePaint);

    // Subtle laces or metallic buckle
    canvas.drawCircle(Offset(x + width * 0.5, y + height * 0.35), 2.5, detailPaint);
  }

  // -------------------------------------------------------------------------
  // SCULPTED CLOTHING (Molded around SAMI's pear body)
  // -------------------------------------------------------------------------
  void _paintSculptedClothing(
    Canvas canvas,
    double w,
    double h,
    double frontWeight,
    double backWeight,
    double shiftX,
    double foreshorten,
  ) {
    final clothId = equipment.clothingId;
    if (clothId == 'ropa_clasica') return;

    final cx = w * 0.50 + shiftX;
    final neckY = h * 0.49;
    final bellyY = h * 0.74;
    final halfTopW = (w * 0.17) * foreshorten;
    final halfBellyW = (w * 0.25) * foreshorten;

    switch (clothId) {
      // 1. TRAJE EJECUTIVO
      case 'ropa_ejecutivo':
        // Base suit jacket curved along SAMI's pear body
        final suitPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A),
              const Color(0xFF0F172A),
            ],
          ).createShader(Rect.fromLTWH(cx - halfBellyW, neckY, halfBellyW * 2, bellyY - neckY));

        final suitPath = Path();
        suitPath.moveTo(cx - halfTopW, neckY);
        suitPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        suitPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        suitPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        suitPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        suitPath.close();
        canvas.drawPath(suitPath, suitPaint);

        if (frontWeight > 0.08) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();

          // White shirt triangle inside collar
          final shirtPaint = Paint()..color = Colors.white.withAlpha(alpha);
          final shirtPath = Path();
          shirtPath.moveTo(cx - halfTopW * 0.45, neckY);
          shirtPath.lineTo(cx + halfTopW * 0.45, neckY);
          shirtPath.lineTo(cx, neckY + 28);
          shirtPath.close();
          canvas.drawPath(shirtPath, shirtPaint);

          // Silk red tie
          final tiePaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
            ).createShader(Rect.fromLTWH(cx - 7, neckY + 8, 14, 38));
          final tiePath = Path();
          tiePath.moveTo(cx - 5, neckY + 6);
          tiePath.lineTo(cx + 5, neckY + 6);
          tiePath.lineTo(cx + 7, neckY + 36);
          tiePath.lineTo(cx, neckY + 44);
          tiePath.lineTo(cx - 7, neckY + 36);
          tiePath.close();
          canvas.drawPath(tiePath, tiePaint);

          // Lapel fold edges with highlighted borders
          final lapelStroke = Paint()
            ..color = const Color(0xFF38BDF8).withAlpha((alpha * 0.6).toInt())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawLine(Offset(cx - halfTopW * 0.8, neckY + 2), Offset(cx - 4, neckY + 38), lapelStroke);
          canvas.drawLine(Offset(cx + halfTopW * 0.8, neckY + 2), Offset(cx + 4, neckY + 38), lapelStroke);
        } else if (backWeight > 0.1) {
          // Back tailored seam
          final seamPaint = Paint()
            ..color = const Color(0xFF0F172A)
            ..strokeWidth = 2.0;
          canvas.drawLine(Offset(cx, neckY + 4), Offset(cx, bellyY - 4), seamPaint);
        }
        break;

      // 2. SUDADERA STREETWEAR
      case 'ropa_sudadera':
        final hoodiePaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
          ).createShader(Rect.fromLTWH(cx - halfBellyW, neckY, halfBellyW * 2, bellyY - neckY));

        final bodyPath = Path();
        bodyPath.moveTo(cx - halfTopW, neckY);
        bodyPath.quadraticBezierTo(cx, neckY - 6, cx + halfTopW, neckY);
        bodyPath.quadraticBezierTo(cx + halfBellyW * 1.08, h * 0.62, cx + halfBellyW, bellyY);
        bodyPath.quadraticBezierTo(cx, bellyY + 7, cx - halfBellyW, bellyY);
        bodyPath.quadraticBezierTo(cx - halfBellyW * 1.08, h * 0.62, cx - halfTopW, neckY);
        bodyPath.close();
        canvas.drawPath(bodyPath, hoodiePaint);

        // Ribbed hem at waist
        final hemPaint = Paint()..color = const Color(0xFF0369A1);
        final hemRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - halfBellyW * 0.95, bellyY - 4, halfBellyW * 1.9, 10),
          const Radius.circular(5),
        );
        canvas.drawRRect(hemRect, hemPaint);

        if (frontWeight > 0.1) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();
          // Kangaroo pocket on belly
          final pocketPaint = Paint()..color = const Color(0xFF075985).withAlpha(alpha);
          final pocketPath = Path();
          final pw = halfBellyW * 0.8;
          pocketPath.moveTo(cx - pw * 0.6, h * 0.63);
          pocketPath.lineTo(cx + pw * 0.6, h * 0.63);
          pocketPath.lineTo(cx + pw * 0.85, bellyY - 6);
          pocketPath.lineTo(cx - pw * 0.85, bellyY - 6);
          pocketPath.close();
          canvas.drawPath(pocketPath, pocketPaint);

          // Drawstring cords
          final cordPaint = Paint()
            ..color = Colors.white.withAlpha(alpha)
            ..strokeWidth = 2.0;
          canvas.drawLine(Offset(cx - 8, neckY + 4), Offset(cx - 8, neckY + 22), cordPaint);
          canvas.drawLine(Offset(cx + 8, neckY + 4), Offset(cx + 8, neckY + 22), cordPaint);
        }
        break;

      // 3. TRAJE SUPERHEROE
      case 'ropa_superheroe':
        final redSuit = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
          ).createShader(Rect.fromLTWH(cx - halfBellyW, neckY, halfBellyW * 2, bellyY - neckY));

        final suitPath = Path();
        suitPath.moveTo(cx - halfTopW, neckY);
        suitPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        suitPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        suitPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        suitPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        suitPath.close();
        canvas.drawPath(suitPath, redSuit);

        if (frontWeight > 0.1) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();
          // Gold emblem on chest
          final emblemPaint = Paint()..color = const Color(0xFFFFD54F).withAlpha(alpha);
          canvas.drawCircle(Offset(cx, h * 0.58), 13 * foreshorten, emblemPaint);

          // Gold utility belt
          final beltPaint = Paint()..color = const Color(0xFFFFB300).withAlpha(alpha);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - halfBellyW * 0.85, bellyY - 6, halfBellyW * 1.7, 8),
              const Radius.circular(4),
            ),
            beltPaint,
          );
        }
        break;

      // 4. ARMADURA GALACTICA
      case 'ropa_armadura':
        final armorPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF475569), Color(0xFF1E293B)],
          ).createShader(Rect.fromLTWH(cx - halfBellyW, neckY, halfBellyW * 2, bellyY - neckY));

        final armorPath = Path();
        armorPath.moveTo(cx - halfTopW, neckY);
        armorPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        armorPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        armorPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        armorPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        armorPath.close();
        canvas.drawPath(armorPath, armorPaint);

        // Glowing cyan power core
        final coreGlow = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(cx, h * 0.60), 12 * foreshorten, coreGlow);
        break;

      // 5. FILIPINA CHEF
      case 'ropa_chef':
        final chefPaint = Paint()..color = Colors.white;
        final chefPath = Path();
        chefPath.moveTo(cx - halfTopW, neckY);
        chefPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        chefPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        chefPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        chefPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        chefPath.close();
        canvas.drawPath(chefPath, chefPaint);

        if (frontWeight > 0.1) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();
          final goldBtn = Paint()..color = const Color(0xFFFFD54F).withAlpha(alpha);
          final spacing = 12 * foreshorten;
          canvas.drawCircle(Offset(cx - spacing, h * 0.56), 3, goldBtn);
          canvas.drawCircle(Offset(cx + spacing, h * 0.56), 3, goldBtn);
          canvas.drawCircle(Offset(cx - spacing, h * 0.64), 3, goldBtn);
          canvas.drawCircle(Offset(cx + spacing, h * 0.64), 3, goldBtn);
        }
        break;

      // 6. TOGA IMPERIAL
      case 'ropa_toga':
        final togaPaint = Paint()..color = const Color(0xFFFFFBEB);
        final togaPath = Path();
        togaPath.moveTo(cx - halfTopW, neckY);
        togaPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        togaPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        togaPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        togaPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        togaPath.close();
        canvas.drawPath(togaPath, togaPaint);

        // Gold sash draped over shoulder
        final sashPaint = Paint()
          ..shader = const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFD97706)])
              .createShader(Rect.fromLTWH(cx - halfTopW, neckY, halfBellyW * 2, bellyY - neckY));
        final sashPath = Path();
        sashPath.moveTo(cx - halfTopW * 0.7, neckY);
        sashPath.lineTo(cx - halfTopW * 0.2, neckY);
        sashPath.lineTo(cx + halfBellyW * 0.9, bellyY);
        sashPath.lineTo(cx + halfBellyW * 0.4, bellyY);
        sashPath.close();
        canvas.drawPath(sashPath, sashPaint);
        break;

      // 7. CONJUNTO ATLETICO TECH
      case 'ropa_deportiva':
        final sportPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF115E59)],
          ).createShader(Rect.fromLTWH(cx - halfBellyW, neckY, halfBellyW * 2, bellyY - neckY));

        final sportPath = Path();
        sportPath.moveTo(cx - halfTopW, neckY);
        sportPath.quadraticBezierTo(cx, neckY - 4, cx + halfTopW, neckY);
        sportPath.quadraticBezierTo(cx + halfBellyW * 1.05, h * 0.62, cx + halfBellyW, bellyY);
        sportPath.quadraticBezierTo(cx, bellyY + 6, cx - halfBellyW, bellyY);
        sportPath.quadraticBezierTo(cx - halfBellyW * 1.05, h * 0.62, cx - halfTopW, neckY);
        sportPath.close();
        canvas.drawPath(sportPath, sportPaint);
        break;
    }
  }

  // -------------------------------------------------------------------------
  // SCULPTED ACCESSORIES (Bufandas, Cascos, Gorra, Corona, Lentes, Auriculares)
  // -------------------------------------------------------------------------
  void _paintSculptedAccessories(
    Canvas canvas,
    double w,
    double h,
    double frontWeight,
    double backWeight,
    double shiftX,
    double foreshorten,
  ) {
    final accId = equipment.accessoryId;
    if (accId == 'acc_ninguno') return;

    final cx = w * 0.50 + shiftX;
    final headY = h * 0.32;
    final neckY = h * 0.48;

    switch (accId) {
      // 1. BUFANDAS (Snug 3D toroidal wrap around neck)
      case 'acc_bufanda_nordica':
      case 'acc_bufanda_carmesi':
        final isNordic = (accId == 'acc_bufanda_nordica');
        final scarfColor = isNordic ? const Color(0xFF0284C7) : const Color(0xFFE11D48);
        final scarfAccent = isNordic ? Colors.white : const Color(0xFFFFD54F);

        final scarfPaint = Paint()..color = scarfColor;
        final accentPaint = Paint()..color = scarfAccent;

        // Torus neck ring wrapping 360°
        final ringRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - (w * 0.22) * foreshorten, neckY - 8, (w * 0.44) * foreshorten, 22),
          const Radius.circular(12),
        );
        canvas.drawRRect(ringRect, scarfPaint);

        // Decorative stripes on the collar
        canvas.drawRect(Rect.fromLTWH(cx - 10, neckY - 8, 4, 22), accentPaint);
        canvas.drawRect(Rect.fromLTWH(cx + 8, neckY - 8, 4, 22), accentPaint);

        // Hanging tail swaying with rotation
        if (frontWeight > 0.15) {
          final tailRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 14, neckY + 10, 18, 38),
            const Radius.circular(6),
          );
          canvas.drawRRect(tailRect, scarfPaint);
          canvas.drawRect(Rect.fromLTWH(cx - 14, neckY + 22, 18, 4), accentPaint);
          canvas.drawRect(Rect.fromLTWH(cx - 14, neckY + 32, 18, 4), accentPaint);
        }
        break;

      // 2. CASCO DE ASTRONAUTA (Dome bubble + gold visor)
      case 'acc_casco_astronauta':
        final domePaint = Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.3),
            colors: [
              Colors.white.withValues(alpha: 0.35),
              const Color(0xFF00E5FF).withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, headY + 8), radius: w * 0.30));

        // Glass sphere
        canvas.drawCircle(Offset(cx, headY + 8), w * 0.29, domePaint);

        // Gold curved visor in front
        if (frontWeight > 0.1) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();
          final visorPaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
            ).createShader(Rect.fromLTWH(cx - 40 * foreshorten, headY - 10, 80 * foreshorten, 42));
          visorPaint.color = visorPaint.color.withAlpha(alpha);

          final visorRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 40 * foreshorten, headY - 8, 80 * foreshorten, 40),
            const Radius.circular(16),
          );
          canvas.drawRRect(visorRect, visorPaint);
        }
        break;

      // 3. CASCO CYBERPUNK (HUD Holográfico)
      case 'acc_casco_cyberpunk':
        if (frontWeight > 0.1) {
          final hudPaint = Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: frontWeight * 0.85);
          final hudRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 44 * foreshorten, headY + 16, 88 * foreshorten, 18),
            const Radius.circular(8),
          );
          canvas.drawRRect(hudRect, hudPaint);

          // Glowing scanline
          final linePaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 2.0;
          canvas.drawLine(
            Offset(cx - 36 * foreshorten, headY + 25),
            Offset(cx + 36 * foreshorten, headY + 25),
            linePaint,
          );
        }
        break;

      // 4. CASCO DE PILOTO AVIADOR
      case 'acc_casco_piloto':
        final capPaint = Paint()..color = const Color(0xFF78350F);
        // Cap curve over crown
        canvas.drawArc(
          Rect.fromLTWH(cx - 52 * foreshorten, headY - 32, 104 * foreshorten, 60),
          math.pi,
          math.pi,
          true,
          capPaint,
        );
        // Brass goggles
        if (frontWeight > 0.1) {
          final gogglePaint = Paint()..color = const Color(0xFF38BDF8);
          final rimPaint = Paint()
            ..color = const Color(0xFFFFD54F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          final g1 = Rect.fromCircle(center: Offset(cx - 16 * foreshorten, headY - 6), radius: 10 * foreshorten);
          final g2 = Rect.fromCircle(center: Offset(cx + 16 * foreshorten, headY - 6), radius: 10 * foreshorten);
          canvas.drawOval(g1, gogglePaint);
          canvas.drawOval(g2, gogglePaint);
          canvas.drawOval(g1, rimPaint);
          canvas.drawOval(g2, rimPaint);
        }
        break;

      // 5. GORRA SNAPBACK URBANA
      case 'acc_gorra':
        final crownPaint = Paint()..color = const Color(0xFF2563EB);
        final visorPaint = Paint()..color = const Color(0xFF00E5FF);

        // Cap crown
        canvas.drawArc(
          Rect.fromLTWH(cx - 48 * foreshorten, headY - 30, 96 * foreshorten, 55),
          math.pi,
          math.pi,
          true,
          crownPaint,
        );

        if (frontWeight > 0.1) {
          // Visor projecting forward
          final visorRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 52 * foreshorten, headY - 4, 104 * foreshorten, 12),
            const Radius.circular(6),
          );
          canvas.drawRRect(visorRect, visorPaint);
        }
        break;

      // 6. CORONA IMPERIAL
      case 'acc_corona':
        final goldCrown = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
          ).createShader(Rect.fromLTWH(cx - 36, headY - 40, 72, 36));

        final crownPath = Path();
        final cw = 36.0 * foreshorten;
        crownPath.moveTo(cx - cw, headY - 6);
        crownPath.lineTo(cx - cw, headY - 30);
        crownPath.lineTo(cx - cw * 0.5, headY - 18);
        crownPath.lineTo(cx, headY - 38);
        crownPath.lineTo(cx + cw * 0.5, headY - 18);
        crownPath.lineTo(cx + cw, headY - 30);
        crownPath.lineTo(cx + cw, headY - 6);
        crownPath.close();
        canvas.drawPath(crownPath, goldCrown);

        // Rubies & Emeralds on peaks
        final ruby = Paint()..color = const Color(0xFFDC2626);
        final emerald = Paint()..color = const Color(0xFF10B981);
        canvas.drawCircle(Offset(cx, headY - 36), 3.5, ruby);
        canvas.drawCircle(Offset(cx - cw * 0.9, headY - 28), 2.5, emerald);
        canvas.drawCircle(Offset(cx + cw * 0.9, headY - 28), 2.5, emerald);
        break;

      // 7. LENTES VIP
      case 'acc_lentes_vip':
        if (frontWeight > 0.1) {
          final alpha = (frontWeight * 255).clamp(0, 255).toInt();
          final lensPaint = Paint()..color = const Color(0xFF0F172A).withAlpha(alpha);
          final framePaint = Paint()
            ..color = const Color(0xFFFFD54F).withAlpha(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          final l1 = Rect.fromCircle(center: Offset(cx - 18 * foreshorten, headY + 14), radius: 11 * foreshorten);
          final l2 = Rect.fromCircle(center: Offset(cx + 18 * foreshorten, headY + 14), radius: 11 * foreshorten);
          canvas.drawOval(l1, lensPaint);
          canvas.drawOval(l2, lensPaint);
          canvas.drawOval(l1, framePaint);
          canvas.drawOval(l2, framePaint);
          canvas.drawLine(Offset(cx - 7 * foreshorten, headY + 14), Offset(cx + 7 * foreshorten, headY + 14), framePaint);
        }
        break;

      // 8. AURICULARES DJ
      case 'acc_auriculares':
        final phonePaint = Paint()..color = const Color(0xFF9333EA);
        final bandPaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;

        // Headband over crest
        canvas.drawArc(
          Rect.fromLTWH(cx - 56 * foreshorten, headY - 42, 112 * foreshorten, 60),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );

        // Side cushioned earcups
        canvas.drawOval(Rect.fromLTWH(cx - 58 * foreshorten, headY - 4, 14, 28), phonePaint);
        canvas.drawOval(Rect.fromLTWH(cx + 44 * foreshorten, headY - 4, 14, 28), phonePaint);
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
