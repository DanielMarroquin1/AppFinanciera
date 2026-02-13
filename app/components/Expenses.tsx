import { Calendar, Filter, Search } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

const expenses = [
  { category: "🍔 Comida", amount: 450.50, percentage: 35, color: "bg-red-500" },
  { category: "🚗 Transporte", amount: 280.00, percentage: 22, color: "bg-blue-500" },
  { category: "🏠 Hogar", amount: 520.00, percentage: 40, color: "bg-purple-500" },
  { category: "🎮 Entretenimiento", amount: 150.00, percentage: 12, color: "bg-pink-500" },
  { category: "💊 Salud", amount: 95.00, percentage: 7, color: "bg-green-500" },
];

const recentExpenses = [
  { id: 1, category: "🛒", name: "Walmart", date: "Hoy", amount: 45.50 },
  { id: 2, category: "🚕", name: "Uber", date: "Ayer", amount: 12.00 },
  { id: 3, category: "☕", name: "Starbucks", date: "Ayer", amount: 8.50 },
  { id: 4, category: "🍕", name: "Pizza Hut", date: "2 Ene", amount: 32.00 },
  { id: 5, category: "⚡", name: "Luz (CFE)", date: "1 Ene", amount: 245.00 },
  { id: 6, category: "🎬", name: "Netflix", date: "1 Ene", amount: 139.00 },
];

export function Expenses() {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Mis Gastos 💸</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Febrero 2026</p>
      </div>

      {/* Search and Filter */}
      <div className="flex gap-3 mb-6">
        <div className={`flex-1 ${isDark ? "bg-gray-800" : "bg-gray-100"} rounded-2xl px-4 py-3 flex items-center gap-2`}>
          <Search className={`w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
          <input
            type="text"
            placeholder="Buscar gastos..."
            className={`bg-transparent outline-none text-sm flex-1 ${isDark ? "text-white placeholder-gray-500" : ""}`}
          />
        </div>
        <button className={`${isDark ? "bg-purple-700 hover:bg-purple-800" : "bg-purple-600 hover:bg-purple-700"} text-white p-3 rounded-2xl transition-all`}>
          <Filter className="w-5 h-5" />
        </button>
      </div>

      {/* Month Selector */}
      <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 mb-6 flex items-center justify-between border shadow-sm`}>
        <button className={`${isDark ? "text-gray-500" : "text-gray-400"}`}>←</button>
        <div className="flex items-center gap-2">
          <Calendar className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
          <span className={`text-sm ${isDark ? "text-white" : ""}`}>Febrero 2026</span>
        </div>
        <button className={`${isDark ? "text-gray-500" : "text-gray-400"}`}>→</button>
      </div>

      {/* Total Expenses Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-red-900 to-pink-900" : "bg-gradient-to-br from-red-500 to-pink-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <p className="text-sm opacity-90 mb-2">Total de Gastos</p>
        <h2 className="text-4xl mb-4">$2,550.00</h2>
        <div className={`${isDark ? "bg-white/20" : "bg-white/20"} rounded-full h-2 overflow-hidden backdrop-blur-sm`}>
          <div className="bg-white h-full w-2/3"></div>
        </div>
        <p className="text-xs opacity-90 mt-2">67% de tu presupuesto mensual ($3,800)</p>
      </div>

      {/* Expenses by Category */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Gastos por Categoría</h3>
        <div className="space-y-3">
          {expenses.map((expense) => (
            <div key={expense.category} className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 border shadow-sm`}>
              <div className="flex items-center justify-between mb-2">
                <span className={`text-sm ${isDark ? "text-white" : ""}`}>{expense.category}</span>
                <span className={`text-sm ${isDark ? "text-white" : ""}`}>${expense.amount.toFixed(2)}</span>
              </div>
              <div className={`${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-full h-2 overflow-hidden`}>
                <div
                  className={`${expense.color} h-full transition-all`}
                  style={{ width: `${expense.percentage}%` }}
                ></div>
              </div>
              <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"} mt-1`}>{expense.percentage}% del total</p>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Historial de Gastos</h3>
        <div className="space-y-2">
          {recentExpenses.map((expense) => (
            <div
              key={expense.id}
              className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 flex items-center gap-4 border shadow-sm`}
            >
              <div className={`w-12 h-12 ${isDark ? "bg-gray-700" : "bg-gray-50"} rounded-xl flex items-center justify-center`}>
                <span className="text-2xl">{expense.category}</span>
              </div>
              <div className="flex-1">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>{expense.name}</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{expense.date}</p>
              </div>
              <p className={`${isDark ? "text-red-400" : "text-red-600"}`}>-${expense.amount.toFixed(2)}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
