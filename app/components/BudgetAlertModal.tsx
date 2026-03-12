import { X, Bell, Percent, Save } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface BudgetAlertModalProps {
  onClose: () => void;
}

export function BudgetAlertModal({ onClose }: BudgetAlertModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [alertPercentage, setAlertPercentage] = useState("80");
  const [enableAlerts, setEnableAlerts] = useState(true);

  const monthlyBudget = 15000; // Ejemplo de presupuesto mensual

  const handleSave = () => {
    toast.success("Alertas configuradas", {
      description: `Recibirás una notificación al llegar al ${alertPercentage}% de tu presupuesto`,
    });
    onClose();
  };

  const alertAmount = (monthlyBudget * parseFloat(alertPercentage)) / 100;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-amber-700 to-yellow-700" : "bg-gradient-to-r from-amber-600 to-yellow-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Bell className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl mb-1">Alertas de Presupuesto</h2>
                <p className="text-sm opacity-90">Controla tus gastos</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Toggle Alerts */}
          <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4 mb-6`}>
            <div className="flex items-center justify-between">
              <div>
                <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                  Activar Alertas
                </p>
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Recibe notificaciones cuando te acerques al límite
                </p>
              </div>
              <button
                onClick={() => setEnableAlerts(!enableAlerts)}
                className={`w-12 h-6 rounded-full relative transition-all ${enableAlerts ? isDark ? "bg-amber-600" : "bg-amber-500" : isDark ? "bg-gray-600" : "bg-gray-300"}`}
              >
                <div
                  className={`w-5 h-5 bg-white rounded-full absolute top-0.5 shadow-sm transition-all ${enableAlerts ? "left-6" : "left-0.5"}`}
                ></div>
              </button>
            </div>
          </div>

          {/* Budget Info */}
          <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} border-2 rounded-2xl p-4 mb-6`}>
            <p className={`text-xs mb-1 ${isDark ? "text-blue-300" : "text-blue-700"}`}>
              Presupuesto Mensual
            </p>
            <p className={`text-2xl font-bold ${isDark ? "text-blue-400" : "text-blue-600"}`}>
              ${monthlyBudget.toFixed(2)}
            </p>
          </div>

          {/* Percentage Selector */}
          <div className="mb-6">
            <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Porcentaje de Alerta
            </label>
            
            {/* Percentage Input */}
            <div className="relative mb-4">
              <Percent className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                min="50"
                max="100"
                step="5"
                value={alertPercentage}
                onChange={(e) => setAlertPercentage(e.target.value)}
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all text-lg font-bold`}
              />
            </div>

            {/* Visual Slider */}
            <div className="mb-4">
              <input
                type="range"
                min="50"
                max="100"
                step="5"
                value={alertPercentage}
                onChange={(e) => setAlertPercentage(e.target.value)}
                className="w-full h-2 rounded-lg appearance-none cursor-pointer"
                style={{
                  background: isDark 
                    ? `linear-gradient(to right, rgb(245, 158, 11) 0%, rgb(245, 158, 11) ${alertPercentage}%, rgb(75, 85, 99) ${alertPercentage}%, rgb(75, 85, 99) 100%)`
                    : `linear-gradient(to right, rgb(251, 191, 36) 0%, rgb(251, 191, 36) ${alertPercentage}%, rgb(229, 231, 235) ${alertPercentage}%, rgb(229, 231, 235) 100%)`
                }}
              />
              <div className="flex justify-between text-xs mt-2">
                <span className={isDark ? "text-gray-500" : "text-gray-400"}>50%</span>
                <span className={isDark ? "text-gray-500" : "text-gray-400"}>75%</span>
                <span className={isDark ? "text-gray-500" : "text-gray-400"}>100%</span>
              </div>
            </div>

            {/* Alert Preview */}
            <div className={`${isDark ? "bg-amber-900/30 border-amber-800" : "bg-amber-50 border-amber-200"} border-2 rounded-xl p-4`}>
              <div className="flex items-start gap-3">
                <Bell className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"} flex-shrink-0 mt-0.5`} />
                <div>
                  <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                    Vista Previa de Alerta
                  </p>
                  <p className={`text-xs ${isDark ? "text-amber-300" : "text-amber-800"}`}>
                    Recibirás una notificación cuando gastes ${alertAmount.toFixed(2)} ({alertPercentage}% de tu presupuesto mensual)
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Quick Presets */}
          <div className="mb-6">
            <p className={`text-xs mb-3 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Presets Rápidos
            </p>
            <div className="grid grid-cols-4 gap-2">
              {["50", "70", "80", "90"].map((preset) => (
                <button
                  key={preset}
                  onClick={() => setAlertPercentage(preset)}
                  className={`py-2 rounded-lg text-sm transition-all ${
                    alertPercentage === preset
                      ? isDark
                        ? "bg-amber-700 text-white"
                        : "bg-amber-500 text-white"
                      : isDark
                      ? "bg-gray-700 text-gray-300 hover:bg-gray-650"
                      : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  }`}
                >
                  {preset}%
                </button>
              ))}
            </div>
          </div>

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
              className={`flex-1 ${isDark ? "bg-gradient-to-r from-amber-700 to-yellow-700 hover:from-amber-600 hover:to-yellow-600" : "bg-gradient-to-r from-amber-600 to-yellow-600 hover:from-amber-700 hover:to-yellow-700"} text-white py-3 rounded-xl transition-all shadow-lg flex items-center justify-center gap-2`}
            >
              <Save className="w-5 h-5" />
              Guardar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
