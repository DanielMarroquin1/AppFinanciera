import { X, Check, Lock, ShoppingBag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface ColorPaletteModalProps {
  onClose: () => void;
  onSave: (palette: ColorPalette) => void;
  currentPalette: ColorPalette;
}

export interface ColorPalette {
  primary: string;
  secondary: string;
  accent: string;
  name: string;
}

interface PaletteOption extends ColorPalette {
  colors: [string, string, string]; // Actual hex for preview
}

const presetPalettes: PaletteOption[] = [
  {
    name: "Índigo Esmeralda",
    primary: "indigo",
    secondary: "emerald",
    accent: "violet",
    colors: ["#6366f1", "#10b981", "#8b5cf6"],
  },
  {
    name: "Paleta Océano",
    primary: "sky",
    secondary: "cyan",
    accent: "blue",
    colors: ["#0ea5e9", "#06b6d4", "#3b82f6"],
  },
  {
    name: "Paleta Atardecer",
    primary: "orange",
    secondary: "rose",
    accent: "amber",
    colors: ["#f97316", "#f43f5e", "#f59e0b"],
  },
  {
    name: "Paleta Bosque",
    primary: "emerald",
    secondary: "lime",
    accent: "green",
    colors: ["#10b981", "#84cc16", "#22c55e"],
  },
  {
    name: "Paleta Lavanda",
    primary: "violet",
    secondary: "purple",
    accent: "fuchsia",
    colors: ["#8b5cf6", "#a855f7", "#d946ef"],
  },
  {
    name: "Paleta Medianoche",
    primary: "slate",
    secondary: "indigo",
    accent: "blue",
    colors: ["#64748b", "#6366f1", "#3b82f6"],
  },
];

export function ColorPaletteModal({ onClose, onSave, currentPalette }: ColorPaletteModalProps) {
  const { theme, unlockedPalettes } = useTheme();
  const isDark = theme === "dark";
  const [selectedPalette, setSelectedPalette] = useState<PaletteOption>(
    presetPalettes.find(p => p.name === currentPalette.name) || presetPalettes[0]
  );

  const handleSave = () => {
    if (!unlockedPalettes.includes(selectedPalette.name)) {
      toast.error("Paleta bloqueada", {
        description: "Canjea esta paleta en la tienda de puntos para usarla",
      });
      return;
    }
    onSave({
      primary: selectedPalette.primary,
      secondary: selectedPalette.secondary,
      accent: selectedPalette.accent,
      name: selectedPalette.name,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300 max-h-[80vh] overflow-y-auto`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>

        <div className="mb-6">
          <h2 className={`text-2xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            Paleta de Colores 🎨
          </h2>
          <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
            Personaliza los colores de tu app
          </p>
        </div>

        {/* Palette Presets */}
        <div className="space-y-3 mb-6">
          {presetPalettes.map((palette) => {
            const isSelected = selectedPalette.name === palette.name;
            const isUnlocked = unlockedPalettes.includes(palette.name);
            return (
              <button
                key={palette.name}
                onClick={() => isUnlocked ? setSelectedPalette(palette) : null}
                className={`w-full p-4 rounded-2xl transition-all relative ${!isUnlocked
                    ? isDark
                      ? "bg-gray-700/50 border-2 border-gray-600 opacity-70 cursor-not-allowed"
                      : "bg-gray-50/50 border-2 border-gray-200 opacity-70 cursor-not-allowed"
                    : isSelected
                      ? isDark
                        ? "bg-indigo-900/50 border-2 border-indigo-600"
                        : "bg-indigo-50 border-2 border-indigo-500"
                      : isDark
                        ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                        : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                  }`}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className={`text-sm font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
                      {palette.name}
                    </span>
                    {!isUnlocked && (
                      <div className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded-full ${isDark ? "bg-gray-600 text-gray-400" : "bg-gray-200 text-gray-500"}`}>
                        <Lock className="w-3 h-3" />
                        Bloqueada
                      </div>
                    )}
                  </div>
                  {isSelected && isUnlocked && (
                    <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isDark ? "bg-indigo-600" : "bg-indigo-500"}`}>
                      <Check className="w-4 h-4 text-white" />
                    </div>
                  )}
                </div>
                <div className="flex gap-2">
                  {palette.colors.map((color, i) => (
                    <div
                      key={i}
                      className={`flex-1 h-8 rounded-lg ${!isUnlocked ? "filter grayscale" : ""}`}
                      style={{ backgroundColor: color }}
                    ></div>
                  ))}
                </div>
                {!isUnlocked && (
                  <p className={`text-xs mt-2 text-center ${isDark ? "text-gray-500" : "text-gray-400"}`}>
                    <ShoppingBag className="w-3 h-3 inline mr-1" />
                    Disponible en la tienda de puntos
                  </p>
                )}
              </button>
            );
          })}
        </div>

        {/* Preview */}
        {unlockedPalettes.includes(selectedPalette.name) && (
          <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-100"} rounded-2xl p-4 mb-6`}>
            <h3 className={`text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>Vista Previa</h3>
            <div
              className="rounded-2xl p-6 text-white"
              style={{
                background: `linear-gradient(135deg, ${selectedPalette.colors[0]}, ${selectedPalette.colors[1]}, ${selectedPalette.colors[2]})`,
              }}
            >
              <h4 className="text-lg mb-2">Tu App de Finanzas</h4>
              <p className="text-sm opacity-90">Así se verán los elementos principales</p>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-3">
          <button
            onClick={onClose}
            className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
          >
            Cancelar
          </button>
          <button
            onClick={handleSave}
            disabled={!unlockedPalettes.includes(selectedPalette.name)}
            className={`flex-1 ${isDark ? "bg-gradient-to-r from-indigo-700 to-emerald-700 hover:from-indigo-600 hover:to-emerald-600 disabled:from-gray-700 disabled:to-gray-700" : "bg-gradient-to-r from-indigo-600 to-emerald-500 hover:from-indigo-700 hover:to-emerald-600 disabled:from-gray-300 disabled:to-gray-300"} text-white py-3 rounded-xl transition-all disabled:cursor-not-allowed`}
          >
            Guardar
          </button>
        </div>
      </div>
    </div>
  );
}
