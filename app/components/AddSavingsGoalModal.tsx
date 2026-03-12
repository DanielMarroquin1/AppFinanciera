import { X, Target, DollarSign, Calendar, Tag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface AddSavingsGoalModalProps {
  onClose: () => void;
}

export function AddSavingsGoalModal({ onClose }: AddSavingsGoalModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [goalName, setGoalName] = useState("");
  const [targetAmount, setTargetAmount] = useState("");
  const [deadline, setDeadline] = useState("");
  const [category, setCategory] = useState("");
  const [currentAmount, setCurrentAmount] = useState("");

  const categories = [
    { value: "vacation", label: "Vacaciones", emoji: "🏖️" },
    { value: "emergency", label: "Fondo de Emergencia", emoji: "🆘" },
    { value: "car", label: "Coche", emoji: "🚗" },
    { value: "house", label: "Casa", emoji: "🏠" },
    { value: "education", label: "Educación", emoji: "🎓" },
    { value: "gadget", label: "Electrónico", emoji: "📱" },
    { value: "investment", label: "Inversión", emoji: "📈" },
    { value: "wedding", label: "Boda", emoji: "💍" },
    { value: "travel", label: "Viaje", emoji: "✈️" },
    { value: "other", label: "Otro", emoji: "🎯" },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Aquí se guardaría la meta
    console.log({ goalName, targetAmount, deadline, category, currentAmount });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-800" : "bg-white"
        } rounded-t-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-blue-700 to-cyan-700" : "bg-gradient-to-r from-blue-600 to-cyan-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Target className="w-6 h-6" />
              </div>
              <h2 className="text-2xl">Nueva Meta de Ahorro</h2>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
          <p className="text-sm text-white/90">Define tu objetivo y comienza a ahorrar</p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 120px)" }}>
          {/* Goal Name */}
          <div className="mb-5">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Nombre de la Meta 🎯
            </label>
            <div className="relative">
              <Tag className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="text"
                value={goalName}
                onChange={(e) => setGoalName(e.target.value)}
                placeholder="Ej: Vacaciones en la playa"
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3.5 pl-12 pr-4 rounded-xl focus:outline-none focus:border-blue-500 transition-all`}
              />
            </div>
          </div>

          {/* Category */}
          <div className="mb-5">
            <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Categoría 🏷️
            </label>
            <div className="grid grid-cols-2 gap-2">
              {categories.map((cat) => (
                <label
                  key={cat.value}
                  className={`flex items-center gap-2 p-3 rounded-xl cursor-pointer transition-all ${
                    category === cat.value
                      ? isDark
                        ? "bg-blue-900/50 border-2 border-blue-600"
                        : "bg-blue-100 border-2 border-blue-500"
                      : isDark
                      ? "bg-gray-700 border-2 border-gray-600 hover:bg-gray-650"
                      : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                  }`}
                >
                  <input
                    type="radio"
                    name="category"
                    value={cat.value}
                    checked={category === cat.value}
                    onChange={(e) => setCategory(e.target.value)}
                    className="sr-only"
                    required
                  />
                  <span className="text-xl">{cat.emoji}</span>
                  <span className={`flex-1 text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                    {cat.label}
                  </span>
                  {category === cat.value && (
                    <div className="w-5 h-5 bg-blue-600 rounded-full flex items-center justify-center">
                      <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  )}
                </label>
              ))}
            </div>
          </div>

          {/* Target Amount */}
          <div className="mb-5">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Meta a Alcanzar 💰
            </label>
            <div className="relative">
              <DollarSign className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                step="0.01"
                value={targetAmount}
                onChange={(e) => setTargetAmount(e.target.value)}
                placeholder="0.00"
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-4 pl-12 pr-4 rounded-xl focus:outline-none focus:border-blue-500 transition-all text-2xl font-semibold`}
              />
            </div>
          </div>

          {/* Current Amount (Optional) */}
          <div className="mb-5">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Cantidad Inicial (Opcional) 💵
            </label>
            <div className="relative">
              <DollarSign className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                step="0.01"
                value={currentAmount}
                onChange={(e) => setCurrentAmount(e.target.value)}
                placeholder="0.00"
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3.5 pl-12 pr-4 rounded-xl focus:outline-none focus:border-blue-500 transition-all`}
              />
            </div>
          </div>

          {/* Deadline */}
          <div className="mb-6">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Fecha Límite 📅
            </label>
            <div className="relative">
              <Calendar className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="date"
                value={deadline}
                onChange={(e) => setDeadline(e.target.value)}
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3.5 pl-12 pr-4 rounded-xl focus:outline-none focus:border-blue-500 transition-all`}
              />
            </div>
          </div>

          {/* Preview */}
          {targetAmount && (
            <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} border-2 rounded-2xl p-4 mb-6`}>
              <p className={`text-xs mb-2 ${isDark ? "text-blue-300" : "text-blue-700"}`}>
                Vista Previa
              </p>
              <div className="flex items-center justify-between mb-2">
                <span className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                  {goalName || "Tu meta"}
                </span>
                <span className={`text-sm font-bold ${isDark ? "text-blue-400" : "text-blue-600"}`}>
                  {currentAmount ? `${Math.round((parseFloat(currentAmount) / parseFloat(targetAmount)) * 100)}%` : "0%"}
                </span>
              </div>
              <div className={`${isDark ? "bg-gray-700" : "bg-gray-200"} rounded-full h-2 overflow-hidden`}>
                <div
                  className="bg-gradient-to-r from-blue-500 to-cyan-500 h-full transition-all"
                  style={{
                    width: currentAmount && targetAmount
                      ? `${Math.min((parseFloat(currentAmount) / parseFloat(targetAmount)) * 100, 100)}%`
                      : "0%",
                  }}
                ></div>
              </div>
              <div className="flex items-center justify-between mt-2">
                <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  ${currentAmount || "0"} ahorrado
                </span>
                <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Meta: ${targetAmount}
                </span>
              </div>
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            className={`w-full ${isDark ? "bg-gradient-to-r from-blue-700 to-cyan-700 hover:from-blue-600 hover:to-cyan-600" : "bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl font-medium`}
          >
            Crear Meta de Ahorro
          </button>
        </form>
      </div>
    </div>
  );
}