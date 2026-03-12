import { X, Bell, DollarSign, Target, TrendingUp } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface NotificationsSettingsModalProps {
  onClose: () => void;
}

export function NotificationsSettingsModal({ onClose }: NotificationsSettingsModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [settings, setSettings] = useState({
    expenseAlerts: true,
    savingsReminders: true,
    budgetWarnings: true,
    achievementNotifications: true,
    weeklyReports: false,
    monthlyReports: true,
  });

  const handleToggle = (key: keyof typeof settings) => {
    setSettings((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const notificationOptions = [
    {
      key: "expenseAlerts" as const,
      icon: DollarSign,
      label: "Alertas de Gastos",
      description: "Notificaciones cuando registres un gasto",
      color: "red",
    },
    {
      key: "savingsReminders" as const,
      icon: Target,
      label: "Recordatorios de Ahorro",
      description: "Recordatorios para cumplir tus metas",
      color: "green",
    },
    {
      key: "budgetWarnings" as const,
      icon: TrendingUp,
      label: "Advertencias de Presupuesto",
      description: "Avisos cuando te acerques al límite",
      color: "orange",
    },
    {
      key: "achievementNotifications" as const,
      icon: Bell,
      label: "Notificaciones de Logros",
      description: "Cuando desbloquees un nuevo logro",
      color: "purple",
    },
    {
      key: "weeklyReports" as const,
      icon: Bell,
      label: "Reportes Semanales",
      description: "Resumen de tu semana financiera",
      color: "blue",
    },
    {
      key: "monthlyReports" as const,
      icon: Bell,
      label: "Reportes Mensuales",
      description: "Resumen mensual de finanzas",
      color: "cyan",
    },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300 max-h-[85vh] overflow-y-auto`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>

        <div className="mb-6">
          <div className="text-4xl mb-3 text-center">🔔</div>
          <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            Notificaciones
          </h2>
          <p className={`text-sm text-center ${isDark ? "text-gray-400" : "text-gray-600"}`}>
            Personaliza tus alertas y recordatorios
          </p>
        </div>

        {/* Notification Options */}
        <div className="space-y-3 mb-6">
          {notificationOptions.map((option) => {
            const Icon = option.icon;
            const isEnabled = settings[option.key];
            return (
              <div
                key={option.key}
                className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4`}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 bg-${option.color}-500 rounded-xl flex items-center justify-center`}>
                      <Icon className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className={`text-sm font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
                        {option.label}
                      </p>
                      <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                        {option.description}
                      </p>
                    </div>
                  </div>
                  <button
                    onClick={() => handleToggle(option.key)}
                    className={`w-12 h-6 rounded-full relative transition-all ${isEnabled ? "bg-purple-600" : isDark ? "bg-gray-600" : "bg-gray-300"}`}
                  >
                    <div
                      className={`w-5 h-5 bg-white rounded-full absolute top-0.5 shadow-sm transition-all ${isEnabled ? "left-6" : "left-0.5"}`}
                    ></div>
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        <button
          onClick={onClose}
          className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
        >
          Guardar Preferencias
        </button>
      </div>
    </div>
  );
}
