import { X, ShoppingBag, Star, Gift, Sparkles, Crown, Check, Lock, Palette } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface RewardsShopModalProps {
  onClose: () => void;
  userPoints: number;
}

interface Reward {
  id: string;
  name: string;
  description: string;
  icon: string;
  cost: number;
  category: "avatar" | "theme" | "feature" | "special";
  unlocked: boolean;
  paletteColors?: [string, string, string]; // for theme previews
}

// Palette definitions for theme rewards
const themePalettes: Record<string, { primary: string; secondary: string; accent: string }> = {
  "theme-ocean": { primary: "sky", secondary: "cyan", accent: "blue" },
  "theme-sunset": { primary: "orange", secondary: "rose", accent: "amber" },
  "theme-forest": { primary: "emerald", secondary: "lime", accent: "green" },
  "theme-lavender": { primary: "violet", secondary: "purple", accent: "fuchsia" },
  "theme-midnight": { primary: "slate", secondary: "indigo", accent: "blue" },
};

export function RewardsShopModal({ onClose, userPoints }: RewardsShopModalProps) {
  const { theme, unlockPalette, unlockedPalettes } = useTheme();
  const isDark = theme === "dark";
  const [points, setPoints] = useState(userPoints);
  const [purchasedRewards, setPurchasedRewards] = useState<string[]>([]);

  const rewards: Reward[] = [
    // Avatares especiales
    {
      id: "avatar-superhero",
      name: "Avatar Superhéroe",
      description: "Desbloquea avatares de superhéroes",
      icon: "🦸",
      cost: 50,
      category: "avatar",
      unlocked: false,
    },
    {
      id: "avatar-fantasy",
      name: "Avatar Fantasía",
      description: "Desbloquea avatares mágicos",
      icon: "🧙",
      cost: 50,
      category: "avatar",
      unlocked: false,
    },
    {
      id: "avatar-animals",
      name: "Avatar Animales",
      description: "Desbloquea avatares de animales",
      icon: "🐶",
      cost: 50,
      category: "avatar",
      unlocked: false,
    },
    // Temas / Paletas — with real color previews
    {
      id: "theme-ocean",
      name: "Paleta Océano",
      description: "Tonos azules y turquesa del mar",
      icon: "🌊",
      cost: 100,
      category: "theme",
      unlocked: false,
      paletteColors: ["#0ea5e9", "#06b6d4", "#3b82f6"], // sky, cyan, blue
    },
    {
      id: "theme-sunset",
      name: "Paleta Atardecer",
      description: "Tonos cálidos de naranja y rosa",
      icon: "🌅",
      cost: 100,
      category: "theme",
      unlocked: false,
      paletteColors: ["#f97316", "#f43f5e", "#f59e0b"], // orange, rose, amber
    },
    {
      id: "theme-forest",
      name: "Paleta Bosque",
      description: "Tonos verdes de naturaleza",
      icon: "🌲",
      cost: 100,
      category: "theme",
      unlocked: false,
      paletteColors: ["#10b981", "#84cc16", "#22c55e"], // emerald, lime, green
    },
    {
      id: "theme-lavender",
      name: "Paleta Lavanda",
      description: "Tonos suaves de violeta y púrpura",
      icon: "💜",
      cost: 120,
      category: "theme",
      unlocked: false,
      paletteColors: ["#8b5cf6", "#a855f7", "#d946ef"], // violet, purple, fuchsia
    },
    {
      id: "theme-midnight",
      name: "Paleta Medianoche",
      description: "Tonos profundos de azul oscuro",
      icon: "🌙",
      cost: 150,
      category: "theme",
      unlocked: false,
      paletteColors: ["#64748b", "#6366f1", "#3b82f6"], // slate, indigo, blue
    },
    // Funciones especiales
    {
      id: "feature-reports",
      name: "Reportes Avanzados",
      description: "Acceso a reportes detallados",
      icon: "📊",
      cost: 200,
      category: "feature",
      unlocked: false,
    },
    {
      id: "feature-export",
      name: "Exportar Datos",
      description: "Exporta tus datos a Excel/PDF",
      icon: "📤",
      cost: 150,
      category: "feature",
      unlocked: false,
    },
    {
      id: "feature-categories",
      name: "Categorías Personalizadas",
      description: "Crea tus propias categorías",
      icon: "🏷️",
      cost: 100,
      category: "feature",
      unlocked: false,
    },
    // Recompensas especiales
    {
      id: "special-premium-trial",
      name: "Prueba Premium 7 Días",
      description: "Acceso completo por 1 semana",
      icon: "👑",
      cost: 300,
      category: "special",
      unlocked: false,
    },
    {
      id: "special-discount-10",
      name: "10% Descuento Premium",
      description: "Cupón de descuento para suscripción",
      icon: "🎟️",
      cost: 250,
      category: "special",
      unlocked: false,
    },
    {
      id: "special-badge-master",
      name: "Insignia Maestro del Ahorro",
      description: "Insignia exclusiva para tu perfil",
      icon: "🏆",
      cost: 500,
      category: "special",
      unlocked: false,
    },
  ];

  // Map theme IDs to palette names
  const themeIdToName: Record<string, string> = {
    "theme-ocean": "Paleta Océano",
    "theme-sunset": "Paleta Atardecer",
    "theme-forest": "Paleta Bosque",
    "theme-lavender": "Paleta Lavanda",
    "theme-midnight": "Paleta Medianoche",
  };

  const handlePurchase = (reward: Reward) => {
    if (points >= reward.cost && !purchasedRewards.includes(reward.id)) {
      setPoints(points - reward.cost);
      setPurchasedRewards([...purchasedRewards, reward.id]);

      // If it's a theme, unlock the palette
      if (reward.category === "theme" && themePalettes[reward.id]) {
        const paletteName = themeIdToName[reward.id];
        if (paletteName) {
          unlockPalette(paletteName);
        }
      }

      toast.success(`¡${reward.name} desbloqueado! 🎉`, {
        description: `Te quedan ${points - reward.cost} puntos`,
      });
    } else if (purchasedRewards.includes(reward.id)) {
      toast.info("Ya has desbloqueado esta recompensa");
    } else {
      toast.error("No tienes suficientes puntos", {
        description: `Necesitas ${reward.cost - points} puntos más`,
      });
    }
  };

  const getCategoryLabel = (category: string) => {
    const labels: Record<string, string> = {
      avatar: "Avatares",
      theme: "🎨 Paletas de Colores",
      feature: "Funciones",
      special: "Especiales",
    };
    return labels[category];
  };

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      avatar: isDark ? "from-violet-900 to-pink-900" : "from-violet-500 to-pink-500",
      theme: isDark ? "from-indigo-900 to-emerald-900" : "from-indigo-500 to-emerald-500",
      feature: isDark ? "from-green-900 to-emerald-900" : "from-green-500 to-emerald-500",
      special: isDark ? "from-amber-900 to-orange-900" : "from-amber-500 to-orange-500",
    };
    return colors[category];
  };

  const groupedRewards = rewards.reduce((acc, reward) => {
    if (!acc[reward.category]) {
      acc[reward.category] = [];
    }
    acc[reward.category].push(reward);
    return acc;
  }, {} as Record<string, Reward[]>);

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${isDark ? "bg-gray-900" : "bg-white"
          } rounded-t-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-3">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <ShoppingBag className="w-7 h-7" />
              </div>
              <div>
                <h2 className="text-2xl">Tienda de Recompensas</h2>
                <p className="text-sm text-white/90">Canjea tus puntos</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Points Display */}
          <div className="bg-white/20 rounded-xl p-3 backdrop-blur-sm">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Star className="w-5 h-5" />
                <p className="text-sm text-white/90">Tus Puntos</p>
              </div>
              <p className="text-2xl font-bold">{points}</p>
            </div>
          </div>
        </div>

        {/* Rewards List */}
        <div className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 200px)" }}>
          {Object.entries(groupedRewards).map(([category, categoryRewards]) => (
            <div key={category} className="mb-6">
              {/* Category Header */}
              <div className="flex items-center gap-2 mb-3">
                <div className={`h-1 flex-1 rounded-full bg-gradient-to-r ${getCategoryColor(category)}`}></div>
                <h3 className={`text-sm font-semibold ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  {getCategoryLabel(category)}
                </h3>
                <div className={`h-1 flex-1 rounded-full bg-gradient-to-r ${getCategoryColor(category)}`}></div>
              </div>

              {/* Category Rewards */}
              <div className="space-y-3">
                {categoryRewards.map((reward) => {
                  const isPurchased = purchasedRewards.includes(reward.id) || (reward.category === "theme" && themeIdToName[reward.id] && unlockedPalettes.includes(themeIdToName[reward.id]));
                  const canAfford = points >= reward.cost;

                  return (
                    <div
                      key={reward.id}
                      className={`${isPurchased
                          ? isDark
                            ? "bg-green-900/30 border-green-700"
                            : "bg-green-50 border-green-400"
                          : isDark
                            ? "bg-gray-800 border-gray-700"
                            : "bg-white border-gray-200"
                        } border-2 rounded-2xl p-4 transition-all`}
                    >
                      <div className="flex items-start gap-4">
                        {/* Icon */}
                        <div className="relative flex-shrink-0">
                          <div
                            className={`w-14 h-14 ${isPurchased
                                ? isDark
                                  ? "bg-green-900/50"
                                  : "bg-green-100"
                                : isDark
                                  ? "bg-gray-700"
                                  : "bg-gray-100"
                              } rounded-2xl flex items-center justify-center text-2xl`}
                          >
                            {isPurchased ? (
                              <Check className={`w-8 h-8 ${isDark ? "text-green-400" : "text-green-600"}`} />
                            ) : (
                              reward.icon
                            )}
                          </div>
                          {isPurchased && (
                            <div className="absolute -top-1 -right-1 w-5 h-5 bg-green-500 rounded-full flex items-center justify-center border-2 border-white">
                              <Check className="w-3 h-3 text-white" />
                            </div>
                          )}
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between mb-1">
                            <h3
                              className={`text-sm font-semibold ${isPurchased
                                  ? isDark
                                    ? "text-green-400"
                                    : "text-green-700"
                                  : isDark
                                    ? "text-white"
                                    : "text-gray-900"
                                }`}
                            >
                              {reward.name}
                            </h3>
                          </div>
                          <p
                            className={`text-xs mb-2 ${isDark ? "text-gray-400" : "text-gray-600"
                              }`}
                          >
                            {reward.description}
                          </p>

                          {/* Palette Color Preview for theme rewards */}
                          {reward.category === "theme" && reward.paletteColors && (
                            <div className="flex gap-1.5 mb-3">
                              {reward.paletteColors.map((color, i) => (
                                <div
                                  key={i}
                                  className={`flex-1 h-6 rounded-lg ${!isPurchased && !canAfford ? "opacity-40" : ""}`}
                                  style={{ backgroundColor: color }}
                                ></div>
                              ))}
                            </div>
                          )}

                          {/* Purchase Button */}
                          {!isPurchased ? (
                            <button
                              onClick={() => handlePurchase(reward)}
                              disabled={!canAfford}
                              className={`w-full py-2 px-4 rounded-xl transition-all text-sm font-medium flex items-center justify-center gap-2 ${canAfford
                                  ? isDark
                                    ? "bg-gradient-to-r from-indigo-700 to-emerald-700 hover:from-indigo-600 hover:to-emerald-600 text-white"
                                    : "bg-gradient-to-r from-indigo-600 to-emerald-500 hover:from-indigo-700 hover:to-emerald-600 text-white"
                                  : isDark
                                    ? "bg-gray-700 text-gray-500 cursor-not-allowed"
                                    : "bg-gray-200 text-gray-400 cursor-not-allowed"
                                }`}
                            >
                              <Star className="w-4 h-4" />
                              {canAfford ? `Canjear por ${reward.cost} pts` : (
                                <>
                                  <Lock className="w-3 h-3" />
                                  {reward.cost} pts
                                </>
                              )}
                            </button>
                          ) : (
                            <div className={`w-full py-2 px-4 rounded-xl text-sm font-medium flex items-center justify-center gap-2 ${isDark ? "bg-green-900/50 text-green-400" : "bg-green-100 text-green-700"}`}>
                              <Sparkles className="w-4 h-4" />
                              Desbloqueado
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Footer */}
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} border-t px-6 py-4`}>
          <p className={`text-xs text-center ${isDark ? "text-gray-500" : "text-gray-500"}`}>
            ¡Gana más puntos completando logros! 🎯
          </p>
        </div>
      </div>
    </div>
  );
}
