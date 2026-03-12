import { useState } from "react";
import { X, TrendingDown, Calendar, DollarSign, Tag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { toast } from "sonner";

interface AddExpenseModalProps {
  onClose: () => void;
}

export function AddExpenseModal({ onClose }: AddExpenseModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("");
  const [description, setDescription] = useState("");
  const [date, setDate] = useState(new Date().toISOString().split("T")[0]);

  const expenseCategories = [
    { value: "food", label: "Comida", emoji: "🍔" },
    { value: "transport", label: "Transporte", emoji: "🚗" },
    { value: "shopping", label: "Compras", emoji: "🛍️" },
    { value: "bills", label: "Servicios", emoji: "📱" },
    { value: "entertainment", label: "Ocio", emoji: "🎮" },
    { value: "health", label: "Salud", emoji: "💊" },
    { value: "education", label: "Educación", emoji: "📚" },
    { value: "home", label: "Hogar", emoji: "🏠" },
    { value: "other", label: "Otro", emoji: "💸" },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Aquí se guardaría el gasto
    console.log({ amount, category, description, date });
    onClose();
  };


  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"
          } rounded-t-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-red-700 to-pink-700" : "bg-gradient-to-r from-red-600 to-pink-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <TrendingDown className="w-6 h-6" />
              </div>
              <h2 className="text-2xl">Nuevo Gasto</h2>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
          <p className="text-sm text-white/90">Registra tus gastos para tener mejor control</p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 120px)" }}>
          {/* Amount */}
          <div className="mb-5">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Monto 💵
            </label>
            <div className="relative">
              <DollarSign className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                step="0.01"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="0.00"
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-4 pl-12 pr-4 rounded-xl focus:outline-none focus:border-red-500 transition-all text-2xl font-semibold`}
              />
            </div>
          </div>

          {/* Category */}
          <div className="mb-5">
            <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Categoría 🏷️
            </label>
            <div className="grid grid-cols-2 gap-2">
              {expenseCategories.map((cat) => (
                <label
                  key={cat.value}
                  className={`flex items-center gap-2 p-3 rounded-xl cursor-pointer transition-all ${category === cat.value
                      ? isDark
                        ? "bg-red-900/50 border-2 border-red-600"
                        : "bg-red-100 border-2 border-red-500"
                      : isDark
                        ? "bg-gray-700 border-2 border-gray-600 hover:bg-gray-650"
                        : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                    }`}
                >
                  <input
                    type="radio"
                    name="category"
                    value={cat.value}
                    checked={category === cat.value}
                    onChange={(e) => setCategory(e.target.value)}
                    className="sr-only"
                    required
                  />
                  <span className="text-xl">{cat.emoji}</span>
                  <span className={`flex-1 text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                    {cat.label}
                  </span>
                  {category === cat.value && (
                    <div className="w-5 h-5 bg-red-600 rounded-full flex items-center justify-center">
                      <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  )}
                </label>
              ))}
            </div>
          </div>

          {/* Description */}
          <div className="mb-5">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Descripción (Opcional) 📝
            </label>
            <div className="relative">
              <Tag className={`absolute left-4 top-4 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Ej: Compras en supermercado..."
                rows={3}
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-red-500 transition-all resize-none`}
              />
            </div>
          </div>

          {/* Date */}
          <div className="mb-6">
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Fecha 📅
            </label>
            <div className="relative">
              <Calendar className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3.5 pl-12 pr-4 rounded-xl focus:outline-none focus:border-red-500 transition-all`}
              />
            </div>
          </div>


          {/* Submit Button */}
          <button
            type="submit"
            className={`w-full ${isDark ? "bg-gradient-to-r from-red-700 to-pink-700 hover:from-red-600 hover:to-pink-600" : "bg-gradient-to-r from-red-600 to-pink-600 hover:from-red-700 hover:to-pink-700"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl font-medium`}
          >
            Agregar Gasto
          </button>
        </form>
      </div>
    </div>
  );
}