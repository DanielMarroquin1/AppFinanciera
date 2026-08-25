import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import 'avatar_selector_modal.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  const EditProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedAvatarId = '👤';
  bool isSaving = false;
  String? _errorMessage;

  String get selectedEmoji {
    switch (selectedAvatarId) {
      case 'avatar1': return '🦸';
      case 'avatar2': return '🧙';
      case 'avatar3': return '👑';
      case 'avatar4': return '🥷';
      case 'avatar5': return '🧑‍🚀';
      case 'avatar6': return '💎';
      case 'avatar7': return '🐳';
      case 'avatar8': return '⚔️';
      case 'avatar9': return '🐉';
      case 'avatar10': return '🔥';
      default: return selectedAvatarId;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authProvider).user;
      if (user != null && mounted) {
        setState(() {
          nameController.text = user.name.isNotEmpty ? user.name : '';
          emailController.text = user.email;
          selectedAvatarId = user.currentAvatar ?? user.avatarEmoji;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _errorMessage = null);
    final user = ref.read(authProvider).user;
    final newName = nameController.text.trim();
    
    if (user == null || newName.isEmpty) {
      setState(() => _errorMessage = 'Por favor, ingresa tu nombre');
      return;
    }

    final badWords = [
      'puto', 'puta', 'mierda', 'cabron', 'cabrón', 'pendejo', 'pendeja', 
      'idiota', 'estupido', 'estúpido', 'imbecil', 'imbécil', 'verga', 'culo', 
      'zorra', 'perra', 'maricon', 'maricón', 'jodido', 'chinga', 'chingar', 
      'fuck', 'shit', 'bitch', 'asshole', 'pene', 'vagina', 'coño', 'cagon',
      'cagón', 'cerote', 'malparido', 'ramera', 'puto', 'panocha', 'vergas'
    ];
    
    final lowerName = newName.toLowerCase();
    for (final word in badWords) {
      if (lowerName.contains(word)) {
        setState(() => _errorMessage = 'Por favor, usa un nombre apropiado sin palabras ofensivas.');
        return;
      }
    }

    setState(() => isSaving = true);
    
    try {
      final updatedUser = user.copyWith(
        name: newName,
        currentAvatar: selectedAvatarId,
      );
      
      await ref.read(authProvider.notifier).updateProfile(updatedUser);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil actualizado con éxito!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al guardar: $e';
          isSaving = false;
        });
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showAvatarSelector() {
    final user = ref.read(authProvider).user;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarSelectorModal(
        currentAvatarId: selectedAvatarId,
        unlockedItems: user?.unlockedItems ?? [],
        onAvatarSelected: (id) {
          setState(() {
            selectedAvatarId = id;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Header
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 20, left: 24, right: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Editar Perfil', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Personaliza tu identidad visual', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14)),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.x, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(selectedEmoji, style: const TextStyle(fontSize: 64)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showAvatarSelector,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 4),
                              ),
                              child: const Icon(LucideIcons.pencil, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Form Fields
                  _buildLabel(isDark, 'Nombre Completo'),
                  _buildTextField(isDark, controller: nameController, hint: 'Ej. Juan Pérez', icon: LucideIcons.user),
                  const SizedBox(height: 24),
                  
                  _buildLabel(isDark, 'Correo Electrónico (No Editable)'),
                  _buildTextField(isDark, controller: emailController, hint: 'correo@ejemplo.com', icon: LucideIcons.mail, enabled: false),
                  const SizedBox(height: 48),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), // Indigo 500
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildLabel(bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTextField(bool isDark, {required TextEditingController controller, required String hint, required IconData icon, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
        filled: true,
        fillColor: enabled 
            ? (isDark ? const Color(0xFF1E293B) : Colors.white)
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
