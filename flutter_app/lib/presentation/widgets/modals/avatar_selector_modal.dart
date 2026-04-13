import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AvatarSelectorModal extends StatefulWidget {
  final String currentAvatar;
  final bool isPremiumUser;
  
  const AvatarSelectorModal({super.key, required this.currentAvatar, this.isPremiumUser = false});

  @override
  State<AvatarSelectorModal> createState() => _AvatarSelectorModalState();
}

class _AvatarSelectorModalState extends State<AvatarSelectorModal> {
  late String selectedAvatar;

  final avatars = [
    // Free avatars 
    {'emoji': '👤', 'isPremium': false},
    {'emoji': '👨', 'isPremium': false},
    {'emoji': '👩', 'isPremium': false},
    {'emoji': '🧑', 'isPremium': false},
    {'emoji': '😊', 'isPremium': false},
    {'emoji': '👽', 'isPremium': false},
    // Premium avatars
    {'emoji': '👴', 'isPremium': true},
    {'emoji': '👵', 'isPremium': true},
    {'emoji': '👨‍💼', 'isPremium': true},
    {'emoji': '👩‍💼', 'isPremium': true},
    {'emoji': '👨‍🎓', 'isPremium': true},
    {'emoji': '👩‍🎓', 'isPremium': true},
    {'emoji': '👨‍⚕️', 'isPremium': true},
    {'emoji': '👩‍⚕️', 'isPremium': true},
    {'emoji': '👨‍🔧', 'isPremium': true},
    {'emoji': '👩‍🔧', 'isPremium': true},
    {'emoji': '👨‍🍳', 'isPremium': true},
    {'emoji': '👩‍🍳', 'isPremium': true},
    {'emoji': '🦸‍♂️', 'isPremium': true},
    {'emoji': '🦸‍♀️', 'isPremium': true},
    {'emoji': '🧙‍♂️', 'isPremium': true},
    {'emoji': '🧙‍♀️', 'isPremium': true},
    {'emoji': '🧝‍♂️', 'isPremium': true},
    {'emoji': '🧝‍♀️', 'isPremium': true},
    {'emoji': '🐶', 'isPremium': true},
    {'emoji': '🐱', 'isPremium': true},
    {'emoji': '🐭', 'isPremium': true},
    {'emoji': '🦊', 'isPremium': true},
    {'emoji': '🐼', 'isPremium': true},
    {'emoji': '🦁', 'isPremium': true},
  ];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF1D4ED8)]) // purple-700 to blue-700
                  : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]), // purple-600 to blue-600
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                          ? const LinearGradient(colors: [Color(0xFF581C87), Color(0xFF1E3A8A)]) // purple-900 to blue-900
                          : const LinearGradient(colors: [Color(0xFFF3E8FF), Color(0xFFDBEAFE)]), // purple-100 to blue-100
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: Text(selectedAvatar, style: const TextStyle(fontSize: 48)),
                  ),

                  // Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = avatars[index];
                      final emoji = avatar['emoji'] as String;
                      final isPremium = avatar['isPremium'] as bool;
                      final isLocked = isPremium && !widget.isPremiumUser;
                      final isSelected = selectedAvatar == emoji;

                      return GestureDetector(
                        onTap: () {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar Premium. Necesitas ser Premium.')));
                          } else {
                            setState(() => selectedAvatar = emoji);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF))
                                : (isLocked 
                                    ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB))
                                    : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6))),
                            border: Border.all(
                              color: isSelected 
                                  ? (isDark ? const Color(0xFF9333EA) : const Color(0xFFA855F7))
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 24, color: isLocked ? Colors.white.withValues(alpha: 0.5) : null)),
                              if (isLocked)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(color: isDark ? Colors.black45 : Colors.white54, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(LucideIcons.lock, size: 16),
                                  ),
                                ),
                              if (isPremium && !isLocked)
                                Positioned(
                                  top: -4, right: -4,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.crown, color: Colors.white, size: 10),
                                  ),
                                ),
                              if (isSelected && !isLocked)
                                Positioned(
                                  top: -4, right: -4,
                                  child: Container(
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFF9333EA) : const Color(0xFFA855F7), shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.check, color: Colors.white, size: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: isDark 
                                ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF1D4ED8)]) 
                                : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop(selectedAvatar); // Usually we would pass back the data, but using pop
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Seleccionar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
