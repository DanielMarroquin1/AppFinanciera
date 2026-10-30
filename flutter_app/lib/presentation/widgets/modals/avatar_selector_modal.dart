import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';

enum _ArmarioTab {
  ropa,
  zapatos,
  cabeza,
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
  // Rotación 3D continua (0 a 360 grados)
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

  // Categoría activa de pestaña en el armario rediseñado
  _ArmarioTab _activeTab = _ArmarioTab.ropa;

  // Equipamiento actual en vista previa (Simulación / Probador en vivo)
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

    // Giro automático continuo
    _autoSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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

  void _snapToAngle(double deg) {
    AppHaptics.selection();
    if (_isAutoSpinning) {
      _autoSpinController.stop();
      _isAutoSpinning = false;
    }
    setState(() {
      _rotationDegrees = deg % 360.0;
    });
  }

  bool _isItemUnlocked(WardrobeItem item, List<String> unlocked) {
    if (item.isFree) return true;
    return unlocked.contains(item.id) ||
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

  /// Al tocar CUALQUIER prenda (incluso si no está comprada), SAMI se la pone inmediatamente en 3D
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
                        '¡Registra tus transacciones y mantén tu racha para ganar más monedas!',
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

  String _getCurrentSamiAsset(double deg) {
    final d = (deg % 360.0 + 360.0) % 360.0;
    if (d >= 315.0 || d < 45.0) {
      if (_isBlinking) {
        return 'assets/images/sami_3d_front.png';
      }
      return 'assets/images/sami_3d_front_open.png';
    } else if (d >= 45.0 && d < 135.0) {
      return 'assets/images/sami_3d_facing_right.png';
    } else if (d >= 135.0 && d < 225.0) {
      return 'assets/images/sami_3d_back.png';
    } else {
      return 'assets/images/sami_3d_facing_left.png';
    }
  }

  List<WardrobeItem> _getItemsForActiveTab() {
    switch (_activeTab) {
      case _ArmarioTab.ropa:
        return WardrobeItem.getByCategory(WardrobeCategory.clothing);
      case _ArmarioTab.zapatos:
        return WardrobeItem.getByCategory(WardrobeCategory.shoes);
      case _ArmarioTab.cabeza:
        final allAcc = WardrobeItem.getByCategory(WardrobeCategory.accessories);
        final none = allAcc.firstWhere((i) => i.id == 'acc_ninguno');
        final headItems = allAcc.where((i) => _isHeadItem(i.id)).toList();
        return [none, ...headItems];
      case _ArmarioTab.accesorios:
        final allAcc = WardrobeItem.getByCategory(WardrobeCategory.accessories);
        return allAcc.where((i) => !_isHeadItem(i.id)).toList();
    }
  }

  String _getAngleDescription(double deg) {
    final d = (deg % 360.0 + 360.0) % 360.0;
    if (d >= 315.0 || d < 45.0) {
      return 'Frente (0°)';
    } else if (d >= 45.0 && d < 135.0) {
      return 'Perfil Der (90°)';
    } else if (d >= 135.0 && d < 225.0) {
      return 'Espalda (180°)';
    } else {
      return 'Perfil Izq (270°)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final activeItems = _getItemsForActiveTab();
    final normalizedDeg = (_rotationDegrees % 360.0 + 360.0) % 360.0;
    final currentAsset = _getCurrentSamiAsset(normalizedDeg);

    final perspectiveAngle =
        (normalizedDeg % 90.0 - 45.0) * (math.pi / 180.0) * 0.35;

    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 3.5;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.10)
        : 1.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0A141B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E3A4A), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF2C4452),
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
                      'Personaliza ropa, zapatos y accesorios en 3D',
                      style: TextStyle(
                        color: Color(0xFF8BA0AE),
                        fontSize: 11.5,
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
                    color: const Color(0xFF172832),
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

          const SizedBox(height: 4),

          // =================================================================
          // ESCENARIO 3D INTERACTIVO CON SIMULACIÓN EN VIVO (TURNTABLE STAGE)
          // =================================================================
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.90,
                colors: [
                  Color(0xFF122C3A),
                  Color(0xFF0D1D27),
                  Color(0xFF071016),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF1F3846), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Plataforma circular interactiva
                  Positioned(
                    bottom: 10,
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

                                    // 2. SIMULACIÓN DE ROPA, ZAPATOS Y ACCESORIOS EN VIVO (Con retiro de pelo en cabeza)
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
                                                .withValues(alpha: 0.35),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Color(0xFF00E5FF),
                                            size: 16,
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

                  // Globo de diálogo si SAMI está saludando o fue tocado
                  if (_speechMessage != null)
                    Positioned(
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        constraints: const BoxConstraints(maxWidth: 240),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2B3B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          _speechMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Controles Superiores del Escenario: Indicador de Ángulo y Auto-Giro
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF09161F).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF1E3A4A),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.compass, size: 12, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 5),
                          Text(
                            _getAngleDescription(normalizedDeg),
                            style: const TextStyle(
                              color: Color(0xFF7DD3FC),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones de acción flotantes a la derecha: Saludar y Auto-Girar
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón Saludar 👋
                        GestureDetector(
                          onTap: _onTapSami,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF09161F).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF1E3A4A),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('👋', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'Saludar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Botón Auto-Girar 💫
                        GestureDetector(
                          onTap: _toggleAutoSpin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isAutoSpinning
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                                  : const Color(0xFF09161F).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isAutoSpinning
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF1E3A4A),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.rotateCw,
                                  size: 12,
                                  color: _isAutoSpinning
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF8BA0AE),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isAutoSpinning ? 'Girando' : 'Girar',
                                  style: TextStyle(
                                    color: _isAutoSpinning
                                        ? const Color(0xFF00E5FF)
                                        : Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barra Inferior de Ángulos Rápidos: [ Frente | Perfil Der | Espalda | Perfil Izq ]
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D12).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1B313E),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAngleSnapButton(label: 'Frente', deg: 0.0, currentDeg: normalizedDeg),
                          _buildAngleSnapButton(label: 'Perfil', deg: 90.0, currentDeg: normalizedDeg),
                          _buildAngleSnapButton(label: 'Espalda', deg: 180.0, currentDeg: normalizedDeg),
                          _buildAngleSnapButton(label: 'Perfil', deg: 270.0, currentDeg: normalizedDeg),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // =================================================================
          // SELECTOR DE CATEGORÍAS REDISEÑADO: [ 👕 Ropa | 👟 Zapatos | 👑 Cabeza | 🧣 Accesorios ]
          // =================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryTab(
                  label: 'Ropa',
                  emoji: '👕',
                  tab: _ArmarioTab.ropa,
                ),
                const SizedBox(width: 6),
                _buildCategoryTab(
                  label: 'Zapatos',
                  emoji: '👟',
                  tab: _ArmarioTab.zapatos,
                ),
                const SizedBox(width: 6),
                _buildCategoryTab(
                  label: 'Cabeza',
                  emoji: '👑',
                  tab: _ArmarioTab.cabeza,
                ),
                const SizedBox(width: 6),
                _buildCategoryTab(
                  label: 'Accesorios',
                  emoji: '🧣',
                  tab: _ArmarioTab.accesorios,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =================================================================
          // CUADRÍCULA DE PRENDAS Y ACCESORIOS (PROBADOR EN VIVO)
          // =================================================================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.15,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                final isSelected = _selectedItem.id == item.id;
                final isEquipped = _isItemEquipped(item);
                final isUnlocked = _isItemUnlocked(item, unlockedList);

                return GestureDetector(
                  onTap: () => _tryOnItem(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF142B38)
                          : const Color(0xFF111D25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00E5FF)
                            : (isEquipped
                                ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                : const Color(0xFF1E313D)),
                        width: isSelected ? 2.0 : 1.2,
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
                          width: 44,
                          height: 44,
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
                        const SizedBox(width: 8),
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
                                  fontSize: 12,
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
                            size: 13,
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
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0C161C),
              border: Border(
                top: BorderSide(color: Color(0xFF192A34), width: 1.5),
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
                                  fontSize: 13.5,
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
                  const SizedBox(width: 14),
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
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
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
                        : Text(
                            isSelectedEquipped
                                ? '✓ Equipado'
                                : (isSelectedUnlocked
                                    ? 'Equipar'
                                    : '🪙 ${_selectedItem.cost}'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
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

  Widget _buildAngleSnapButton({
    required String label,
    required double deg,
    required double currentDeg,
  }) {
    final diff = (currentDeg - deg).abs();
    final isCurrent = diff < 45.0 || diff > 315.0;

    return GestureDetector(
      onTap: () => _snapToAngle(deg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isCurrent ? const Color(0xFF00E5FF) : const Color(0xFF8BA0AE),
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required String emoji,
    required _ArmarioTab tab,
  }) {
    final isSelected = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          setState(() => _activeTab = tab);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1CB0F6)
                : const Color(0xFF14242D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF223541),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF092A40) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
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

  bool get _hasHeadAccessory {
    final id = equipment.accessoryId;
    return id == 'acc_casco_astronauta' ||
        id == 'acc_gorra' ||
        id == 'acc_corona' ||
        id == 'acc_auriculares' ||
        id == 'acc_casco_cyberpunk' ||
        id == 'acc_casco_piloto';
  }

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

    // 0. Si tiene accesorio en la cabeza, QUITARLE EL PELO cubriendo el brote cyan con la piel azul de SAMI
    if (_hasHeadAccessory) {
      _coverHeadSprout(canvas, w, h, isFront, isRight, isBack, isLeft);
    }

    // 1. Capa trasera (si es superhéroe y se ve desde el frente / perfiles)
    _paintCapeBack(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 2. Calzado esculpido anatómicamente a las patitas de SAMI (frente, espalda, laterales)
    _paintSculptedShoes(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 3. Ropa esculpida ceñida al cuerpo, hombros, brazos y vientre de SAMI
    _paintSculptedClothing(canvas, w, h, isFront, isRight, isBack, isLeft);

    // 4. Accesorios (Bufandas envolventes 360°, Cascos, Gorra, Corona, Gafas)
    _paintSculptedAccessories(canvas, w, h, isFront, isRight, isBack, isLeft);
  }

  // -------------------------------------------------------------------------
  // OCULTAR EL PELO DE SAMI (BROTE CYAN) CUANDO USA ACCESORIO EN LA CABEZA
  // -------------------------------------------------------------------------
  void _coverHeadSprout(
    Canvas canvas,
    double w,
    double h,
    bool isFront,
    bool isRight,
    bool isBack,
    bool isLeft,
  ) {
    final sproutCenter = isFront
        ? Offset(w * 0.53, h * 0.17)
        : isBack
            ? Offset(w * 0.52, h * 0.17)
            : isRight
                ? Offset(w * 0.56, h * 0.16)
                : Offset(w * 0.44, h * 0.16);

    final skullPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: const [
          Color(0xFF034A74),
          Color(0xFF003859),
          Color(0xFF002237),
        ],
      ).createShader(Rect.fromCircle(center: sproutCenter, radius: w * 0.22));

    canvas.drawOval(
      Rect.fromCenter(center: sproutCenter, width: w * 0.38, height: h * 0.20),
      skullPaint,
    );
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
      final capePath = Path();
      capePath.moveTo(w * 0.32, h * 0.45);
      capePath.quadraticBezierTo(w * 0.10, h * 0.58, w * 0.12, h * 0.84);
      capePath.quadraticBezierTo(w * 0.28, h * 0.80, w * 0.35, h * 0.68);
      capePath.close();
      canvas.drawPath(capePath, capePaint);
    } else if (isLeft) {
      final capePath = Path();
      capePath.moveTo(w * 0.68, h * 0.45);
      capePath.quadraticBezierTo(w * 0.90, h * 0.58, w * 0.88, h * 0.84);
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
      // 1. TRAJE EJECUTIVO
      case 'ropa_ejecutivo':
        final suitShader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        );

        if (isFront) {
          final suitPath = Path();
          suitPath.moveTo(w * 0.28, h * 0.59);
          suitPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.72, h * 0.59);
          suitPath.quadraticBezierTo(w * 0.82, h * 0.63, w * 0.87, h * 0.67);
          suitPath.quadraticBezierTo(w * 0.88, h * 0.74, w * 0.78, h * 0.76);
          suitPath.quadraticBezierTo(w * 0.75, h * 0.815, w * 0.50, h * 0.815);
          suitPath.quadraticBezierTo(w * 0.25, h * 0.815, w * 0.22, h * 0.76);
          suitPath.quadraticBezierTo(w * 0.12, h * 0.74, w * 0.13, h * 0.67);
          suitPath.quadraticBezierTo(w * 0.18, h * 0.63, w * 0.28, h * 0.59);
          suitPath.close();

          canvas.drawPath(
            suitPath,
            Paint()..shader = suitShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.24)),
          );

          // Puños blancos
          final cuffPaint = Paint()..color = Colors.white;
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.14, h * 0.72, w * 0.08, h * 0.024), const Radius.circular(3)), cuffPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.78, h * 0.72, w * 0.08, h * 0.024), const Radius.circular(3)), cuffPaint);

          // Pechera blanca en V
          final shirtPath = Path();
          shirtPath.moveTo(w * 0.43, h * 0.605);
          shirtPath.lineTo(w * 0.57, h * 0.605);
          shirtPath.lineTo(w * 0.50, h * 0.70);
          shirtPath.close();
          canvas.drawPath(shirtPath, cuffPaint);

          // Corbata de seda roja
          final tiePaint = Paint()..shader = const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]).createShader(Rect.fromLTWH(w * 0.46, h * 0.61, w * 0.08, h * 0.16));
          final tiePath = Path();
          tiePath.moveTo(w * 0.47, h * 0.615);
          tiePath.lineTo(w * 0.53, h * 0.615);
          tiePath.lineTo(w * 0.52, h * 0.645);
          tiePath.lineTo(w * 0.48, h * 0.645);
          tiePath.close();
          tiePath.moveTo(w * 0.48, h * 0.645);
          tiePath.lineTo(w * 0.52, h * 0.645);
          tiePath.lineTo(w * 0.54, h * 0.74);
          tiePath.lineTo(w * 0.50, h * 0.77);
          tiePath.lineTo(w * 0.46, h * 0.74);
          tiePath.close();
          canvas.drawPath(tiePath, tiePaint);

          // Botones dorados
          final btnPaint = Paint()..color = const Color(0xFFFFD54F);
          canvas.drawCircle(Offset(w * 0.50, h * 0.75), 2.2, btnPaint);
          canvas.drawCircle(Offset(w * 0.50, h * 0.785), 2.2, btnPaint);
        } else if (isBack) {
          // Espalda: cubre desde la nuca (h * 0.35) hasta abajo (h * 0.815)
          final backSuit = Path();
          backSuit.moveTo(w * 0.44, h * 0.35);
          backSuit.quadraticBezierTo(w * 0.50, h * 0.36, w * 0.56, h * 0.35);
          backSuit.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          backSuit.quadraticBezierTo(w * 0.84, h * 0.74, w * 0.74, h * 0.815);
          backSuit.lineTo(w * 0.26, h * 0.815);
          backSuit.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.12, h * 0.66);
          backSuit.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          backSuit.close();

          canvas.drawPath(
            backSuit,
            Paint()..shader = suitShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.35, w * 0.76, h * 0.47)),
          );

          // Cuellito blanco
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.34, w * 0.10, h * 0.018), const Radius.circular(2)), Paint()..color = Colors.white);

          // Costura central trasera con abertura
          final seamPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2.0;
          canvas.drawLine(Offset(w * 0.50, h * 0.37), Offset(w * 0.50, h * 0.77), seamPaint);
          canvas.drawLine(Offset(w * 0.50, h * 0.77), Offset(w * 0.49, h * 0.815), Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)..strokeWidth = 1.2);
        } else if (isRight) {
          // Perfil Derecho: SAMI mira hacia la DERECHA. Espalda a la izquierda, pecho a la derecha.
          final sideSuit = Path();
          sideSuit.moveTo(w * 0.35, h * 0.36); // Nuca en la izquierda
          sideSuit.quadraticBezierTo(w * 0.22, h * 0.56, w * 0.22, h * 0.815); // Curva de la espalda
          sideSuit.lineTo(w * 0.74, h * 0.815); // Basta inferior hacia el vientre
          sideSuit.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.66, h * 0.59); // Pecho derecho
          sideSuit.quadraticBezierTo(w * 0.50, h * 0.45, w * 0.35, h * 0.36);
          sideSuit.close();

          canvas.drawPath(sideSuit, Paint()..shader = suitShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.58, h * 0.46)));

          // Manga cubriendo el brazo derecho en el centro-derecha
          final sleeve = Path();
          sleeve.moveTo(w * 0.62, h * 0.58);
          sleeve.quadraticBezierTo(w * 0.78, h * 0.60, w * 0.76, h * 0.74);
          sleeve.lineTo(w * 0.64, h * 0.74);
          sleeve.close();
          canvas.drawPath(sleeve, Paint()..color = const Color(0xFF1E3A8A));
          // Puño blanco
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.64, h * 0.73, w * 0.12, h * 0.02), const Radius.circular(2)), Paint()..color = Colors.white);

          // Asomo de solapa y corbata en el perfil del pecho
          final tie = Path();
          tie.moveTo(w * 0.68, h * 0.62);
          tie.lineTo(w * 0.73, h * 0.62);
          tie.lineTo(w * 0.71, h * 0.72);
          tie.close();
          canvas.drawPath(tie, Paint()..color = const Color(0xFFEF4444));
        } else if (isLeft) {
          // Perfil Izquierdo: SAMI mira hacia la IZQUIERDA. Pecho a la izquierda, espalda a la derecha.
          final sideSuit = Path();
          sideSuit.moveTo(w * 0.65, h * 0.36); // Nuca en la derecha
          sideSuit.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.78, h * 0.815); // Curva de la espalda
          sideSuit.lineTo(w * 0.26, h * 0.815); // Basta inferior hacia el vientre
          sideSuit.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.34, h * 0.59); // Pecho izquierdo
          sideSuit.quadraticBezierTo(w * 0.50, h * 0.45, w * 0.65, h * 0.36);
          sideSuit.close();

          canvas.drawPath(sideSuit, Paint()..shader = suitShader.createShader(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.58, h * 0.46)));

          // Manga cubriendo el brazo izquierdo en el centro-izquierda
          final sleeve = Path();
          sleeve.moveTo(w * 0.38, h * 0.58);
          sleeve.quadraticBezierTo(w * 0.22, h * 0.60, w * 0.24, h * 0.74);
          sleeve.lineTo(w * 0.36, h * 0.74);
          sleeve.close();
          canvas.drawPath(sleeve, Paint()..color = const Color(0xFF1E3A8A));
          // Puño blanco
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.73, w * 0.12, h * 0.02), const Radius.circular(2)), Paint()..color = Colors.white);

          // Asomo de solapa y corbata en el perfil del pecho
          final tie = Path();
          tie.moveTo(w * 0.32, h * 0.62);
          tie.lineTo(w * 0.27, h * 0.62);
          tie.lineTo(w * 0.29, h * 0.72);
          tie.close();
          canvas.drawPath(tie, Paint()..color = const Color(0xFFEF4444));
        }
        break;

      // 2. SUDADERA STREETWEAR
      case 'ropa_sudadera':
        final hoodShader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
        );

        if (isFront) {
          final body = Path();
          body.moveTo(w * 0.28, h * 0.59);
          body.quadraticBezierTo(w * 0.50, h * 0.61, w * 0.72, h * 0.59);
          body.quadraticBezierTo(w * 0.88, h * 0.67, w * 0.78, h * 0.78);
          body.lineTo(w * 0.22, h * 0.78);
          body.quadraticBezierTo(w * 0.12, h * 0.67, w * 0.28, h * 0.59);
          body.close();
          canvas.drawPath(body, Paint()..shader = hoodShader.createShader(Rect.fromLTWH(w * 0.15, h * 0.58, w * 0.70, h * 0.22)));

          // Bolsillo canguro
          final pocket = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, h * 0.70, w * 0.28, h * 0.08), const Radius.circular(8));
          canvas.drawRRect(pocket, Paint()..color = const Color(0xFF0891B2));

          // Ribete inferior
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.78, w * 0.48, h * 0.035), const Radius.circular(4)), Paint()..color = const Color(0xFF0E7490));
        } else if (isBack) {
          final back = Path();
          back.moveTo(w * 0.40, h * 0.36);
          back.quadraticBezierTo(w * 0.76, h * 0.45, w * 0.86, h * 0.70);
          back.lineTo(w * 0.74, h * 0.80);
          back.lineTo(w * 0.26, h * 0.80);
          back.lineTo(w * 0.14, h * 0.70);
          back.quadraticBezierTo(w * 0.24, h * 0.45, w * 0.40, h * 0.36);
          back.close();
          canvas.drawPath(back, Paint()..shader = hoodShader.createShader(Rect.fromLTWH(w * 0.14, h * 0.36, w * 0.72, h * 0.46)));

          // Capucha plegada en la espalda
          final hood = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, h * 0.36, w * 0.28, h * 0.12), const Radius.circular(14));
          canvas.drawRRect(hood, Paint()..color = const Color(0xFF0891B2));
          // Ribete inferior
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.78, w * 0.48, h * 0.035), const Radius.circular(4)), Paint()..color = const Color(0xFF0E7490));
        } else if (isRight) {
          final side = Path();
          side.moveTo(w * 0.35, h * 0.36);
          side.quadraticBezierTo(w * 0.22, h * 0.56, w * 0.22, h * 0.81);
          side.lineTo(w * 0.74, h * 0.81);
          side.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.66, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = hoodShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.58, h * 0.46)));
          // Manga
          canvas.drawOval(Rect.fromLTWH(w * 0.60, h * 0.60, w * 0.16, h * 0.16), Paint()..color = const Color(0xFF0891B2));
        } else if (isLeft) {
          final side = Path();
          side.moveTo(w * 0.65, h * 0.36);
          side.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.78, h * 0.81);
          side.lineTo(w * 0.26, h * 0.81);
          side.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.34, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = hoodShader.createShader(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.58, h * 0.46)));
          // Manga
          canvas.drawOval(Rect.fromLTWH(w * 0.24, h * 0.60, w * 0.16, h * 0.16), Paint()..color = const Color(0xFF0891B2));
        }
        break;

      // 3. TRAJE DE SUPERHÉROE
      case 'ropa_superheroe':
        final heroShader = const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
        );

        if (isFront) {
          final suit = Path();
          suit.moveTo(w * 0.28, h * 0.59);
          suit.quadraticBezierTo(w * 0.50, h * 0.61, w * 0.72, h * 0.59);
          suit.quadraticBezierTo(w * 0.88, h * 0.67, w * 0.78, h * 0.81);
          suit.lineTo(w * 0.22, h * 0.81);
          suit.quadraticBezierTo(w * 0.12, h * 0.67, w * 0.28, h * 0.59);
          suit.close();
          canvas.drawPath(suit, Paint()..shader = heroShader.createShader(Rect.fromLTWH(w * 0.15, h * 0.58, w * 0.70, h * 0.24)));

          // Cinturón dorado
          final belt = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.76, w * 0.48, h * 0.035), const Radius.circular(4));
          canvas.drawRRect(belt, Paint()..color = const Color(0xFFFFD54F));
          // Emblema
          canvas.drawCircle(Offset(w * 0.50, h * 0.66), 7.0, Paint()..color = const Color(0xFFFFD54F));
        } else if (isBack) {
          // Capa extendida cubriendo toda la espalda
          final cape = Path();
          cape.moveTo(w * 0.36, h * 0.38);
          cape.lineTo(w * 0.64, h * 0.38);
          cape.quadraticBezierTo(w * 0.88, h * 0.60, w * 0.84, h * 0.84);
          cape.lineTo(w * 0.16, h * 0.84);
          cape.quadraticBezierTo(w * 0.12, h * 0.60, w * 0.36, h * 0.38);
          cape.close();
          canvas.drawPath(cape, Paint()..shader = const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFF881337)]).createShader(Rect.fromLTWH(0, h * 0.38, w, h * 0.48)));

          // Broches dorados
          canvas.drawCircle(Offset(w * 0.36, h * 0.39), 4.0, Paint()..color = const Color(0xFFFFD54F));
          canvas.drawCircle(Offset(w * 0.64, h * 0.39), 4.0, Paint()..color = const Color(0xFFFFD54F));
        } else if (isRight) {
          final side = Path();
          side.moveTo(w * 0.35, h * 0.36);
          side.quadraticBezierTo(w * 0.22, h * 0.56, w * 0.22, h * 0.81);
          side.lineTo(w * 0.74, h * 0.81);
          side.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.66, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = heroShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.58, h * 0.46)));
          // Cinturón
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.76, w * 0.28, h * 0.035), const Radius.circular(4)), Paint()..color = const Color(0xFFFFD54F));
        } else if (isLeft) {
          final side = Path();
          side.moveTo(w * 0.65, h * 0.36);
          side.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.78, h * 0.81);
          side.lineTo(w * 0.26, h * 0.81);
          side.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.34, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = heroShader.createShader(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.58, h * 0.46)));
          // Cinturón
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.27, h * 0.76, w * 0.28, h * 0.035), const Radius.circular(4)), Paint()..color = const Color(0xFFFFD54F));
        }
        break;

      // 4. FILIPINA DE CHEF
      case 'ropa_chef':
        final chefShader = const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0)]);
        if (isFront) {
          final body = Path();
          body.moveTo(w * 0.28, h * 0.59);
          body.quadraticBezierTo(w * 0.50, h * 0.61, w * 0.72, h * 0.59);
          body.quadraticBezierTo(w * 0.88, h * 0.67, w * 0.78, h * 0.81);
          body.lineTo(w * 0.22, h * 0.81);
          body.quadraticBezierTo(w * 0.12, h * 0.67, w * 0.28, h * 0.59);
          body.close();
          canvas.drawPath(body, Paint()..shader = chefShader.createShader(Rect.fromLTWH(w * 0.15, h * 0.58, w * 0.70, h * 0.24)));

          // Doble botonadura dorada
          final btn = Paint()..color = const Color(0xFFFFD54F);
          for (int i = 0; i < 3; i++) {
            canvas.drawCircle(Offset(w * 0.45, h * (0.64 + i * 0.05)), 2.5, btn);
            canvas.drawCircle(Offset(w * 0.55, h * (0.64 + i * 0.05)), 2.5, btn);
          }
          // Pañoleta roja
          final scarf = Path();
          scarf.moveTo(w * 0.46, h * 0.60);
          scarf.lineTo(w * 0.54, h * 0.60);
          scarf.lineTo(w * 0.50, h * 0.65);
          scarf.close();
          canvas.drawPath(scarf, Paint()..color = const Color(0xFFEF4444));
        } else if (isBack) {
          final back = Path();
          back.moveTo(w * 0.44, h * 0.35);
          back.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          back.lineTo(w * 0.74, h * 0.81);
          back.lineTo(w * 0.26, h * 0.81);
          back.lineTo(w * 0.12, h * 0.66);
          back.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          back.close();
          canvas.drawPath(back, Paint()..shader = chefShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.35, w * 0.76, h * 0.47)));
        } else if (isRight) {
          final side = Path();
          side.moveTo(w * 0.35, h * 0.36);
          side.quadraticBezierTo(w * 0.22, h * 0.56, w * 0.22, h * 0.81);
          side.lineTo(w * 0.74, h * 0.81);
          side.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.66, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = chefShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.58, h * 0.46)));
        } else if (isLeft) {
          final side = Path();
          side.moveTo(w * 0.65, h * 0.36);
          side.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.78, h * 0.81);
          side.lineTo(w * 0.26, h * 0.81);
          side.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.34, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = chefShader.createShader(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.58, h * 0.46)));
        }
        break;

      // 5. ARMADURA GALÁCTICA
      case 'ropa_armadura':
        final armorShader = const LinearGradient(colors: [Color(0xFF64748B), Color(0xFF1E293B)]);
        if (isFront) {
          final chest = Path();
          chest.moveTo(w * 0.28, h * 0.59);
          chest.quadraticBezierTo(w * 0.50, h * 0.61, w * 0.72, h * 0.59);
          chest.quadraticBezierTo(w * 0.88, h * 0.67, w * 0.78, h * 0.81);
          chest.lineTo(w * 0.22, h * 0.81);
          chest.quadraticBezierTo(w * 0.12, h * 0.67, w * 0.28, h * 0.59);
          chest.close();
          canvas.drawPath(chest, Paint()..shader = armorShader.createShader(Rect.fromLTWH(w * 0.15, h * 0.58, w * 0.70, h * 0.24)));

          // Núcleo de energía de reactor
          canvas.drawCircle(Offset(w * 0.50, h * 0.68), 8.0, Paint()..color = const Color(0xFF00E5FF));
          canvas.drawCircle(Offset(w * 0.50, h * 0.68), 4.5, Paint()..color = Colors.white);
        } else if (isBack) {
          final back = Path();
          back.moveTo(w * 0.44, h * 0.35);
          back.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.88, h * 0.66);
          back.lineTo(w * 0.74, h * 0.81);
          back.lineTo(w * 0.26, h * 0.81);
          back.lineTo(w * 0.12, h * 0.66);
          back.quadraticBezierTo(w * 0.22, h * 0.45, w * 0.44, h * 0.35);
          back.close();
          canvas.drawPath(back, Paint()..shader = armorShader.createShader(Rect.fromLTWH(w * 0.12, h * 0.35, w * 0.76, h * 0.47)));
          // Turbinas traseras
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.38, h * 0.50, w * 0.10, h * 0.18), const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.50, w * 0.10, h * 0.18), const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
        } else if (isRight) {
          final side = Path();
          side.moveTo(w * 0.35, h * 0.36);
          side.quadraticBezierTo(w * 0.22, h * 0.56, w * 0.22, h * 0.81);
          side.lineTo(w * 0.74, h * 0.81);
          side.quadraticBezierTo(w * 0.78, h * 0.68, w * 0.66, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = armorShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.58, h * 0.46)));
        } else if (isLeft) {
          final side = Path();
          side.moveTo(w * 0.65, h * 0.36);
          side.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.78, h * 0.81);
          side.lineTo(w * 0.26, h * 0.81);
          side.quadraticBezierTo(w * 0.22, h * 0.68, w * 0.34, h * 0.59);
          side.close();
          canvas.drawPath(side, Paint()..shader = armorShader.createShader(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.58, h * 0.46)));
        }
        break;

      // 6. TOGA IMPERIAL / DEPORTIVA
      default:
        final togaShader = const LinearGradient(colors: [Color(0xFFD97706), Color(0xFF78350F)]);
        if (isFront) {
          final drape = Path();
          drape.moveTo(w * 0.26, h * 0.59);
          drape.lineTo(w * 0.72, h * 0.66);
          drape.lineTo(w * 0.72, h * 0.81);
          drape.lineTo(w * 0.22, h * 0.81);
          drape.close();
          canvas.drawPath(drape, Paint()..shader = togaShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.58, w * 0.55, h * 0.24)));
        } else if (isBack) {
          final drape = Path();
          drape.moveTo(w * 0.44, h * 0.36);
          drape.lineTo(w * 0.74, h * 0.81);
          drape.lineTo(w * 0.26, h * 0.81);
          drape.close();
          canvas.drawPath(drape, Paint()..shader = togaShader.createShader(Rect.fromLTWH(w * 0.20, h * 0.36, w * 0.55, h * 0.46)));
        } else {
          final drape = Path();
          drape.moveTo(w * 0.30, h * 0.45);
          drape.lineTo(w * 0.70, h * 0.81);
          drape.lineTo(w * 0.30, h * 0.81);
          drape.close();
          canvas.drawPath(drape, Paint()..shader = togaShader.createShader(Rect.fromLTWH(w * 0.30, h * 0.45, w * 0.40, h * 0.38)));
        }
        break;
    }
  }

  // -------------------------------------------------------------------------
  // CALZADO ESCULPIDO ANATÓMICAMENTE A LAS PATITAS DE SAMI
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

    final Color primaryColor = (shoeId == 'zap_sneakers')
        ? const Color(0xFF00E5FF)
        : (shoeId == 'zap_botas')
            ? const Color(0xFF92400E)
            : (shoeId == 'zap_charol')
                ? const Color(0xFF1E293B)
                : (shoeId == 'zap_espaciales')
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFFFD54F);

    final shoePaint = Paint()..color = primaryColor;
    final solePaint = Paint()..color = Colors.white;

    if (isFront) {
      // Patita izquierda frontal
      final lShoe = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.84, w * 0.20, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(lShoe, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.89, w * 0.22, h * 0.035), const Radius.circular(4)), solePaint);

      // Patita derecha frontal
      final rShoe = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.84, w * 0.20, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(rShoe, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.54, h * 0.89, w * 0.22, h * 0.035), const Radius.circular(4)), solePaint);
    } else if (isBack) {
      // Talón izquierdo trasero
      final lHeel = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.84, w * 0.20, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(lHeel, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.89, w * 0.22, h * 0.035), const Radius.circular(4)), solePaint);

      // Talón derecho trasero
      final rHeel = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.84, w * 0.20, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(rHeel, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.54, h * 0.89, w * 0.22, h * 0.035), const Radius.circular(4)), solePaint);
    } else if (isRight) {
      // Perfil derecho (zapato mirando hacia la derecha)
      final foot = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.84, w * 0.38, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(foot, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.30, h * 0.89, w * 0.42, h * 0.035), const Radius.circular(4)), solePaint);
    } else if (isLeft) {
      // Perfil izquierdo (zapato mirando hacia la izquierda)
      final foot = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.30, h * 0.84, w * 0.38, h * 0.08), const Radius.circular(8));
      canvas.drawRRect(foot, shoePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.89, w * 0.42, h * 0.035), const Radius.circular(4)), solePaint);
    }
  }

  // -------------------------------------------------------------------------
  // ACCESORIOS (Bufandas, Cascos, Gorra, Corona, Gafas, Auriculares)
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
      // 1. BUFANDAS
      case 'acc_bufanda_nordica':
      case 'acc_bufanda_carmesi':
        final isNordic = (accId == 'acc_bufanda_nordica');
        final scarfColor = isNordic ? const Color(0xFF0284C7) : const Color(0xFFE11D48);
        final scarfAccent = isNordic ? Colors.white : const Color(0xFFFFD54F);

        if (isFront) {
          final neckRing = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.56, w * 0.48, h * 0.08), const Radius.circular(14));
          canvas.drawRRect(neckRing, Paint()..color = scarfColor);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.56, w * 0.08, h * 0.08), const Radius.circular(6)), Paint()..color = scarfAccent);
          final tail = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, h * 0.62, w * 0.12, h * 0.15), const Radius.circular(6));
          canvas.drawRRect(tail, Paint()..color = scarfColor);
          canvas.drawRect(Rect.fromLTWH(w * 0.36, h * 0.74, w * 0.12, h * 0.015), Paint()..color = scarfAccent);
        } else if (isBack) {
          final backRing = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.34, h * 0.33, w * 0.32, h * 0.075), const Radius.circular(12));
          canvas.drawRRect(backRing, Paint()..color = scarfColor);
        } else {
          final sideRing = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.48, w * 0.36, h * 0.08), const Radius.circular(12));
          canvas.drawRRect(sideRing, Paint()..color = scarfColor);
        }
        break;

      // 2. CASCO DE ASTRONAUTA (Burbuja transparente de cristal espacial)
      case 'acc_casco_astronauta':
        final helmetCenter = isFront
            ? Offset(w * 0.50, h * 0.36)
            : isBack
                ? Offset(w * 0.50, h * 0.36)
                : isRight
                    ? Offset(w * 0.52, h * 0.36)
                    : Offset(w * 0.48, h * 0.36);

        final domeRadius = w * 0.33;

        final domeShader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withValues(alpha: 0.32),
            const Color(0xFF00E5FF).withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: helmetCenter, radius: domeRadius));

        canvas.drawCircle(helmetCenter, domeRadius, Paint()..shader = domeShader);
        canvas.drawCircle(
          helmetCenter,
          domeRadius,
          Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 2.2,
        );
        // Destello de reflejo curvado
        canvas.drawArc(
          Rect.fromCircle(center: helmetCenter, radius: domeRadius * 0.85),
          math.pi * 1.15,
          math.pi * 0.45,
          false,
          Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 2.5,
        );
        // Aro base del cuello
        canvas.drawOval(
          Rect.fromCenter(center: Offset(helmetCenter.dx, h * 0.58), width: w * 0.44, height: h * 0.06),
          Paint()..color = Colors.white,
        );
        break;

      // 3. GORRA SNAPBACK URBANA
      case 'acc_gorra':
        final capPaint = Paint()..color = const Color(0xFF2563EB);
        final visorPaint = Paint()..color = const Color(0xFF1D4ED8);

        if (isFront) {
          // Domo de la gorra cubriendo la frente y cabeza
          canvas.drawArc(
            Rect.fromLTWH(w * 0.30, h * 0.13, w * 0.40, h * 0.22),
            math.pi,
            math.pi,
            true,
            capPaint,
          );
          // Visera frontal hacia adelante
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.23, w * 0.48, h * 0.05), const Radius.circular(8)),
            visorPaint,
          );
          // Botón superior
          canvas.drawCircle(Offset(w * 0.50, h * 0.13), 3.0, Paint()..color = const Color(0xFF00E5FF));
        } else if (isBack) {
          // Parte trasera de la snapback con broche plástico
          canvas.drawArc(
            Rect.fromLTWH(w * 0.30, h * 0.13, w * 0.40, h * 0.22),
            math.pi,
            math.pi,
            true,
            capPaint,
          );
          // Abertura semicircular trasera
          canvas.drawArc(
            Rect.fromLTWH(w * 0.42, h * 0.19, w * 0.16, h * 0.08),
            math.pi,
            math.pi,
            true,
            Paint()..color = const Color(0xFF0A141B),
          );
          // Tira plástica
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.23, w * 0.20, h * 0.025), const Radius.circular(2)),
            Paint()..color = const Color(0xFF1E293B),
          );
        } else if (isRight) {
          // Visera saliendo a la derecha
          canvas.drawArc(
            Rect.fromLTWH(w * 0.34, h * 0.13, w * 0.40, h * 0.22),
            math.pi * 0.9,
            math.pi,
            true,
            capPaint,
          );
          final visor = Path();
          visor.moveTo(w * 0.62, h * 0.23);
          visor.lineTo(w * 0.86, h * 0.23);
          visor.lineTo(w * 0.84, h * 0.26);
          visor.lineTo(w * 0.62, h * 0.26);
          visor.close();
          canvas.drawPath(visor, visorPaint);
        } else if (isLeft) {
          // Visera saliendo a la izquierda
          canvas.drawArc(
            Rect.fromLTWH(w * 0.26, h * 0.13, w * 0.40, h * 0.22),
            math.pi * 1.1,
            math.pi,
            true,
            capPaint,
          );
          final visor = Path();
          visor.moveTo(w * 0.38, h * 0.23);
          visor.lineTo(w * 0.14, h * 0.23);
          visor.lineTo(w * 0.16, h * 0.26);
          visor.lineTo(w * 0.38, h * 0.26);
          visor.close();
          canvas.drawPath(visor, visorPaint);
        }
        break;

      // 4. CORONA IMPERIAL
      case 'acc_corona':
        final crownPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFF59E0B)],
          ).createShader(Rect.fromLTWH(w * 0.32, h * 0.08, w * 0.36, h * 0.16));

        final crownPath = Path();
        crownPath.moveTo(w * 0.34, h * 0.22);
        crownPath.lineTo(w * 0.34, h * 0.12);
        crownPath.lineTo(w * 0.42, h * 0.16);
        crownPath.lineTo(w * 0.50, h * 0.08);
        crownPath.lineTo(w * 0.58, h * 0.16);
        crownPath.lineTo(w * 0.66, h * 0.12);
        crownPath.lineTo(w * 0.66, h * 0.22);
        crownPath.close();
        canvas.drawPath(crownPath, crownPaint);

        // Gemas
        canvas.drawCircle(Offset(w * 0.50, h * 0.08), 3.2, Paint()..color = const Color(0xFFDC2626));
        canvas.drawCircle(Offset(w * 0.34, h * 0.12), 2.5, Paint()..color = const Color(0xFF10B981));
        canvas.drawCircle(Offset(w * 0.66, h * 0.12), 2.5, Paint()..color = const Color(0xFF10B981));
        break;

      // 5. LENTES DE SOL VIP
      case 'acc_lentes_vip':
        if (isFront) {
          final lensPaint = Paint()..color = const Color(0xFF0F172A);
          final framePaint = Paint()
            ..color = const Color(0xFFFFD54F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          final l1 = Rect.fromCircle(center: Offset(w * 0.42, h * 0.45), radius: w * 0.065);
          final l2 = Rect.fromCircle(center: Offset(w * 0.58, h * 0.45), radius: w * 0.065);

          canvas.drawOval(l1, lensPaint);
          canvas.drawOval(l2, lensPaint);
          canvas.drawOval(l1, framePaint);
          canvas.drawOval(l2, framePaint);
          canvas.drawLine(Offset(w * 0.485, h * 0.45), Offset(w * 0.515, h * 0.45), framePaint);
        } else if (isRight) {
          final l = Rect.fromCircle(center: Offset(w * 0.68, h * 0.44), radius: w * 0.065);
          canvas.drawOval(l, Paint()..color = const Color(0xFF0F172A));
          canvas.drawOval(l, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 2.0);
        } else if (isLeft) {
          final l = Rect.fromCircle(center: Offset(w * 0.32, h * 0.44), radius: w * 0.065);
          canvas.drawOval(l, Paint()..color = const Color(0xFF0F172A));
          canvas.drawOval(l, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 2.0);
        }
        break;

      // 6. AURICULARES GAMER DJ
      case 'acc_auriculares':
        final bandPaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;
        final cupPaint = Paint()..color = const Color(0xFF9333EA);

        canvas.drawArc(
          Rect.fromLTWH(w * 0.30, h * 0.12, w * 0.40, h * 0.28),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );
        canvas.drawOval(Rect.fromLTWH(w * 0.26, h * 0.24, w * 0.07, h * 0.10), cupPaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.67, h * 0.24, w * 0.07, h * 0.10), cupPaint);
        break;

      // 7. OTROS CASCOS
      default:
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
// PAINTER PARA LA PLATAFORMA CIRCULAR GIRATORIA (TURNTABLE PEDESTAL)
// ---------------------------------------------------------------------------
class _TurntablePedestalPainter extends CustomPainter {
  final double angleDegrees;

  _TurntablePedestalPainter({required this.angleDegrees});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.65);

    // Sombra de piso
    final floorShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 4), width: w * 0.90, height: h * 0.55), floorShadow);

    // Base del podio futurista
    final baseGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F3142), Color(0xFF081822)],
    ).createShader(Rect.fromCenter(center: center, width: w * 0.88, height: h * 0.50));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.88, height: h * 0.50),
      Paint()..shader = baseGradient,
    );

    // Anillo exterior brillante
    final ringPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.86, height: h * 0.48),
      ringPaint,
    );

    // Anillo interior sutil
    final innerRing = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.65, height: h * 0.35),
      innerRing,
    );

    // Punto de orientación rotativo que gira con el ángulo
    final rad = angleDegrees * math.pi / 180.0;
    final dotX = center.dx + math.cos(rad) * (w * 0.43);
    final dotY = center.dy + math.sin(rad) * (h * 0.24);

    final dotGlow = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(dotX, dotY), 6.0, dotGlow);

    final dotPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(dotX, dotY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TurntablePedestalPainter oldDelegate) {
    return oldDelegate.angleDegrees != angleDegrees;
  }
}
