import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/color_palette_provider.dart';
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
  bool notificationsEnabled = true;
  String selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);

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
                                onPressed: () {
                                  EditProfileModal.show(context);
                                },
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
                  colors: paletteGradient,
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
                      Stack(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
                          ),
                          if (isPremium)
                            Positioned(
                              top: -4, right: -4,
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(LucideIcons.crown, color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('María García', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                if (isPremium) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.crown, color: Colors.white, size: 10),
                                        SizedBox(width: 4),
                                        Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text('maria.garcia@email.com', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      EditProfileModal.show(context);
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
                        PremiumModal.show(context);
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
                _buildSettingItem(isDark, icon: LucideIcons.bell, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Notificaciones', subtitle: 'Alertas y recordatorios', onTap: () => _showNotificationsModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.globe, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: 'Idioma', subtitle: selectedLanguage, onTap: () => _showLanguageModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.moon, iconBg: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4B5563), title: 'Tema Oscuro', subtitle: 'Activar modo nocturno', hasSwitch: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Seguridad',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.lock, iconBg: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7), iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), title: 'Cambiar Contraseña', subtitle: 'Última actualización hace 3 meses', onTap: () => _showChangePasswordModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.key, iconBg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2), iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), title: 'Autenticación de Dos Factores', subtitle: 'Protege tu cuenta', onTap: () => _showTwoFactorModal(context, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            // Presupuestos Section (New - from web)
            _buildSection(
              isDark,
              title: 'Presupuestos',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.pieChart, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Presupuesto por Categoría', subtitle: 'Establece límites por rubro', onTap: () => _showCategoryBudgetModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.bellRing, iconBg: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), title: 'Alertas de Presupuesto', subtitle: 'Notificaciones al acercarte al límite', onTap: () => _showBudgetAlertModal(context, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Apariencia',
              isPro: true,
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.palette, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Paleta de Colores', subtitle: 'Personaliza tus colores', onTap: () {
                  ColorPaletteModal.show(context);
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
                    onTap: () { 
                      _showCancelSubscriptionModal(context, isDark);
                    },
                  )
                ],
              ),
            
            if (isPremium) const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Datos',
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.cloud, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: 'Sincronización en la Nube', subtitle: 'Premium', badge: 'Premium', badgeColor: Colors.orange, onTap: () => _showCloudSyncModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.save, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Respaldo Local', subtitle: 'Último respaldo: Hoy', onTap: () => _showLocalBackupModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.creditCard, iconBg: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7), iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), title: 'Exportar Datos', subtitle: 'Descargar en formato CSV', onTap: () => _showExportDataModal(context, isDark)),
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text('¿Cerrar sesión?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    content: Text('Tendrás que ingresar tus credenciales nuevamente.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'), 
                        child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
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

  // ========================
  // Section & Item Builders
  // ========================

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
                activeThumbColor: Colors.purple,
              )
            else
              Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // ========================
  // Modal Methods (matching the web app's modals)
  // ========================

  void _showNotificationsModal(BuildContext context, bool isDark) {
    bool pushEnabled = notificationsEnabled;
    bool emailEnabled = true;
    bool budgetAlerts = true;
    bool weeklyReport = false;
    bool savingsReminder = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Notificaciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text('Configura tus alertas y recordatorios', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              _buildSwitchItem(isDark, 'Notificaciones Push', 'Recibir alertas en tu dispositivo', pushEnabled, (v) => setModalState(() => pushEnabled = v), LucideIcons.bell),
              _buildSwitchItem(isDark, 'Correo Electrónico', 'Resúmenes y alertas por email', emailEnabled, (v) => setModalState(() => emailEnabled = v), LucideIcons.mail),
              _buildSwitchItem(isDark, 'Alertas de Presupuesto', 'Aviso al acercarte al límite', budgetAlerts, (v) => setModalState(() => budgetAlerts = v), LucideIcons.alertTriangle),
              _buildSwitchItem(isDark, 'Reporte Semanal', 'Resumen semanal de tus finanzas', weeklyReport, (v) => setModalState(() => weeklyReport = v), LucideIcons.barChart2),
              _buildSwitchItem(isDark, 'Recordatorio de Ahorro', 'Recordatorio diario para ahorrar', savingsReminder, (v) => setModalState(() => savingsReminder = v), LucideIcons.piggyBank),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => notificationsEnabled = pushEnabled);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(bool isDark, String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context, bool isDark) {
    final languages = [
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Seleccionar Idioma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text('Elige el idioma de la aplicación', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            ...languages.map((lang) {
              final isSelected = selectedLanguage == lang['name'];
              return InkWell(
                onTap: () {
                  setState(() => selectedLanguage = lang['name']!);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF))
                        : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? const Color(0xFF9333EA) : const Color(0xFF9333EA))
                          : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(lang['name']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      if (isSelected) const Icon(LucideIcons.checkCircle2, color: Color(0xFF9333EA), size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context, bool isDark) {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Cambiar Contraseña', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text('Actualiza tu contraseña periódicamente', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              _buildPasswordField(isDark, currentPwdCtrl, 'Contraseña Actual', LucideIcons.lock),
              const SizedBox(height: 12),
              _buildPasswordField(isDark, newPwdCtrl, 'Nueva Contraseña', LucideIcons.key),
              const SizedBox(height: 12),
              _buildPasswordField(isDark, confirmPwdCtrl, 'Confirmar Contraseña', LucideIcons.checkCircle),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(children: [Icon(LucideIcons.checkCircle, color: Colors.white), SizedBox(width: 12), Text('Contraseña actualizada correctamente')]),
                        backgroundColor: const Color(0xFF16A34A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Actualizar Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark, TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('🔐', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 16),
            Text('Autenticación de Dos Factores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(
              'Añade una capa extra de seguridad a tu cuenta. Cada vez que inicies sesión, necesitarás un código de verificación.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTwoFactorOption(isDark, '📱', 'SMS', 'Recibe un código por SMS'),
            const SizedBox(height: 12),
            _buildTwoFactorOption(isDark, '📧', 'Email', 'Recibe un código por correo'),
            const SizedBox(height: 12),
            _buildTwoFactorOption(isDark, '🔑', 'App Autenticadora', 'Google Authenticator, Authy, etc.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(children: [Icon(LucideIcons.shield, color: Colors.white), SizedBox(width: 12), Text('2FA activado correctamente')]),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Activar 2FA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorOption(bool isDark, String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  void _showCategoryBudgetModal(BuildContext context, bool isDark) {
    final categories = [
      {'name': '🍔 Comida', 'budget': 500.0, 'spent': 450.0, 'color': const Color(0xFFF43F5E)},
      {'name': '🚗 Transporte', 'budget': 300.0, 'spent': 180.0, 'color': const Color(0xFF0EA5E9)},
      {'name': '🏠 Hogar', 'budget': 600.0, 'spent': 520.0, 'color': const Color(0xFF6366F1)},
      {'name': '🎮 Entretenimiento', 'budget': 200.0, 'spent': 80.0, 'color': const Color(0xFFD946EF)},
      {'name': '💊 Salud', 'budget': 150.0, 'spent': 95.0, 'color': const Color(0xFF10B981)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Presupuesto por Categoría', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text('Establece límites de gasto por rubro', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              ...categories.map((cat) {
                final percentage = ((cat['spent'] as double) / (cat['budget'] as double) * 100).clamp(0, 100);
                final isOver = percentage >= 90;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOver
                          ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                          : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                      width: isOver ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('\$${(cat['spent'] as double).toStringAsFixed(0)} / \$${(cat['budget'] as double).toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8, width: double.infinity,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (percentage / 100).clamp(0.0, 1.0),
                          child: Container(decoration: BoxDecoration(color: cat['color'] as Color, borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${percentage.toStringAsFixed(0)}% usado', style: TextStyle(color: isOver ? const Color(0xFFDC2626) : Colors.grey, fontSize: 12, fontWeight: isOver ? FontWeight.bold : FontWeight.normal)),
                          if (isOver) Text('⚠️ Cerca del límite', style: TextStyle(color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetAlertModal(BuildContext context, bool isDark) {
    double alertThreshold = 80;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Alertas de Presupuesto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text('Configura cuándo recibir alertas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.bellRing, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text('Alertar al ${alertThreshold.toStringAsFixed(0)}%', style: TextStyle(color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: alertThreshold,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      activeColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                      inactiveColor: isDark ? const Color(0xFF374151) : const Color(0xFFFDE68A),
                      label: '${alertThreshold.toStringAsFixed(0)}%',
                      onChanged: (v) => setModalState(() => alertThreshold = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                        Text('100%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Guardar Configuración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCloudSyncModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('☁️', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 16),
            Text('Sincronización en la Nube', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(
              isPremium 
                  ? 'Tus datos se sincronizan automáticamente en la nube. Accede desde cualquier dispositivo.'
                  : 'Actualiza a Premium para sincronizar tus datos en la nube y acceder desde cualquier dispositivo.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.checkCircle, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Sincronizado • Última actualización: ahora', style: TextStyle(color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), fontSize: 14))),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    PremiumModal.show(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.crown, size: 18),
                      SizedBox(width: 8),
                      Text('Obtener Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLocalBackupModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('💾', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 16),
            Text('Respaldo Local', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(
              'Guarda una copia de seguridad de tus datos en tu dispositivo.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Último respaldo: Hoy, ${TimeOfDay.now().format(context)}', style: TextStyle(color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), fontSize: 14))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(children: [Icon(LucideIcons.save, color: Colors.white), SizedBox(width: 12), Text('Respaldo creado exitosamente')]),
                      backgroundColor: const Color(0xFF9333EA),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Crear Respaldo Ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExportDataModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: Icon(LucideIcons.download, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), size: 36)),
            ),
            const SizedBox(height: 16),
            Text('Exportar Datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(
              'Descarga tus datos financieros en formato CSV para analizarlos en Excel o Google Sheets.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildExportOption(isDark, '📊', 'Transacciones', 'Todos tus ingresos y gastos'),
            const SizedBox(height: 8),
            _buildExportOption(isDark, '🎯', 'Metas de Ahorro', 'Progreso de tus metas'),
            const SizedBox(height: 8),
            _buildExportOption(isDark, '💳', 'Deudas', 'Historial de pagos'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(children: [Icon(LucideIcons.download, color: Colors.white), SizedBox(width: 12), Text('Archivo CSV descargado')]),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Descargar CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(bool isDark, String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Checkbox(
            value: true,
            onChanged: (_) {},
            activeColor: const Color(0xFF22C55E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionModal(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('¿Cancelar Premium?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perderás acceso a:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 12),
            _buildCancelFeature(isDark, '☁️', 'Sincronización en la nube'),
            _buildCancelFeature(isDark, '🎨', 'Paletas de colores'),
            _buildCancelFeature(isDark, '📊', 'Reportes avanzados'),
            _buildCancelFeature(isDark, '🤖', 'Asistente de inversión'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Mantener Premium', style: TextStyle(color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              setState(() => isPremium = false);
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelFeature(bool isDark, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }
}
