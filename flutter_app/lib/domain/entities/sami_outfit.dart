import 'package:flutter/material.dart';

class SamiOutfit {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String accessoryEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final int cost; // en monedas de la tienda
  final bool isFree;
  final String rarity; // 'Inicial', 'Común', 'Especial', 'Épico', 'Legendario'
  final Color rarityColor;

  const SamiOutfit({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.accessoryEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cost,
    this.isFree = false,
    required this.rarity,
    required this.rarityColor,
  });

  /// Lista de todos los atuendos de SAMI disponibles en QUIVO
  static const List<SamiOutfit> allOutfits = [
    // 1. Clásico (Gratis / Inicial)
    SamiOutfit(
      id: 'sami_default',
      name: 'SAMI Clásico',
      subtitle: 'Semilla Original',
      description: 'El tierno personaje original de QUIVO saludando con su hojita verde.',
      imageAsset: 'assets/images/sami_bienvenida.png',
      accessoryEmoji: '🌱',
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
      cost: 0,
      isFree: true,
      rarity: 'Inicial',
      rarityColor: Color(0xFF10B981),
    ),

    // 2. Gorra Deportiva Urbana
    SamiOutfit(
      id: 'sami_cap',
      name: 'SAMI Urbano',
      subtitle: 'Gorra Deportiva QUIVO',
      description: 'Estilo fresco y juvenil con gorra deportiva azul y cyan para el día a día.',
      imageAsset: 'assets/images/sami_bienvenida.png',
      accessoryEmoji: '🧢',
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF2563EB),
      cost: 50,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
    ),

    // 3. Traje Formal Ejecutivo
    SamiOutfit(
      id: 'sami_executive',
      name: 'SAMI Ejecutivo',
      subtitle: 'Traje Formal y Corbata',
      description: 'Vestido de etiqueta con saco formal y corbata de seda para grandes negocios.',
      imageAsset: 'assets/images/sami_ahorro.png',
      accessoryEmoji: '👔',
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFF0F172A),
      cost: 75,
      rarity: 'Especial',
      rarityColor: Color(0xFF60A5FA),
    ),

    // 4. Detective Financiero
    SamiOutfit(
      id: 'sami_detective',
      name: 'SAMI Detective',
      subtitle: 'Rastreador de Gastos',
      description: 'Equipado con lupa dorada y sombrero para rastrear cada centavo de tu presupuesto.',
      imageAsset: 'assets/images/sami_analizando.png',
      accessoryEmoji: '🔍',
      primaryColor: Color(0xFF78350F),
      secondaryColor: Color(0xFF451A03),
      cost: 75,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
    ),

    // 5. Festivo y Celebración
    SamiOutfit(
      id: 'sami_party',
      name: 'SAMI Festivo',
      subtitle: 'Gorro de Fiesta',
      description: 'Listo para festejar tus rachas y logros de ahorro con confeti y alegría.',
      imageAsset: 'assets/images/sami_celebrando.png',
      accessoryEmoji: '🥳',
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFBE185D),
      cost: 100,
      rarity: 'Especial',
      rarityColor: Color(0xFFF472B6),
    ),

    // 6. Superhéroe del Ahorro
    SamiOutfit(
      id: 'sami_superhero',
      name: 'SAMI Superhéroe',
      subtitle: 'Capa Protectora',
      description: 'Con capa flotante y escudo invencible para proteger tu bolsillo de las deudas.',
      imageAsset: 'assets/images/sami_alerta.png',
      accessoryEmoji: '🦸',
      primaryColor: Color(0xFFEF4444),
      secondaryColor: Color(0xFF991B1B),
      cost: 100,
      rarity: 'Épico',
      rarityColor: Color(0xFFF87171),
    ),

    // 7. Chef Gourmet
    SamiOutfit(
      id: 'sami_chef',
      name: 'SAMI Chef',
      subtitle: 'Gorro de Cocina',
      description: 'Cocinando las mejores recetas de ahorro e inversiones saludables para ti.',
      imageAsset: 'assets/images/sami_ahorro.png',
      accessoryEmoji: '👨‍🍳',
      primaryColor: Color(0xFFF97316),
      secondaryColor: Color(0xFFC2410C),
      cost: 150,
      rarity: 'Épico',
      rarityColor: Color(0xFFFB923C),
    ),

    // 8. Mago de las Finanzas
    SamiOutfit(
      id: 'sami_wizard',
      name: 'SAMI Mago',
      subtitle: 'Hechicero del Dinero',
      description: 'Sombrero místico con estrellas doradas y varita multiplicadora de ahorros.',
      imageAsset: 'assets/images/sami_analizando.png',
      accessoryEmoji: '🧙',
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFF5B21B6),
      cost: 150,
      rarity: 'Épico',
      rarityColor: Color(0xFFA78BFA),
    ),

    // 9. Ninja Antigasto
    SamiOutfit(
      id: 'sami_ninja',
      name: 'SAMI Ninja',
      subtitle: 'Cinta y Sigilo',
      description: 'Cinta ninja frontal y técnica de sombras para eliminar gastos innecesarios.',
      imageAsset: 'assets/images/sami_alerta.png',
      accessoryEmoji: '🥷',
      primaryColor: Color(0xFF334155),
      secondaryColor: Color(0xFF0F172A),
      cost: 200,
      rarity: 'Épico',
      rarityColor: Color(0xFF94A3B8),
    ),

    // 10. Astronauta Cripto
    SamiOutfit(
      id: 'sami_astronaut',
      name: 'SAMI Astronauta',
      subtitle: 'Casco Espacial QUIVO',
      description: 'Traje presurizado con visor reflectante para llevar tus metas financieras a la luna.',
      imageAsset: 'assets/images/sami_celebrando.png',
      accessoryEmoji: '🧑‍🚀',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0F172A),
      cost: 250,
      rarity: 'Legendario',
      rarityColor: Color(0xFF38BDF8),
    ),

    // 11. Rey del Ahorro
    SamiOutfit(
      id: 'sami_king',
      name: 'SAMI Rey Imperial',
      subtitle: 'Corona de Oro y Gemas',
      description: 'Corona imperial y cetro real reservado para los verdaderos monarcas de la disciplina.',
      imageAsset: 'assets/images/sami_celebrando.png',
      accessoryEmoji: '👑',
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
      cost: 300,
      rarity: 'Legendario',
      rarityColor: Color(0xFFFBBF24),
    ),

    // 12. Inversionista Wall Street
    SamiOutfit(
      id: 'sami_wallstreet',
      name: 'SAMI Wall Street',
      subtitle: 'Gafas de Sol y Diamante',
      description: 'Lentes oscuros VIP, cadena dorada y estilo millonario de las grandes ligas.',
      imageAsset: 'assets/images/sami_ahorro.png',
      accessoryEmoji: '💎',
      primaryColor: Color(0xFF0D9488),
      secondaryColor: Color(0xFF115E59),
      cost: 350,
      rarity: 'Legendario',
      rarityColor: Color(0xFF2DD4BF),
    ),
  ];

  /// Obtiene un outfit por ID con retrocompatibilidad para los antiguos IDs (avatar1..avatar10)
  static SamiOutfit getOutfit(String? id) {
    if (id == null || id.isEmpty || id == 'default' || id == '👤') {
      return allOutfits.first; // sami_default
    }

    // Mapeo retrocompatible para usuarios existentes
    const legacyMap = {
      'avatar1': 'sami_superhero',
      'avatar2': 'sami_wizard',
      'avatar3': 'sami_king',
      'avatar4': 'sami_ninja',
      'avatar5': 'sami_astronaut',
      'avatar6': 'sami_wallstreet',
      'avatar7': 'sami_chef',
      'avatar8': 'sami_detective',
      'avatar9': 'sami_party',
      'avatar10': 'sami_executive',
      '🦸': 'sami_superhero',
      '🧙': 'sami_wizard',
      '👑': 'sami_king',
      '🥷': 'sami_ninja',
      '🧑‍🚀': 'sami_astronaut',
      '💎': 'sami_wallstreet',
      '🥳': 'sami_party',
      '🌱': 'sami_default',
      '🧢': 'sami_cap',
      '👔': 'sami_executive',
      '🔍': 'sami_detective',
      '👨‍🍳': 'sami_chef',
    };

    final resolvedId = legacyMap[id] ?? id;

    return allOutfits.firstWhere(
      (outfit) => outfit.id == resolvedId,
      orElse: () => allOutfits.first,
    );
  }
}
