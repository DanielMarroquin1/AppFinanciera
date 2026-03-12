import { ArrowLeft, Calendar, TrendingDown } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface CategoryExpenseDetailProps {
  category: {
    category: string;
    amount: number;
    percentage: number;
    color: string;
  };
  onBack: () => void;
}

const mockExpensesByCategory: Record<string, Array<{ id: number; name: string; date: string; amount: number; icon: string }>> = {
  "🍔 Comida": [
    { id: 1, name: "Walmart - Despensa", date: "23 Feb", amount: 120.50, icon: "🛒" },
    { id: 2, name: "Oxxo - Snacks", date: "22 Feb", amount: 35.00, icon: "🏪" },
    { id: 3, name: "Restaurante La Parilla", date: "21 Feb", amount: 180.00, icon: "🍽️" },
    { id: 4, name: "Starbucks", date: "20 Feb", amount: 65.00, icon: "☕" },
    { id: 5, name: "Pizza Hut", date: "19 Feb", amount: 250.00, icon: "🍕" },
  ],
  "🚗 Transporte": [
    { id: 1, name: "Uber - Centro", date: "23 Feb", amount: 45.00, icon: "🚕" },
    { id: 2, name: "Gasolina Pemex", date: "22 Feb", amount: 500.00, icon: "⛽" },
    { id: 3, name: "Uber - Aeropuerto", date: "20 Feb", amount: 180.00, icon: "🚕" },
    { id: 4, name: "Estacionamiento", date: "19 Feb", amount: 55.00, icon: "🅿️" },
  ],
  "🏠 Hogar": [
    { id: 1, name: "Renta - Febrero", date: "1 Feb", amount: 8000.00, icon: "🏡" },
    { id: 2, name: "Luz (CFE)", date: "5 Feb", amount: 320.00, icon: "⚡" },
    { id: 3, name: "Internet Telmex", date: "10 Feb", amount: 450.00, icon: "📶" },
    { id: 4, name: "Gas LP", date: "15 Feb", amount: 250.00, icon: "🔥" },
  ],
  "🎮 Entretenimiento": [
    { id: 1, name: "Netflix", date: "1 Feb", amount: 139.00, icon: "🎬" },
    { id: 2, name: "Spotify Premium", date: "1 Feb", amount: 115.00, icon: "🎵" },
    { id: 3, name: "Cine - Cinépolis", date: "18 Feb", amount: 220.00, icon: "🎥" },
    { id: 4, name: "PlayStation Plus", date: "12 Feb", amount: 180.00, icon: "🎮" },
  ],
  "💊 Salud": [
    { id: 1, name: "Farmacia Guadalajara", date: "20 Feb", amount: 235.00, icon: "💊" },
    { id: 2, name: "Consulta Médica", date: "18 Feb", amount: 450.00, icon: "👨‍⚕️" },
    { id: 3, name: "Vitaminas", date: "10 Feb", amount: 180.00, icon: "💊" },
  ],
};

export function CategoryExpenseDetail({ category, onBack }: CategoryExpenseDetailProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const expenses = mockExpensesByCategory[category.category] || [];

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={onBack}
          className={`flex items-center gap-2 mb-4 ${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"} transition-colors`}
        >
          <ArrowLeft className="w-5 h-5" />
          <span className="text-sm">Volver</span>
        </button>
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>{category.category}</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Febrero 2026</p>
      </div>

      {/* Category Summary Card */}
      <div className={`${category.color} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <div className="flex items-center gap-2 mb-2">
          <TrendingDown className="w-5 h-5" />
          <p className="text-sm opacity-90">Total Gastado</p>
        </div>
        <h2 className="text-4xl mb-4">${category.amount.toFixed(2)}</h2>
        <div className="flex items-center justify-between">
          <div className={`${isDark ? "bg-white/20" : "bg-white/20"} rounded-full h-2 flex-1 overflow-hidden backdrop-blur-sm`}>
            <div
              className="bg-white h-full transition-all"
              style={{ width: `${category.percentage}%` }}
            ></div>
          </div>
          <span className="text-sm opacity-90 ml-3">{category.percentage}% del total</span>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 border shadow-sm`}>
          <p className={`text-xs mb-1 ${isDark ? "text-gray-400" : "text-gray-500"}`}>Transacciones</p>
          <p className={`text-2xl ${isDark ? "text-white" : ""}`}>{expenses.length}</p>
        </div>
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 border shadow-sm`}>
          <p className={`text-xs mb-1 ${isDark ? "text-gray-400" : "text-gray-500"}`}>Promedio</p>
          <p className={`text-2xl ${isDark ? "text-white" : ""}`}>${(category.amount / expenses.length).toFixed(2)}</p>
        </div>
      </div>

      {/* Expense List */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>
          Todos los Gastos ({expenses.length})
        </h3>
        <div className="space-y-2">
          {expenses.map((expense) => (
            <div
              key={expense.id}
              className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 flex items-center gap-4 border shadow-sm`}
            >
              <div className={`w-12 h-12 ${isDark ? "bg-gray-700" : "bg-gray-50"} rounded-xl flex items-center justify-center`}>
                <span className="text-2xl">{expense.icon}</span>
              </div>
              <div className="flex-1">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>{expense.name}</p>
                <div className="flex items-center gap-2">
                  <Calendar className={`w-3 h-3 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{expense.date}</p>
                </div>
              </div>
              <p className={`${isDark ? "text-red-400" : "text-red-600"} font-medium`}>
                -${expense.amount.toFixed(2)}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
