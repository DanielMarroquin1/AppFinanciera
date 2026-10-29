import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_haptics.dart';
import '../rewards_shop_modal.dart';
import '../common/sami_avatar_widget.dart';

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
}

class _AvatarSelectorModalState extends ConsumerState<AvatarSelectorModal> {
  late String selectedId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Normalizar ID con retrocompatibilidad
    selectedId = SamiOutfit.getOutfit(widget.currentAvatarId).id;
  }

  bool _isOutfitUnlocked(SamiOutfit outfit, List<String> unlocked) {
    if (outfit.isFree) return true;
    return unlocked.contains(outfit.id) ||
        // Retrocompatibilidad con antiguos IDs de la tienda
        (outfit.id == 'sami_superhero' && unlocked.contains('avatar1')) ||
        (outfit.id == 'sami_wizard' && unlocked.contains('avatar2')) ||
        (outfit.id == 'sami_king' && unlocked.contains('avatar3')) ||
        (outfit.id == 'sami_ninja' && unlocked.contains('avatar4')) ||
        (outfit.id == 'sami_astronaut' && unlocked.contains('avatar5')) ||
        (outfit.id == 'sami_wallstreet' && unlocked.contains('avatar6')) ||
        (outfit.id == 'sami_chef' && unlocked.contains('avatar7')) ||
        (outfit.id == 'sami_detective' && unlocked.contains('avatar8')) ||
        (outfit.id == 'sami_party' && unlocked.contains('avatar9')) ||
        (outfit.id == 'sami_executive' && unlocked.contains('avatar10'));
  }

  Future<void> _handleUnlock(SamiOutfit outfit) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (user.points < outfit.cost) {
      AppHaptics.error();
      _showNotEnoughCoinsDialog(outfit, user.points);
      return;
    }

    setState(() => _isProcessing = true);
    AppHaptics.mediumImpact();

    try {
      final success = await ref
          .read(authProvider.notifier)
          .purchaseItem(outfit.cost, outfit.id);

      if (success && mounted) {
        AppHaptics.success();
        widget.onAvatarSelected(outfit.id);
        await ref.read(authProvider.notifier).equipAvatar(outfit.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Desbloqueaste y equipaste "${outfit.name}"!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (_) {
      AppHaptics.error();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showNotEnoughCoinsDialog(SamiOutfit outfit, int userPoints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🪙', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Monedas Insuficientes',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Necesitas ${outfit.cost} monedas para desbloquear este outfit de SAMI. Tienes $userPoints monedas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Entendido'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                        RewardsShopModal.show(context);
                      },
                      icon: const Icon(LucideIcons.shoppingBag, size: 16),
                      label: const Text('Ir a la Tienda'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final unlocked = user?.unlockedItems ?? widget.unlockedItems;
    final userPoints = user?.points ?? 0;

    final currentOutfit = SamiOutfit.getOutfit(selectedId);
    final isCurrentUnlocked = _isOutfitUnlocked(currentOutfit, unlocked);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4.5,
            width: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text('🌱', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atuendos de SAMI',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Personaliza tu avatar con ropa y accesorios',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Balance de monedas del usuario
                BounceTap(
                  scaleDown: 0.92,
                  hapticType: HapticType.light,
                  onTap: () {
                    Navigator.pop(context);
                    RewardsShopModal.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '$userPoints',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            height: 1,
          ),

          // Scrollable Body
          Flexible(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. HERO PREVIEW DEL ATUENDO SELECCIONADO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              currentOutfit.primaryColor.withValues(alpha: 0.25),
                              const Color(0xFF1E293B),
                            ]
                          : [
                              currentOutfit.primaryColor.withValues(alpha: 0.12),
                              const Color(0xFFF8FAFC),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: currentOutfit.primaryColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentOutfit.primaryColor.withValues(
                          alpha: isDark ? 0.25 : 0.10,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Gran avatar 3D con accesorio
                      SamiAvatarWidget(
                        avatarId: currentOutfit.id,
                        size: 92,
                        isDark: isDark,
                        isSelected: true,
                        showAccessoryBadge: true,
                      ),
                      const SizedBox(width: 18),
                      // Detalles del Atuendo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rarity pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: currentOutfit.rarityColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: currentOutfit.rarityColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Text(
                                currentOutfit.rarity.toUpperCase(),
                                style: TextStyle(
                                  color: currentOutfit.rarityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentOutfit.name,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  currentOutfit.accessoryEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentOutfit.description,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. GRID DE TODOS LOS ATUENDOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COLECCIÓN DE ATUENDOS',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '${SamiOutfit.allOutfits.length} disponibles',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: SamiOutfit.allOutfits.length,
                  itemBuilder: (context, index) {
                    final outfit = SamiOutfit.allOutfits[index];
                    final isUnlocked = _isOutfitUnlocked(outfit, unlocked);
                    final isSelected = selectedId == outfit.id;

                    return BounceTap(
                      scaleDown: 0.92,
                      hapticType: HapticType.selection,
                      onTap: () {
                        setState(() => selectedId = outfit.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? outfit.primaryColor.withValues(
                                  alpha: isDark ? 0.25 : 0.12,
                                )
                              : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? outfit.primaryColor
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: outfit.primaryColor.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SamiAvatarWidget(
                              avatarId: outfit.id,
                              size: 58,
                              isDark: isDark,
                              isLocked: !isUnlocked,
                              isSelected: isSelected,
                              showAccessoryBadge: isUnlocked,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              outfit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (!isUnlocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${outfit.cost}',
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                isSelected ? '✓ Seleccionado' : 'Desbloqueado',
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : (isDark ? Colors.white54 : Colors.grey[600]),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: isCurrentUnlocked
                ? BounceTap(
                    scaleDown: 0.95,
                    hapticType: HapticType.success,
                    onTap: () async {
                      AppHaptics.success();
                      widget.onAvatarSelected(currentOutfit.id);
                      await ref
                          .read(authProvider.notifier)
                          .equipAvatar(currentOutfit.id);
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Equipar este Avatar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // Botón Tienda
                      Expanded(
                        flex: 2,
                        child: BounceTap(
                          scaleDown: 0.95,
                          hapticType: HapticType.light,
                          onTap: () {
                            Navigator.pop(context);
                            RewardsShopModal.show(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.shoppingBag,
                                  size: 17,
                                  color: Color(0xFF06B6D4),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Ver Tienda',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Desbloquear Directo
                      Expanded(
                        flex: 3,
                        child: BounceTap(
                          scaleDown: 0.95,
                          hapticType: HapticType.medium,
                          onTap: _isProcessing
                              ? null
                              : () => _handleUnlock(currentOutfit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isProcessing
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        LucideIcons.unlock,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Desbloquear (${currentOutfit.cost} 🪙)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
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
}
