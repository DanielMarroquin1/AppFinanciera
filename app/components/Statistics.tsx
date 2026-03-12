import { TrendingDown, TrendingUp, Calendar } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

export function Statistics() {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun"];
  const data = [
    { month: "Ene", income: 3500, expenses: 2300 },
    { month: "Feb", income: 3500, expenses: 2550 },
    { month: "Mar", income: 4200, expenses: 2800 },
    { month: "Abr", income: 3500, expenses: 2200 },
    { month: "May", income: 3800, expenses: 2900 },
    { month: "Jun", income: 3500, expenses: 2400 },
  ];

  const maxValue = Math.max(...data.flatMap((d) => [d.income, d.expenses]));

  const categoryData = [
    { name: "Comida", amount: 450, color: "bg-red-500", percentage: 35 },
    { name: "Transporte", amount: 280, color: "bg-blue-500", percentage: 22 },
    { name: "Hogar", amount: 520, color: "bg-purple-500", percentage: 40 },
    { name: "Entretenimiento", amount: 150, color: "bg-pink-500", percentage: 12 },
    { name: "Salud", amount: 95, color: "bg-green-500", percentage: 7 },
    { name: "Otros", amount: 55, color: "bg-gray-500", percentage: 4 },
  ];

  return (
    <div className={`p-6 pb-20 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Reportes 📊</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Análisis de tus finanzas</p>
      </div>

      {/* Period Selector */}
      <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 mb-6 flex items-center justify-between border shadow-sm`}>
        <button className={`${isDark ? "text-gray-500" : "text-gray-400"}`}>←</button>
        <div className="flex items-center gap-2">
          <Calendar className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
          <span className={`text-sm ${isDark ? "text-white" : ""}`}>Últimos 6 meses</span>
        </div>
        <button className={`${isDark ? "text-gray-500" : "text-gray-400"}`}>→</button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        <div className={`${isDark ? "bg-gradient-to-br from-green-800 to-emerald-900" : "bg-gradient-to-br from-green-500 to-emerald-600"} rounded-2xl p-4 text-white shadow-sm`}>
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="w-4 h-4" />
            <p className="text-xs opacity-90">Ingresos</p>
          </div>
          <p className="text-2xl">$22,000</p>
          <p className="text-xs opacity-75 mt-1">Este mes</p>
        </div>

        <div className={`${isDark ? "bg-gradient-to-br from-red-800 to-pink-900" : "bg-gradient-to-br from-red-500 to-pink-600"} rounded-2xl p-4 text-white shadow-sm`}>
          <div className="flex items-center gap-2 mb-2">
            <TrendingDown className="w-4 h-4" />
            <p className="text-xs opacity-90">Gastos</p>
          </div>
          <p className="text-2xl">$15,150</p>
          <p className="text-xs opacity-75 mt-1">Este mes</p>
        </div>
      </div>

      {/* Bar Chart */}
      <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-3xl p-5 mb-6 border shadow-sm`}>
        <h3 className={`text-sm mb-4 ${isDark ? "text-white" : ""}`}>Ingresos vs Gastos</h3>
        <div className="flex items-end justify-between gap-2 h-48 mb-4">
          {data.map((item, index) => (
            <div key={index} className="flex-1 flex flex-col items-center gap-2 h-full justify-end">
              <div className="flex flex-col gap-1 items-center w-full">
                <div
                  className={`${isDark ? "bg-green-600" : "bg-green-500"} rounded-t-lg w-full`}
                  style={{ height: `${(item.income / maxValue) * 100}%`, minHeight: "20px" }}
                ></div>
                <div
                  className={`${isDark ? "bg-red-600" : "bg-red-500"} rounded-t-lg w-full`}
                  style={{ height: `${(item.expenses / maxValue) * 100}%`, minHeight: "20px" }}
                ></div>
              </div>
              <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{item.month}</span>
            </div>
          ))}
        </div>
        <div className={`flex items-center justify-center gap-4 pt-3 ${isDark ? "border-gray-700" : "border-gray-100"} border-t`}>
          <div className="flex items-center gap-2">
            <div className={`w-3 h-3 ${isDark ? "bg-green-600" : "bg-green-500"} rounded`}></div>
            <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>Ingresos</span>
          </div>
          <div className="flex items-center gap-2">
            <div className={`w-3 h-3 ${isDark ? "bg-red-600" : "bg-red-500"} rounded`}></div>
            <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>Gastos</span>
          </div>
        </div>
      </div>

      {/* Pie Chart (Visual Representation) */}
      <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-3xl p-5 mb-6 border shadow-sm`}>
        <h3 className={`text-sm mb-4 ${isDark ? "text-white" : ""}`}>Distribución de Gastos</h3>
        
        {/* Donut Chart Visual */}
        <div className="flex items-center justify-center mb-6">
          <div className="relative w-40 h-40">
            <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
              {categoryData.reduce((acc, cat, index) => {
                const prevPercentage = categoryData.slice(0, index).reduce((sum, c) => sum + c.percentage, 0);
                const circumference = 2 * Math.PI * 35;
                const offset = (prevPercentage / 100) * circumference;
                const dashArray = `${(cat.percentage / 100) * circumference} ${circumference}`;
                
                return [
                  ...acc,
                  <circle
                    key={cat.name}
                    cx="50"
                    cy="50"
                    r="35"
                    fill="none"
                    strokeWidth="20"
                    className={cat.color.replace('bg-', 'stroke-')}
                    strokeDasharray={dashArray}
                    strokeDashoffset={-offset}
                  />
                ];
              }, [] as JSX.Element[])}
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <p className={`text-2xl ${isDark ? "text-white" : ""}`}>$1,550</p>
              <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Total</p>
            </div>
          </div>
        </div>

        {/* Legend */}
        <div className="space-y-2">
          {categoryData.map((cat) => (
            <div key={cat.name} className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className={`w-3 h-3 rounded ${cat.color}`}></div>
                <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>{cat.name}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{cat.percentage}%</span>
                <span className={`text-xs ${isDark ? "text-white" : ""}`}>${cat.amount}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Export Button */}
      <button className={`w-full ${isDark ? "bg-purple-700 hover:bg-purple-800" : "bg-purple-600 hover:bg-purple-700"} text-white py-4 rounded-2xl transition-all shadow-sm`}>
        Descargar Reporte PDF
      </button>
    </div>
  );
}
