import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/theme_provider.dart';
import '../widgets/modals/edit_profile_modal.dart';
import '../widgets/modals/color_palette_modal.dart';
import '../widgets/modals/premium_modal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isPremium = false;
  bool showBanner = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Missing Data Banner
            if (showBanner)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark 
                      ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF7F1D1D)]) 
                      : const LinearGradient(colors: [Color(0xFFFB923C), Color(0xFFEF4444)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF9A3412) : const Color(0xFFEA580C),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => showBanner = false),
                        child: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertCircle, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('¡Completa tu perfil!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Necesitamos algunos datos para personalizar tu experiencia y ayudarte a ahorrar:', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                              const SizedBox(height: 12),
                              const Row(children: [Icon(Icons.circle, size: 6, color: Colors.white), SizedBox(width: 8), Text('País', style: TextStyle(color: Colors.white))]),
                              const SizedBox(height: 4),
                              const Row(children: [Icon(Icons.circle, size: 6, color: Colors.white), SizedBox(width: 8), Text('Moneda', style: TextStyle(color: Colors.white))]),
                              const SizedBox(height: 4),
                              const Row(children: [Icon(Icons.circle, size: 6, color: Colors.white), SizedBox(width: 8), Text('Salario', style: TextStyle(color: Colors.white))]),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFDC2626),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('Completar Ahora', style: TextStyle(fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

            // Header
            Text(
              'Configuración ⚙️',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Personaliza tu experiencia',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF581C87), const Color(0xFF1E3A8A)] // purple-900 to blue-900
                      : [const Color(0xFF9333EA), const Color(0xFF2563EB)], // purple-600 to blue-600
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('María García', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('maria.garcia@email.com', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EditProfileModal(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Editar Perfil'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Premium Banner
            if (!isPremium)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark 
                      ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFC2410C)]) 
                      : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.crown, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text('Actualizar a Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Desbloquea todas las funciones: sin anuncios, reportes avanzados, sincronización en la nube y más.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () { 
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const PremiumModal(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEA580C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Ver Planes', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Sections
            _buildSection(
              isDark,
              title: 'General',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.bell, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Notificaciones', subtitle: 'Alertas y recordatorios'),
                _buildSettingItem(isDark, icon: LucideIcons.globe, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: 'Idioma', subtitle: 'Español'),
                _buildSettingItem(isDark, icon: LucideIcons.moon, iconBg: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4B5563), title: 'Tema Oscuro', subtitle: 'Activar modo nocturno', hasSwitch: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Seguridad',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.lock, iconBg: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7), iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), title: 'Cambiar Contraseña', subtitle: 'Última actualización hace 3 meses'),
                _buildSettingItem(isDark, icon: LucideIcons.key, iconBg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2), iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), title: 'Autenticación de Dos Factores', subtitle: 'Protege tu cuenta'),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Apariencia',
              isPro: true,
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.palette, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Paleta de Colores', subtitle: 'Personaliza tus colores', onTap: () {
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const ColorPaletteModal());
                }),
              ],
            ),
            const SizedBox(height: 24),

            if (isPremium)
              _buildSection(
                isDark,
                title: 'Suscripción Premium',
                items: [
                  _buildSettingItem(isDark, icon: LucideIcons.crown, iconBg: Colors.transparent, iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), title: 'Plan Premium Anual', subtitle: 'Próxima renovación: 24 Feb 2027', badge: 'Activo'),
                  ListTile(
                    title: const Center(child: Text('Cancelar Suscripción', style: TextStyle(color: Colors.red, fontSize: 14))),
                    onTap: () { setState(() => isPremium = false); },
                  )
                ],
              ),
            
            if (isPremium) const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Datos',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.cloud, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: 'Sincronización en la Nube', subtitle: 'Premium', badge: 'Premium', badgeColor: Colors.orange),
                _buildSettingItem(isDark, icon: LucideIcons.save, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Respaldo Local', subtitle: 'Último respaldo: Hoy'),
                _buildSettingItem(isDark, icon: LucideIcons.creditCard, iconBg: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7), iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), title: 'Exportar Datos', subtitle: 'Descargar en formato CSV'),
              ],
            ),
            const SizedBox(height: 24),

            // About
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Versión 2.5.0', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('© 2026 Tu App de Finanzas', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
                  border: Border.all(color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, {required String title, required List<Widget> items, bool isPro = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            if (isPro) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.crown, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              if (idx < items.length - 1 && child is! ListTile) {
                return Column(
                  children: [
                    child,
                    Divider(height: 1, color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                  ],
                );
              }
              return child;
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildSettingItem(
    bool isDark, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool hasSwitch = false,
    String? badge,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor != null ? badgeColor.withValues(alpha: 0.2) : (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor ?? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D)), fontSize: 12)),
              )
            else if (hasSwitch)
              Switch(
                value: isDark,
                onChanged: (val) {
                  if (title == 'Tema Oscuro') {
                    ref.read(themeProvider.notifier).toggleTheme(context);
                  }
                },
                activeColor: Colors.purple,
              )
            else
              Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
