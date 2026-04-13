import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PremiumModal extends StatefulWidget {
  const PremiumModal({super.key});

  @override
  State<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends State<PremiumModal> {
  String selectedPlan = 'annual';

  final features = [
    {'icon': LucideIcons.palette, 'text': 'Paletas de colores personalizadas'},
    {'icon': LucideIcons.cloud, 'text': 'Sincronización en la nube'},
    {'icon': LucideIcons.barChart3, 'text': 'Reportes avanzados y exportación'},
    {'icon': LucideIcons.sparkles, 'text': 'Consulta ilimitada con IA financiera'},
    {'icon': LucideIcons.zap, 'text': 'Sin anuncios'},
    {'icon': LucideIcons.crown, 'text': 'Insignia Premium'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFC2410C)]) // amber-600 to orange-700
                  : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]), // amber-400 to orange-500
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.crown, color: Colors.white, size: 40),
                    ),
                    const Text('Hazte Premium', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Desbloquea todo el potencial de tu app financiera', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14), textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan Selection
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedPlan = 'monthly'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedPlan == 'monthly'
                                  ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7))
                                  : (isDark ? const Color(0xFF374151) : Colors.white),
                              border: Border.all(
                                color: selectedPlan == 'monthly'
                                    ? (isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B))
                                    : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text('Mensual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('\$9.99', style: TextStyle(color: selectedPlan == 'monthly' ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)) : (isDark ? Colors.white : Colors.black), fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('por mes', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedPlan = 'annual'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedPlan == 'annual'
                                  ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7))
                                  : (isDark ? const Color(0xFF374151) : Colors.white),
                              border: Border.all(
                                color: selectedPlan == 'annual'
                                    ? (isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B))
                                    : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -24, right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Ahorra 40%', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text('Anual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('\$5.99', style: TextStyle(color: selectedPlan == 'annual' ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)) : (isDark ? Colors.white : Colors.black), fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('por mes', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Features
                  Text('Incluye todo de Premium:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 16),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                          child: Icon(f['icon'] as IconData, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(f['text'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14))),
                        const Icon(LucideIcons.check, color: Colors.green, size: 20),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedPlan == 'monthly' ? 'Facturación mensual' : 'Facturación anual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                            Text(selectedPlan == 'monthly' ? '\$9.99/mes' : '\$71.88/año', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (selectedPlan == 'annual') ...[
                          const SizedBox(height: 8),
                          const Text('✓ Ahorras \$47.88 al año', style: TextStyle(color: Colors.green, fontSize: 12)),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.crown, color: Colors.white, size: 20),
                    label: const Text('Actualizar a Premium', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) => null), // Handled by Ink
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      return Ink(
                        decoration: BoxDecoration(
                          gradient: isDark 
                              ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFC2410C)]) 
                              : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.crown, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Actualizar a Premium', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  Text('Cancela cuando quieras. Sin compromisos.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
