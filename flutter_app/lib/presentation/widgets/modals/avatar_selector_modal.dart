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
  // Animación idle de respiración / flotación suave 2D
  late AnimationController _idleController;

  // Animación de parpadeo natural de ojos
  late AnimationController _blinkController;
  bool _isBlinking = false;

  // Animación de saludo y rebote al tocar a SAMI en 2D
  late AnimationController _tapBounceController;
  late AnimationController _waveController;
  bool _isWaving = false;
  String? _speechMessage;

  // Categoría activa en el armario
  _ArmarioTab _activeTab = _ArmarioTab.ropa;

  // Equipamiento actual en vista previa (Probador / Simulador en vivo 2D)
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

    // Respiración orgánica / flotación 2D (2.4s)
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

    // Rebote y squash al tocar en 2D
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Movimiento de saludo
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
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

  /// Al tocar CUALQUIER prenda en la cuadrícula, SAMI se la prueba en vivo en 2D inmediatamente
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final activeItems = _getItemsForActiveTab();
    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 3.5;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.08)
        : 1.0;

    // Asset frontal 2D de SAMI (con ojos abiertos o parpadeo)
    final samiFrontAsset = _isBlinking
        ? 'assets/images/sami_3d_front.png'
        : 'assets/images/sami_3d_front_open.png';

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
          // Drag handle superior
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
                          'Armario de QUIVO',
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
                      'Prueba y personaliza la ropa, zapatos y accesorios de SAMI',
                      style: TextStyle(
                        color: Color(0xFF8BA0AE),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Saldo de monedas del usuario
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

          const SizedBox(height: 6),

          // =================================================================
          // ESCENARIO 2D ELEGANTE CON SIMULACIÓN EN VIVO (SHOWCASE STAGE)
          // =================================================================
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -0.1),
                radius: 0.95,
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
                  // Resplandor ambiental de fondo detrás de SAMI
                  Positioned(
                    top: 20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00E5FF).withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pedestal base de presentación 2D
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 160,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFF0284C7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 154,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF08141C),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SAMI 2D INTERACTIVO (Rebote, Flotación y Probador en Vivo)
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
                              width: 180,
                              height: 163.3,
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // 1. Personaje Base SAMI (HD frontal 2D)
                                  Image.asset(
                                    samiFrontAsset,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),

                                  // 2. SIMULACIÓN DE ROPA, ZAPATOS Y ACCESORIOS EN VIVO 2D
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _Sami2DApparelPainter(
                                        equipment: _currentEquipment,
                                        isWaving: _isWaving,
                                        waveProgress: _waveController.value,
                                      ),
                                    ),
                                  ),

                                  // 3. Destello de interacción al tocarlo
                                  if (_isWaving)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
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
                        );
                      },
                    ),
                  ),

                  // Globo de diálogo si SAMI está saludando o fue tocado
                  if (_speechMessage != null)
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2B3B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
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

                  // Chip inferior: "👆 Toca a SAMI para interactuar"
                  if (_speechMessage == null)
                    Positioned(
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060D12).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1B313E),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👆', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text(
                              'Toca a SAMI para interactuar',
                              style: TextStyle(
                                color: Color(0xFF7DD3FC),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
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

          const SizedBox(height: 10),

          // =================================================================
          // SELECTOR DE CATEGORÍAS 2D: [ 👕 Ropa | 👟 Calzado | 👑 Cabeza | 🧣 Accesorios ]
          // =================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryTab(
                  label: 'Atuendos',
                  emoji: '👕',
                  tab: _ArmarioTab.ropa,
                ),
                const SizedBox(width: 6),
                _buildCategoryTab(
                  label: 'Calzado',
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

          const SizedBox(height: 10),

          // =================================================================
          // CUADRÍCULA DE ÍTEMS DEL ARMARIO (2 COLUMNAS CON PROBADOR EN VIVO)
          // =================================================================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                final isUnlocked = _isItemUnlocked(item, unlockedList);
                final isEquipped = _isItemEquipped(item);
                final isSelectedInPreview = _selectedItem.id == item.id;

                return GestureDetector(
                  onTap: () => _tryOnItem(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelectedInPreview
                          ? const Color(0xFF132B39)
                          : const Color(0xFF101C24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelectedInPreview
                            ? const Color(0xFF00E5FF)
                            : (isEquipped
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1C2D38)),
                        width: isSelectedInPreview ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        if (isSelectedInPreview)
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icono / Emoji con fondo suave de rareza
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.rarityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.rarityColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Nombre + Estado + Precio
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
                              // Estado o precio
                              Row(
                                children: [
                                  if (isEquipped) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
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
                                    const Text(
                                      'En tu colección',
                                      style: TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ] else ...[
                                    const Text('🪙 ', style: TextStyle(fontSize: 10)),
                                    Text(
                                      '${item.cost}',
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

          // =================================================================
          // BARRA INFERIOR DE ACCIÓN (EQUIPAR O DESBLOQUEAR)
          // =================================================================
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

// ===========================================================================
// PAINTER 2D PARA SIMULACIÓN EN VIVO DE ROPA, ZAPATOS Y ACCESORIOS DE SAMI
// ===========================================================================
class _Sami2DApparelPainter extends CustomPainter {
  final SamiEquipment equipment;
  final bool isWaving;
  final double waveProgress;

  _Sami2DApparelPainter({
    required this.equipment,
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

    // 0. Si tiene accesorio en la cabeza, RETIRAR EL PELO cubriendo el brote cyan con el tono azul marino de SAMI
    if (_hasHeadAccessory) {
      _coverHeadSprout(canvas, w, h);
    }

    // 1. Capa de superhéroe trasera (si está equipada)
    if (equipment.clothingId == 'ropa_superheroe') {
      _paintHeroCape(canvas, w, h);
    }

    // 2. Calzado esculpido en 2D adaptado a las patitas frontales de SAMI
    _paintShoes2D(canvas, w, h);

    // 3. Ropa esculpida ceñida al cuerpo y vientre de SAMI en 2D
    _paintClothing2D(canvas, w, h);

    // 4. Accesorios (Bufandas, Gafas, Cascos, Gorra, Corona, Auriculares)
    _paintAccessories2D(canvas, w, h);
  }

  // -------------------------------------------------------------------------
  // OCULTAR EL PELO / BROTE CYAN CUANDO USA ACCESORIO EN LA CABEZA
  // -------------------------------------------------------------------------
  void _coverHeadSprout(Canvas canvas, double w, double h) {
    final sproutCenter = Offset(w * 0.52, h * 0.16);

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
      Rect.fromCenter(center: sproutCenter, width: w * 0.36, height: h * 0.18),
      skullPaint,
    );
  }

  // -------------------------------------------------------------------------
  // CAPA DE SUPERHÉROE
  // -------------------------------------------------------------------------
  void _paintHeroCape(Canvas canvas, double w, double h) {
    final capePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE11D48), Color(0xFF9F1239), Color(0xFF4C0519)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.50));

    // Ala izquierda de la capa
    final leftWing = Path();
    leftWing.moveTo(w * 0.22, h * 0.58);
    leftWing.quadraticBezierTo(w * 0.08, h * 0.68, w * 0.11, h * 0.82);
    leftWing.quadraticBezierTo(w * 0.18, h * 0.76, w * 0.24, h * 0.68);
    leftWing.close();
    canvas.drawPath(leftWing, capePaint);

    // Ala derecha de la capa
    final rightWing = Path();
    rightWing.moveTo(w * 0.78, h * 0.58);
    rightWing.quadraticBezierTo(w * 0.92, h * 0.68, w * 0.89, h * 0.82);
    rightWing.quadraticBezierTo(w * 0.82, h * 0.76, w * 0.76, h * 0.68);
    rightWing.close();
    canvas.drawPath(rightWing, capePaint);
  }

  // -------------------------------------------------------------------------
  // ROPA ESCULPIDA EN 2D (ADAPTADA AL PECHO Y VIENTRE DE SAMI FRONTAL)
  // -------------------------------------------------------------------------
  void _paintClothing2D(Canvas canvas, double w, double h) {
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
      case 'ropa_deportiva':
        _paintSportJersey(canvas, w, h);
        break;
      case 'ropa_chef':
        _paintChefCoat(canvas, w, h);
        break;
      case 'ropa_armadura':
        _paintGalacticArmor(canvas, w, h);
        break;
      case 'ropa_toga':
        _paintImperialToga(canvas, w, h);
        break;
      case 'ropa_clasica':
      default:
        // Plumaje natural de SAMI (sin overlay de ropa)
        break;
    }
  }

  // Traje Ejecutivo: Saco azul marino, camisa blanca y corbata roja con clip de oro
  void _paintExecutiveSuit(Canvas canvas, double w, double h) {
    final suitPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final suitPath = Path();
    suitPath.moveTo(w * 0.30, h * 0.54);
    suitPath.quadraticBezierTo(w * 0.20, h * 0.65, w * 0.22, h * 0.84);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.78, h * 0.84);
    suitPath.quadraticBezierTo(w * 0.80, h * 0.65, w * 0.70, h * 0.54);
    suitPath.quadraticBezierTo(w * 0.50, h * 0.60, w * 0.30, h * 0.54);
    suitPath.close();
    canvas.drawPath(suitPath, suitPaint);

    // Cuello de camisa blanca triangular
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path();
    shirtPath.moveTo(w * 0.42, h * 0.56);
    shirtPath.lineTo(w * 0.50, h * 0.70);
    shirtPath.lineTo(w * 0.58, h * 0.56);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Corbata de seda roja
    final tiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.46, h * 0.58, w * 0.08, h * 0.24));

    final tiePath = Path();
    tiePath.moveTo(w * 0.48, h * 0.58);
    tiePath.lineTo(w * 0.52, h * 0.58);
    tiePath.lineTo(w * 0.53, h * 0.74);
    tiePath.lineTo(w * 0.50, h * 0.79);
    tiePath.lineTo(w * 0.47, h * 0.74);
    tiePath.close();
    canvas.drawPath(tiePath, tiePaint);

    // Clip de oro en la corbata
    final goldClipPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.47, h * 0.66, w * 0.06, h * 0.015),
        const Radius.circular(2),
      ),
      goldClipPaint,
    );

    // Botones dorados del saco
    final buttonPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(w * 0.44, h * 0.76), 3.0, buttonPaint);
    canvas.drawCircle(Offset(w * 0.44, h * 0.81), 3.0, buttonPaint);
  }

  // Sudadera Streetwear: Cyan moderno con bolsillo canguro y cordones blancos
  void _paintStreetwearHoodie(Canvas canvas, double w, double h) {
    final hoodiePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final hoodiePath = Path();
    hoodiePath.moveTo(w * 0.28, h * 0.53);
    hoodiePath.quadraticBezierTo(w * 0.19, h * 0.65, w * 0.21, h * 0.84);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.79, h * 0.84);
    hoodiePath.quadraticBezierTo(w * 0.81, h * 0.65, w * 0.72, h * 0.53);
    hoodiePath.quadraticBezierTo(w * 0.50, h * 0.58, w * 0.28, h * 0.53);
    hoodiePath.close();
    canvas.drawPath(hoodiePath, hoodiePaint);

    // Bolsillo canguro frontal
    final pocketPaint = Paint()
      ..color = const Color(0xFF075985).withValues(alpha: 0.85);
    final pocketPath = Path();
    pocketPath.moveTo(w * 0.36, h * 0.71);
    pocketPath.lineTo(w * 0.64, h * 0.71);
    pocketPath.lineTo(w * 0.67, h * 0.82);
    pocketPath.lineTo(w * 0.33, h * 0.82);
    pocketPath.close();
    canvas.drawPath(pocketPath, pocketPaint);

    // Cordones de la capucha
    final stringPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.56), Offset(w * 0.43, h * 0.65), stringPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.56), Offset(w * 0.57, h * 0.65), stringPaint);
  }

  // Traje de Superhéroe: Escarlata con cinturón dorado y emblema
  void _paintSuperheroSuit(Canvas canvas, double w, double h) {
    final heroPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final heroPath = Path();
    heroPath.moveTo(w * 0.30, h * 0.53);
    heroPath.quadraticBezierTo(w * 0.20, h * 0.65, w * 0.22, h * 0.84);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.78, h * 0.84);
    heroPath.quadraticBezierTo(w * 0.80, h * 0.65, w * 0.70, h * 0.53);
    heroPath.quadraticBezierTo(w * 0.50, h * 0.58, w * 0.30, h * 0.53);
    heroPath.close();
    canvas.drawPath(heroPath, heroPaint);

    // Emblema dorado en el pecho (Escudo geométrico)
    final emblemPaint = Paint()..color = const Color(0xFFFFD54F);
    final emblemPath = Path();
    emblemPath.moveTo(w * 0.50, h * 0.61);
    emblemPath.lineTo(w * 0.56, h * 0.64);
    emblemPath.lineTo(w * 0.50, h * 0.71);
    emblemPath.lineTo(w * 0.44, h * 0.64);
    emblemPath.close();
    canvas.drawPath(emblemPath, emblemPaint);

    // Cinturón dorado de superhéroe
    final beltPaint = Paint()..color = const Color(0xFFFFC107);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.77, w * 0.44, h * 0.045),
        const Radius.circular(4),
      ),
      beltPaint,
    );
    // Hebilla del cinturón
    final bucklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.50, h * 0.792), 4.5, bucklePaint);
  }

  // Conjunto Atlético: Jersey deportivo teal con franjas blancas
  void _paintSportJersey(Canvas canvas, double w, double h) {
    final jerseyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D9488), Color(0xFF115E59)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final jerseyPath = Path();
    jerseyPath.moveTo(w * 0.30, h * 0.54);
    jerseyPath.quadraticBezierTo(w * 0.20, h * 0.65, w * 0.22, h * 0.84);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.78, h * 0.84);
    jerseyPath.quadraticBezierTo(w * 0.80, h * 0.65, w * 0.70, h * 0.54);
    jerseyPath.quadraticBezierTo(w * 0.50, h * 0.59, w * 0.30, h * 0.54);
    jerseyPath.close();
    canvas.drawPath(jerseyPath, jerseyPaint);

    // Franjas laterales blancas
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.28, h * 0.58), Offset(w * 0.26, h * 0.82), stripePaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.58), Offset(w * 0.74, h * 0.82), stripePaint);

    // Número atlético 01 en el pecho
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '01',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(w * 0.50 - textPainter.width / 2, h * 0.66 - textPainter.height / 2),
    );
  }

  // Filipina de Chef: Chaqueta culinaria blanca con botones dorados y pañuelo rojo
  void _paintChefCoat(Canvas canvas, double w, double h) {
    final coatPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final coatPath = Path();
    coatPath.moveTo(w * 0.30, h * 0.54);
    coatPath.quadraticBezierTo(w * 0.20, h * 0.65, w * 0.22, h * 0.84);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.78, h * 0.84);
    coatPath.quadraticBezierTo(w * 0.80, h * 0.65, w * 0.70, h * 0.54);
    coatPath.quadraticBezierTo(w * 0.50, h * 0.60, w * 0.30, h * 0.54);
    coatPath.close();
    canvas.drawPath(coatPath, coatPaint);

    // Pañuelo rojo de chef al cuello
    final scarfPaint = Paint()..color = const Color(0xFFEF4444);
    final scarfPath = Path();
    scarfPath.moveTo(w * 0.44, h * 0.56);
    scarfPath.lineTo(w * 0.50, h * 0.62);
    scarfPath.lineTo(w * 0.56, h * 0.56);
    scarfPath.close();
    canvas.drawPath(scarfPath, scarfPaint);

    // Doble hilera de botones negros
    final buttonPaint = Paint()..color = const Color(0xFF1E293B);
    for (int i = 0; i < 3; i++) {
      final y = h * (0.65 + i * 0.06);
      canvas.drawCircle(Offset(w * 0.42, y), 2.8, buttonPaint);
      canvas.drawCircle(Offset(w * 0.58, y), 2.8, buttonPaint);
    }
  }

  // Armadura Galáctica: Coraza de nanotecnología con reactor cyan central
  void _paintGalacticArmor(Canvas canvas, double w, double h) {
    final armorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final armorPath = Path();
    armorPath.moveTo(w * 0.30, h * 0.53);
    armorPath.quadraticBezierTo(w * 0.20, h * 0.65, w * 0.22, h * 0.84);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.78, h * 0.84);
    armorPath.quadraticBezierTo(w * 0.80, h * 0.65, w * 0.70, h * 0.53);
    armorPath.quadraticBezierTo(w * 0.50, h * 0.58, w * 0.30, h * 0.53);
    armorPath.close();
    canvas.drawPath(armorPath, armorPaint);

    // Borde de titanio
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(armorPath, rimPaint);

    // Reactor arc cyan resplandeciente en el pecho
    final coreGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(Offset(w * 0.50, h * 0.68), 12.0, coreGlowPaint);

    final corePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(w * 0.50, h * 0.68), 7.0, corePaint);

    final coreCenterPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.50, h * 0.68), 3.5, coreCenterPaint);
  }

  // Toga Imperial de Oro: Manto imperial drapeado con broche de rubí
  void _paintImperialToga(Canvas canvas, double w, double h) {
    final togaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF78350F)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.35));

    final togaPath = Path();
    togaPath.moveTo(w * 0.30, h * 0.53);
    togaPath.lineTo(w * 0.72, h * 0.68);
    togaPath.lineTo(w * 0.78, h * 0.84);
    togaPath.quadraticBezierTo(w * 0.50, h * 0.87, w * 0.22, h * 0.84);
    togaPath.close();
    canvas.drawPath(togaPath, togaPaint);

    // Broche de oro y rubí en el hombro
    final broochGold = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(w * 0.32, h * 0.55), 7.0, broochGold);
    final rubyGem = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.32, h * 0.55), 3.8, rubyGem);
  }

  // -------------------------------------------------------------------------
  // CALZADO ESCULPIDO EN 2D (PATITAS FRONTALES DE SAMI)
  // -------------------------------------------------------------------------
  void _paintShoes2D(Canvas canvas, double w, double h) {
    if (equipment.shoesId == 'zap_clasicos') return; // Patitas naturales

    final leftFoot = Rect.fromCenter(
      center: Offset(w * 0.37, h * 0.89),
      width: w * 0.20,
      height: h * 0.12,
    );
    final rightFoot = Rect.fromCenter(
      center: Offset(w * 0.63, h * 0.89),
      width: w * 0.20,
      height: h * 0.12,
    );

    switch (equipment.shoesId) {
      case 'zap_sneakers':
        final shoePaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawRRect(RRect.fromRectAndRadius(leftFoot, const Radius.circular(8)), shoePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightFoot, const Radius.circular(8)), shoePaint);
        // Suela blanca
        final solePaint = Paint()..color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(leftFoot.left, leftFoot.bottom - 4, leftFoot.width, 4),
            const Radius.circular(4),
          ),
          solePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rightFoot.left, rightFoot.bottom - 4, rightFoot.width, 4),
            const Radius.circular(4),
          ),
          solePaint,
        );
        break;

      case 'zap_botas':
        final bootPaint = Paint()..color = const Color(0xFF78350F);
        canvas.drawRRect(RRect.fromRectAndRadius(leftFoot, const Radius.circular(6)), bootPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightFoot, const Radius.circular(6)), bootPaint);
        break;

      case 'zap_charol':
        final galaPaint = Paint()..color = const Color(0xFF0F172A);
        canvas.drawRRect(RRect.fromRectAndRadius(leftFoot, const Radius.circular(8)), galaPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightFoot, const Radius.circular(8)), galaPaint);
        // Brillo blanco
        final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
        canvas.drawCircle(Offset(leftFoot.left + 8, leftFoot.top + 4), 2.5, shinePaint);
        canvas.drawCircle(Offset(rightFoot.left + 8, rightFoot.top + 4), 2.5, shinePaint);
        break;

      case 'zap_espaciales':
        final spacePaint = Paint()..color = const Color(0xFF7C3AED);
        canvas.drawRRect(RRect.fromRectAndRadius(leftFoot, const Radius.circular(8)), spacePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightFoot, const Radius.circular(8)), spacePaint);
        final glowRing = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawLine(
          Offset(leftFoot.left + 4, leftFoot.bottom - 2),
          Offset(leftFoot.right - 4, leftFoot.bottom - 2),
          glowRing..strokeWidth = 2,
        );
        canvas.drawLine(
          Offset(rightFoot.left + 4, rightFoot.bottom - 2),
          Offset(rightFoot.right - 4, rightFoot.bottom - 2),
          glowRing..strokeWidth = 2,
        );
        break;

      case 'zap_dorados':
        final goldPaint = Paint()..color = const Color(0xFFFFD54F);
        canvas.drawRRect(RRect.fromRectAndRadius(leftFoot, const Radius.circular(8)), goldPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightFoot, const Radius.circular(8)), goldPaint);
        final coinPaint = Paint()..color = const Color(0xFFF59E0B);
        canvas.drawCircle(leftFoot.center, 4, coinPaint);
        canvas.drawCircle(rightFoot.center, 4, coinPaint);
        break;
    }
  }

  // -------------------------------------------------------------------------
  // ACCESORIOS ESCULPIDOS EN 2D (CABEZA, CUELLO Y OJOS)
  // -------------------------------------------------------------------------
  void _paintAccessories2D(Canvas canvas, double w, double h) {
    switch (equipment.accessoryId) {
      // 1. Bufanda Nórdica
      case 'acc_bufanda_nordica':
        final scarfPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          ).createShader(Rect.fromLTWH(w * 0.28, h * 0.50, w * 0.44, h * 0.12));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.28, h * 0.50, w * 0.44, h * 0.11),
            const Radius.circular(14),
          ),
          scarfPaint,
        );
        // Cola de la bufanda colgando
        final tailPaint = Paint()..color = const Color(0xFF0284C7);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.58, h * 0.57, w * 0.10, h * 0.16),
            const Radius.circular(6),
          ),
          tailPaint,
        );
        break;

      // 2. Bufanda Carmesí
      case 'acc_bufanda_carmesi':
        final silkPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
          ).createShader(Rect.fromLTWH(w * 0.28, h * 0.50, w * 0.44, h * 0.12));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.28, h * 0.50, w * 0.44, h * 0.11),
            const Radius.circular(14),
          ),
          silkPaint,
        );
        final silkTail = Paint()..color = const Color(0xFFE11D48);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.32, h * 0.57, w * 0.09, h * 0.17),
            const Radius.circular(6),
          ),
          silkTail,
        );
        break;

      // 3. Lentes Oscuros VIP
      case 'acc_lentes_vip':
        final framePaint = Paint()..color = const Color(0xFF090D10);
        final leftLens = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.34, h * 0.42, w * 0.14, h * 0.08),
          const Radius.circular(5),
        );
        final rightLens = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.52, h * 0.42, w * 0.14, h * 0.08),
          const Radius.circular(5),
        );
        canvas.drawRRect(leftLens, framePaint);
        canvas.drawRRect(rightLens, framePaint);
        // Puente
        canvas.drawLine(
          Offset(w * 0.48, h * 0.45),
          Offset(w * 0.52, h * 0.45),
          Paint()..color = const Color(0xFF090D10)..strokeWidth = 2.5,
        );
        // Reflejo blanco en las lentes
        final glassReflection = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = 1.8;
        canvas.drawLine(
          Offset(w * 0.36, h * 0.48),
          Offset(w * 0.43, h * 0.44),
          glassReflection,
        );
        canvas.drawLine(
          Offset(w * 0.54, h * 0.48),
          Offset(w * 0.61, h * 0.44),
          glassReflection,
        );
        break;

      // 4. Gorra Snapback Urbana
      case 'acc_gorra':
        final capPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ).createShader(Rect.fromLTWH(w * 0.28, h * 0.14, w * 0.44, h * 0.18));
        // Corona de la gorra
        final capPath = Path();
        capPath.moveTo(w * 0.30, h * 0.27);
        capPath.quadraticBezierTo(w * 0.32, h * 0.14, w * 0.50, h * 0.13);
        capPath.quadraticBezierTo(w * 0.68, h * 0.14, w * 0.70, h * 0.27);
        capPath.close();
        canvas.drawPath(capPath, capPaint);
        // Visera plana cyan
        final visorPaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.26, h * 0.25, w * 0.48, h * 0.05),
            const Radius.circular(6),
          ),
          visorPaint,
        );
        // Logo Q frontal
        final qPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(Offset(w * 0.50, h * 0.20), 4.5, qPaint);
        break;

      // 5. Corona Imperial de Oro
      case 'acc_corona':
        final crownPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEA00), Color(0xFFFFB300), Color(0xFFD97706)],
          ).createShader(Rect.fromLTWH(w * 0.30, h * 0.08, w * 0.40, h * 0.16));

        final crownPath = Path();
        crownPath.moveTo(w * 0.32, h * 0.24);
        crownPath.lineTo(w * 0.30, h * 0.11); // Pico izquierdo
        crownPath.lineTo(w * 0.40, h * 0.17);
        crownPath.lineTo(w * 0.50, h * 0.08); // Pico central alto
        crownPath.lineTo(w * 0.60, h * 0.17);
        crownPath.lineTo(w * 0.70, h * 0.11); // Pico derecho
        crownPath.lineTo(w * 0.68, h * 0.24);
        crownPath.close();
        canvas.drawPath(crownPath, crownPaint);

        // Gemas incrustadas
        final rubyPaint = Paint()..color = const Color(0xFFEF4444);
        canvas.drawCircle(Offset(w * 0.50, h * 0.14), 3.5, rubyPaint);
        final emeraldPaint = Paint()..color = const Color(0xFF10B981);
        canvas.drawCircle(Offset(w * 0.37, h * 0.20), 2.8, emeraldPaint);
        canvas.drawCircle(Offset(w * 0.63, h * 0.20), 2.8, emeraldPaint);
        break;

      // 6. Casco de Astronauta
      case 'acc_casco_astronauta':
        // Cúpula esférica de cristal con borde metálico
        final helmetDomePaint = Paint()
          ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        final helmetRimPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        final helmetRect = Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.32),
          width: w * 0.64,
          height: h * 0.44,
        );
        canvas.drawOval(helmetRect, helmetDomePaint);
        canvas.drawOval(helmetRect, helmetRimPaint);

        // Visera reflectante de oro
        final visorGoldPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
          ).createShader(helmetRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.28),
            width: w * 0.48,
            height: h * 0.18,
          ),
          0.2,
          2.7,
          false,
          visorGoldPaint..strokeWidth = 4..style = PaintingStyle.stroke,
        );
        break;

      // 7. Auriculares DJ Wireless
      case 'acc_auriculares':
        final bandPaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.26),
            width: w * 0.56,
            height: h * 0.30,
          ),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );
        // Almohadillas a los costados
        final earpadPaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.21, h * 0.38), width: w * 0.08, height: h * 0.14),
          earpadPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.79, h * 0.38), width: w * 0.08, height: h * 0.14),
          earpadPaint,
        );
        break;

      // 8. Casco Gamer Cyberpunk
      case 'acc_casco_cyberpunk':
        final visorPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
          ).createShader(Rect.fromLTWH(w * 0.26, h * 0.38, w * 0.48, h * 0.12));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.26, h * 0.38, w * 0.48, h * 0.10),
            const Radius.circular(8),
          ),
          visorPaint,
        );
        // HUD Grid Line
        final hudLine = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(w * 0.30, h * 0.43), Offset(w * 0.70, h * 0.43), hudLine);
        break;

      // 9. Casco de Piloto Aviador
      case 'acc_casco_piloto':
        final leatherPaint = Paint()..color = const Color(0xFF78350F);
        // Gorro de aviador
        canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.50, h * 0.24), width: w * 0.54, height: h * 0.24),
          math.pi,
          math.pi,
          true,
          leatherPaint,
        );
        // Gafas de aviador sobre la frente
        final gogglePaint = Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(w * 0.42, h * 0.22), 6.5, gogglePaint);
        canvas.drawCircle(Offset(w * 0.58, h * 0.22), 6.5, gogglePaint);
        break;

      case 'acc_ninguno':
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _Sami2DApparelPainter oldDelegate) {
    return oldDelegate.equipment.clothingId != equipment.clothingId ||
        oldDelegate.equipment.shoesId != equipment.shoesId ||
        oldDelegate.equipment.accessoryId != equipment.accessoryId ||
        oldDelegate.isWaving != isWaving ||
        oldDelegate.waveProgress != waveProgress;
  }
}
