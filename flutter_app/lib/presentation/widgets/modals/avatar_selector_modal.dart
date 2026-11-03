import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';

/// ARMARIO DE SAMI (REDISEÑADO TOTALMENTE DESDE CERO - SOLO ATUENDOS)
/// Experiencia boutique inmersiva enfocada 100% en la ropa de SAMI:
/// - Sin pestañas innecesarias de zapatos ni accesorios
/// - SAMI en 3D acoplado en gran formato como protagonista central
/// - Tarjetas amplias sin textos cortados
/// - Guardado persistente que se refleja en Settings y Dashboard de inmediato
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

  late String _equippedId;
  late WardrobeItem _selectedItem;

  bool _isProcessing = false;

  final List<String> _motivationalPhrases = [
    '¡Hola! 👋 ¡Este estilo me queda increíble!',
    '¡Ahorrar con estilo es otro nivel! ✨',
    '¡Listo para vencer cualquier gasto impulsivo! 🛡️',
    '¡Cada peso que ahorras te acerca a tus sueños! 📈',
    '¡Pruébame lo que quieras del armario! 🪙',
  ];

  // Lista exclusiva de atuendos de ropa de SAMI
  late final List<WardrobeItem> _outfitList;

  @override
  void initState() {
    super.initState();
    _outfitList = WardrobeItem.allItems
        .where((i) => i.category == WardrobeCategory.clothing)
        .toList();

    // Normalizar ID equipado inicial
    final rawId = widget.currentAvatarId;
    final cleanId = rawId.contains('|') ? rawId.split('|')[0] : rawId;
    _equippedId = cleanId.isEmpty ? 'ropa_clasica' : cleanId;

    _selectedItem = _outfitList.firstWhere(
      (item) => item.id == _equippedId,
      orElse: () => _outfitList.first,
    );

    // Flotación suave y natural
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Rebote elástico al tocar a SAMI
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

  void _selectOutfit(WardrobeItem item) {
    AppHaptics.lightImpact();
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

  Future<void> _handleEquipOrUnlock(WardrobeItem item) async {
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
          'Para desbloquear "${item.name}" necesitas ${item.cost} puntos.\n\nActualmente tienes $currentPoints puntos. ¡Sigue registrando tus movimientos diarios y manteniendo tu racha con SAMI para acumular más puntos!',
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

  String _getSamiHeroAsset() {
    if (_isWaving && _selectedItem.id == 'ropa_clasica') {
      return 'assets/images/sami_3d_waving.png';
    }
    return SamiOutfit.getAssetForEquipment(SamiEquipment(clothingId: _selectedItem.id));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userCoins = user?.points ?? 0;
    final unlockedList = user?.unlockedItems ?? [];

    final isSelectedUnlocked = _isItemUnlocked(_selectedItem, unlockedList);
    final isSelectedEquipped = _isItemEquipped(_selectedItem);

    final floatY = math.sin(_idleController.value * math.pi) * 3.8;
    final bounceScale = _tapBounceController.isAnimating
        ? 1.0 + (math.sin(_tapBounceController.value * math.pi) * 0.08)
        : 1.0;

    final samiHeroAsset = _getSamiHeroAsset();

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF070B10),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Halo ambiental en el fondo que reacciona a la ropa
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            height: 290,
            child: Center(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _selectedItem.primaryColor.withValues(alpha: 0.28),
                      _selectedItem.primaryColor.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido Principal
          Column(
            children: [
              // Barra superior de navegación boutique
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D26),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
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
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Armario de SAMI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Colección de Atuendos 3D',
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Chip de Monedas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.50),
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

              // =================================================================
              // 1. ESCENARIO CENTRAL DE PROBADOR (STUDIO HERO STAGE)
              // =================================================================
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Podio circular de luz bajo SAMI
                    Positioned(
                      bottom: 22,
                      child: Container(
                        width: 190,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedItem.primaryColor.withValues(alpha: 0.50),
                              blurRadius: 30,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.85),
                              blurRadius: 22,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Chip de Probador en Vivo
                    Positioned(
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101923).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles, color: Color(0xFF06B6D4), size: 12),
                            SizedBox(width: 6),
                            Text(
                              'Probador en Vivo',
                              style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Globo de diálogo al tocar a SAMI
                    if (_speechMessage != null)
                      Positioned(
                        top: 36,
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.40),
                                  blurRadius: 16,
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

                    // SAMI Modelando en 3D
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
                                width: 240,
                                height: 230,
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

                    // Indicador inferior
                    Positioned(
                      bottom: 0,
                      child: Text(
                        'Toca a SAMI para interactuar 👋',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.40),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================================
              // 2. DETALLE DEL ATUENDO SELECCIONADO
              // =================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedItem.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: _selectedItem.rarityColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedItem.rarityColor.withValues(alpha: 0.50),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _selectedItem.rarity,
                            style: TextStyle(
                              color: _selectedItem.rarityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedItem.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // =================================================================
              // 3. CARRUSEL BOUTIQUE DE ATUENDOS (TARJETAS AMPLIAS SIN RECORTES)
              // =================================================================
              SizedBox(
                height: 125,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _outfitList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = _outfitList[index];
                    final isSelected = _selectedItem.id == item.id;
                    final isEquipped = _isItemEquipped(item);
                    final isUnlocked = _isItemUnlocked(item, unlockedList);

                    return _OutfitRackCard(
                      item: item,
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
              // 4. BOTÓN DE ACCIÓN PRINCIPAL (EQUIPAR / DESBLOQUEAR)
              // =================================================================
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom + 6
                      : 18,
                ),
                child: GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () => _handleEquipOrUnlock(_selectedItem),
                  child: Container(
                    width: double.infinity,
                    height: 52,
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
                                  const Text(
                                    'Estilo Equipado en Perfil',
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
                                  const Text(
                                    'Equipar en tu Perfil',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ] else ...[
                                  const Text('🪙', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Desbloquear por ${_selectedItem.cost} pts',
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
// OUTFIT RACK CARD (Tarjetas amplias que nunca cortan los nombres)
// =============================================================================
class _OutfitRackCard extends StatelessWidget {
  final WardrobeItem item;
  final bool isSelected;
  final bool isEquipped;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _OutfitRackCard({
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
        duration: const Duration(milliseconds: 180),
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF13202C) : const Color(0xFF0E161F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF1A2633),
            width: isSelected ? 2.2 : 1.0,
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
            // Icono / Emoji con aura
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    item.primaryColor.withValues(alpha: 0.32),
                    item.secondaryColor.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                  color: item.rarityColor.withValues(alpha: 0.40),
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

            const SizedBox(height: 7),

            // Nombre completo del atuendo
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

            // Estado (En uso / Listo / Costo en pts)
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En uso',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 10,
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
                child: const Text(
                  'Listo',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 10.5)),
                  const SizedBox(width: 3),
                  Text(
                    '${item.cost} pts',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 10.5,
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
