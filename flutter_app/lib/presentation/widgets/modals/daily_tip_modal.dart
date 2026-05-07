import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Data ────────────────────────────────────────────────────────────────────
class FinancialTip {
  final int id;
  final String categoria;
  final String titulo;
  final String consejo;

  const FinancialTip({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.consejo,
  });
}

const List<FinancialTip> kFinancialTips = [
  FinancialTip(id: 1,  categoria: 'personal', titulo: 'Regla 24 Horas',          consejo: 'Antes de una compra impulsiva, espera 24 horas. Si mañana aún lo quieres, cómpralo.'),
  FinancialTip(id: 2,  categoria: 'parejas',  titulo: 'Cita Financiera',          consejo: 'Tengan una breve reunión mensual para revisar su dashboard compartido y ajustar metas.'),
  FinancialTip(id: 3,  categoria: 'ahorro',   titulo: 'Pequeñas Gotas',           consejo: 'Ahorrar 5 dólares a la semana es mejor que no ahorrar nada. La constancia vence a la cantidad.'),
  FinancialTip(id: 4,  categoria: 'personal', titulo: 'Gasto Hormiga',            consejo: 'Ese café diario suma más de lo que crees. Calcula cuánto gastas en él al mes.'),
  FinancialTip(id: 5,  categoria: 'parejas',  titulo: 'Metas Comunes',            consejo: 'Definan un objetivo grande juntos (viaje, casa) para mantener la motivación en el ahorro duo.'),
  FinancialTip(id: 6,  categoria: 'ahorro',   titulo: 'Págate a ti primero',      consejo: 'En cuanto recibas tu ingreso, separa un porcentaje para ahorro antes de empezar a gastar.'),
  FinancialTip(id: 7,  categoria: 'personal', titulo: 'Suscripciones',            consejo: 'Revisa tus suscripciones mensuales. Cancela las que no hayas usado en los últimos 30 días.'),
  FinancialTip(id: 8,  categoria: 'parejas',  titulo: 'Sinceridad Ante Todo',     consejo: 'La honestidad financiera es la base de la confianza en la pareja. Registren todos los gastos compartidos.'),
  FinancialTip(id: 9,  categoria: 'ahorro',   titulo: 'Fondo de Emergencia',      consejo: 'Tu primera meta debe ser ahorrar al menos un mes de tus gastos básicos para imprevistos.'),
  FinancialTip(id: 10, categoria: 'personal', titulo: 'Lista de Compras',         consejo: 'Nunca vayas al supermercado con hambre o sin lista; gastarás un 20% más por impulso.'),
  FinancialTip(id: 11, categoria: 'parejas',  titulo: 'Gastos Individuales',      consejo: 'Es sano que cada uno tenga un pequeño presupuesto personal \'libre\' dentro de la economía duo.'),
  FinancialTip(id: 12, categoria: 'ahorro',   titulo: 'Día de Cero Gastos',       consejo: 'Reta al menos un día a la semana a no gastar absolutamente nada fuera de lo esencial.'),
  FinancialTip(id: 13, categoria: 'personal', titulo: 'Calidad vs Precio',        consejo: 'A veces lo barato sale caro. Invierte en cosas que duren más tiempo para ahorrar a largo plazo.'),
  FinancialTip(id: 14, categoria: 'parejas',  titulo: 'Fondo Común',              consejo: 'Aporten al fondo compartido proporcionalmente a sus ingresos para que sea un trato justo.'),
  FinancialTip(id: 15, categoria: 'ahorro',   titulo: 'Regla 50/30/20',           consejo: 'Intenta destinar 50% a necesidades, 30% a deseos y 20% directamente a tus ahorros.'),
  FinancialTip(id: 16, categoria: 'personal', titulo: 'Evita Deudas',             consejo: 'Si no puedes pagarlo en efectivo hoy, probablemente no puedas permitírtelo todavía.'),
  FinancialTip(id: 17, categoria: 'parejas',  titulo: 'Celebración',              consejo: 'Cuando alcancen una meta de ahorro en pareja, celebren con algo sencillo para reforzar el hábito.'),
  FinancialTip(id: 18, categoria: 'ahorro',   titulo: 'Servicios Públicos',       consejo: 'Apagar luces y desconectar aparatos puede ahorrarte un buen porcentaje en tu factura mensual.'),
  FinancialTip(id: 19, categoria: 'personal', titulo: 'Inflación de Estilo',      consejo: 'Si tus ingresos suben, no subas tus gastos de inmediato. Aumenta tu capacidad de ahorro.'),
  FinancialTip(id: 20, categoria: 'parejas',  titulo: 'Transparencia',            consejo: 'Usen las categorías de la app para que ambos entiendan en qué se está yendo el dinero del dúo.'),
  FinancialTip(id: 21, categoria: 'ahorro',   titulo: 'Marcas Blancas',           consejo: 'Prueba productos genéricos o de marca propia del súper; la calidad suele ser igual por menor precio.'),
  FinancialTip(id: 22, categoria: 'personal', titulo: 'Educa tu Mente',           consejo: 'Dedica 15 minutos a la semana a leer sobre finanzas personales o inversiones.'),
  FinancialTip(id: 23, categoria: 'parejas',  titulo: 'Plan de Comida',           consejo: 'Planear el menú semanal en pareja reduce drásticamente el gasto en comida rápida y domicilio.'),
  FinancialTip(id: 24, categoria: 'ahorro',   titulo: 'Vende lo que no usas',     consejo: 'Si algo lleva un año guardado, véndelo. Es dinero estancado que podrías estar ahorrando.'),
  FinancialTip(id: 25, categoria: 'personal', titulo: 'Efectivo vs Tarjeta',      consejo: 'Si te cuesta controlarte, intenta usar efectivo para tus gastos variables; duele más soltar el billete.'),
  FinancialTip(id: 26, categoria: 'parejas',  titulo: 'Regalos con Tiempo',       consejo: 'Planifiquen los regalos de cumpleaños o navidad con meses de antelación para aprovechar ofertas.'),
  FinancialTip(id: 27, categoria: 'ahorro',   titulo: 'Interés Compuesto',        consejo: 'Entender cómo el dinero crece con el tiempo es la mejor herramienta para tu futuro.'),
  FinancialTip(id: 28, categoria: 'personal', titulo: 'Revisión Semanal',         consejo: 'No esperes a fin de mes. Revisa tus gastos cada domingo para ver si vas por buen camino.'),
  FinancialTip(id: 29, categoria: 'parejas',  titulo: 'Limites de Gasto',         consejo: 'Pongan un límite de gasto por el cual deben consultarse antes de realizar la compra.'),
  FinancialTip(id: 30, categoria: 'ahorro',   titulo: 'Repara antes de Comprar',  consejo: 'Antes de tirar algo roto, mira si tiene arreglo. Reparar suele ser mucho más barato que reemplazar.'),
  FinancialTip(id: 31, categoria: 'personal', titulo: 'Presupuesto Base Cero',    consejo: 'Dale un trabajo a cada centavo que ganes antes de que el mes comience.'),
  FinancialTip(id: 32, categoria: 'parejas',  titulo: 'Fondo de Citas',           consejo: 'Tengan un pequeño presupuesto mensual exclusivo para salir y fortalecer su relación.'),
  FinancialTip(id: 33, categoria: 'ahorro',   titulo: 'Agua en Casa',             consejo: 'Llevar tu propia botella de agua te ahorra mucho dinero al mes y ayudas al medio ambiente.'),
  FinancialTip(id: 34, categoria: 'personal', titulo: 'Analiza tus Errores',      consejo: 'Si un mes te excedes, no te castigues. Analiza por qué pasó y ajusta el siguiente mes.'),
  FinancialTip(id: 35, categoria: 'parejas',  titulo: 'Tareas Divididas',         consejo: 'Dividan quién revisa qué facturas para que ambos estén involucrados en la administración.'),
  FinancialTip(id: 36, categoria: 'ahorro',   titulo: 'Coche vs Caminar',         consejo: 'Si el trayecto es corto, camina. Ahorras gasolina, mantenimiento y ganas salud.'),
  FinancialTip(id: 37, categoria: 'personal', titulo: 'Objetivos Visuales',       consejo: 'Pon una foto de lo que quieres lograr cerca de tu billetera o como fondo de pantalla.'),
  FinancialTip(id: 38, categoria: 'parejas',  titulo: 'Ahorro Automático',        consejo: 'Programen una transferencia automática a su cuenta de ahorro duo el día que cobran.'),
  FinancialTip(id: 39, categoria: 'ahorro',   titulo: 'Comparar Precios',         consejo: 'Antes de una compra grande, revisa al menos tres opciones o tiendas diferentes.'),
  FinancialTip(id: 40, categoria: 'personal', titulo: 'Seguros',                  consejo: 'Tener un buen seguro no es un gasto, es una protección para tu ahorro ante una catástrofe.'),
  FinancialTip(id: 41, categoria: 'parejas',  titulo: 'Sin Culpa',                consejo: 'Si la pareja se equivoca con un gasto, hablen de cómo evitarlo en lugar de buscar culpables.'),
  FinancialTip(id: 42, categoria: 'ahorro',   titulo: 'Luz Natural',              consejo: 'Aprovecha la luz del sol lo más posible para reducir el consumo eléctrico en casa.'),
  FinancialTip(id: 43, categoria: 'personal', titulo: 'Ingresos Extras',          consejo: 'Si recibes un bono o regalo, destina al menos el 50% de eso directamente a tus ahorros.'),
  FinancialTip(id: 44, categoria: 'parejas',  titulo: 'Diversión Low-Cost',       consejo: 'Busquen actividades gratuitas en su ciudad; no siempre hay que gastar para pasarla bien.'),
  FinancialTip(id: 45, categoria: 'ahorro',   titulo: 'Cocina en Lote',           consejo: 'Cocinar grandes cantidades evita que pidas comida por cansancio entre semana.'),
  FinancialTip(id: 46, categoria: 'personal', titulo: 'Cero Comisiones',          consejo: 'Asegúrate de que tus cuentas bancarias no te cobren comisiones por manejo o retiros.'),
  FinancialTip(id: 47, categoria: 'parejas',  titulo: 'Sincronización',           consejo: 'Anoten el gasto en la app en el momento que sucede para que el dashboard sea real.'),
  FinancialTip(id: 48, categoria: 'ahorro',   titulo: 'Biblioteca',               consejo: 'Antes de comprar un libro, mira si está en una biblioteca o si alguien te lo puede prestar.'),
  FinancialTip(id: 49, categoria: 'personal', titulo: 'Mantén la Calma',          consejo: 'Las inversiones a largo plazo requieren paciencia. No tomes decisiones financieras por pánico.'),
  FinancialTip(id: 50, categoria: 'ahorro',   titulo: 'Mentalidad de Abundancia', consejo: '¡Ahorrar no es limitarse, es liberarse de preocupaciones futuras! ¡Sigue adelante!'),
];

// ─── Category metadata ───────────────────────────────────────────────────────
Map<String, _CatMeta> _catMeta(bool isDark) => {
  'personal': _CatMeta(
    emoji: '👤',
    label: 'Personal',
    gradient: isDark
        ? [const Color(0xFF6D28D9), const Color(0xFF4C1D95)]
        : [const Color(0xFF7C3AED), const Color(0xFF5B21B6)],
    chip: isDark ? const Color(0xFF7C3AED) : const Color(0xFFEDE9FE),
    chipText: isDark ? Colors.white : const Color(0xFF4C1D95),
  ),
  'parejas': _CatMeta(
    emoji: '💑',
    label: 'Parejas',
    gradient: isDark
        ? [const Color(0xFF9D174D), const Color(0xFF831843)]
        : [const Color(0xFFDB2777), const Color(0xFFBE185D)],
    chip: isDark ? const Color(0xFFBE185D) : const Color(0xFFFCE7F3),
    chipText: isDark ? Colors.white : const Color(0xFF831843),
  ),
  'ahorro': _CatMeta(
    emoji: '💰',
    label: 'Ahorro',
    gradient: isDark
        ? [const Color(0xFF065F46), const Color(0xFF064E3B)]
        : [const Color(0xFF059669), const Color(0xFF047857)],
    chip: isDark ? const Color(0xFF047857) : const Color(0xFFD1FAE5),
    chipText: isDark ? Colors.white : const Color(0xFF064E3B),
  ),
};

class _CatMeta {
  final String emoji;
  final String label;
  final List<Color> gradient;
  final Color chip;
  final Color chipText;
  const _CatMeta({
    required this.emoji,
    required this.label,
    required this.gradient,
    required this.chip,
    required this.chipText,
  });
}

// ─── SharedPreferences key ────────────────────────────────────────────────────
const _kLastTipDateKey = 'daily_tip_last_shown_date';
const _kLastTipIdKey   = 'daily_tip_last_id';

// ─── Static helper ────────────────────────────────────────────────────────────
class DailyTipModal {
  /// Shows the modal only once per calendar day. Call from dashboard's
  /// [initState] / [build] post-frame callback.
  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastShown = prefs.getString(_kLastTipDateKey) ?? '';

    if (lastShown == today) return; // Already shown today

    // Pick a tip: cycle through all 50 by day-of-year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final tip = kFinancialTips[dayOfYear % kFinancialTips.length];

    // Save state
    await prefs.setString(_kLastTipDateKey, today);
    await prefs.setInt(_kLastTipIdKey, tip.id);

    if (!context.mounted) return;
    _show(context, tip);
  }

  /// Force-show for testing / manual trigger.
  static void show(BuildContext context) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final tip = kFinancialTips[dayOfYear % kFinancialTips.length];
    _show(context, tip);
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static void _show(BuildContext context, FinancialTip tip) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Consejo del día',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => _DailyTipDialog(tip: tip),
    );
  }
}

// ─── Dialog widget ────────────────────────────────────────────────────────────
class _DailyTipDialog extends StatelessWidget {
  final FinancialTip tip;
  const _DailyTipDialog({required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _catMeta(isDark)[tip.categoria]!;
    final today = DateTime.now();
    final dayLabel = _dayLabel(today);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: meta.gradient[0].withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header gradient banner ──
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: meta.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -20, right: -20,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30, left: -10,
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Consejo del Día',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  dayLabel,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(meta.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tip.titulo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: meta.chip,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${meta.emoji}  ${meta.label}',
                        style: TextStyle(
                          color: meta.chipText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tip text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : meta.gradient[0].withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : meta.gradient[0].withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.format_quote_rounded,
                              color: meta.gradient[0].withValues(alpha: 0.6),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip.consejo,
                              style: TextStyle(
                                color: isDark ? Colors.grey[200] : const Color(0xFF1F2937),
                                fontSize: 15,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tip counter pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Consejo #${tip.id} de ${kFinancialTips.length}',
                            style: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: meta.gradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: meta.gradient[0].withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '¡Entendido, lo aplicaré hoy! 💪',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
