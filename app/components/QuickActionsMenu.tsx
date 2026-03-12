import { TrendingUp, TrendingDown, Target, Receipt, MessageSquare, X, Crown, ShoppingBag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface QuickActionsMenuProps {
  onClose: () => void;
  onSelectAction: (action: "income" | "expense" | "savings-goal" | "fixed-expense" | "ai-chat" | "rewards-shop") => void;
}

export function QuickActionsMenu({ onClose, onSelectAction }: QuickActionsMenuProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const actions = [
    {
      id: "income" as const,
      label: "Agregar Ingreso",
      icon: TrendingUp,
      color: "green",
      gradient: isDark ? "from-green-700 to-emerald-700" : "from-green-600 to-emerald-600",
      isPremium: false,
    },
    {
      id: "expense" as const,
      label: "Agregar Gasto",
      icon: TrendingDown,
      color: "red",
      gradient: isDark ? "from-red-700 to-pink-700" : "from-red-600 to-pink-600",
      isPremium: false,
    },
    {
      id: "savings-goal" as const,
      label: "Nueva Meta de Ahorro",
      icon: Target,
      color: "blue",
      gradient: isDark ? "from-blue-700 to-cyan-700" : "from-blue-600 to-cyan-600",
      isPremium: false,
    },
    {
      id: "rewards-shop" as const,
      label: "Tienda de Recompensas",
      icon: ShoppingBag,
      color: "amber",
      gradient: isDark ? "from-amber-600 to-orange-700" : "from-amber-400 to-orange-500",
      isPremium: false,
    },
    {
      id: "fixed-expense" as const,
      label: "Gasto Fijo",
      icon: Receipt,
      color: "purple",
      gradient: isDark ? "from-purple-700 to-indigo-700" : "from-purple-600 to-indigo-600",
      isPremium: false,
    },
    {
      id: "ai-chat" as const,
      label: "Consultar IA",
      icon: MessageSquare,
      color: "purple",
      gradient: isDark ? "from-purple-700 to-indigo-700" : "from-purple-600 to-indigo-600",
      isPremium: true,
    },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Menu */}
      <div className={`relative w-[90%] max-w-sm ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300 p-6`}>
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h2 className={`text-2xl ${isDark ? "text-white" : "text-gray-900"}`}>
            Acciones Rápidas
          </h2>
          <button
            onClick={onClose}
            className={`${isDark ? "hover:bg-gray-700" : "hover:bg-gray-100"} rounded-full p-2 transition-colors`}
          >
            <X className={`w-5 h-5 ${isDark ? "text-gray-400" : "text-gray-600"}`} />
          </button>
        </div>

        {/* Actions */}
        <div className="space-y-3">
          {actions.map((action) => {
            const Icon = action.icon;
            return (
              <button
                key={action.id}
                onClick={() => {
                  onSelectAction(action.id);
                  onClose();
                }}
                className={`w-full bg-gradient-to-r ${action.gradient} text-white p-4 rounded-2xl flex items-center gap-4 transition-all hover:shadow-lg hover:scale-105 active:scale-95 relative`}
              >
                <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                  <Icon className="w-6 h-6" />
                </div>
                <span className="text-left font-medium flex-1">{action.label}</span>
                {action.isPremium && (
                  <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
                    <Crown className="w-3 h-3" />
                    PRO
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Footer */}
        <p className={`text-xs text-center mt-6 ${isDark ? "text-gray-500" : "text-gray-500"}`}>
          Selecciona una acción para continuar
        </p>
      </div>
    </div>
  );
}