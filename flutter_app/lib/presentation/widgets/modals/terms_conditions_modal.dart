import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const TermsConditionsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 15))
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: isDark 
                    ? const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF047857)])
                    : const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF10B981)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.fileSignature, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Términos y Condiciones',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                          child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Última actualización: Marzo 2026', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
            
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                        border: Border.all(color: isDark ? const Color(0xFF064E3B) : const Color(0xFFA7F3D0), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46), fontSize: 14, height: 1.5),
                          children: const [
                            TextSpan(text: 'Al utilizar esta aplicación, aceptas los siguientes términos y condiciones. Te rogamos leer detenidamente este contrato antes de continuar.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('1. Uso de la Aplicación', LucideIcons.smartphone, isDark),
                    _buildParagraph('Esta aplicación es de uso personal e intransferible. Te comprometes a usar la aplicación de buena fe y no para propósitos ilícitos o fraudulentos.', isDark),
                    
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('2. Propiedad Intelectual', LucideIcons.copyright, isDark),
                    _buildParagraph('Todo el contenido, marcas registradas, logotipos y diseños son propiedad exclusiva de los desarrolladores. No está permitida su copia, distribución o modificación sin consentimiento.', isDark),
                    
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('3. Responsabilidad', LucideIcons.alertTriangle, isDark),
                    _buildParagraph('La aplicación se proporciona "tal cual". Los desarrolladores no garantizan que la aplicación estará libre de errores o interrupciones, y no se hacen responsables de daños directos o indirectos ocasionados por su uso.', isDark),
                    
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('4. Actualizaciones y Modificaciones', LucideIcons.refreshCw, isDark),
                    _buildParagraph('Nos reservamos el derecho de modificar estos términos en cualquier momento. El uso continuado de la aplicación tras dichos cambios constituirá tu consentimiento a los mismos.', isDark),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF0F766E) : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Entendido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? const Color(0xFF14B8A6) : const Color(0xFF059669)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }
}
