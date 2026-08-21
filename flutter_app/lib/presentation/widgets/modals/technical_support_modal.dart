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
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.lifeBuoy, color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Soporte Técnico', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Envíanos tu consulta o error', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Text('Correo Electrónico', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'tu@correo.com',
                prefixIcon: Icon(LucideIcons.mail, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            
            Text('Asunto / Título del Ticket', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Ej. Error al guardar presupuesto',
                prefixIcon: Icon(LucideIcons.tag, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            
            Text('Descripción del Problema', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Describe detalladamente el error o tu consulta...',
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Imágenes (Max 2)', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                TextButton.icon(
                  onPressed: _attachImage,
                  icon: const Icon(LucideIcons.imagePlus, size: 18),
                  label: const Text('Adjuntar'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                )
              ],
            ),
            
            if (_attachedImages.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Stack(
                        children: [
                          const Center(child: Icon(LucideIcons.image, color: Colors.grey)),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _attachedImages.removeAt(index));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.x, color: Colors.white, size: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Políticas de Soporte: Si no contesta una consulta después de 24h se cerrará su ticket automáticamente.',
                      style: TextStyle(color: Color(0xFFD97706), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Enviar Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
