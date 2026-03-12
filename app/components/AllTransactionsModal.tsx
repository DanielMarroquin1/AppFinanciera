import { X, Calendar, Search, Filter } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface AllTransactionsModalProps {
  onClose: () => void;
}

const allTransactions = [
  { id: 1, type: "expense", category: "🛒", name: "Walmart", date: "24 Feb 2026", amount: -45.50 },
  { id: 2, type: "expense", category: "🚕", name: "Uber", date: "23 Feb 2026", amount: -12.00 },
  { id: 3, type: "expense", category: "☕", name: "Starbucks", date: "23 Feb 2026", amount: -8.50 },
  { id: 4, type: "expense", category: "🍕", name: "Pizza Hut", date: "22 Feb 2026", amount: -32.00 },
  { id: 5, type: "expense", category: "⚡", name: "Luz (CFE)", date: "20 Feb 2026", amount: -245.00 },
  { id: 6, type: "expense", category: "🎬", name: "Netflix", date: "18 Feb 2026", amount: -139.00 },
  { id: 7, type: "income", category: "💼", name: "Salario", date: "15 Feb 2026", amount: 3500.00 },
  { id: 8, type: "expense", category: "⛽", name: "Gasolina", date: "14 Feb 2026", amount: -500.00 },
  { id: 9, type: "expense", category: "🎮", name: "PlayStation Plus", date: "12 Feb 2026", amount: -180.00 },
  { id: 10, type: "expense", category: "💊", name: "Farmacia", date: "10 Feb 2026", amount: -235.00 },
  { id: 11, type: "income", category: "💰", name: "Freelance", date: "8 Feb 2026", amount: 1200.00 },
  { id: 12, type: "expense", category: "🏠", name: "Renta", date: "1 Feb 2026", amount: -8000.00 },
];

export function AllTransactionsModal({ onClose }: AllTransactionsModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [searchTerm, setSearchTerm] = useState("");

  const filteredTransactions = allTransactions.filter((t) =>
    t.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300 max-h-[85vh] flex flex-col`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors z-10`}
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header */}
        <div className="mb-4">
          <h2 className={`text-2xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            Todas las Transacciones
          </h2>
          <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
            Historial completo de movimientos
          </p>
        </div>

        {/* Search */}
        <div className="mb-4">
          <div className={`${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-xl px-4 py-3 flex items-center gap-2`}>
            <Search className={`w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
            <input
              type="text"
              placeholder="Buscar transacción..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className={`bg-transparent outline-none text-sm flex-1 ${isDark ? "text-white placeholder-gray-500" : "placeholder-gray-400"}`}
            />
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3`}>
            <p className={`text-xs mb-1 ${isDark ? "text-gray-400" : "text-gray-500"}`}>Total Ingresos</p>
            <p className={`text-lg ${isDark ? "text-green-400" : "text-green-600"}`}>+$4,700</p>
          </div>
          <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3`}>
            <p className={`text-xs mb-1 ${isDark ? "text-gray-400" : "text-gray-500"}`}>Total Gastos</p>
            <p className={`text-lg ${isDark ? "text-red-400" : "text-red-600"}`}>-$9,396</p>
          </div>
        </div>

        {/* Transaction List */}
        <div className="flex-1 overflow-y-auto space-y-2 pr-2">
          {filteredTransactions.map((transaction) => (
            <div
              key={transaction.id}
              className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3 flex items-center gap-3`}
            >
              <div className={`w-10 h-10 ${transaction.type === "income" ? isDark ? "bg-green-900/30" : "bg-green-100" : isDark ? "bg-gray-700" : "bg-white"} rounded-lg flex items-center justify-center`}>
                <span className="text-xl">{transaction.category}</span>
              </div>
              <div className="flex-1 min-w-0">
                <p className={`text-sm truncate ${isDark ? "text-white" : "text-gray-900"}`}>
                  {transaction.name}
                </p>
                <div className="flex items-center gap-1">
                  <Calendar className={`w-3 h-3 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>
                    {transaction.date}
                  </p>
                </div>
              </div>
              <p
                className={`text-sm font-medium ${
                  transaction.type === "income"
                    ? isDark
                      ? "text-green-400"
                      : "text-green-600"
                    : isDark
                    ? "text-red-400"
                    : "text-red-600"
                }`}
              >
                {transaction.amount > 0 ? "+" : ""}${Math.abs(transaction.amount).toFixed(2)}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
