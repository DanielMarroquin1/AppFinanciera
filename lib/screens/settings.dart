import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const SettingsScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración ⚙️',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personaliza tu experiencia',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.primaryGradientDark
                  : AppGradients.primaryGradientLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                 BoxShadow(
                  color: (isDark ? AppColors.purple900 : AppColors.purple600).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('👤', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                       Text(
                        'María García',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       Text(
                        'maria.garcia@email.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Premium Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.achievementGradientDark
                  : AppGradients.achievementGradientLight,
              borderRadius: BorderRadius.circular(24),
            ),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                     Icon(Icons.star, color: Colors.white),
                     SizedBox(width: 12),
                     Text(
                      'Actualizar a Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Desbloquea todas las funciones: sin anuncios, reportes avanzados, sincronización en la nube y más.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Ver Planes',
                      style: TextStyle(
                        color: isDark ? AppColors.amber600 : AppColors.amber600, // orange-700 / orange-600
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Sections
           _buildSectionTitle(context, 'General'),
           Container(
             decoration: BoxDecoration(
                color: isDark ? AppColors.gray800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.gray600.withOpacity(0.5) : AppColors.gray100,
                ),
             ),
             child: Column(
               children: [
                 _buildSettingItem(context, Icons.notifications, 'Notificaciones', 'Alertas y recordatorios', Colors.purple),
                 const Divider(height: 1),
                 _buildSettingItem(context, Icons.language, 'Idioma', 'Español', Colors.blue),
                 const Divider(height: 1),
                  _buildThemeToggle(context, isDark),
               ],
             ),
           ),
           const SizedBox(height: 24),

           _buildSectionTitle(context, 'Seguridad'),
            Container(
             decoration: BoxDecoration(
                color: isDark ? AppColors.gray800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.gray600.withOpacity(0.5) : AppColors.gray100,
                ),
             ),
             child: Column(
               children: [
                 _buildSettingItem(context, Icons.lock, 'Cambiar Contraseña', 'Última actualización hace 3 meses', Colors.green),
                 const Divider(height: 1),
                 _buildSettingItem(context, Icons.security, 'Autenticación de Dos Factores', 'Protege tu cuenta', Colors.red),
               ],
             ),
           ),
           const SizedBox(height: 24),

           _buildSectionTitle(context, 'Datos'),
            Container(
             decoration: BoxDecoration(
                color: isDark ? AppColors.gray800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.gray600.withOpacity(0.5) : AppColors.gray100,
                ),
             ),
             child: Column(
               children: [
                 _buildSettingItem(context, Icons.cloud_upload, 'Sincronización en la Nube', 'Premium', Colors.blue, isPremium: true),
                 const Divider(height: 1),
                 _buildSettingItem(context, Icons.save, 'Respaldo Local', 'Último respaldo: Hoy', Colors.purple),
                 const Divider(height: 1),
                 _buildSettingItem(context, Icons.file_download, 'Exportar Datos', 'Descargar en formato CSV', Colors.green),
               ],
             ),
           ),
           const SizedBox(height: 24),

           // About
            Center(
              child: Column(
                children: [
                  Text('Versión 2.5.0', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
                  Text('© 2026 Tu App de Finanzas', style: TextStyle(color: AppColors.gray400, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                 color: isDark ? AppColors.red900.withOpacity(0.3) : AppColors.red50,
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(
                   color: isDark ? AppColors.red800 : AppColors.red200,
                   width: 2,
                 ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: isDark ? AppColors.red400 : AppColors.red600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
             const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.gray400 : AppColors.gray500,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, MaterialColor color, {bool isPremium = false}) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return ListTile(
       leading: Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: isDark ? color[900]!.withOpacity(0.5) : color[100],
           borderRadius: BorderRadius.circular(12),
         ),
         child: Icon(icon, color: isDark ? color[400] : color[600], size: 20),
       ),
       title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
       subtitle: Text(subtitle, style: TextStyle(color: AppColors.gray500, fontSize: 12)),
       trailing: isPremium 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.amber900 : AppColors.amber100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Premium', style: TextStyle(color: isDark ? AppColors.amber300 : AppColors.amber700, fontSize: 10)),
          )
        : Icon(Icons.chevron_right, color: isDark ? AppColors.gray600 : AppColors.gray400),
       onTap: () {},
     );
  }

   Widget _buildThemeToggle(BuildContext context, bool isDark) {
     return ListTile(
       leading: Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: isDark ? AppColors.gray700 : AppColors.gray100,
           borderRadius: BorderRadius.circular(12),
         ),
         child: Icon(Icons.nightlight_round, color: isDark ? Colors.yellow : Colors.grey, size: 20),
       ),
       title: Text('Tema Oscuro', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
       subtitle: Text('Activar modo nocturno', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
       trailing: Switch(
         value: isDark,
         onChanged: (_) => onToggleTheme(),
         activeColor: AppColors.purple600,
       ),
       onTap: onToggleTheme,
     );
  }
}
