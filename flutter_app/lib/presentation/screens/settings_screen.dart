import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../providers/color_palette_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/modals/edit_profile_modal.dart';
import '../widgets/modals/color_palette_modal.dart';
import '../widgets/modals/premium_modal.dart';
import '../widgets/modals/premium_sync_hub_modal.dart';
import '../widgets/modals/premium_paywall_dialog.dart';
import '../widgets/modals/complete_profile_modal.dart';
import '../widgets/modals/language_modal.dart';
import '../widgets/modals/technical_support_modal.dart';
import '../../core/utils/localization.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/local_notification_service.dart';
import '../widgets/modals/category_budget_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/rewards_shop_modal.dart';
import '../providers/transaction_provider.dart';
import 'dashboard_screen.dart'; // Add import for showTutorialProvider

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool showBanner = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isPremium = user?.isPremium ?? false;
    
    final loc = ref.watch(localizationProvider);
    final selectedLanguage = user?.language ?? 'Español';
    final selectedCountry = user?.country ?? 'No seleccionado';
    final selectedCurrency = user?.currency ?? 'Dólares (USD)';

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              loc.get('settings_title'),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Missing Data Banner
            if (showBanner && user != null && !user.profileComplete)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFEA580C).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -5, right: -5,
                      child: IconButton(
                        onPressed: () => setState(() => showBanner = false),
                        icon: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertCircle, color: Colors.white, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.get('complete_profile'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(loc.get('complete_profile_desc'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => CompleteProfileModal.show(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFEA580C),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: Text(loc.get('complete_now'), style: const TextStyle(fontWeight: FontWeight.w800)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

            // Profile Card
            GestureDetector(
              onTap: () => EditProfileModal.show(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: paletteGradient[0].withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Center(child: Text(user?.avatarEmoji ?? '👤', style: const TextStyle(fontSize: 34))),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Usuario',
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'correo@email.com', 
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isPremium) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 12),
                                  SizedBox(width: 6),
                                  Text('PREMIUM', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Premium Banner
            if (!isPremium) ...[
              GestureDetector(
                onTap: () => PremiumModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: paletteGradient[0].withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.crown, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Actualizar a Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Desbloquea todo el potencial', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.arrowRight, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Sections
            _buildSection(
              isDark,
              title: loc.get('general'),
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.bell, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: loc.get('notifications'), subtitle: loc.get('notifications_desc'), onTap: () => _showNotificationsModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.globe, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: loc.get('language'), subtitle: selectedLanguage, onTap: () => _showLanguageModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.mapPin, iconBg: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7), iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), title: loc.get('country'), subtitle: selectedCountry, onTap: () => _showCountryModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.dollarSign, iconBg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), title: loc.get('currency'), subtitle: selectedCurrency, onTap: () => _showCurrencyModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.moon, iconBg: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4B5563), title: loc.get('dark_theme'), subtitle: loc.get('dark_theme_desc'), hasSwitch: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: loc.get('security'),
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.lock, iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), title: loc.get('change_password'), subtitle: 'Última actualización hace 3 meses', onTap: () => _showChangePasswordModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.key, iconBg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2), iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), title: loc.get('two_factor'), subtitle: 'Protege tu cuenta', onTap: () => _showTwoFactorModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.fingerprint, iconBg: isDark ? const Color(0xFF0284C7).withValues(alpha: 0.3) : const Color(0xFFE0F2FE), iconColor: const Color(0xFF38BDF8), title: 'Huella Digital / Face ID', subtitle: 'Acceso rápido biométrico activado', onTap: () => _showBiometricTestModal(context, isDark)),
                _buildSettingItem(isDark, icon: LucideIcons.timer, iconBg: isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : const Color(0xFFE0E7FF), iconColor: const Color(0xFF818CF8), title: 'Cierre Automático (${user?.autoLockMinutes ?? 1} min)', subtitle: 'Protección de privacidad activa', onTap: () => _showTimeoutInfoModal(context, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            // Presupuestos & Sincronización Section
            _buildSection(
              isDark,
              title: 'Automatización & Límites',
              items: [
                _buildSettingItem(
                  isDark,
                  icon: LucideIcons.zap,
                  iconBg: isDark ? const Color(0xFF312E81).withValues(alpha: 0.6) : const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF6366F1),
                  title: 'Conexión Bancaria y Siri',
                  subtitle: 'Clasificación de gastos automática',
                  badge: !isPremium ? 'PRO' : 'Activo',
                  badgeColor: !isPremium ? const Color(0xFFD97706) : const Color(0xFF6366F1),
                  onTap: () {
                    if (!isPremium) {
                      PremiumPaywallDialog.show(context, customMessage: 'Conecta notificaciones bancarias y atajos de voz de Siri con el Plan Premium.');
                    } else {
                      PremiumSyncHubModal.show(context);
                    }
                  },
                ),
                _buildSettingItem(isDark, icon: LucideIcons.pieChart, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Presupuesto por Categoría', subtitle: 'Establece límites por rubro', badge: !isPremium ? 'PRO' : null, badgeColor: !isPremium ? const Color(0xFFD97706) : null, onTap: () => CategoryBudgetModal.show(context)),
                _buildSettingItem(isDark, icon: LucideIcons.bellRing, iconBg: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7), iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), title: 'Alertas de Presupuesto', subtitle: 'Avisos al acercarte al límite', badge: !isPremium ? 'PRO' : null, badgeColor: !isPremium ? const Color(0xFFD97706) : null, onTap: () => _showBudgetAlertModal(context, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark,
              title: 'Apariencia',
              isPro: true,
              items: [
                _buildSettingItem(isDark, icon: LucideIcons.palette, iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), title: 'Paleta de Colores', subtitle: 'Personaliza tu aplicación', onTap: () => ColorPaletteModal.show(context)),
              ],
            ),
            const SizedBox(height: 24),

            if (isPremium) ...[
              _buildSection(
                isDark,
                title: 'Suscripción Premium',
                items: [
                  _buildSettingItem(isDark, icon: LucideIcons.crown, iconBg: const Color(0xFFFEF3C7), iconColor: const Color(0xFFD97706), title: 'Plan Premium', subtitle: 'Próxima renovación: 24 Feb 2027', badge: 'Activo', badgeColor: const Color(0xFF10B981)),
                  _buildSettingItem(
                    isDark,
                    icon: LucideIcons.zap,
                    iconBg: isDark ? const Color(0xFF312E81).withValues(alpha: 0.6) : const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF6366F1),
                    title: 'Hub de Sincronización',
                    subtitle: 'Configura tus conexiones bancarias',
                    badge: 'VIP',
                    badgeColor: const Color(0xFF6366F1),
                    onTap: () => PremiumSyncHubModal.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showCancelSubscriptionModal(context, isDark),
                child: Center(
                  child: Text('Cancelar Suscripción', style: TextStyle(color: isDark ? Colors.redAccent : Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 32),
            ],

            _buildSection(
              isDark,
              title: loc.get('help_tutorials'),
              items: [
                _buildSettingItem(
                  isDark,
                  icon: LucideIcons.lifeBuoy,
                  iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                  iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  title: loc.get('technical_support'),
                  subtitle: loc.get('technical_support_desc'),
                  onTap: () => TechnicalSupportModal.show(context),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // About
            Center(
              child: Column(
                children: [
                  const Icon(LucideIcons.fingerprint, size: 32, color: Color(0xFF6366F1)),
                  const SizedBox(height: 8),
                  Text('Versión 2.5.0', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('© 2026 Tu Ecosistema Financiero', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tutorial Button
            InkWell(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_seen_app_tutorial', false);
                if (context.mounted) {
                  context.go('/dashboard');
                  Future.delayed(const Duration(milliseconds: 500), () {
                    showTutorialTrigger.value = true;
                  });
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.sparkles, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      loc.get('tutorial_btn'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: const Text('¿Cerrar sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text('Tendrás que ingresar tus credenciales nuevamente para acceder a tu bóveda.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.redAccent.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, color: isDark ? Colors.redAccent : Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: isDark ? Colors.redAccent : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
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
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Row(
            children: [
              Text(title.toUpperCase(), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              if (isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Text('PRO', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ]
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              if (idx < items.length - 1 && child is! ListTile) {
                return Column(
                  children: [
                    child,
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                    ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor != null ? badgeColor.withValues(alpha: 0.15) : (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge, style: TextStyle(color: badgeColor ?? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D)), fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else if (hasSwitch)
                Switch(
                  value: isDark,
                  onChanged: (val) {
                    if (title == 'Tema Oscuro' || title == 'Dark Theme') {
                      // We don't have loc access here, so just relying on the switch itself
                      // or better, if the user toggles any switch we just toggle theme for now
                      ref.read(themeProvider.notifier).toggleTheme(context);
                    }
                  },
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF6366F1),
                )
              else
                Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[700] : Colors.grey[300], size: 20),
            ],
          ),
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
    LanguageModal.show(context);
  }

  void _showChangePasswordModal(BuildContext context, bool isDark) {
    final loc = ref.read(localizationProvider);
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF4ADE80)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.lock, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.get('change_password_modal_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 2),
                          Text(loc.get('change_password_modal_subtitle'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPasswordField(isDark, currentPwdCtrl, loc.get('current_password') ?? 'Contraseña Actual', LucideIcons.lock, showCurrent, () => setState(() => showCurrent = !showCurrent)),
                const SizedBox(height: 12),
                _buildPasswordField(isDark, newPwdCtrl, loc.get('new_password') ?? 'Nueva Contraseña', LucideIcons.key, showNew, () => setState(() => showNew = !showNew)),
                const SizedBox(height: 12),
                _buildPasswordField(isDark, confirmPwdCtrl, loc.get('confirm_password') ?? 'Confirmar Contraseña', LucideIcons.checkCircle, showConfirm, () => setState(() => showConfirm = !showConfirm)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      final currentPassword = currentPwdCtrl.text.trim();
                      final newPassword = newPwdCtrl.text.trim();
                      final confirmPassword = confirmPwdCtrl.text.trim();

                      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.get('pwd_complete_all') ?? 'Completa todos los campos'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      if (newPassword != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.get('pwd_mismatch') ?? 'Las contraseñas no coinciden'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.email != null) {
                          final AuthCredential credential = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPassword,
                          );
                          await user.reauthenticateWithCredential(credential);
                          await user.updatePassword(newPassword);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [const Icon(LucideIcons.checkCircle, color: Colors.white), const SizedBox(width: 12), Text(loc.get('pwd_success') ?? 'Contraseña cambiada con éxito')]),
                                backgroundColor: const Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error al cambiar contraseña: Verifica tu contraseña actual.'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(loc.get('change_password_modal_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user?.email != null) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.get('reset_link_sent')), backgroundColor: const Color(0xFF0284C7)),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.mail, size: 16, color: Color(0xFF0284C7)),
                    label: Text(loc.get('send_reset_link'), style: const TextStyle(fontSize: 13, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark, TextEditingController ctrl, String hint, IconData icon, bool showText, VoidCallback onToggle) {
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
              obscureText: !showText,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(showText ? LucideIcons.eyeOff : LucideIcons.eye, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }

  void _showTwoFactorModal(BuildContext context, bool isDark) {
    final loc = ref.read(localizationProvider);
    String selectedMethod = 'email';
    String selectedCountryCode = '+52';
    bool showOtpEntry = false;
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    String generatedOtp = '123456';

    final countries = [
      {'flag': '🇲🇽', 'code': '+52', 'name': 'México'},
      {'flag': '🇨🇴', 'code': '+57', 'name': 'Colombia'},
      {'flag': '🇪🇸', 'code': '+34', 'name': 'España'},
      {'flag': '🇺🇸', 'code': '+1', 'name': 'EE. UU. / Canadá'},
      {'flag': '🇦🇷', 'code': '+54', 'name': 'Argentina'},
      {'flag': '🇨🇱', 'code': '+56', 'name': 'Chile'},
      {'flag': '🇵🇪', 'code': '+51', 'name': 'Perú'},
      {'flag': '🇪🇨', 'code': '+593', 'name': 'Ecuador'},
      {'flag': '🇻🇪', 'code': '+58', 'name': 'Venezuela'},
      {'flag': '🇬🇹', 'code': '+502', 'name': 'Guatemala'},
      {'flag': '🇨🇷', 'code': '+506', 'name': 'Costa Rica'},
      {'flag': '🇵🇦', 'code': '+507', 'name': 'Panamá'},
      {'flag': '🇩🇴', 'code': '+1-809', 'name': 'Rep. Dominicana'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final user = ref.read(authProvider).user;
          final isCurrentlyEnabled = user?.isTwoFactorEnabled ?? false;
          final currentMethod = user?.twoFactorMethod ?? 'email';

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.3), blurRadius: 16)],
                    ),
                    child: const Center(child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 36)),
                  ),
                  const SizedBox(height: 16),
                  Text(loc.get('two_factor_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    isCurrentlyEnabled 
                        ? '${loc.get('two_factor_active_status')} (${currentMethod.toUpperCase()})'
                        : loc.get('two_factor_modal_desc'),
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  if (isCurrentlyEnabled && !showOtpEntry) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.get('two_factor_active_status'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: 2),
                                Text(
                                  currentMethod == 'sms' && user?.twoFactorPhone != null
                                      ? 'MÉTODO: SMS (${user!.twoFactorPhone})'
                                      : '${loc.get('two_factor_method_label')} ${currentMethod.toUpperCase()}',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (user != null) {
                          final updated = user.copyWith(isTwoFactorEnabled: false, twoFactorMethod: null, twoFactorPhone: null);
                          await ref.read(authProvider.notifier).updateProfile(updated);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('two_factor_disabled_snack')), backgroundColor: Colors.red));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text(loc.get('two_factor_disable_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (!showOtpEntry && (!isCurrentlyEnabled || isCurrentlyEnabled)) ...[
                    Text(loc.get('two_factor_select_method'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                    const SizedBox(height: 12),
                    
                    // Email Option
                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'email'),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: selectedMethod == 'email' ? const Color(0xFFDC2626) : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildTwoFactorOption(isDark, '📧', loc.get('two_factor_email_title'), loc.get('two_factor_email_subtitle')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // SMS Option
                    GestureDetector(
                      onTap: () => setState(() => selectedMethod = 'sms'),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: selectedMethod == 'sms' ? const Color(0xFFDC2626) : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildTwoFactorOption(isDark, '📱', loc.get('two_factor_sms_title'), loc.get('two_factor_sms_subtitle')),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedMethod == 'sms') ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.info, color: Color(0xFF3B82F6), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Para enviar SMS reales a redes celulares, el operador requiere el código internacional E.164 (+52, +57, etc.) y una pasarela de mensajería conectada. Aquí vincularemos tu número y simularemos el envío seguro.',
                                style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF1E3A8A), fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
                                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                                items: countries.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c['code']!,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(c['flag']!, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text(c['code']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedCountryCode = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: loc.get('two_factor_phone_hint'),
                                prefixIcon: Icon(LucideIcons.phone, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedMethod == 'sms' && phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.get('two_factor_phone_hint')), backgroundColor: Colors.amber[800]),
                            );
                            return;
                          }

                          if (user != null) {
                            generatedOtp = (100000 + Random().nextInt(900000)).toString();
                            
                            if (selectedMethod == 'email') {
                              await FirebaseFirestore.instance.collection('mail').add({
                                'to': user.email,
                                'message': {
                                  'subject': '${loc.get('two_factor_title')} - Código',
                                  'text': 'Tu código de activación de 2FA es: $generatedOtp',
                                  'html': '<p>Tu código de activación de 2FA es: <strong>$generatedOtp</strong></p>',
                                },
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              
                              // Simulamos notificación push del correo para pruebas rápidas
                              Future.delayed(const Duration(seconds: 2), () {
                                LocalNotificationService.showNotification(
                                  id: 808,
                                  title: 'App Financiera Seguridad',
                                  body: 'Tu código de verificación por correo es: $generatedOtp. No lo compartas.',
                                );
                              });
                            } else if (selectedMethod == 'sms') {
                              final fullNumber = '$selectedCountryCode ${phoneController.text.trim()}';
                              // Simulamos recepción de SMS nativo
                              Future.delayed(const Duration(seconds: 2), () {
                                LocalNotificationService.showNotification(
                                  id: 809,
                                  title: 'Mensajes',
                                  body: 'Finanzas: Tu código SMS de verificación es $generatedOtp. (Para $fullNumber)',
                                );
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📲 SMS de verificación generado para $fullNumber (Espera la notificación...)'),
                                  duration: const Duration(seconds: 4),
                                  backgroundColor: const Color(0xFF0284C7),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                            setState(() => showOtpEntry = true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(loc.get('two_factor_send_code_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],

                  if (showOtpEntry) ...[
                    Text(
                      '${loc.get('two_factor_enter_code')} ${selectedMethod == 'email' ? user?.email : '$selectedCountryCode ${phoneController.text.trim()}'} ($generatedOtp):',
                      style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '000000',
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (otpController.text.trim() == generatedOtp) {
                            if (user != null) {
                              final fullPhone = selectedMethod == 'sms' ? '$selectedCountryCode ${phoneController.text.trim()}' : null;
                              final updated = user.copyWith(
                                isTwoFactorEnabled: true,
                                twoFactorMethod: selectedMethod,
                                twoFactorPhone: fullPhone,
                              );
                              await ref.read(authProvider.notifier).updateProfile(updated);
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(children: [const Icon(LucideIcons.shieldCheck, color: Colors.white), const SizedBox(width: 12), Text(loc.get('two_factor_enabled_snack'))]),
                                    backgroundColor: const Color(0xFF16A34A),
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('two_factor_wrong_code')), backgroundColor: Colors.red));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(loc.get('two_factor_verify_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBiometricTestModal(BuildContext context, bool isDark) {
    final loc = ref.read(localizationProvider);
    final passwordCtrl = TextEditingController();
    bool showPassword = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => FutureBuilder<bool>(
          future: BiometricService.isBiometricEnabled(),
          builder: (context, snapshot) {
            final isEnabled = snapshot.data ?? false;
            final user = ref.read(authProvider).user;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3), width: 1.5),
                ),
                padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 24, bottom: 24,
                ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), blurRadius: 16)],
                      ),
                      child: const Center(child: Icon(LucideIcons.fingerprint, color: Colors.white, size: 44)),
                    ),
                    const SizedBox(height: 16),
                    Text(loc.get('biometrics_modal_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 8),
                    Text(
                      loc.get('biometrics_modal_desc'),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isEnabled ? const Color(0xFF10B981) : Colors.grey[400]!),
                      ),
                      child: Row(
                        children: [
                          Icon(isEnabled ? LucideIcons.shieldCheck : LucideIcons.shieldOff, color: isEnabled ? const Color(0xFF10B981) : Colors.grey[500], size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isEnabled ? loc.get('biometrics_status_enabled') : loc.get('biometrics_status_disabled'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: 2),
                                Text(isEnabled ? 'Activado para inicio rápido' : 'Inactivo actualmente', style: TextStyle(color: isEnabled ? const Color(0xFF10B981) : Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Switch(
                            value: isEnabled,
                            activeColor: const Color(0xFF0284C7),
                            onChanged: (val) async {
                              if (!val) {
                                await BiometricService.setBiometricEnabled(false);
                                setState(() {});
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('biometrics_status_disabled')), backgroundColor: Colors.grey[700]));
                                }
                              } else {
                                if (passwordCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('biometrics_confirm_password_hint')), backgroundColor: Colors.amber[800]));
                                  return;
                                }
                                final authSuccess = await BiometricService.authenticate(reason: loc.get('biometrics_modal_title'));
                                if (authSuccess && user?.email != null) {
                                  await BiometricService.setBiometricEnabled(true, user!.email!, passwordCtrl.text.trim());
                                  setState(() {});
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('biometrics_status_enabled')), backgroundColor: const Color(0xFF16A34A)));
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isEnabled) ...[
                      _buildPasswordField(isDark, passwordCtrl, loc.get('biometrics_confirm_password_hint'), LucideIcons.lock, showPassword, () => setState(() => showPassword = !showPassword)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (passwordCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('biometrics_confirm_password_hint')), backgroundColor: Colors.amber[800]));
                              return;
                            }
                            final success = await BiometricService.authenticate(reason: loc.get('biometrics_modal_title'));
                            if (success && user?.email != null) {
                              await BiometricService.setBiometricEnabled(true, user!.email!, passwordCtrl.text.trim());
                              setState(() {});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.get('biometrics_status_enabled')), backgroundColor: const Color(0xFF16A34A)));
                              }
                            }
                          },
                          icon: const Icon(LucideIcons.fingerprint, size: 20),
                          label: Text(loc.get('biometrics_toggle_enable'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final success = await BiometricService.authenticate(reason: loc.get('biometrics_modal_title'));
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [const Icon(LucideIcons.checkCircle, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(loc.get('biometrics_test_success')))]),
                                backgroundColor: const Color(0xFF0284C7),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.fingerprint, size: 20),
                        label: Text(loc.get('biometrics_test_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          side: BorderSide(color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ));
          },
        ),
      ),
    );
  }

  
  void _showAIVoiceModal(BuildContext context, bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    String currentVoice = prefs.getString('ai_voice_preset') ?? 'amigable';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final voices = [
            {'id': 'amigable', 'name': 'Femenina Amigable (QUIVO)', 'icon': LucideIcons.sparkles, 'desc': 'Un tono más agudo, rápido y empático.'},
            {'id': 'profesional', 'name': 'Masculina Profesional', 'icon': LucideIcons.briefcase, 'desc': 'Un tono grave, pausado y ejecutivo.'},
            {'id': 'neutra', 'name': 'Voz Neutra Estándar', 'icon': LucideIcons.bot, 'desc': 'El tono por defecto del sistema sin ajustes.'}
          ];

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 24),
                Text('Voz de IA', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Personaliza cómo te habla QUIVO en los ingresos por voz.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 24),
                ...voices.map((v) {
                  final isSelected = currentVoice == v['id'];
                  return GestureDetector(
                    onTap: () async {
                      setModalState(() => currentVoice = v['id'] as String);
                      await prefs.setString('ai_voice_preset', v['id'] as String);
                      if (context.mounted) Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? (isDark ? const Color(0xFF8B5CF6).withOpacity(0.15) : const Color(0xFFEDE9FE)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)), width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(v['icon'] as IconData, color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.grey[400] : Colors.grey[600]), size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(v['desc'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isSelected) const Icon(LucideIcons.checkCircle2, color: Color(0xFF8B5CF6)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

void _showTimeoutInfoModal(BuildContext context, bool isDark) {
    final loc = ref.read(localizationProvider);
    final user = ref.read(authProvider).user;
    int currentMinutes = user?.autoLockMinutes ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3), width: 1.5),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF6366F1)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 16)],
                  ),
                  child: const Center(child: Icon(LucideIcons.timer, color: Colors.white, size: 44)),
                ),
                const SizedBox(height: 16),
                Text(loc.get('auto_lock_modal_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  loc.get('auto_lock_modal_desc'),
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 1 Min Option
                _buildAutoLockOption(
                  isDark,
                  1,
                  loc.get('auto_lock_1min'),
                  currentMinutes == 1,
                  () async {
                    setState(() => currentMinutes = 1);
                    if (user != null) {
                      await ref.read(authProvider.notifier).updateProfile(user.copyWith(autoLockMinutes: 1));
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 2 Min Option
                _buildAutoLockOption(
                  isDark,
                  2,
                  loc.get('auto_lock_2min'),
                  currentMinutes == 2,
                  () async {
                    setState(() => currentMinutes = 2);
                    if (user != null) {
                      await ref.read(authProvider.notifier).updateProfile(user.copyWith(autoLockMinutes: 2));
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 5 Min Option
                _buildAutoLockOption(
                  isDark,
                  5,
                  loc.get('auto_lock_5min'),
                  currentMinutes == 5,
                  () async {
                    setState(() => currentMinutes = 5);
                    if (user != null) {
                      await ref.read(authProvider.notifier).updateProfile(user.copyWith(autoLockMinutes: 5));
                    }
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(children: [const Icon(LucideIcons.checkCircle, color: Colors.white), const SizedBox(width: 12), Text('${loc.get('auto_lock_updated_snack')} $currentMinutes min')]),
                          backgroundColor: const Color(0xFF6366F1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Confirmar y Guardar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoLockOption(bool isDark, int minutes, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : const Color(0xFFEEF2FF))
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[500],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
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

  void _showBudgetAlertModal(BuildContext context, bool isDark) {
    final isPremium = ref.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumPaywallDialog.show(context, customMessage: 'Establece alertas de presupuesto y recibe notificaciones antes de exceder tu límite con el Plan Premium.');
      return;
    }
    final user = ref.read(authProvider).user;
    double alertThreshold = user?.monthlyLimit ?? 80.0;
    final sym = CurrencyFormatter.getSymbol(user?.currency);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final txs = ref.read(transactionsProvider).value ?? [];
          final now = DateTime.now();
          double totalExpense = 0;
          double totalIncome = 0;
          for (var t in txs) {
            if (t.isFixed) continue;
            if (t.date.year == now.year && t.date.month == now.month) {
              if (t.type == 'expense') totalExpense += t.amount;
              if (t.type == 'income') totalIncome += t.amount;
            }
          }
          final calculatedLimit = (totalIncome * alertThreshold) / 100.0;
          final isOverLimit = totalIncome > 0 && totalExpense >= calculatedLimit;

          return Container(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7), shape: BoxShape.circle),
                      child: Icon(LucideIcons.bellRing, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alertas de Presupuesto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 2),
                          Text('Configura y sincroniza con tu límite de Inicio', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
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
                          Text('Alertar al ${alertThreshold.toStringAsFixed(0)}% de los ingresos', style: TextStyle(color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 16)),
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
                          Text('50% (Muy anticipado)', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                          Text('100% (Al tope)', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      ref.read(authProvider.notifier).updateMonthlyLimit(alertThreshold);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alerta de presupuesto general guardada y sincronizada (${alertThreshold.toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );

                      if (isOverLimit) {
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(LucideIcons.alertTriangle, color: Colors.red),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: Text('¡Límite General Alcanzado!', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Has gastado el 103% de tus ingresos mensuales, superando tu límite establecido del ${alertThreshold.toInt()}%.',
                                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Presupuesto Máximo:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                          Text('$sym${calculatedLimit.toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Gastado:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                          Text('$sym${totalExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx),
                                child: const Text('Entendido', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }

                      if (user != null) {
                        final updated = user.copyWith(monthlyLimit: alertThreshold);
                        await ref.read(authProvider.notifier).updateProfile(updated);
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Límite y alertas actualizados a $sym${alertThreshold.toStringAsFixed(0)}'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Guardar y Sincronizar Alertas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelSubscriptionModal(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24, offset: const Offset(0, 12)
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alertTriangle, size: 48, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 24),
              Text(
                '¿Cancelar Premium?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Si cancelas ahora, perderás acceso inmediato a todos los beneficios VIP y tus datos avanzados no se sincronizarán.',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildCancelFeature(isDark, '🎨', 'Todas las Paletas VIP'),
                    _buildCancelFeature(isDark, '📊', 'Reportes PDF e IA'),
                    _buildCancelFeature(isDark, '🤖', 'Gasto por Voz (Siri / Mic)'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('MANTENER PREMIUM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).cancelSubscription();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Suscripción cancelada correctamente.')),
                    );
                  }
                },
                child: const Text('Sí, cancelar suscripción', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
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

  void _showCountryModal(BuildContext context, bool isDark) {
    final Map<String, List<Map<String, String>>> regions = {
      'Norteamérica': [
        {'code': 'US', 'name': 'Estados Unidos', 'flag': '🇺🇸', 'currencyName': 'Dólares (USD)'},
        {'code': 'MX', 'name': 'México', 'flag': '🇲🇽', 'currencyName': 'Pesos Mexicanos (MXN)'},
      ],
      'Centroamérica': [
        {'code': 'GT', 'name': 'Guatemala', 'flag': '🇬🇹', 'currencyName': 'Quetzales (GTQ)'},
        {'code': 'CR', 'name': 'Costa Rica', 'flag': '🇨🇷', 'currencyName': 'Colones (CRC)'},
      ],
      'Suramérica': [
        {'code': 'CO', 'name': 'Colombia', 'flag': '🇨🇴', 'currencyName': 'Pesos Colombianos (COP)'},
        {'code': 'CL', 'name': 'Chile', 'flag': '🇨🇱', 'currencyName': 'Pesos Chilenos (CLP)'},
        {'code': 'PE', 'name': 'Perú', 'flag': '🇵🇪', 'currencyName': 'Soles (PEN)'},
        {'code': 'AR', 'name': 'Argentina', 'flag': '🇦🇷', 'currencyName': 'Pesos Argentinos (ARS)'},
      ],
      'Europa': [
        {'code': 'ES', 'name': 'España', 'flag': '🇪🇸', 'currencyName': 'Euros (EUR)'},
        {'code': 'GB', 'name': 'Reino Unido', 'flag': '🇬🇧', 'currencyName': 'Libras (GBP)'},
      ],
    };

    final user = ref.watch(authProvider).user;
    final currentCountry = user?.country ?? 'No seleccionado';
    final loc = ref.watch(localizationProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.get('select_country'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: isDark ? Colors.white : Colors.black, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(loc.get('select_country_desc'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: regions.keys.length,
                  itemBuilder: (context, index) {
                    final regionName = regions.keys.elementAt(index);
                    final countries = regions[regionName]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8),
                          child: Text(regionName.toUpperCase(), style: TextStyle(color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                        ...countries.map((country) {
                          final isSelected = currentCountry == country['name'];
                          return GestureDetector(
                            onTap: () {
                              if (user != null) {
                                ref.read(authProvider.notifier).updateProfile(
                                  user.copyWith(country: country['name'], currency: country['currencyName'])
                                );
                              }
                              Navigator.pop(ctx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF8B5CF6).withOpacity(0.15) : const Color(0xFFEDE9FE))
                                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))] : [],
                              ),
                              child: Row(
                                children: [
                                  Text(country['flag']!, style: const TextStyle(fontSize: 28)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(country['name']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                                  ),
                                  if (isSelected) 
                                    const Icon(LucideIcons.checkCircle2, color: Color(0xFF8B5CF6), size: 22),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyModal(BuildContext context, bool isDark) {
    final currencies = [
      {'code': 'USD', 'name': 'Dólares (USD)', 'flag': '🇺🇸', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euros (EUR)', 'flag': '🇪🇺', 'symbol': '€'},
      {'code': 'GTQ', 'name': 'Quetzales (GTQ)', 'flag': '🇬🇹', 'symbol': 'Q'},
      {'code': 'MXN', 'name': 'Pesos Mexicanos (MXN)', 'flag': '🇲🇽', 'symbol': '\$'},
      {'code': 'GBP', 'name': 'Libras (GBP)', 'flag': '🇬🇧', 'symbol': '£'},
      {'code': 'ARS', 'name': 'Pesos Argentinos (ARS)', 'flag': '🇦🇷', 'symbol': '\$'},
      {'code': 'COP', 'name': 'Pesos Colombianos (COP)', 'flag': '🇨🇴', 'symbol': '\$'},
      {'code': 'CLP', 'name': 'Pesos Chilenos (CLP)', 'flag': '🇨🇱', 'symbol': '\$'},
      {'code': 'PEN', 'name': 'Soles (PEN)', 'flag': '🇵🇪', 'symbol': 'S/'},
    ];
    final user = ref.watch(authProvider).user;
    final currentCurrency = user?.currency ?? 'Dólares (USD)';
    final loc = ref.watch(localizationProvider);

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
            Text(loc.get('select_currency'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text(loc.get('select_currency_desc'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: currencies.map((curr) {
                    final isSelected = currentCurrency == curr['name'] || currentCurrency == curr['code'];
                    return InkWell(
                      onTap: () {
                        if (user != null) {
                          ref.read(authProvider.notifier).updateProfile(user.copyWith(currency: curr['name']));
                        }
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFD1FAE5))
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? const Color(0xFF10B981) : const Color(0xFF10B981))
                                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(curr['flag']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(curr['name']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                            if (isSelected) const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
