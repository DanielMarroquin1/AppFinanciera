import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechnicalSupportModal extends StatefulWidget {
  const TechnicalSupportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const TechnicalSupportModal(),
      ),
    );
  }

  @override
  State<TechnicalSupportModal> createState() => _TechnicalSupportModalState();
}

class _TechnicalSupportModalState extends State<TechnicalSupportModal> {
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _attachedImages = []; 
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<String> _generateTicketNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final monthKey = 'ticket_count_${now.year}_${now.month}';
    
    int currentCount = prefs.getInt(monthKey) ?? 0;
    currentCount++;
    await prefs.setInt(monthKey, currentCount);
    
    final yearStr = now.year.toString();
    final monthStr = now.month.toString().padLeft(2, '0');
    final countStr = currentCount.toString().padLeft(4, '0');
    
    return 'TKT-$yearStr$monthStr-$countStr';
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo electrónico es obligatorio.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un correo válido.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un asunto o título.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, describe el error o consulta.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    final ticketNumber = await _generateTicketNumber();

    // Simulate network request and email sending
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Ticket Creado!'),
            content: Text('Tu número de ticket es: $ticketNumber\n\nHemos enviado un correo de confirmación a "$email".'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))
            ],
          ),
        );
      }
    });
  }

  void _attachImage() {
    if (_attachedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes adjuntar un máximo de 2 imágenes.')),
      );
      return;
    }
    
    setState(() {
      _attachedImages.add('image_${_attachedImages.length + 1}.png');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.lifeBuoy, color: Color(0xFF3B82F6), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Soporte Técnico', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text('Estamos aquí para ayudarte', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel(isDark, 'Correo de contacto'),
                  const SizedBox(height: 8),
                  _buildTextField(isDark, controller: _emailController, hintText: 'tu@correo.com', prefixIcon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
                  
                  const SizedBox(height: 20),
                  _buildInputLabel(isDark, 'Asunto del ticket'),
                  const SizedBox(height: 8),
                  _buildTextField(isDark, controller: _subjectController, hintText: 'Ej. Error en presupuesto', prefixIcon: LucideIcons.tag),
                  
                  const SizedBox(height: 20),
                  _buildInputLabel(isDark, 'Descripción del problema'),
                  const SizedBox(height: 8),
                  _buildTextField(isDark, controller: _descriptionController, hintText: 'Describe el error o tu consulta con detalle...', prefixIcon: LucideIcons.messageSquare, maxLines: 5),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Imágenes (Max 2)', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _attachImage,
                        icon: const Icon(LucideIcons.imagePlus, size: 18),
                        label: const Text('Adjuntar', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                  if (_attachedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: _attachedImages.map((img) => Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.image, size: 16, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 8),
                            Text(img, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(width: 16),
                        Expanded(child: Text('Políticas de Soporte: Si no respondes tras 24h, cerraremos el ticket.', style: TextStyle(color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706), fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _isSubmitting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enviar Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(bool isDark, String label) {
    return Text(
      label,
      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(
    bool isDark, {
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
          prefixIcon: maxLines == 1 ? Icon(prefixIcon, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
        ),
      ),
    );
  }
}
