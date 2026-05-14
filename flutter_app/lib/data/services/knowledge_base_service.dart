class KnowledgeBaseService {
  // Una "base de datos" estática simulando un sistema RAG
  static const Map<String, String> _knowledgeBase = {
    'regla 50 30 20': '''
Regla 50/30/20: Es un método de presupuesto muy popular.
- 50% para "Necesidades" (vivienda, comida, servicios básicos).
- 30% para "Deseos" (entretenimiento, restaurantes, viajes).
- 20% para "Ahorro e Inversión" (fondo de emergencia, acciones, retiro).
''',
    'padre rico padre pobre': '''
Conceptos clave de Padre Rico, Padre Pobre (Robert Kiyosaki):
- Diferencia entre Activos y Pasivos: Un activo pone dinero en tu bolsillo, un pasivo saca dinero de tu bolsillo. Compra activos, no pasivos.
- Haz que el dinero trabaje para ti: No trabajes por dinero, invierte en educación financiera para que tus inversiones generen flujo de efectivo.
''',
    'interés compuesto': '''
Interés Compuesto: Es el interés que se calcula sobre el capital inicial y también sobre los intereses acumulados de períodos anteriores. "El interés compuesto es la octava maravilla del mundo. El que lo entiende, lo gana; el que no, lo paga" - Albert Einstein.
''',
    'fondo de emergencia': '''
Fondo de Emergencia: Es una reserva de efectivo reservada para gastos no planificados o emergencias financieras (facturas médicas, reparaciones de auto, pérdida de empleo). Se recomienda que cubra de 3 a 6 meses de gastos de subsistencia esenciales.
''',
    'ahorro': '''
Estrategias de Ahorro:
1. Págate a ti mismo primero: Ahorra una parte de tu ingreso antes de pagar cualquier otra cosa.
2. Automatiza el ahorro: Configura transferencias automáticas a tu cuenta de ahorros el día de pago.
3. Evita las compras por impulso: Aplica la regla de las 24 horas (o 30 días) antes de hacer compras no esenciales.
'''
  };

  /// Busca en la base de conocimientos usando palabras clave del prompt
  static String getRelevantKnowledge(String prompt) {
    final lowercasePrompt = prompt.toLowerCase();
    List<String> relevantSnippets = [];

    _knowledgeBase.forEach((keyword, content) {
      // Búsqueda simple de palabras clave (simulando búsqueda vectorial)
      if (lowercasePrompt.contains(keyword) || 
          (keyword == 'ahorro' && (lowercasePrompt.contains('ahorrar') || lowercasePrompt.contains('plan de ahorro')))) {
        relevantSnippets.add(content);
      }
    });

    if (relevantSnippets.isEmpty) return "";

    return '''
[EXTRACCIÓN DE BASE DE CONOCIMIENTO (LIBROS Y TEORÍA)]:
${relevantSnippets.join("\n")}
''';
  }
}
