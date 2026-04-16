import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PrivacyPolicyModal(),
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
                    ? const LinearGradient(colors: [Color(0xFF7E22CE), Color(0xFF1D4ED8)])
                    : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
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
                            child: const Icon(LucideIcons.shieldCheck, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Políticas de Privacidad',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                        color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
                        border: Border.all(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A), fontSize: 14, height: 1.5),
                          children: const [
                            TextSpan(text: 'En '),
                            TextSpan(text: 'Finanzas App', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ', tu privacidad es nuestra prioridad. Esta política describe cómo recopilamos, usamos y protegemos tu información.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sections
                    _buildSection(
                      isDark: isDark,
                      icon: LucideIcons.database,
                      iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                      iconBg: isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF),
                      title: 'Información que Recopilamos',
                      items: [
                        'Información de perfil (nombre, correo electrónico)',
                        'Datos financieros (ingresos, gastos, metas de ahorro)',
                        'Preferencias y configuraciones de la aplicación',
                        'Información de uso y análisis anónimos',
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      isDark: isDark,
                      icon: LucideIcons.userCheck,
                      iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                      iconBg: isDark ? const Color(0xFF14532D).withValues(alpha: 0.5) : const Color(0xFFDCFCE7),
                      title: 'Cómo Usamos tu Información',
                      items: [
                        'Proporcionarte servicios personalizados de gestión financiera',
                        'Generar reportes y análisis de tus finanzas',
                        'Mejorar y optimizar la aplicación',
                        'Enviarte notificaciones importantes sobre tu cuenta',
                        'Cumplir con requisitos legales y de seguridad',
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      isDark: isDark,
                      icon: LucideIcons.lock,
                      iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      iconBg: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFDBEAFE),
                      title: 'Protección de Datos',
                      items: [
                        'Encriptación de datos end-to-end',
                        'Almacenamiento seguro en servidores protegidos',
                        'Acceso restringido solo a personal autorizado',
                        'Auditorías de seguridad regulares',
                        'Cumplimiento con estándares internacionales',
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      isDark: isDark,
                      icon: LucideIcons.eye,
                      iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                      iconBg: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7),
                      title: 'Compartir Información',
                      items: [
                        'NO vendemos tu información personal a terceros',
                        'Solo compartimos datos necesarios con proveedores de servicios confiables',
                        'Podemos compartir datos anónimos para investigación',
                        'Cumplimiento legal cuando sea requerido por ley',
                      ],
                    ),
                    const SizedBox(height: 24),

                     _buildSection(
                      isDark: isDark,
                      icon: LucideIcons.shield,
                      iconColor: isDark ? const Color(0xFFF472B6) : const Color(0xFFDB2777),
                      iconBg: isDark ? const Color(0xFF831843).withValues(alpha: 0.5) : const Color(0xFFFCE7F3),
                      title: 'Tus Derechos',
                      items: [
                        'Acceder y descargar tu información personal',
                        'Corregir información inexacta',
                        'Eliminar tu cuenta y datos asociados',
                        'Optar por no recibir comunicaciones de marketing',
                        'Presentar quejas ante autoridades de protección de datos',
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('Cookies y Tecnologías Similares', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Utilizamos cookies y tecnologías similares para mejorar tu experiencia, recordar tus preferencias y analizar el uso de la aplicación. Puedes controlar las cookies a través de la configuración de tu navegador.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    Text('Cambios a esta Política', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios importantes mediante correo electrónico o un aviso en la aplicación.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF581C87).withValues(alpha: 0.3) : const Color(0xFFF3E8FF),
                        border: Border.all(color: isDark ? const Color(0xFF581C87) : const Color(0xFFE9D5FF), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contacto', style: TextStyle(color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8), fontSize: 14),
                              children: const [
                                TextSpan(text: 'Si tienes preguntas sobre esta política, contáctanos en:\n'),
                                TextSpan(text: 'privacidad@finanzasapp.com', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer Layer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isDark 
                      ? const LinearGradient(colors: [Color(0xFF7E22CE), Color(0xFF1D4ED8)])
                      : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 48),
                    child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
