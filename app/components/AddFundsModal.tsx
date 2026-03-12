import { X, Plus, DollarSign } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface AddFundsModalProps {
  onClose: () => void;
  goal: {
    id: number;
    name: string;
    icon: string;
    current: number;
    goal: number;
    color: string;
  };
  onAddFunds: (goalId: number, amount: number) => void;
}

export function AddFundsModal({ onClose, goal, onAddFunds }: AddFundsModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [amount, setAmount] = useState("");
  const [selectedQuickAmount, setSelectedQuickAmount] = useState<number | null>(null);

  const remaining = goal.goal - goal.current;
  const quickAmounts = [100, 250, 500, 1000];

  const handleQuickAmount = (value: number) => {
    setSelectedQuickAmount(value);
    setAmount(value.toString());
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const amountNumber = parseFloat(amount);
    if (amountNumber > 0) {
      onAddFunds(goal.id, amountNumber);
      onClose();
    }
  };

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

        <h2 className={`text-2xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
          Agregar Fondos 💰
        </h2>
        <p className={`text-sm mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
          {goal.name}
        </p>

        {/* Goal Progress Card */}
        <div className={`bg-gradient-to-r ${goal.color} rounded-2xl p-5 mb-6 text-white`}>
          <div className="flex items-center gap-3 mb-3">
            <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm text-2xl">
              {goal.icon}
            </div>
            <div className="flex-1">
              <p className="text-sm opacity-90">Progreso actual</p>
              <p className="text-xl font-medium">
                ${goal.current.toLocaleString()} / ${goal.goal.toLocaleString()}
              </p>
            </div>
          </div>
          <div className="bg-white/20 rounded-full h-2 overflow-hidden backdrop-blur-sm">
            <div
              className="bg-white h-full transition-all"
              style={{ width: `${(goal.current / goal.goal) * 100}%` }}
            ></div>
          </div>
          <p className="text-xs opacity-90 mt-2">Te faltan ${remaining.toLocaleString()} para tu meta</p>
        </div>

        <form onSubmit={handleSubmit}>
          {/* Quick Amount Buttons */}
          <div className="mb-4">
            <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Cantidades rápidas
            </label>
            <div className="grid grid-cols-4 gap-2">
              {quickAmounts.map((value) => (
                <button
                  key={value}
                  type="button"
                  onClick={() => handleQuickAmount(value)}
                  className={`py-3 rounded-xl text-sm transition-all ${
                    selectedQuickAmount === value
                      ? isDark
                        ? "bg-purple-900/50 border-2 border-purple-600 text-white"
                        : "bg-purple-100 border-2 border-purple-500 text-purple-700"
                      : isDark
                      ? "bg-gray-700 border-2 border-gray-600 text-gray-300 hover:border-gray-500"
                      : "bg-gray-100 border-2 border-gray-200 text-gray-700 hover:border-gray-300"
                  }`}
                >
                  ${value}
                </button>
              ))}
            </div>
          </div>

          {/* Custom Amount Input */}
          <div className="mb-6">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Monto personalizado
            </label>
            <div className="relative">
              <DollarSign className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                value={amount}
                onChange={(e) => {
                  setAmount(e.target.value);
                  setSelectedQuickAmount(null);
                }}
                placeholder="0.00"
                step="0.01"
                min="0"
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
              />
            </div>
          </div>

          {/* Info Box */}
          <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} rounded-xl p-3 mb-6 border`}>
            <p className={`text-xs ${isDark ? "text-blue-300" : "text-blue-700"}`}>
              💡 Los fondos se agregarán inmediatamente a tu meta de ahorro
            </p>
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <button
              type="button"
              onClick={onClose}
              className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className={`flex-1 ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all flex items-center justify-center gap-2`}
            >
              <Plus className="w-5 h-5" />
              Agregar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
