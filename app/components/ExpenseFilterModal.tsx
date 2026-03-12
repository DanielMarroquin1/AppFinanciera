import { X, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface ExpenseFilterModalProps {
  onClose: () => void;
  onApply: (filters: FilterOptions) => void;
}

export interface FilterOptions {
  categories: string[];
  minAmount: string;
  maxAmount: string;
  sortBy: "date" | "amount" | "category";
}

const categories = [
  { id: "food", label: "🍔 Comida", value: "food" },
  { id: "transport", label: "🚗 Transporte", value: "transport" },
  { id: "home", label: "🏠 Hogar", value: "home" },
  { id: "entertainment", label: "🎮 Entretenimiento", value: "entertainment" },
  { id: "health", label: "💊 Salud", value: "health" },
  { id: "shopping", label: "🛍️ Compras", value: "shopping" },
];

export function ExpenseFilterModal({ onClose, onApply }: ExpenseFilterModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [minAmount, setMinAmount] = useState("");
  const [maxAmount, setMaxAmount] = useState("");
  const [sortBy, setSortBy] = useState<"date" | "amount" | "category">("date");

  const handleCategoryToggle = (category: string) => {
    setSelectedCategories((prev) =>
      prev.includes(category)
        ? prev.filter((c) => c !== category)
        : [...prev, category]
    );
  };

  const handleApply = () => {
    onApply({
      categories: selectedCategories,
      minAmount,
      maxAmount,
      sortBy,
    });
    onClose();
  };

  const handleClear = () => {
    setSelectedCategories([]);
    setMinAmount("");
    setMaxAmount("");
    setSortBy("date");
  };

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

        <h2 className={`text-2xl mb-6 ${isDark ? "text-white" : "text-gray-900"}`}>
          Filtrar Gastos 🔍
        </h2>

        {/* Categories */}
        <div className="mb-6">
          <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Categorías
          </label>
          <div className="space-y-2">
            {categories.map((category) => (
              <button
                key={category.id}
                onClick={() => handleCategoryToggle(category.value)}
                className={`w-full p-3 rounded-xl flex items-center justify-between transition-all ${
                  selectedCategories.includes(category.value)
                    ? isDark
                      ? "bg-purple-900/50 border-2 border-purple-600"
                      : "bg-purple-100 border-2 border-purple-500"
                    : isDark
                    ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                    : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                }`}
              >
                <span className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                  {category.label}
                </span>
                {selectedCategories.includes(category.value) && (
                  <div className={`w-5 h-5 rounded-full flex items-center justify-center ${isDark ? "bg-purple-600" : "bg-purple-500"}`}>
                    <Check className="w-3 h-3 text-white" />
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Amount Range */}
        <div className="mb-6">
          <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Rango de Monto
          </label>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <input
                type="number"
                placeholder="Mínimo"
                value={minAmount}
                onChange={(e) => setMinAmount(e.target.value)}
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 px-3 rounded-xl focus:outline-none focus:border-purple-500 transition-all text-sm`}
              />
            </div>
            <div>
              <input
                type="number"
                placeholder="Máximo"
                value={maxAmount}
                onChange={(e) => setMaxAmount(e.target.value)}
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 px-3 rounded-xl focus:outline-none focus:border-purple-500 transition-all text-sm`}
              />
            </div>
          </div>
        </div>

        {/* Sort By */}
        <div className="mb-6">
          <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Ordenar Por
          </label>
          <div className="space-y-2">
            {[
              { value: "date", label: "Fecha" },
              { value: "amount", label: "Monto" },
              { value: "category", label: "Categoría" },
            ].map((option) => (
              <button
                key={option.value}
                onClick={() => setSortBy(option.value as "date" | "amount" | "category")}
                className={`w-full p-3 rounded-xl flex items-center justify-between transition-all ${
                  sortBy === option.value
                    ? isDark
                      ? "bg-purple-900/50 border-2 border-purple-600"
                      : "bg-purple-100 border-2 border-purple-500"
                    : isDark
                    ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                    : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                }`}
              >
                <span className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                  {option.label}
                </span>
                {sortBy === option.value && (
                  <div className={`w-5 h-5 rounded-full flex items-center justify-center ${isDark ? "bg-purple-600" : "bg-purple-500"}`}>
                    <Check className="w-3 h-3 text-white" />
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-3">
          <button
            onClick={handleClear}
            className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
          >
            Limpiar
          </button>
          <button
            onClick={handleApply}
            className={`flex-1 ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
          >
            Aplicar
          </button>
        </div>
      </div>
    </div>
  );
}
