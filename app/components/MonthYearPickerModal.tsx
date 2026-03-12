import { X, ChevronLeft, ChevronRight } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface MonthYearPickerModalProps {
  onClose: () => void;
  onSelect: (month: number, year: number) => void;
  currentMonth: number;
  currentYear: number;
}

const months = [
  "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
  "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
];

export function MonthYearPickerModal({ onClose, onSelect, currentMonth, currentYear }: MonthYearPickerModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedYear, setSelectedYear] = useState(currentYear);
  const [selectedMonth, setSelectedMonth] = useState(currentMonth);

  const handlePreviousYear = () => {
    setSelectedYear((prev) => prev - 1);
  };

  const handleNextYear = () => {
    setSelectedYear((prev) => prev + 1);
  };

  const handleSelect = () => {
    onSelect(selectedMonth, selectedYear);
    onClose();
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

        <h2 className={`text-2xl mb-6 ${isDark ? "text-white" : "text-gray-900"}`}>
          Seleccionar Periodo 📅
        </h2>

        {/* Year Selector */}
        <div className="mb-6">
          <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Año
          </label>
          <div className={`${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-xl p-4 flex items-center justify-between`}>
            <button
              onClick={handlePreviousYear}
              className={`${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"} transition-colors`}
            >
              <ChevronLeft className="w-6 h-6" />
            </button>
            <span className={`text-2xl font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
              {selectedYear}
            </span>
            <button
              onClick={handleNextYear}
              className={`${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"} transition-colors`}
            >
              <ChevronRight className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Month Grid */}
        <div className="mb-6">
          <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Mes
          </label>
          <div className="grid grid-cols-3 gap-2">
            {months.map((month, index) => (
              <button
                key={index}
                onClick={() => setSelectedMonth(index)}
                className={`p-3 rounded-xl text-sm transition-all ${
                  selectedMonth === index
                    ? isDark
                      ? "bg-purple-900/50 border-2 border-purple-600 text-white"
                      : "bg-purple-100 border-2 border-purple-500 text-purple-700"
                    : isDark
                    ? "bg-gray-700 border-2 border-gray-600 text-gray-300 hover:border-gray-500"
                    : "bg-gray-50 border-2 border-gray-200 text-gray-700 hover:border-gray-300"
                }`}
              >
                {month.substring(0, 3)}
              </button>
            ))}
          </div>
        </div>

        {/* Selected Preview */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-900/40 to-blue-900/40 border-purple-800" : "bg-gradient-to-r from-purple-100 to-blue-100 border-purple-200"} rounded-2xl p-4 mb-6 border-2 text-center`}>
          <p className={`text-sm ${isDark ? "text-gray-300" : "text-gray-700"} mb-1`}>
            Periodo Seleccionado
          </p>
          <p className={`text-xl font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
            {months[selectedMonth]} {selectedYear}
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-3">
          <button
            onClick={onClose}
            className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
          >
            Cancelar
          </button>
          <button
            onClick={handleSelect}
            className={`flex-1 ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
          >
            Confirmar
          </button>
        </div>
      </div>
    </div>
  );
}
