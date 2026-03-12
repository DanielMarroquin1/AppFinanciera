import { X, Target, TrendingUp, PiggyBank, Lightbulb } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface SavingsGuideModalProps {
  onClose: () => void;
}

export function SavingsGuideModal({ onClose }: SavingsGuideModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const tips = [
    {
      icon: Target,
      title: "Define metas claras",
      description: "Establece objetivos específicos y alcanzables para mantener tu motivación.",
      color: "from-blue-500 to-cyan-500",
    },
    {
      icon: TrendingUp,
      title: "Regla 50/30/20",
      description: "Destina el 50% a necesidades, 30% a deseos y 20% a ahorros.",
      color: "from-green-500 to-emerald-500",
    },
    {
      icon: PiggyBank,
      title: "Automatiza tus ahorros",
      description: "Configura transferencias automáticas justo después de recibir tu salario.",
      color: "from-purple-500 to-pink-500",
    },
    {
      icon: Lightbulb,
      title: "Reduce gastos hormiga",
      description: "Identifica pequeños gastos diarios que suman mucho al final del mes.",
      color: "from-orange-500 to-red-500",
    },
  ];

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
          <div className="text-4xl mb-3 text-center">📚</div>
          <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            Guía de Ahorro
          </h2>
          <p className={`text-sm text-center ${isDark ? "text-gray-400" : "text-gray-600"}`}>
            Consejos para alcanzar tus metas financieras más rápido
          </p>
        </div>

        {/* Tips */}
        <div className="space-y-4 mb-6">
          {tips.map((tip, index) => {
            const Icon = tip.icon;
            return (
              <div
                key={index}
                className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4`}
              >
                <div className="flex items-start gap-3">
                  <div className={`w-12 h-12 bg-gradient-to-r ${tip.color} rounded-xl flex items-center justify-center flex-shrink-0`}>
                    <Icon className="w-6 h-6 text-white" />
                  </div>
                  <div className="flex-1">
                    <h3 className={`text-sm font-medium mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      {tip.title}
                    </h3>
                    <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      {tip.description}
                    </p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Challenge */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-900/40 to-blue-900/40 border-purple-800" : "bg-gradient-to-r from-purple-100 to-blue-100 border-purple-200"} rounded-2xl p-4 mb-6 border-2`}>
          <h3 className={`text-sm font-medium mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            🎯 Reto del Mes
          </h3>
          <p className={`text-xs ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Ahorra $50 extra esta semana reduciendo una compra innecesaria. ¡Pequeños pasos hacen grandes diferencias!
          </p>
        </div>

        <button
          onClick={onClose}
          className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
        >
          ¡Entendido!
        </button>
      </div>
    </div>
  );
}
