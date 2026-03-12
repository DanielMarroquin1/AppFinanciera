import { X, AlertTriangle, Crown, Palette, BarChart3, Cloud, Sparkles } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface CancelSubscriptionModalProps {
  onClose: () => void;
  onConfirm: () => void;
}

export function CancelSubscriptionModal({ onClose, onConfirm }: CancelSubscriptionModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const benefits = [
    { icon: Palette, label: "Paleta de colores personalizada", color: "purple" },
    { icon: BarChart3, label: "Reportes avanzados e insights", color: "blue" },
    { icon: Cloud, label: "Sincronización en la nube", color: "cyan" },
    { icon: Sparkles, label: "Asistente IA ilimitado", color: "pink" },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>

        {/* Warning Icon */}
        <div className={`w-16 h-16 ${isDark ? "bg-amber-900/30" : "bg-amber-100"} rounded-2xl flex items-center justify-center mx-auto mb-4`}>
          <AlertTriangle className={`w-8 h-8 ${isDark ? "text-amber-400" : "text-amber-600"}`} />
        </div>

        <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
          ¿Cancelar Premium?
        </h2>
        <p className={`text-sm text-center mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
          Perderás acceso a estas funciones exclusivas:
        </p>

        {/* Benefits List */}
        <div className="space-y-3 mb-6">
          {benefits.map((benefit, index) => {
            const Icon = benefit.icon;
            return (
              <div
                key={index}
                className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3 flex items-center gap-3`}
              >
                <div className={`w-10 h-10 bg-gradient-to-br from-${benefit.color}-500 to-${benefit.color}-600 rounded-lg flex items-center justify-center`}>
                  <Icon className="w-5 h-5 text-white" />
                </div>
                <span className={`text-sm ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  {benefit.label}
                </span>
              </div>
            );
          })}
        </div>

        {/* Special Offer */}
        <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} rounded-2xl p-4 mb-6 text-white`}>
          <div className="flex items-center gap-2 mb-2">
            <Crown className="w-5 h-5" />
            <h3 className="text-sm font-medium">Oferta Especial</h3>
          </div>
          <p className="text-xs opacity-90">
            ¡Mantén tu suscripción y obtén 2 meses adicionales gratis!
          </p>
        </div>

        {/* Actions */}
        <div className="space-y-3">
          <button
            onClick={onClose}
            className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
          >
            Mantener Premium
          </button>
          <button
            onClick={() => {
              onConfirm();
              onClose();
            }}
            className={`w-full ${isDark ? "bg-gray-700 hover:bg-gray-600 text-gray-300" : "bg-gray-100 hover:bg-gray-200 text-gray-700"} py-3 rounded-xl transition-all`}
          >
            Cancelar de todas formas
          </button>
        </div>

        <p className={`text-xs text-center mt-4 ${isDark ? "text-gray-500" : "text-gray-500"}`}>
          Tu suscripción permanecerá activa hasta el final del periodo
        </p>
      </div>
    </div>
  );
}
