import { X, DollarSign, Save } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface CategoryBudgetModalProps {
  onClose: () => void;
}

interface CategoryBudget {
  id: string;
  emoji: string;
  name: string;
  budget: string;
}

export function CategoryBudgetModal({ onClose }: CategoryBudgetModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const [categories, setCategories] = useState<CategoryBudget[]>([
    { id: "1", emoji: "☕", name: "Café", budget: "500" },
    { id: "2", emoji: "🍔", name: "Comida Rápida", budget: "800" },
    { id: "3", emoji: "🚕", name: "Transporte", budget: "600" },
    { id: "4", emoji: "🎬", name: "Entretenimiento", budget: "400" },
    { id: "5", emoji: "🛒", name: "Compras Pequeñas", budget: "300" },
    { id: "6", emoji: "🍿", name: "Snacks", budget: "200" },
  ]);

  const handleBudgetChange = (id: string, value: string) => {
    setCategories(categories.map(cat => 
      cat.id === id ? { ...cat, budget: value } : cat
    ));
  };

  const handleSave = () => {
    toast.success("Presupuestos guardados", {
      description: "Los presupuestos de tus categorías han sido actualizados",
    });
    onClose();
  };

  const totalBudget = categories.reduce((sum, cat) => sum + parseFloat(cat.budget || "0"), 0);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300 max-h-[85vh] overflow-hidden flex flex-col`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-orange-700 to-amber-700" : "bg-gradient-to-r from-orange-600 to-amber-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div>
              <h2 className="text-2xl mb-1">Presupuestos por Categoría</h2>
              <p className="text-sm opacity-90">Controla tus gastos hormiga</p>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {/* Total Budget Summary */}
          <div className={`${isDark ? "bg-gradient-to-br from-orange-900/50 to-amber-900/50 border-orange-800" : "bg-gradient-to-br from-orange-50 to-amber-50 border-orange-200"} border-2 rounded-2xl p-4 mb-6`}>
            <p className={`text-xs mb-1 ${isDark ? "text-orange-300" : "text-orange-700"}`}>
              Presupuesto Total (Gastos Hormiga)
            </p>
            <p className={`text-3xl font-bold ${isDark ? "text-orange-400" : "text-orange-600"}`}>
              ${totalBudget.toFixed(2)}
            </p>
            <p className={`text-xs mt-1 ${isDark ? "text-orange-400/70" : "text-orange-600/70"}`}>
              mensual
            </p>
          </div>

          {/* Info Alert */}
          <div className={`${isDark ? "bg-blue-900/30" : "bg-blue-50"} rounded-xl p-3 mb-4`}>
            <p className={`text-xs ${isDark ? "text-blue-300" : "text-blue-800"}`}>
              💡 Los gastos hormiga son pequeños gastos que se repiten y pueden afectar tu presupuesto si no los controlas
            </p>
          </div>

          {/* Categories List */}
          <div className="space-y-3">
            {categories.map((category) => (
              <div
                key={category.id}
                className={`${isDark ? "bg-gray-700/50 border-gray-600" : "bg-white border-gray-200"} border-2 rounded-xl p-4`}
              >
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-2xl">{category.emoji}</span>
                  <span className={`text-sm flex-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                    {category.name}
                  </span>
                </div>
                
                <div className="relative">
                  <DollarSign className={`absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <input
                    type="number"
                    step="0.01"
                    value={category.budget}
                    onChange={(e) => handleBudgetChange(category.id, e.target.value)}
                    className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white" : "bg-gray-50 border-gray-300 text-gray-900"} border-2 py-2 pl-9 pr-4 rounded-lg focus:outline-none focus:border-purple-500 transition-all text-sm`}
                    placeholder="0.00"
                  />
                </div>
                
                {/* Visual Budget Bar */}
                <div className="mt-2">
                  <div className={`h-1.5 ${isDark ? "bg-gray-600" : "bg-gray-200"} rounded-full overflow-hidden`}>
                    <div
                      className={`h-full ${isDark ? "bg-gradient-to-r from-orange-600 to-amber-600" : "bg-gradient-to-r from-orange-500 to-amber-500"} rounded-full transition-all`}
                      style={{ width: `${Math.min((parseFloat(category.budget) / 1000) * 100, 100)}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Footer Actions */}
        <div className="p-6 pt-0">
          <div className="flex gap-3">
            <button
              onClick={onClose}
              className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
            >
              Cancelar
            </button>
            <button
              onClick={handleSave}
              className={`flex-1 ${isDark ? "bg-gradient-to-r from-orange-700 to-amber-700 hover:from-orange-600 hover:to-amber-600" : "bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700"} text-white py-3 rounded-xl transition-all shadow-lg flex items-center justify-center gap-2`}
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
