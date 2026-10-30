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
                              child: SizedBox(
                                width: 200,
                                height: 181.45,
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Personaje Base SAMI (HD)
                                    Image.asset(
                                      currentAsset,
                                      fit: BoxFit.fill,
                                      width: 200,
                                      height: 181.45,
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

    // Normalizar ángulo en 4 cuadrantes correspondientes a los 4 renders 3D oficiales de SAMI
    final d = (angleDegrees % 360.0 + 360.0) % 360.0;
    final bool isFront = (d >= 315.0 || d < 45.0);
    final bool isRight = (d >= 45.0 && d < 135.0);
    final bool isBack = (d >= 135.0 && d < 225.0);
    final bool isLeft = (d >= 225.0 && d < 315.0);

    // 1. Capa trasera (si es superhéroe y se ve desde el frente / perfiles)
    _paintCapeBack(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 2. Calzado esculpido anatómicamente a las patitas de SAMI
    _paintSculptedShoes(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 3. Ropa esculpida ceñida al cuerpo, hombros, brazos y vientre de SAMI
    _paintSculptedClothing(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 4. Accesorios (Bufandas envolventes 360°, Cascos, Gorra, Corona, Gafas)
    _paintSculptedAccessories(canvas, w, h, isFront, isRight, isBack, isLeft);
  }

  // -------------------------------------------------------------------------
  // CAPA TRASERA DE SUPERHÉROE
  // -------------------------------------------------------------------------
  void _paintCapeBack(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isRight,
    bool isBack,
    bool isLeft,
  ) {
    if (equipment.clothingId != 'ropa_superheroe') return;

    final capePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE11D48), Color(0xFF9F1239), Color(0xFF4C0519)],
      ).createShader(Rect.fromLTWH(0, h * 0.40, w, h * 0.50));

    if (isFront) {
      // Alas de la capa asomándose ondulantes detrás de ambos hombros
      final leftWing = Path();
      leftWing.moveTo(w * 0.22, h * 0.60);
      leftWing.quadraticBezierTo(w * 0.08, h * 0.68, w * 0.11, h * 0.82);
      leftWing.quadraticBezierTo(w * 0.18, h * 0.76, w * 0.24, h * 0.68);
      leftWing.close();
      canvas.drawPath(leftWing, capePaint);

      final rightWing = Path();
      rightWing.moveTo(w * 0.78, h * 0.60);
      rightWing.quadraticBezierTo(w * 0.92, h * 0.68, w * 0.89, h * 0.82);
      rightWing.quadraticBezierTo(w * 0.82, h * 0.76, w * 0.76, h * 0.68);
      rightWing.close();
      canvas.drawPath(rightWing, capePaint);
    } else if (isRight) {
      // Capa ondeando hacia la izquierda (detrás de la espalda)
      final capePath = Path();
      capePath.moveTo(w * 0.32, h * 0.45);
      capePath.quadraticBezierTo(w * 0.12, h * 0.58, w * 0.14, h * 0.84);
      capePath.quadraticBezierTo(w * 0.28, h * 0.80, w * 0.35, h * 0.68);
      capePath.close();
      canvas.drawPath(capePath, capePaint);
    } else if (isLeft) {
      // Capa ondeando hacia la derecha (detrás de la espalda)
      final capePath = Path();
      capePath.moveTo(w * 0.68, h * 0.45);
      capePath.quadraticBezierTo(w * 0.88, h * 0.58, w * 0.86, h * 0.84);
      capePath.quadraticBezierTo(w * 0.72, h * 0.80, w * 0.65, h * 0.68);
      capePath.close();
      canvas.drawPath(capePath, capePaint);
    }
  }

  // -------------------------------------------------------------------------
  // ROPA ESCULPIDA Y CEÑIDA (Frente, Espalda y Laterales)
  // -------------------------------------------------------------------------
  void _paintSculptedClothing(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isRight,
    bool isBack,
    bool isLeft,
  ) {
    final clothId = equipment.clothingId;
    if (clothId == 'ropa_clasica') return;

    switch (clothId) {
      // =====================================================================
      // 1. TRAJE EJECUTIVO (Saco formal azul marino, camisa blanca y corbata)
      // =====================================================================
      case 'ropa_ejecutivo':
        final suitShader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        );

        if (isFront) {
          // A) Saco frontal cubriendo todo el cuerpo azul debajo de la cara blanca y ambos brazos
          final suitPath = Path();
          suitPath.moveTo(w * 0.28, h * 0.59);
          suitPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          // Hombro y manga derecha
          suitPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          suitPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          // Costado derecho y basta inferior
          suitPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          // Costado izquierdo y manga izquierda
          suitPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          suitPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          suitPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          suitPath.close();

          final suitPaint = Paint()
            ..shader = suitShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.24));
          canvas.drawPath(suitPath, suitPaint);

          // B) Puños blancos de la camisa en las muñecas
          final cuffPaint = Paint()..color = Colors.white;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.14, h * 0.72, w * 0.08, h * 0.024), const Radius.circular(3)),
            cuffPaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.78, h * 0.72, w * 0.08, h * 0.024), const Radius.circular(3)),
            cuffPaint,
          );

          // C) Cuello y pechera en V de la camisa blanca
          final shirtPath = Path();
          shirtPath.moveTo(w * 0.43, h * 0.605);
          shirtPath.lineTo(w * 0.57, h * 0.605);
          shirtPath.lineTo(w * 0.50, h * 0.70);
          shirtPath.close();
          canvas.drawPath(shirtPath, cuffPaint);

          // D) Corbata roja de seda
          final tieShader = const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
          ).createShader(Rect.fromLTWH(w * 0.46, h * 0.61, w * 0.08, h * 0.16));
          final tiePaint = Paint()..shader = tieShader;

          final tiePath = Path();
          // Nudo
          tiePath.moveTo(w * 0.47, h * 0.615);
          tiePath.lineTo(w * 0.53, h * 0.615);
          tiePath.lineTo(w * 0.52, h * 0.645);
          tiePath.lineTo(w * 0.48, h * 0.645);
          tiePath.close();
          // Cuerpo y punta de flecha
          tiePath.moveTo(w * 0.48, h * 0.645);
          tiePath.lineTo(w * 0.52, h * 0.645);
          tiePath.lineTo(w * 0.54, h * 0.74);
          tiePath.lineTo(w * 0.50, h * 0.77);
          tiePath.lineTo(w * 0.46, h * 0.74);
          tiePath.close();
          canvas.drawPath(tiePath, tiePaint);

          // E) Solapas del saco
          final lapelStroke = Paint()
            ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawLine(Offset(w * 0.41, h * 0.60), Offset(w * 0.49, h * 0.72), lapelStroke);
          canvas.drawLine(Offset(w * 0.59, h * 0.60), Offset(w * 0.51, h * 0.72), lapelStroke);

          // F) Botones dorados frontales
          final btnPaint = Paint()..color = const Color(0xFFFFD54F);
          canvas.drawCircle(Offset(w * 0.50, h * 0.75), 2.2, btnPaint);
          canvas.drawCircle(Offset(w * 0.50, h * 0.785), 2.2, btnPaint);
        } else if (isBack) {
          // Saco cubriendo la espalda completa desde la nuca (h * 0.35) hasta abajo (h * 0.815)
          final backSuit = Path();
          backSuit.moveTo(w * 0.44, h * 0.35);
          backSuit.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          // Hombros y mangas traseras
          backSuit.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          backSuit.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          backSuit.lineTo(w * 0.26, h * 0.815);
          backSuit.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          backSuit.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          backSuit.close();

          final backPaint = Paint()
            ..shader = suitShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.35, w * 0.76, h * 0.47));
          canvas.drawPath(backSuit, backPaint);

          // Cuellito blanco asomándose en la nuca
          final collarPaint = Paint()..color = Colors.white;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.34, w * 0.10, h * 0.018), const Radius.circular(2)),
            collarPaint,
          );

          // Costura central trasera con abertura de ventilación
          final seamPaint = Paint()
            ..color = const Color(0xFF0F172A)
            ..strokeWidth = 2.0;
          canvas.drawLine(Offset(w * 0.50, h * 0.37), Offset(w * 0.50, h * 0.77), seamPaint);
          // Abertura
          final ventPaint = Paint()
            ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
            ..strokeWidth = 1.2;
          canvas.drawLine(Offset(w * 0.50, h * 0.77), Offset(w * 0.49, h * 0.815), ventPaint);
        } else if (isRight) {
          // Perfil Derecho: El traje cubre la espalda a la izquierda y el pecho a la derecha
          final sideSuit = Path();
          sideSuit.moveTo(w * 0.55, h * 0.59);
          sideSuit.quadraticBezierTo(w * 0.76, h * 0.64, w * 0.74, h * 0.82);
          sideSuit.lineTo(w * 0.22, h * 0.82);
          sideSuit.quadraticBezierTo(w * 0.20, h * 0.55, w * 0.28, h * 0.36);
          sideSuit.quadraticBezierTo(w * 0.42, h * 0.42, w * 0.55, h * 0.59);
          sideSuit.close();

          final sidePaint = Paint()
            ..shader = suitShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.56, h * 0.46));
          canvas.drawPath(sideSuit, sidePaint);

          // Manga cubriendo el brazo derecho
          final sleevePath = Path();
          sleevePath.moveTo(w * 0.24, h * 0.56);
          sleevePath.quadraticBezierTo(w * 0.36, h * 0.56, w * 0.38, h * 0.74);
          sleevePath.lineTo(w * 0.26, h * 0.76);
          sleevePath.close();
          canvas.drawPath(sleevePath, Paint()..color = const Color(0xFF1E3A8A));

          // Puño blanco
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.74, w * 0.12, h * 0.022), const Radius.circular(3)),
            Paint()..color = Colors.white,
          );

          // Asomo de solapa y corbata en el perfil del pecho
          final tieProfile = Path();
          tieProfile.moveTo(w * 0.64, h * 0.62);
          tieProfile.lineTo(w * 0.70, h * 0.63);
          tieProfile.lineTo(w * 0.68, h * 0.72);
          tieProfile.close();
          canvas.drawPath(tieProfile, Paint()..color = const Color(0xFFEF4444));
        } else if (isLeft) {
          // Perfil Izquierdo: Simétrico al derecho
          final sideSuit = Path();
          sideSuit.moveTo(w * 0.45, h * 0.59);
          sideSuit.quadraticBezierTo(w * 0.24, h * 0.64, w * 0.26, h * 0.82);
          sideSuit.lineTo(w * 0.78, h * 0.82);
          sideSuit.quadraticBezierTo(w * 0.80, h * 0.55, w * 0.72, h * 0.36);
          sideSuit.quadraticBezierTo(w * 0.58, h * 0.42, w * 0.45, h * 0.59);
          sideSuit.close();

          final sidePaint = Paint()
            ..shader = suitShader.createShader(Rect.fromLTWH(w * 0.24, h * 0.36, w * 0.56, h * 0.46));
          canvas.drawPath(sideSuit, sidePaint);

          // Manga cubriendo el brazo izquierdo
          final sleevePath = Path();
          sleevePath.moveTo(w * 0.76, h * 0.56);
          sleevePath.quadraticBezierTo(w * 0.64, h * 0.56, w * 0.62, h * 0.74);
          sleevePath.lineTo(w * 0.74, h * 0.76);
          sleevePath.close();
          canvas.drawPath(sleevePath, Paint()..color = const Color(0xFF1E3A8A));

          // Puño blanco
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.63, h * 0.74, w * 0.12, h * 0.022), const Radius.circular(3)),
            Paint()..color = Colors.white,
          );

          // Asomo de solapa y corbata
          final tieProfile = Path();
          tieProfile.moveTo(w * 0.36, h * 0.62);
          tieProfile.lineTo(w * 0.30, h * 0.63);
          tieProfile.lineTo(w * 0.32, h * 0.72);
          tieProfile.close();
          canvas.drawPath(tieProfile, Paint()..color = const Color(0xFFEF4444));
        }
        break;

      // =====================================================================
      // 2. SUDADERA STREETWEAR (Hoodie cyan con bolsillo canguro y capucha)
      // =====================================================================
      case 'ropa_sudadera':
        final hoodieShader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
        );

        if (isFront) {
          final bodyPath = Path();
          bodyPath.moveTo(w * 0.28, h * 0.59);
          bodyPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          bodyPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          bodyPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          bodyPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          bodyPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          bodyPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          bodyPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          bodyPath.close();

          canvas.drawPath(bodyPath, Paint()..shader = hoodieShader.createShader(Rect.fromLTWH(0, 0, w, h)));

          // Ribete elástico inferior
          final hemRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.27, h * 0.785, w * 0.46, h * 0.030),
            const Radius.circular(5),
          );
          canvas.drawRRect(hemRect, Paint()..color = const Color(0xFF0369A1));

          // Bolsillo canguro central
          final pocketPath = Path();
          pocketPath.moveTo(w * 0.38, h * 0.69);
          pocketPath.lineTo(w * 0.62, h * 0.69);
          pocketPath.lineTo(w * 0.67, h * 0.78);
          pocketPath.lineTo(w * 0.33, h * 0.78);
          pocketPath.close();
          canvas.drawPath(pocketPath, Paint()..color = const Color(0xFF0284C7));

          // Cordones de la capucha con herretes blancos
          final cordPaint = Paint()..color = Colors.white..strokeWidth = 2.0;
          canvas.drawLine(Offset(w * 0.46, h * 0.61), Offset(w * 0.46, h * 0.69), cordPaint);
          canvas.drawLine(Offset(w * 0.54, h * 0.61), Offset(w * 0.54, h * 0.69), cordPaint);
        } else if (isBack) {
          // Espalda con la capucha descansando en la nuca
          final backBody = Path();
          backBody.moveTo(w * 0.44, h * 0.35);
          backBody.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          backBody.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          backBody.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          backBody.lineTo(w * 0.26, h * 0.815);
          backBody.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          backBody.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          backBody.close();

          canvas.drawPath(backBody, Paint()..shader = hoodieShader.createShader(Rect.fromLTWH(0, 0, w, h)));

          // Capucha descansando en la nuca
          final hoodRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.36, h * 0.33, w * 0.28, h * 0.12),
            const Radius.circular(14),
          );
          canvas.drawRRect(hoodRect, Paint()..color = const Color(0xFF0369A1));
        } else {
          // Perfiles
          final sideRect = Rect.fromLTWH(w * 0.22, h * 0.40, w * 0.56, h * 0.42);
          canvas.drawRRect(
            RRect.fromRectAndRadius(sideRect, const Radius.circular(22)),
            Paint()..shader = hoodieShader.createShader(sideRect),
          );
        }
        break;

      // =====================================================================
      // 3. TRAJE DE SUPERHÉROE (Escarlata con escudo dorado y capa)
      // =====================================================================
      case 'ropa_superheroe':
        final heroShader = const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
        );

        if (isFront) {
          final heroBody = Path();
          heroBody.moveTo(w * 0.28, h * 0.59);
          heroBody.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          heroBody.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          heroBody.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          heroBody.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          heroBody.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          heroBody.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          heroBody.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          heroBody.close();

          canvas.drawPath(heroBody, Paint()..shader = heroShader.createShader(Rect.fromLTWH(0, 0, w, h)));

          // Escudo dorado con "Q" en el pecho
          final emblemCenter = Offset(w * 0.50, h * 0.69);
          canvas.drawCircle(emblemCenter, w * 0.075, Paint()..color = const Color(0xFFFFD54F));
          canvas.drawCircle(emblemCenter, w * 0.065, Paint()..color = const Color(0xFFFF8F00));
          // Letra Q
          canvas.drawCircle(
            emblemCenter,
            w * 0.035,
            Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0,
          );

          // Cinturón de héroe dorado
          final beltRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, h * 0.77, w * 0.40, h * 0.032),
            const Radius.circular(5),
          );
          canvas.drawRRect(beltRect, Paint()..color = const Color(0xFFFFB300));
          canvas.drawCircle(Offset(w * 0.50, h * 0.786), 4.0, Paint()..color = const Color(0xFFFFE082));
        } else if (isBack) {
          // Capa cayendo por toda la espalda
          final fullCape = Path();
          fullCape.moveTo(w * 0.36, h * 0.35);
          fullCape.quadraticBezierTo(w * 0.50, h * 0.34, w * 0.64, h * 0.35);
          fullCape.quadraticBezierTo(w * 0.88, h * 0.58, w * 0.85, h * 0.85);
          fullCape.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.15, h * 0.85);
          fullCape.quadraticBezierTo(w * 0.12, h * 0.58, w * 0.36, h * 0.35);
          fullCape.close();

          canvas.drawPath(
            fullCape,
            Paint()..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE11D48), Color(0xFF7F1D1D)],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
          );

          // Broches dorados en los hombros
          canvas.drawCircle(Offset(w * 0.36, h * 0.37), 4.0, Paint()..color = const Color(0xFFFFD54F));
          canvas.drawCircle(Offset(w * 0.64, h * 0.37), 4.0, Paint()..color = const Color(0xFFFFD54F));
        } else {
          // Perfiles
          final sideRect = Rect.fromLTWH(w * 0.22, h * 0.40, w * 0.56, h * 0.42);
          canvas.drawRRect(
            RRect.fromRectAndRadius(sideRect, const Radius.circular(22)),
            Paint()..shader = heroShader.createShader(sideRect),
          );
        }
        break;

      // =====================================================================
      // 4. FILIPINA DE CHEF
      // =====================================================================
      case 'ropa_chef':
        final chefPath = Path();
        if (isFront) {
          chefPath.moveTo(w * 0.28, h * 0.59);
          chefPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          chefPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          chefPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          chefPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          chefPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          chefPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          chefPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          chefPath.close();
          canvas.drawPath(chefPath, Paint()..color = const Color(0xFFF8FAFC));

          // Botones dorados dobles de chef
          final goldBtn = Paint()..color = const Color(0xFFFFD54F);
          canvas.drawCircle(Offset(w * 0.44, h * 0.66), 2.5, goldBtn);
          canvas.drawCircle(Offset(w * 0.56, h * 0.66), 2.5, goldBtn);
          canvas.drawCircle(Offset(w * 0.44, h * 0.71), 2.5, goldBtn);
          canvas.drawCircle(Offset(w * 0.56, h * 0.71), 2.5, goldBtn);
          canvas.drawCircle(Offset(w * 0.44, h * 0.76), 2.5, goldBtn);
          canvas.drawCircle(Offset(w * 0.56, h * 0.76), 2.5, goldBtn);
        } else if (isBack) {
          chefPath.moveTo(w * 0.44, h * 0.35);
          chefPath.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          chefPath.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          chefPath.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          chefPath.lineTo(w * 0.26, h * 0.815);
          chefPath.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          chefPath.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          chefPath.close();
          canvas.drawPath(chefPath, Paint()..color = const Color(0xFFF1F5F9));
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.40, w * 0.56, h * 0.42), const Radius.circular(22)),
            Paint()..color = Colors.white,
          );
        }
        break;

      // =====================================================================
      // 5. ARMADURA GALÁCTICA
      // =====================================================================
      case 'ropa_armadura':
        final armorShader = const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF0F172A)],
        );
        final armorPath = Path();
        if (isFront) {
          armorPath.moveTo(w * 0.28, h * 0.59);
          armorPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          armorPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          armorPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          armorPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          armorPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          armorPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          armorPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          armorPath.close();
          canvas.drawPath(armorPath, Paint()..shader = armorShader.createShader(Rect.fromLTWH(0, 0, w, h)));

          // Reactor de arco cyan central
          final reactorCenter = Offset(w * 0.50, h * 0.69);
          canvas.drawCircle(reactorCenter, w * 0.055, Paint()..color = const Color(0xFF00E5FF));
          canvas.drawCircle(reactorCenter, w * 0.035, Paint()..color = Colors.white);
        } else if (isBack) {
          armorPath.moveTo(w * 0.44, h * 0.35);
          armorPath.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          armorPath.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          armorPath.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          armorPath.lineTo(w * 0.26, h * 0.815);
          armorPath.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          armorPath.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          armorPath.close();
          canvas.drawPath(armorPath, Paint()..shader = armorShader.createShader(Rect.fromLTWH(0, 0, w, h)));

          // Propulsores cibernéticos traseros
          canvas.drawCircle(Offset(w * 0.42, h * 0.55), 6.0, Paint()..color = const Color(0xFF00E5FF));
          canvas.drawCircle(Offset(w * 0.58, h * 0.55), 6.0, Paint()..color = const Color(0xFF00E5FF));
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.40, w * 0.56, h * 0.42), const Radius.circular(22)),
            Paint()..shader = armorShader.createShader(Rect.fromLTWH(0, 0, w, h)),
          );
        }
        break;

      // =====================================================================
      // 6. TOGA IMPERIAL & DEPORTIVO
      // =====================================================================
      case 'ropa_toga':
      case 'ropa_deportiva':
      default:
        final togaShader = (clothId == 'ropa_toga')
            ? const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)])
            : const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF115E59)]);

        final genPath = Path();
        if (isFront) {
          genPath.moveTo(w * 0.28, h * 0.59);
          genPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          genPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          genPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          genPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          genPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          genPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          genPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          genPath.close();
        } else if (isBack) {
          genPath.moveTo(w * 0.44, h * 0.35);
          genPath.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          genPath.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          genPath.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          genPath.lineTo(w * 0.26, h * 0.815);
          genPath.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          genPath.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          genPath.close();
        } else {
          genPath.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.40, w * 0.56, h * 0.42), const Radius.circular(22)));
        }
        canvas.drawPath(genPath, Paint()..shader = togaShader.createShader(Rect.fromLTWH(0, 0, w, h)));
        break;
    }
  }

  // -------------------------------------------------------------------------
  // CALZADO ESCULPIDO A LAS PATITAS DE SAMI
  // -------------------------------------------------------------------------
  void _paintSculptedShoes(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isRight,
    bool isBack,
    bool isLeft,
  ) {
    final shoeId = equipment.shoesId;
    if (shoeId == 'zap_clasicos') return;

    Color upperColor;
    Color soleColor;

    switch (shoeId) {
      case 'zap_sneakers':
        upperColor = const Color(0xFF00E5FF);
        soleColor = Colors.white;
        break;
      case 'zap_botas':
        upperColor = const Color(0xFF8B4513);
        soleColor = const Color(0xFF3E1D06);
        break;
      case 'zap_charol':
        upperColor = const Color(0xFF0F172A);
        soleColor = const Color(0xFF334155);
        break;
      case 'zap_espaciales':
        upperColor = const Color(0xFF7C3AED);
        soleColor = const Color(0xFF00E5FF);
        break;
      case 'zap_dorados':
        upperColor = const Color(0xFFFFD54F);
        soleColor = const Color(0xFFB45309);
        break;
      default:
        upperColor = const Color(0xFF00E5FF);
        soleColor = Colors.white;
    }

    final upperPaint = Paint()..color = upperColor;
    final solePaint = Paint()..color = soleColor;

    if (isFront || isBack) {
      // Patita Izquierda
      final leftRect = Rect.fromLTWH(w * 0.26, h * 0.81, w * 0.19, h * 0.11);
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(10)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.88, w * 0.21, h * 0.04), const Radius.circular(4)),
        solePaint,
      );

      // Patita Derecha
      final rightRect = Rect.fromLTWH(w * 0.55, h * 0.81, w * 0.19, h * 0.11);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(10)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.54, h * 0.88, w * 0.21, h * 0.04), const Radius.circular(4)),
        solePaint,
      );

      // Detalle de agujetas / broches
      if (isFront) {
        final lacePaint = Paint()..color = Colors.white..strokeWidth = 1.5;
        canvas.drawLine(Offset(w * 0.31, h * 0.84), Offset(w * 0.39, h * 0.84), lacePaint);
        canvas.drawLine(Offset(w * 0.60, h * 0.84), Offset(w * 0.68, h * 0.84), lacePaint);
      }
    } else if (isRight) {
      // Perfil Derecho
      final fRect = Rect.fromLTWH(w * 0.48, h * 0.82, w * 0.23, h * 0.11);
      canvas.drawRRect(RRect.fromRectAndRadius(fRect, const Radius.circular(10)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.47, h * 0.89, w * 0.25, h * 0.04), const Radius.circular(4)),
        solePaint,
      );

      final bRect = Rect.fromLTWH(w * 0.28, h * 0.81, w * 0.19, h * 0.10);
      canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(8)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.27, h * 0.88, w * 0.21, h * 0.035), const Radius.circular(4)),
        solePaint,
      );
    } else if (isLeft) {
      // Perfil Izquierdo
      final fRect = Rect.fromLTWH(w * 0.29, h * 0.82, w * 0.23, h * 0.11);
      canvas.drawRRect(RRect.fromRectAndRadius(fRect, const Radius.circular(10)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.89, w * 0.25, h * 0.04), const Radius.circular(4)),
        solePaint,
      );

      final bRect = Rect.fromLTWH(w * 0.53, h * 0.81, w * 0.19, h * 0.10);
      canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(8)), upperPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.88, w * 0.21, h * 0.035), const Radius.circular(4)),
        solePaint,
      );
    }
  }

  // -------------------------------------------------------------------------
  // ACCESORIOS (Bufandas, Cascos, Gorra, Corona, Lentes)
  // -------------------------------------------------------------------------
  void _paintSculptedAccessories(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isRight,
    bool isBack,
    bool isLeft,
  ) {
    final accId = equipment.accessoryId;
    if (accId == 'acc_ninguno') return;

    switch (accId) {
      // 1. BUFANDAS (Envolventes alrededor del cuello)
      case 'acc_bufanda_nordica':
      case 'acc_bufanda_carmesi':
        final isNordic = (accId == 'acc_bufanda_nordica');
        final scarfColor = isNordic ? const Color(0xFF0284C7) : const Color(0xFFE11D48);
        final scarfAccent = isNordic ? Colors.white : const Color(0xFFFFD54F);

        if (isFront) {
          // Aro envolvente en la base de la cara blanca
          final neckRing = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.26, h * 0.56, w * 0.48, h * 0.08),
            const Radius.circular(14),
          );
          canvas.drawRRect(neckRing, Paint()..color = scarfColor);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.56, w * 0.08, h * 0.08), const Radius.circular(6)),
            Paint()..color = scarfAccent,
          );
          // Cola colgante de la bufanda sobre el pecho
          final tail = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.36, h * 0.62, w * 0.12, h * 0.15),
            const Radius.circular(6),
          );
          canvas.drawRRect(tail, Paint()..color = scarfColor);
          canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.74, w * 0.12, h * 0.015), Paint()..color = scarfAccent);
        } else if (isBack) {
          final backRing = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.34, h * 0.33, w * 0.32, h * 0.075),
            const Radius.circular(12),
          );
          canvas.drawRRect(backRing, Paint()..color = scarfColor);
        } else {
          final sideRing = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.32, h * 0.48, w * 0.36, h * 0.08),
            const Radius.circular(12),
          );
          canvas.drawRRect(sideRing, Paint()..color = scarfColor);
        }
        break;

      // 2. CASCO DE ASTRONAUTA (Burbuja transparente de cristal)
      case 'acc_casco_astronauta':
        final helmetCenter = Offset(w * 0.50, h * 0.38);
        final domeRadius = w * 0.34;

        final domeShader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withValues(alpha: 0.30),
            const Color(0xFF00E5FF).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: helmetCenter, radius: domeRadius));

        canvas.drawCircle(helmetCenter, domeRadius, Paint()..shader = domeShader);
        canvas.drawCircle(
          helmetCenter,
          domeRadius,
          Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 2.0,
        );
        // Destello de reflejo curvado
        final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 2.5;
        canvas.drawArc(
          Rect.fromCircle(center: helmetCenter, radius: domeRadius * 0.85),
          math.pi * 1.15,
          math.pi * 0.45,
          false,
          glintPaint,
        );
        break;

      // 3. GORRA SNAPBACK URBANA
      case 'acc_gorra':
        if (isFront || isBack) {
          canvas.drawArc(
            Rect.fromLTWH(w * 0.30, h * 0.14, w * 0.40, h * 0.20),
            math.pi,
            math.pi,
            true,
            Paint()..color = const Color(0xFF2563EB),
          );
          if (isFront) {
            // Visera plana cyan al frente
            final visor = RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.04),
              const Radius.circular(6),
            );
            canvas.drawRRect(visor, Paint()..color = const Color(0xFF00E5FF));
          }
        } else {
          canvas.drawArc(
            Rect.fromLTWH(w * 0.28, h * 0.14, w * 0.44, h * 0.20),
            math.pi,
            math.pi,
            true,
            Paint()..color = const Color(0xFF2563EB),
          );
        }
        break;

      // 4. CORONA IMPERIAL
      case 'acc_corona':
        final crownPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
          ).createShader(Rect.fromLTWH(w * 0.36, h * 0.10, w * 0.28, h * 0.14));

        final crownPath = Path();
        crownPath.moveTo(w * 0.36, h * 0.22);
        crownPath.lineTo(w * 0.36, h * 0.12);
        crownPath.lineTo(w * 0.43, h * 0.16);
        crownPath.lineTo(w * 0.50, h * 0.09);
        crownPath.lineTo(w * 0.57, h * 0.16);
        crownPath.lineTo(w * 0.64, h * 0.12);
        crownPath.lineTo(w * 0.64, h * 0.22);
        crownPath.close();
        canvas.drawPath(crownPath, crownPaint);

        // Gemas en las puntas
        canvas.drawCircle(Offset(w * 0.50, h * 0.09), 3.0, Paint()..color = const Color(0xFFDC2626));
        canvas.drawCircle(Offset(w * 0.36, h * 0.12), 2.2, Paint()..color = const Color(0xFF10B981));
        canvas.drawCircle(Offset(w * 0.64, h * 0.12), 2.2, Paint()..color = const Color(0xFF10B981));
        break;

      // 5. LENTES DE SOL VIP
      case 'acc_lentes_vip':
        if (isFront) {
          final lensPaint = Paint()..color = const Color(0xFF0F172A);
          final framePaint = Paint()
            ..color = const Color(0xFFFFD54F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          // Lente izquierdo
          final l1 = Rect.fromCircle(center: Offset(w * 0.42, h * 0.45), radius: w * 0.065);
          // Lente derecho
          final l2 = Rect.fromCircle(center: Offset(w * 0.58, h * 0.45), radius: w * 0.065);

          canvas.drawOval(l1, lensPaint);
          canvas.drawOval(l2, lensPaint);
          canvas.drawOval(l1, framePaint);
          canvas.drawOval(l2, framePaint);
          // Puente
          canvas.drawLine(Offset(w * 0.485, h * 0.45), Offset(w * 0.515, h * 0.45), framePaint);
        } else if (isRight) {
          final l = Rect.fromCircle(center: Offset(w * 0.66, h * 0.44), radius: w * 0.065);
          canvas.drawOval(l, Paint()..color = const Color(0xFF0F172A));
          canvas.drawOval(l, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 2.0);
        } else if (isLeft) {
          final l = Rect.fromCircle(center: Offset(w * 0.34, h * 0.44), radius: w * 0.065);
          canvas.drawOval(l, Paint()..color = const Color(0xFF0F172A));
          canvas.drawOval(l, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 2.0);
        }
        break;

      // 6. AURICULARES GAMER DJ
      case 'acc_auriculares':
        final bandPaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        final cupPaint = Paint()..color = const Color(0xFF9333EA);

        // Diadema sobre la cabeza
        canvas.drawArc(
          Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.28),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );
        // Almohadillas a los lados
        canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.24, w * 0.06, h * 0.09), cupPaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.66, h * 0.24, w * 0.06, h * 0.09), cupPaint);
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
