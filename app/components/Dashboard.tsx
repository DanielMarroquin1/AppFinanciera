import { TrendingDown, TrendingUp, Wallet, AlertCircle, Gift } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

export function Dashboard() {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>¡Hola, María! 👋</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Aquí está tu resumen financiero</p>
      </div>

      {/* Balance Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-purple-900 to-blue-900" : "bg-gradient-to-br from-purple-600 to-blue-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <p className="text-sm opacity-90 mb-2">Balance Total</p>
        <h2 className="text-4xl mb-4">$12,450.00</h2>
        <div className="flex gap-4">
          <div className={`flex-1 ${isDark ? "bg-white/10" : "bg-white/20"} rounded-2xl p-3 backdrop-blur-sm`}>
            <p className="text-xs opacity-90 mb-1">Ingresos</p>
            <p className="text-lg">$15,000</p>
          </div>
          <div className={`flex-1 ${isDark ? "bg-white/10" : "bg-white/20"} rounded-2xl p-3 backdrop-blur-sm`}>
            <p className="text-xs opacity-90 mb-1">Gastos</p>
            <p className="text-lg">$2,550</p>
          </div>
        </div>
      </div>

      {/* Alert Banner */}
      <div className={`${isDark ? "bg-amber-900/30 border-amber-800" : "bg-amber-50 border-amber-200"} border-2 rounded-2xl p-4 mb-6 flex items-start gap-3`}>
        <AlertCircle className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"} flex-shrink-0 mt-0.5`} />
        <div>
          <p className={`text-sm ${isDark ? "text-amber-200" : "text-amber-900"}`}>
            <strong>¡Cuidado!</strong> Estás cerca del límite de tu presupuesto mensual.
          </p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Acciones Rápidas</h3>
        <div className="grid grid-cols-3 gap-3">
          <button className={`${isDark ? "bg-green-900/30 border-green-800 hover:bg-green-900/50" : "bg-green-50 border-green-200 hover:bg-green-100"} border-2 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all`}>
            <TrendingUp className={`w-6 h-6 ${isDark ? "text-green-400" : "text-green-600"}`} />
            <span className={`text-xs ${isDark ? "text-green-200" : "text-green-900"}`}>Ingreso</span>
          </button>
          <button className={`${isDark ? "bg-red-900/30 border-red-800 hover:bg-red-900/50" : "bg-red-50 border-red-200 hover:bg-red-100"} border-2 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all`}>
            <TrendingDown className={`w-6 h-6 ${isDark ? "text-red-400" : "text-red-600"}`} />
            <span className={`text-xs ${isDark ? "text-red-200" : "text-red-900"}`}>Gasto</span>
          </button>
          <button className={`${isDark ? "bg-blue-900/30 border-blue-800 hover:bg-blue-900/50" : "bg-blue-50 border-blue-200 hover:bg-blue-100"} border-2 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all`}>
            <Wallet className={`w-6 h-6 ${isDark ? "text-blue-400" : "text-blue-600"}`} />
            <span className={`text-xs ${isDark ? "text-blue-200" : "text-blue-900"}`}>Transferir</span>
          </button>
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-3">
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"}`}>Transacciones Recientes</h3>
          <button className="text-xs text-purple-600">Ver todas</button>
        </div>
        <div className="space-y-3">
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 flex items-center gap-4 border shadow-sm`}>
            <div className={`w-12 h-12 ${isDark ? "bg-red-900/30" : "bg-red-50"} rounded-xl flex items-center justify-center`}>
              <span className="text-xl">🛒</span>
            </div>
            <div className="flex-1">
              <p className={`text-sm ${isDark ? "text-white" : ""}`}>Supermercado</p>
              <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Hoy, 10:30 AM</p>
            </div>
            <p className={`${isDark ? "text-red-400" : "text-red-600"}`}>-$45.50</p>
          </div>

          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 flex items-center gap-4 border shadow-sm`}>
            <div className={`w-12 h-12 ${isDark ? "bg-blue-900/30" : "bg-blue-50"} rounded-xl flex items-center justify-center`}>
              <span className="text-xl">🚕</span>
            </div>
            <div className="flex-1">
              <p className={`text-sm ${isDark ? "text-white" : ""}`}>Uber</p>
              <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Ayer, 6:15 PM</p>
            </div>
            <p className={`${isDark ? "text-red-400" : "text-red-600"}`}>-$12.00</p>
          </div>

          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 flex items-center gap-4 border shadow-sm`}>
            <div className={`w-12 h-12 ${isDark ? "bg-green-900/30" : "bg-green-50"} rounded-xl flex items-center justify-center`}>
              <span className="text-xl">💼</span>
            </div>
            <div className="flex-1">
              <p className={`text-sm ${isDark ? "text-white" : ""}`}>Salario</p>
              <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>15 Ene, 2026</p>
            </div>
            <p className={`${isDark ? "text-green-400" : "text-green-600"}`}>+$3,500.00</p>
          </div>
        </div>
      </div>

      {/* Achievements */}
      <div className={`${isDark ? "bg-gradient-to-br from-amber-600 to-orange-700" : "bg-gradient-to-br from-amber-400 to-orange-500"} rounded-3xl p-5 text-white mb-6`}>
        <div className="flex items-center gap-3 mb-3">
          <Gift className="w-6 h-6" />
          <h3 className="text-lg">¡Logro Desbloqueado!</h3>
        </div>
        <p className="text-sm opacity-90 mb-3">
          Has ahorrado por 7 días consecutivos. ¡Sigue así! 🎉
        </p>
        <div className={`${isDark ? "bg-white/20" : "bg-white/20"} rounded-full h-2 overflow-hidden backdrop-blur-sm`}>
          <div className="bg-white h-full w-3/4"></div>
        </div>
        <p className="text-xs opacity-90 mt-2">75% para el próximo nivel</p>
      </div>
    </div>
  );
}
