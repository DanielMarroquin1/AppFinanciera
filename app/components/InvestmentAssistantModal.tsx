import { X, TrendingUp, DollarSign, Target, AlertCircle, Crown, Send, Sparkles } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface InvestmentAssistantModalProps {
  onClose: () => void;
  isPremium: boolean;
}

export function InvestmentAssistantModal({ onClose, isPremium }: InvestmentAssistantModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [step, setStep] = useState(1);
  const [businessType, setBusinessType] = useState("");
  const [monthlyIncome, setMonthlyIncome] = useState("");
  const [investmentAmount, setInvestmentAmount] = useState("");
  const [riskTolerance, setRiskTolerance] = useState<"low" | "medium" | "high">("medium");

  const businessTypes = [
    { value: "retail", label: "Comercio minorista", emoji: "🛒" },
    { value: "restaurant", label: "Restaurante/Cafetería", emoji: "🍽️" },
    { value: "services", label: "Servicios profesionales", emoji: "💼" },
    { value: "tech", label: "Tecnología/Software", emoji: "💻" },
    { value: "manufacturing", label: "Manufactura", emoji: "🏭" },
    { value: "freelance", label: "Freelance/Autónomo", emoji: "✏️" },
    { value: "ecommerce", label: "E-commerce", emoji: "📦" },
    { value: "other", label: "Otro", emoji: "🎯" },
  ];

  const riskOptions = [
    { value: "low" as const, label: "Bajo", description: "Prefiero inversiones seguras", emoji: "🛡️" },
    { value: "medium" as const, label: "Medio", description: "Balance entre riesgo y ganancia", emoji: "⚖️" },
    { value: "high" as const, label: "Alto", description: "Busco mayores ganancias", emoji: "🚀" },
  ];

  const getRecommendations = () => {
    const recommendations = [];
    
    if (businessType === "retail" || businessType === "restaurant") {
      recommendations.push({
        title: "Mejorar inventario",
        description: "Invierte en productos con alta rotación o equipo que mejore la eficiencia",
        roi: "15-25% anual",
        icon: "📈",
      });
    }
    
    if (businessType === "tech" || businessType === "ecommerce") {
      recommendations.push({
        title: "Marketing digital",
        description: "Campañas en redes sociales y Google Ads para aumentar ventas",
        roi: "20-40% anual",
        icon: "📱",
      });
    }

    recommendations.push({
      title: "Capacitación del equipo",
      description: "Cursos y formación que aumenten la productividad",
      roi: "10-20% anual",
      icon: "📚",
    });

    recommendations.push({
      title: "Mejora de procesos",
      description: "Automatización y herramientas que ahorren tiempo",
      roi: "15-30% anual",
      icon: "⚙️",
    });

    if (riskTolerance === "medium" || riskTolerance === "high") {
      recommendations.push({
        title: "Expansión del negocio",
        description: "Abre nuevos puntos de venta o amplía tu mercado",
        roi: "25-50% anual",
        icon: "🎯",
      });
    }

    if (riskTolerance === "low" || riskTolerance === "medium") {
      recommendations.push({
        title: "Fondo de emergencia",
        description: "Ahorro líquido para imprevistos del negocio",
        roi: "5-8% anual",
        icon: "💰",
      });
    }

    return recommendations;
  };

  if (!isPremium) {
    return (
      <div className="fixed inset-0 z-50 flex items-end justify-center">
        {/* Overlay */}
        <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

        {/* Modal */}
        <div
          className={`relative w-full max-w-md ${
            isDark ? "bg-gray-900" : "bg-white"
          } rounded-t-3xl shadow-2xl transition-all duration-300 p-8`}
        >
          {/* Premium Required */}
          <div className="text-center">
            <div className="w-20 h-20 bg-gradient-to-br from-amber-400 to-orange-500 rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-lg">
              <Crown className="w-10 h-10 text-white" />
            </div>
            <h2 className={`text-2xl mb-3 ${isDark ? "text-white" : "text-gray-900"}`}>
              Función Premium
            </h2>
            <p className={`mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              El Asistente de Inversión es exclusivo para usuarios Premium. Obtén recomendaciones personalizadas para hacer crecer tu negocio.
            </p>
            <button
              className={`w-full ${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700 hover:from-amber-500 hover:to-orange-600" : "bg-gradient-to-r from-amber-400 to-orange-500 hover:from-amber-500 hover:to-orange-600"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl font-medium mb-3`}
            >
              Actualizar a Premium
            </button>
            <button
              onClick={onClose}
              className={`w-full ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-600 hover:text-gray-700"} py-3 transition-colors`}
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-900" : "bg-white"
        } rounded-t-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-green-700 to-emerald-700" : "bg-gradient-to-r from-green-600 to-emerald-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <TrendingUp className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl">Asistente de Inversión</h2>
                <div className="flex items-center gap-1 text-xs text-white/90">
                  <Crown className="w-3 h-3" />
                  <span>Premium</span>
                </div>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
          <p className="text-sm text-white/90">
            {step === 1 && "Cuéntanos sobre tu negocio"}
            {step === 2 && "Información financiera"}
            {step === 3 && "Recomendaciones personalizadas"}
          </p>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 180px)" }}>
          {/* Step 1: Business Type */}
          {step === 1 && (
            <div>
              <h3 className={`text-lg mb-4 ${isDark ? "text-white" : "text-gray-900"}`}>
                ¿Cuál es tu giro de negocio?
              </h3>
              <div className="space-y-2">
                {businessTypes.map((type) => (
                  <label
                    key={type.value}
                    className={`flex items-center gap-3 p-4 rounded-xl cursor-pointer transition-all ${
                      businessType === type.value
                        ? isDark
                          ? "bg-green-900/50 border-2 border-green-600"
                          : "bg-green-100 border-2 border-green-500"
                        : isDark
                        ? "bg-gray-800 border-2 border-gray-700 hover:bg-gray-750"
                        : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="business"
                      value={type.value}
                      checked={businessType === type.value}
                      onChange={(e) => setBusinessType(e.target.value)}
                      className="sr-only"
                    />
                    <span className="text-2xl">{type.emoji}</span>
                    <span className={`flex-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      {type.label}
                    </span>
                  </label>
                ))}
              </div>
            </div>
          )}

          {/* Step 2: Financial Info */}
          {step === 2 && (
            <div className="space-y-6">
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Ingreso mensual promedio
                </label>
                <div className="relative">
                  <DollarSign className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <input
                    type="number"
                    value={monthlyIncome}
                    onChange={(e) => setMonthlyIncome(e.target.value)}
                    placeholder="10000"
                    className={`w-full ${isDark ? "bg-gray-800 border-gray-700 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-green-500 transition-all`}
                  />
                </div>
              </div>

              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  ¿Cuánto quieres invertir?
                </label>
                <div className="relative">
                  <Target className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <input
                    type="number"
                    value={investmentAmount}
                    onChange={(e) => setInvestmentAmount(e.target.value)}
                    placeholder="5000"
                    className={`w-full ${isDark ? "bg-gray-800 border-gray-700 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-green-500 transition-all`}
                  />
                </div>
              </div>

              <div>
                <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Tolerancia al riesgo
                </label>
                <div className="space-y-2">
                  {riskOptions.map((option) => (
                    <label
                      key={option.value}
                      className={`flex items-start gap-3 p-4 rounded-xl cursor-pointer transition-all ${
                        riskTolerance === option.value
                          ? isDark
                            ? "bg-green-900/50 border-2 border-green-600"
                            : "bg-green-100 border-2 border-green-500"
                          : isDark
                          ? "bg-gray-800 border-2 border-gray-700 hover:bg-gray-750"
                          : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                      }`}
                    >
                      <input
                        type="radio"
                        name="risk"
                        value={option.value}
                        checked={riskTolerance === option.value}
                        onChange={(e) => setRiskTolerance(e.target.value as "low" | "medium" | "high")}
                        className="sr-only"
                      />
                      <span className="text-2xl">{option.emoji}</span>
                      <div className="flex-1">
                        <p className={`font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
                          {option.label}
                        </p>
                        <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                          {option.description}
                        </p>
                      </div>
                    </label>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Step 3: Recommendations */}
          {step === 3 && (
            <div>
              <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} border-2 rounded-2xl p-4 mb-6 flex items-start gap-3`}>
                <Sparkles className={`w-5 h-5 ${isDark ? "text-blue-400" : "text-blue-600"} flex-shrink-0 mt-0.5`} />
                <div>
                  <p className={`text-sm ${isDark ? "text-blue-300" : "text-blue-900"}`}>
                    <strong>Recomendaciones personalizadas</strong> basadas en tu giro de negocio y perfil de inversión.
                  </p>
                </div>
              </div>

              <div className="space-y-3">
                {getRecommendations().map((rec, index) => (
                  <div
                    key={index}
                    className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"} border-2 rounded-2xl p-4`}
                  >
                    <div className="flex items-start gap-3">
                      <div className={`w-12 h-12 ${isDark ? "bg-green-900/50" : "bg-green-100"} rounded-xl flex items-center justify-center text-2xl flex-shrink-0`}>
                        {rec.icon}
                      </div>
                      <div className="flex-1">
                        <h4 className={`font-semibold mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                          {rec.title}
                        </h4>
                        <p className={`text-sm mb-2 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                          {rec.description}
                        </p>
                        <div className={`inline-flex items-center gap-1 text-xs px-2 py-1 rounded-full ${isDark ? "bg-green-900/50 text-green-400" : "bg-green-100 text-green-700"}`}>
                          <TrendingUp className="w-3 h-3" />
                          ROI esperado: {rec.roi}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className={`${isDark ? "bg-amber-900/30 border-amber-800" : "bg-amber-50 border-amber-200"} border-2 rounded-2xl p-4 mt-6`}>
                <div className="flex items-start gap-3">
                  <AlertCircle className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"} flex-shrink-0 mt-0.5`} />
                  <p className={`text-xs ${isDark ? "text-amber-300" : "text-amber-900"}`}>
                    <strong>Nota:</strong> Estas son recomendaciones generales. Consulta con un asesor financiero antes de tomar decisiones importantes de inversión.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} border-t px-6 py-4`}>
          <div className="flex gap-3">
            {step > 1 && (
              <button
                onClick={() => setStep(step - 1)}
                className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-650 text-white" : "bg-white hover:bg-gray-50 text-gray-900 border-2 border-gray-200"} py-3 rounded-xl transition-all font-medium`}
              >
                Atrás
              </button>
            )}
            {step < 3 ? (
              <button
                onClick={() => setStep(step + 1)}
                disabled={step === 1 && !businessType || step === 2 && (!monthlyIncome || !investmentAmount)}
                className={`flex-1 ${isDark ? "bg-gradient-to-r from-green-700 to-emerald-700 hover:from-green-600 hover:to-emerald-600 disabled:from-gray-700 disabled:to-gray-700" : "bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 disabled:from-gray-300 disabled:to-gray-300"} text-white py-3 rounded-xl transition-all font-medium disabled:cursor-not-allowed flex items-center justify-center gap-2`}
              >
                Continuar
                <Send className="w-4 h-4" />
              </button>
            ) : (
              <button
                onClick={onClose}
                className={`flex-1 ${isDark ? "bg-gradient-to-r from-green-700 to-emerald-700 hover:from-green-600 hover:to-emerald-600" : "bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700"} text-white py-3 rounded-xl transition-all font-medium`}
              >
                Finalizar
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
