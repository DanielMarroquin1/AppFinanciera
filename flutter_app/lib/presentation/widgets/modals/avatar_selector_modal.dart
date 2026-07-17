import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AvatarSelectorModal extends StatefulWidget {
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
  State<AvatarSelectorModal> createState() => _AvatarSelectorModalState();
}

class _AvatarSelectorModalState extends State<AvatarSelectorModal> {
  late String selectedId;

  final avatars = [
    // Free avatars 
    {'id': '👤', 'emoji': '👤', 'isPremium': false},
    {'id': '👨', 'emoji': '👨', 'isPremium': false},
    {'id': '👩', 'emoji': '👩', 'isPremium': false},
    {'id': '🧑', 'emoji': '🧑', 'isPremium': false},
    {'id': '😊', 'emoji': '😊', 'isPremium': false},
    {'id': '👽', 'emoji': '👽', 'isPremium': false},
    // Premium avatars matching Rewards Shop (avatar1 to avatar10)
    {'id': 'avatar1', 'emoji': '🦸', 'isPremium': true},
    {'id': 'avatar2', 'emoji': '🧙', 'isPremium': true},
    {'id': 'avatar3', 'emoji': '👑', 'isPremium': true},
    {'id': 'avatar4', 'emoji': '🥷', 'isPremium': true},
    {'id': 'avatar5', 'emoji': '🧑‍🚀', 'isPremium': true},
    {'id': 'avatar6', 'emoji': '💎', 'isPremium': true},
    {'id': 'avatar7', 'emoji': '🐳', 'isPremium': true},
    {'id': 'avatar8', 'emoji': '⚔️', 'isPremium': true},
    {'id': 'avatar9', 'emoji': '🐉', 'isPremium': true},
    {'id': 'avatar10', 'emoji': '🔥', 'isPremium': true},
  ];

  @override
  void initState() {
    super.initState();
    selectedId = widget.currentAvatarId;
  }

  String _getEmoji(String id) {
    final match = avatars.firstWhere((a) => a['id'] == id, orElse: () => {'emoji': '👤'});
    return match['emoji'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF1D4ED8)])
                  : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecciona tu Avatar 🎭', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Personaliza tu perfil', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Selected Preview
                  Container(
                    width: 96, height: 96,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF581C87), Color(0xFF1E3A8A)])
                          : const LinearGradient(colors: [Color(0xFFF3E8FF), Color(0xFFDBEAFE)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: Text(_getEmoji(selectedId), style: const TextStyle(fontSize: 48)),
                  ),

                  // Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = avatars[index];
                      final id = avatar['id'] as String;
                      final emoji = avatar['emoji'] as String;
                      final isPremium = avatar['isPremium'] as bool;
                      
                      final isLocked = isPremium && !widget.unlockedItems.contains(id);
                      final isSelected = selectedId == id || selectedId == emoji;

                      return GestureDetector(
                        onTap: () {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🔒 Avatar bloqueado. Canjéalo en la Tienda de Recompensas.'),
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                          } else {
                            setState(() => selectedId = id);
                            widget.onAvatarSelected(id);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF))
                                : (isLocked 
                                    ? (isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6))
                                    : (isDark ? const Color(0xFF374151) : Colors.white)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? (isDark ? const Color(0xFF9333EA) : const Color(0xFF7E22CE))
                                  : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: isLocked ? 0.35 : 1.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 32)),
                                if (isLocked)
                                  Icon(LucideIcons.lock, size: 18, color: isDark ? Colors.white : Colors.black87),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Action button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirmar Selección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
