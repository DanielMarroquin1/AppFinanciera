import { X, Crown, Check, Sparkles, Palette, Cloud, BarChart3, Zap } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface PremiumModalProps {
  onClose: () => void;
  onUpgrade: (plan: "monthly" | "annual") => void;
}

export function PremiumModal({ onClose, onUpgrade }: PremiumModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedPlan, setSelectedPlan] = useState<"monthly" | "annual">("annual");

  const features = [
    { icon: Palette, text: "Paletas de colores personalizadas", color: "purple" },
    { icon: Cloud, text: "Sincronización en la nube", color: "blue" },
    { icon: BarChart3, text: "Reportes avanzados y exportación", color: "green" },
    { icon: Sparkles, text: "Consulta ilimitada con IA financiera", color: "pink" },
    { icon: Zap, text: "Sin anuncios", color: "yellow" },
    { icon: Crown, text: "Insignia Premium", color: "amber" },
  ];

  const handleUpgrade = () => {
    onUpgrade(selectedPlan);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-800" : "bg-white"
        } rounded-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh", overflowY: "auto" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} px-6 py-6 rounded-t-3xl relative overflow-hidden`}>
          {/* Decorative elements */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          
          <button onClick={onClose} className="absolute top-4 right-4 hover:bg-white/20 rounded-full p-1 transition-colors text-white">
            <X className="w-6 h-6" />
          </button>

          <div className="relative">
            <div className="w-16 h-16 bg-white/20 rounded-2xl flex items-center justify-center mx-auto mb-4 backdrop-blur-sm">
              <Crown className="w-10 h-10 text-white" />
            </div>
            <h2 className="text-3xl text-center text-white mb-2">Hazte Premium</h2>
            <p className="text-center text-white/90 text-sm">
              Desbloquea todo el potencial de tu app financiera
            </p>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Plan Selection */}
          <div className="mb-6">
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setSelectedPlan("monthly")}
                className={`p-4 rounded-2xl border-2 transition-all ${
                  selectedPlan === "monthly"
                    ? isDark
                      ? "bg-amber-900/50 border-amber-600"
                      : "bg-amber-100 border-amber-500"
                    : isDark
                    ? "bg-gray-700 border-gray-600 hover:bg-gray-650"
                    : "bg-white border-gray-200 hover:bg-gray-50"
                }`}
              >
                <div className={`text-sm mb-1 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Mensual
                </div>
                <div className={`text-2xl font-bold ${selectedPlan === "monthly" ? (isDark ? "text-amber-400" : "text-amber-600") : (isDark ? "text-white" : "text-gray-900")}`}>
                  $9.99
                </div>
                <div className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>
                  por mes
                </div>
              </button>

              <button
                onClick={() => setSelectedPlan("annual")}
                className={`p-4 rounded-2xl border-2 transition-all relative ${
                  selectedPlan === "annual"
                    ? isDark
                      ? "bg-amber-900/50 border-amber-600"
                      : "bg-amber-100 border-amber-500"
                    : isDark
                    ? "bg-gray-700 border-gray-600 hover:bg-gray-650"
                    : "bg-white border-gray-200 hover:bg-gray-50"
                }`}
              >
                <div className="absolute -top-2 right-2 bg-green-500 text-white text-xs px-2 py-0.5 rounded-full">
                  Ahorra 40%
                </div>
                <div className={`text-sm mb-1 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Anual
                </div>
                <div className={`text-2xl font-bold ${selectedPlan === "annual" ? (isDark ? "text-amber-400" : "text-amber-600") : (isDark ? "text-white" : "text-gray-900")}`}>
                  $5.99
                </div>
                <div className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>
                  por mes
                </div>
              </button>
            </div>
          </div>

          {/* Features */}
          <div className="mb-6">
            <h3 className={`text-sm mb-4 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Incluye todo de Premium:
            </h3>
            <div className="space-y-3">
              {features.map((feature, index) => {
                const Icon = feature.icon;
                return (
                  <div key={index} className="flex items-center gap-3">
                    <div className={`w-10 h-10 ${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-xl flex items-center justify-center flex-shrink-0`}>
                      <Icon className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"}`} />
                    </div>
                    <p className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                      {feature.text}
                    </p>
                    <Check className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"} ml-auto flex-shrink-0`} />
                  </div>
                );
              })}
            </div>
          </div>

          {/* Price Summary */}
          <div className={`${isDark ? "bg-gray-700" : "bg-gray-50"} rounded-2xl p-4 mb-6`}>
            <div className="flex items-center justify-between mb-2">
              <span className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                {selectedPlan === "monthly" ? "Facturación mensual" : "Facturación anual"}
              </span>
              <span className={`text-lg font-bold ${isDark ? "text-white" : "text-gray-900"}`}>
                {selectedPlan === "monthly" ? "$9.99/mes" : "$71.88/año"}
              </span>
            </div>
            {selectedPlan === "annual" && (
              <p className={`text-xs ${isDark ? "text-green-400" : "text-green-600"}`}>
                ✓ Ahorras $47.88 al año
              </p>
            )}
          </div>

          {/* CTA Button */}
          <button
            onClick={handleUpgrade}
            className={`w-full ${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700 hover:from-amber-500 hover:to-orange-600" : "bg-gradient-to-r from-amber-400 to-orange-500 hover:from-amber-500 hover:to-orange-600"} text-white py-4 rounded-2xl transition-all shadow-lg hover:shadow-xl font-medium flex items-center justify-center gap-2`}
          >
            <Crown className="w-5 h-5" />
            Actualizar a Premium
          </button>

          {/* Footer */}
          <p className={`text-xs text-center mt-4 ${isDark ? "text-gray-500" : "text-gray-500"}`}>
            Cancela cuando quieras. Sin compromisos.
          </p>
        </div>
      </div>
    </div>
  );
}