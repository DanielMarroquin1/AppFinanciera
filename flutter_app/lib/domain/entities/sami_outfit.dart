import 'package:flutter/material.dart';

enum WardrobeCategory {
  clothing, // Ropa
  shoes, // Zapatos
  accessories, // Accesorios (bufandas, cascos, etc.)
}

class WardrobeItem {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final WardrobeCategory category;
  final String emoji;
  final int cost;
  final bool isFree;
  final String rarity; // 'Inicial', 'Común', 'Especial', 'Épico', 'Legendario'
  final Color rarityColor;
  final Color primaryColor;
  final Color secondaryColor;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.emoji,
    required this.cost,
    this.isFree = false,
    required this.rarity,
    required this.rarityColor,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static const List<WardrobeItem> allItems = [
    // ==========================================
    // 1. SECCIÓN: ROPA
    // ==========================================
    WardrobeItem(
      id: 'ropa_clasica',
      name: 'SAMI Clásico',
      subtitle: 'Plumaje Original',
      description: 'El estilo original de SAMI con su plumaje azul marino, vientre blanco y el emblema Q.',
      category: WardrobeCategory.clothing,
      emoji: '👕',
      cost: 0,
      isFree: true,
      rarity: 'Inicial',
      rarityColor: Color(0xFF10B981),
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0369A1),
    ),
    WardrobeItem(
      id: 'ropa_ejecutivo',
      name: 'Traje Ejecutivo',
      subtitle: 'Finanzas & Inversión',
      description: 'Saco formal azul marino y corbata de seda para cerrar grandes negocios financieros.',
      category: WardrobeCategory.clothing,
      emoji: '👔',
      cost: 75,
      rarity: 'Especial',
      rarityColor: Color(0xFF60A5FA),
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFF0F172A),
    ),
    WardrobeItem(
      id: 'ropa_sudadera',
      name: 'Sudadera Streetwear',
      subtitle: 'Estilo Urbano Cyan',
      description: 'Hoodie holgado y moderno con detalles en color cyan eléctrico QUIVO.',
      category: WardrobeCategory.clothing,
      emoji: '🧥',
      cost: 60,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0369A1),
    ),
    WardrobeItem(
      id: 'ropa_superheroe',
      name: 'Traje de Superhéroe',
      subtitle: 'Defensor del Presupuesto',
      description: 'Capa escarlata ondeante y traje reforzado para combatir las deudas.',
      category: WardrobeCategory.clothing,
      emoji: '🦸',
      cost: 120,
      rarity: 'Épico',
      rarityColor: Color(0xFFA855F7),
      primaryColor: Color(0xFFDC2626),
      secondaryColor: Color(0xFF991B1B),
    ),
    WardrobeItem(
      id: 'ropa_deportiva',
      name: 'Conjunto Atlético Tech',
      subtitle: 'Rendimiento Fit',
      description: 'Jersey transpirable para mantener el ritmo y la disciplina en tus metas de ahorro.',
      category: WardrobeCategory.clothing,
      emoji: '🎽',
      cost: 50,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
      primaryColor: Color(0xFF0D9488),
      secondaryColor: Color(0xFF115E59),
    ),
    WardrobeItem(
      id: 'ropa_chef',
      name: 'Filipina de Chef',
      subtitle: 'Maestro Culinario',
      description: 'Chaqueta de alta cocina con botones dorados para cocinar grandes ahorros.',
      category: WardrobeCategory.clothing,
      emoji: '👨‍🍳',
      cost: 70,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
    ),
    WardrobeItem(
      id: 'ropa_armadura',
      name: 'Armadura Galáctica',
      subtitle: 'Titanio Blindado',
      description: 'Coraza de nanotecnología impenetrable contra compras impulsivas y gastos hormiga.',
      category: WardrobeCategory.clothing,
      emoji: '🛡️',
      cost: 160,
      rarity: 'Legendario',
      rarityColor: Color(0xFFF43F5E),
      primaryColor: Color(0xFF475569),
      secondaryColor: Color(0xFF0F172A),
    ),
    WardrobeItem(
      id: 'ropa_toga',
      name: 'Toga Imperial de Oro',
      subtitle: 'Realeza Financiera',
      description: 'Toga bordada con hilos de oro de 24k para el soberano absoluto de su presupuesto.',
      category: WardrobeCategory.clothing,
      emoji: '✨',
      cost: 220,
      rarity: 'Legendario',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF78350F),
    ),

    // ==========================================
    // 2. SECCIÓN: ZAPATOS
    // ==========================================
    WardrobeItem(
      id: 'zap_clasicos',
      name: 'Huellitas Originales',
      subtitle: 'Paso Firme',
      description: 'Las suaves patitas naturales de SAMI listas para saltar hacia tus metas.',
      category: WardrobeCategory.shoes,
      emoji: '🐾',
      cost: 0,
      isFree: true,
      rarity: 'Inicial',
      rarityColor: Color(0xFF10B981),
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
    ),
    WardrobeItem(
      id: 'zap_sneakers',
      name: 'Tenis Runner Neón',
      subtitle: 'Suela LED Cyan',
      description: 'Sneakers deportivos con amortiguación y luces LED que brillan al caminar.',
      category: WardrobeCategory.shoes,
      emoji: '👟',
      cost: 45,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF0284C7),
    ),
    WardrobeItem(
      id: 'zap_botas',
      name: 'Botas de Explorador',
      subtitle: 'Cuero Todo Terreno',
      description: 'Botas robustas y resistentes para conquistar senderos y metas financieras.',
      category: WardrobeCategory.shoes,
      emoji: '🥾',
      cost: 60,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFF92400E),
      secondaryColor: Color(0xFF78350F),
    ),
    WardrobeItem(
      id: 'zap_charol',
      name: 'Mocasines de Gala',
      subtitle: 'Charol Espejo',
      description: 'Zapatos de gala negros ultra pulidos para reuniones bancarias de alto nivel.',
      category: WardrobeCategory.shoes,
      emoji: '👞',
      cost: 70,
      rarity: 'Especial',
      rarityColor: Color(0xFF60A5FA),
      primaryColor: Color(0xFF334155),
      secondaryColor: Color(0xFF0F172A),
    ),
    WardrobeItem(
      id: 'zap_espaciales',
      name: 'Botas Antigravedad',
      subtitle: 'Propulsión Lunar',
      description: 'Calzado gravitatorio con suela magnética para flotar sobre el presupuesto.',
      category: WardrobeCategory.shoes,
      emoji: '🥿',
      cost: 110,
      rarity: 'Épico',
      rarityColor: Color(0xFFA855F7),
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFF4C1D95),
    ),
    WardrobeItem(
      id: 'zap_dorados',
      name: 'Pantuflas de Lingotes',
      subtitle: 'Oro Macizo',
      description: 'Pantuflas de terciopelo real con incrustaciones de monedas de oro macizo.',
      category: WardrobeCategory.shoes,
      emoji: '⭐',
      cost: 180,
      rarity: 'Legendario',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
    ),

    // ==========================================
    // 3. SECCIÓN: ACCESORIOS (Bufandas, Cascos, etc.)
    // ==========================================
    WardrobeItem(
      id: 'acc_ninguno',
      name: 'Sin Accesorio',
      subtitle: 'Al Natural',
      description: 'SAMI al natural luciendo su hojita cyan original.',
      category: WardrobeCategory.accessories,
      emoji: '🌱',
      cost: 0,
      isFree: true,
      rarity: 'Inicial',
      rarityColor: Color(0xFF10B981),
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
    ),
    WardrobeItem(
      id: 'acc_bufanda_nordica',
      name: 'Bufanda Nórdica',
      subtitle: 'Lana Suave de Invierno',
      description: 'Bufanda azul y blanca tejida a mano que abriga a SAMI contra el frío financiero.',
      category: WardrobeCategory.accessories,
      emoji: '🧣',
      cost: 55,
      rarity: 'Especial',
      rarityColor: Color(0xFF38BDF8),
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF075985),
    ),
    WardrobeItem(
      id: 'acc_bufanda_carmesi',
      name: 'Bufanda Carmesí',
      subtitle: 'Seda Roja Ondeante',
      description: 'Bufanda de seda roja vibrante que ondea con el viento al caminar con estilo.',
      category: WardrobeCategory.accessories,
      emoji: '🧣',
      cost: 70,
      rarity: 'Especial',
      rarityColor: Color(0xFFF43F5E),
      primaryColor: Color(0xFFE11D48),
      secondaryColor: Color(0xFF9F1239),
    ),
    WardrobeItem(
      id: 'acc_casco_astronauta',
      name: 'Casco de Astronauta',
      subtitle: 'Visor de Oro Galáctico',
      description: 'Casco espacial presurizado con visor reflectante de oro para viajar a las estrellas.',
      category: WardrobeCategory.accessories,
      emoji: '🧑‍🚀',
      cost: 130,
      rarity: 'Épico',
      rarityColor: Color(0xFFA855F7),
      primaryColor: Color(0xFF6366F1),
      secondaryColor: Color(0xFF312E81),
    ),
    WardrobeItem(
      id: 'acc_casco_cyberpunk',
      name: 'Casco Gamer Cyberpunk',
      subtitle: 'HUD Holográfico Neón',
      description: 'Casco futurista con visera digital que proyecta en tiempo real tus estadísticas.',
      category: WardrobeCategory.accessories,
      emoji: '🥽',
      cost: 140,
      rarity: 'Épico',
      rarityColor: Color(0xFF06B6D4),
      primaryColor: Color(0xFF0891B2),
      secondaryColor: Color(0xFF164E63),
    ),
    WardrobeItem(
      id: 'acc_casco_piloto',
      name: 'Casco de Piloto Aviador',
      subtitle: 'Aviación Clásica',
      description: 'Casco de cuero vintage con gafas protectoras para volar alto sobre tus deudas.',
      category: WardrobeCategory.accessories,
      emoji: '🪖',
      cost: 85,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFFB45309),
      secondaryColor: Color(0xFF78350F),
    ),
    WardrobeItem(
      id: 'acc_gorra',
      name: 'Gorra Snapback Urbana',
      subtitle: 'Visera Plana QUIVO',
      description: 'Gorra moderna con bordado de la Q frontal en color cyan y azul medianoche.',
      category: WardrobeCategory.accessories,
      emoji: '🧢',
      cost: 45,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
      primaryColor: Color(0xFF2563EB),
      secondaryColor: Color(0xFF1D4ED8),
    ),
    WardrobeItem(
      id: 'acc_corona',
      name: 'Corona Imperial',
      subtitle: 'Oro Macizo y Rubíes',
      description: 'Corona real dorada con gemas resplandecientes para el emperador del ahorro.',
      category: WardrobeCategory.accessories,
      emoji: '👑',
      cost: 250,
      rarity: 'Legendario',
      rarityColor: Color(0xFFF59E0B),
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF78350F),
    ),
    WardrobeItem(
      id: 'acc_lentes_vip',
      name: 'Lentes Oscuros VIP',
      subtitle: 'Polarizado Negro',
      description: 'Gafas de sol polarizadas de diseñador para inversionistas sofisticados.',
      category: WardrobeCategory.accessories,
      emoji: '🕶️',
      cost: 40,
      rarity: 'Común',
      rarityColor: Color(0xFF94A3B8),
      primaryColor: Color(0xFF475569),
      secondaryColor: Color(0xFF1E293B),
    ),
    WardrobeItem(
      id: 'acc_auriculares',
      name: 'Auriculares DJ Wireless',
      subtitle: 'Audio Espacial',
      description: 'Cascos inalámbricos con cancelación de ruido y sonido estéreo envolvente.',
      category: WardrobeCategory.accessories,
      emoji: '🎧',
      cost: 65,
      rarity: 'Especial',
      rarityColor: Color(0xFFA855F7),
      primaryColor: Color(0xFF9333EA),
      secondaryColor: Color(0xFF581C87),
    ),
  ];

  static WardrobeItem getItem(String? id) {
    if (id == null) return allItems.first;
    return allItems.firstWhere(
      (item) => item.id == id,
      orElse: () => allItems.first,
    );
  }

  static List<WardrobeItem> getByCategory(WardrobeCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }
}

/// Estado de equipamiento completo de SAMI (Ropa, Zapatos, Accesorios)
class SamiEquipment {
  final String clothingId;
  final String shoesId;
  final String accessoryId;

  const SamiEquipment({
    this.clothingId = 'ropa_clasica',
    this.shoesId = 'zap_clasicos',
    this.accessoryId = 'acc_ninguno',
  });

  String toStorageString() => '$clothingId|$shoesId|$accessoryId';

  static SamiEquipment fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return const SamiEquipment();

    if (raw.contains('|')) {
      final parts = raw.split('|');
      return SamiEquipment(
        clothingId: parts.isNotEmpty ? parts[0] : 'ropa_clasica',
        shoesId: parts.length > 1 ? parts[1] : 'zap_clasicos',
        accessoryId: parts.length > 2 ? parts[2] : 'acc_ninguno',
      );
    }

    // Mapeo retrocompatible con antiguos IDs
    switch (raw) {
      case 'sami_cap':
        return const SamiEquipment(accessoryId: 'acc_gorra');
      case 'sami_executive':
      case 'avatar10':
        return const SamiEquipment(
          clothingId: 'ropa_ejecutivo',
          shoesId: 'zap_charol',
        );
      case 'sami_astronaut':
      case 'avatar5':
        return const SamiEquipment(
          clothingId: 'ropa_armadura',
          shoesId: 'zap_espaciales',
          accessoryId: 'acc_casco_astronauta',
        );
      case 'sami_superhero':
      case 'avatar1':
        return const SamiEquipment(
          clothingId: 'ropa_superheroe',
          shoesId: 'zap_sneakers',
        );
      case 'sami_king':
      case 'avatar3':
        return const SamiEquipment(
          clothingId: 'ropa_toga',
          shoesId: 'zap_dorados',
          accessoryId: 'acc_corona',
        );
      case 'sami_chef':
      case 'avatar7':
        return const SamiEquipment(clothingId: 'ropa_chef');
      case 'sami_detective':
      case 'avatar8':
        return const SamiEquipment(
          clothingId: 'ropa_ejecutivo',
          accessoryId: 'acc_lentes_vip',
        );
      case 'sami_party':
      case 'avatar9':
        return const SamiEquipment(
          clothingId: 'ropa_sudadera',
          accessoryId: 'acc_gorra',
        );
      case 'sami_wallstreet':
      case 'avatar6':
        return const SamiEquipment(
          clothingId: 'ropa_ejecutivo',
          shoesId: 'zap_dorados',
          accessoryId: 'acc_corona',
        );
      default:
        // Si coincide con algún WardrobeItem
        for (final item in WardrobeItem.allItems) {
          if (item.id == raw) {
            if (item.category == WardrobeCategory.clothing) {
              return SamiEquipment(clothingId: item.id);
            }
            if (item.category == WardrobeCategory.shoes) {
              return SamiEquipment(shoesId: item.id);
            }
            if (item.category == WardrobeCategory.accessories) {
              return SamiEquipment(accessoryId: item.id);
            }
          }
        }
        return const SamiEquipment();
    }
  }

  SamiEquipment copyWith({
    String? clothingId,
    String? shoesId,
    String? accessoryId,
  }) {
    return SamiEquipment(
      clothingId: clothingId ?? this.clothingId,
      shoesId: shoesId ?? this.shoesId,
      accessoryId: accessoryId ?? this.accessoryId,
    );
  }
}

/// Modelo de atuendos completos (mantenido para retrocompatibilidad en widgets existentes)
class SamiOutfit {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String accessoryEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final int cost;
  final bool isFree;
  final String rarity;
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

  static const List<SamiOutfit> allOutfits = [
    SamiOutfit(
      id: 'sami_default',
      name: 'SAMI Clásico',
      subtitle: 'Semilla Original',
      description: 'El personaje oficial de QUIVO con su suave plumaje azul marino y vientre blanco.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🌱',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0369A1),
      cost: 0,
      isFree: true,
      rarity: 'Inicial',
      rarityColor: Color(0xFF10B981),
    ),
    SamiOutfit(
      id: 'sami_cap',
      name: 'SAMI Urbano',
      subtitle: 'Gorra Snapback QUIVO',
      description: 'Estilo fresco y juvenil con gorra deportiva azul y cyan para el día a día.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🧢',
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF2563EB),
      cost: 45,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
    ),
    SamiOutfit(
      id: 'sami_executive',
      name: 'SAMI Ejecutivo',
      subtitle: 'Traje Formal y Corbata',
      description: 'Vestido de etiqueta con saco formal y corbata de seda para grandes negocios.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '👔',
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFF0F172A),
      cost: 75,
      rarity: 'Especial',
      rarityColor: Color(0xFF60A5FA),
    ),
    SamiOutfit(
      id: 'sami_detective',
      name: 'SAMI Detective',
      subtitle: 'Rastreador de Gastos',
      description: 'Equipado con lentes oscuros para rastrear cada centavo de tu presupuesto.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🕶️',
      primaryColor: Color(0xFF475569),
      secondaryColor: Color(0xFF1E293B),
      cost: 75,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
    ),
    SamiOutfit(
      id: 'sami_party',
      name: 'SAMI Urbano Street',
      subtitle: 'Sudadera Streetwear',
      description: 'Listo con hoodie cyan para festejar tus rachas y logros de ahorro.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🧥',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0369A1),
      cost: 60,
      rarity: 'Común',
      rarityColor: Color(0xFF38BDF8),
    ),
    SamiOutfit(
      id: 'sami_superhero',
      name: 'SAMI Superhéroe',
      subtitle: 'Capa Protectora',
      description: 'Listo para rescatar tus finanzas con su capa roja y valentía inquebrantable.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🦸',
      primaryColor: Color(0xFFDC2626),
      secondaryColor: Color(0xFF991B1B),
      cost: 120,
      rarity: 'Épico',
      rarityColor: Color(0xFFA855F7),
    ),
    SamiOutfit(
      id: 'sami_chef',
      name: 'SAMI Chef',
      subtitle: 'Filipina Gourmet',
      description: 'Cocinando las mejores recetas de ahorro con su chaquetín de alta cocina.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '👨‍🍳',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF78350F),
      cost: 70,
      rarity: 'Especial',
      rarityColor: Color(0xFFF59E0B),
    ),
    SamiOutfit(
      id: 'sami_wizard',
      name: 'SAMI Astronauta',
      subtitle: 'Casco Espacial Galáctico',
      description: 'Explorando nuevas fronteras de ahorro con su casco espacial.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🧑‍🚀',
      primaryColor: Color(0xFF6366F1),
      secondaryColor: Color(0xFF312E81),
      cost: 130,
      rarity: 'Épico',
      rarityColor: Color(0xFFA855F7),
    ),
    SamiOutfit(
      id: 'sami_ninja',
      name: 'SAMI Cyberpunk',
      subtitle: 'Casco Holográfico HUD',
      description: 'Tecnología futurista con visera HUD neón para monitorear cada centavo.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🥽',
      primaryColor: Color(0xFF0891B2),
      secondaryColor: Color(0xFF164E63),
      cost: 140,
      rarity: 'Épico',
      rarityColor: Color(0xFF06B6D4),
    ),
    SamiOutfit(
      id: 'sami_astronaut',
      name: 'SAMI Bufanda Nórdica',
      subtitle: 'Abrigado de Invierno',
      description: 'Con su bufanda tejida azul protegiéndose del frío de la inflación.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '🧣',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF075985),
      cost: 55,
      rarity: 'Especial',
      rarityColor: Color(0xFF38BDF8),
    ),
    SamiOutfit(
      id: 'sami_king',
      name: 'SAMI Rey Imperial',
      subtitle: 'Corona Real de Oro',
      description: 'El soberano del ahorro y el control financiero con su corona real resplandeciente.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '👑',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF78350F),
      cost: 250,
      rarity: 'Legendario',
      rarityColor: Color(0xFFF59E0B),
    ),
    SamiOutfit(
      id: 'sami_wallstreet',
      name: 'SAMI Wall Street',
      subtitle: 'Armadura & Botas Doradas',
      description: 'El máximo nivel financiero: armadura de titanio y pantuflas de lingotes de oro.',
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: '⭐',
      primaryColor: Color(0xFF0F172A),
      secondaryColor: Color(0xFF0284C7),
      cost: 300,
      rarity: 'Legendario',
      rarityColor: Color(0xFF00E5FF),
    ),
  ];

  static SamiOutfit getOutfit(String? id) {
    if (id == null || id.isEmpty) return allOutfits.first;

    // Mapeo retrocompatible
    final equipment = SamiEquipment.fromStorage(id);
    final primaryClothing = WardrobeItem.getItem(equipment.clothingId);
    final primaryAcc = WardrobeItem.getItem(equipment.accessoryId);

    // Buscar si coincide por ID directo
    final directMatch = allOutfits.where((o) => o.id == id);
    if (directMatch.isNotEmpty) return directMatch.first;

    // Crear atuendo dinámico basado en equipamiento
    return SamiOutfit(
      id: equipment.toStorageString(),
      name: primaryClothing.id != 'ropa_clasica'
          ? primaryClothing.name
          : (primaryAcc.id != 'acc_ninguno' ? primaryAcc.name : 'SAMI Clásico'),
      subtitle: primaryAcc.id != 'acc_ninguno'
          ? primaryAcc.subtitle
          : primaryClothing.subtitle,
      description: primaryClothing.description,
      imageAsset: 'assets/images/sami_3d_front.png',
      accessoryEmoji: primaryAcc.id != 'acc_ninguno'
          ? primaryAcc.emoji
          : primaryClothing.emoji,
      primaryColor: primaryAcc.id != 'acc_ninguno'
          ? primaryAcc.primaryColor
          : primaryClothing.primaryColor,
      secondaryColor: primaryAcc.id != 'acc_ninguno'
          ? primaryAcc.secondaryColor
          : primaryClothing.secondaryColor,
      cost: primaryClothing.cost + primaryAcc.cost,
      rarity: primaryClothing.rarity,
      rarityColor: primaryClothing.rarityColor,
    );
  }
}
