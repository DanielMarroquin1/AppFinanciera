import { Calendar, Filter, Search, ChevronLeft, ChevronRight, Sparkles, Crown, Mic, MicOff, Bell, X, DollarSign, ChevronUp } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState, useRef, useCallback } from "react";
import { CategoryExpenseDetail } from "./CategoryExpenseDetail";
import { MonthYearPickerModal } from "./MonthYearPickerModal";
import { ExpenseFilterModal, FilterOptions } from "./ExpenseFilterModal";
import { AIChatModal } from "./AIChatModal";
import { AddExpenseModal } from "./AddExpenseModal";
import { BudgetAlertModal } from "./BudgetAlertModal";
import { toast } from "sonner";

const expenses = [
  { category: "🍔 Comida", amount: 450.50, percentage: 35, color: "bg-rose-500" },
  { category: "🚗 Transporte", amount: 280.00, percentage: 22, color: "bg-sky-500" },
  { category: "🏠 Hogar", amount: 520.00, percentage: 40, color: "bg-indigo-500" },
  { category: "🎮 Entretenimiento", amount: 150.00, percentage: 12, color: "bg-fuchsia-500" },
  { category: "💊 Salud", amount: 95.00, percentage: 7, color: "bg-emerald-500" },
];

const recentExpenses = [
  { id: 1, category: "🛒", name: "Walmart", date: "Hoy", amount: 45.50 },
  { id: 2, category: "🚕", name: "Uber", date: "Ayer", amount: 12.00 },
  { id: 3, category: "☕", name: "Starbucks", date: "Ayer", amount: 8.50 },
  { id: 4, category: "🍕", name: "Pizza Hut", date: "2 Ene", amount: 32.00 },
  { id: 5, category: "⚡", name: "Luz (CFE)", date: "1 Ene", amount: 245.00 },
  { id: 6, category: "🎬", name: "Netflix", date: "1 Ene", amount: 139.00 },
];

const months = [
  "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
  "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
];

// Initial debts data (would come from context/profile in production)
const initialDebts = [
  { id: "1", name: "Laptop", installmentAmount: 1500, totalInstallments: 12, paidInstallments: 5, category: "💻" },
  { id: "2", name: "Préstamo Personal", installmentAmount: 3000, totalInstallments: 24, paidInstallments: 8, category: "🏦" },
  { id: "3", name: "Celular", installmentAmount: 800, totalInstallments: 6, paidInstallments: 4, category: "📱" },
];

export function Expenses() {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [currentMonthIndex, setCurrentMonthIndex] = useState(1);
  const [currentYear, setCurrentYear] = useState(2026);
  const [selectedCategory, setSelectedCategory] = useState<typeof expenses[0] | null>(null);
  const [showMonthYearPicker, setShowMonthYearPicker] = useState(false);
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [showAIChatModal, setShowAIChatModal] = useState(false);
  const [showExpenseModal, setShowExpenseModal] = useState(false);
  const [showBudgetAlertModal, setShowBudgetAlertModal] = useState(false);

  // Debts state
  const [debtsData, setDebtsData] = useState(initialDebts);

  // Voice FAB state
  const [isListening, setIsListening] = useState(false);

  // Long-press category budget alert state
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [longPressCategory, setLongPressCategory] = useState<string | null>(null);
  const [categoryBudgetAmount, setCategoryBudgetAmount] = useState("");

  // Budget alert settings
  const [alertPercentage] = useState(80);
  const monthlyBudget = 3800;
  const totalExpenses = 2550;
  const budgetUsedPercent = Math.round((totalExpenses / monthlyBudget) * 100);
  const alertAmount = (monthlyBudget * alertPercentage) / 100;

  const handlePreviousMonth = () => {
    if (currentMonthIndex === 0) {
      setCurrentMonthIndex(11);
      setCurrentYear((prev) => prev - 1);
    } else {
      setCurrentMonthIndex((prev) => prev - 1);
    }
  };

  const handleNextMonth = () => {
    if (currentMonthIndex === 11) {
      setCurrentMonthIndex(0);
      setCurrentYear((prev) => prev + 1);
    } else {
      setCurrentMonthIndex((prev) => prev + 1);
    }
  };

  const handleMonthYearSelect = (month: number, year: number) => {
    setCurrentMonthIndex(month);
    setCurrentYear(year);
  };

  const handleApplyFilter = (filters: FilterOptions) => {
    console.log("Filters applied:", filters);
  };

  // --- Voice FAB handler ---
  const handleVoiceInput = useCallback(() => {
    if (!("webkitSpeechRecognition" in window) && !("SpeechRecognition" in window)) {
      toast.error("Reconocimiento de voz no disponible", {
        description: "Tu navegador no soporta esta función",
      });
      return;
    }

    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    const recognition = new SpeechRecognition();

    recognition.lang = "es-ES";
    recognition.continuous = false;
    recognition.interimResults = false;

    recognition.onstart = () => {
      setIsListening(true);
      toast.info("🎙️ Escuchando...", {
        description: "Di el monto y la descripción del gasto",
      });
    };

    recognition.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript.toLowerCase();
      console.log("Reconocimiento:", transcript);
      toast.success("Gasto capturado por voz", {
        description: `"${transcript}" — Abriendo formulario...`,
      });
      setShowExpenseModal(true);
    };

    recognition.onerror = () => {
      setIsListening(false);
      toast.error("Error al capturar voz", {
        description: "Por favor intenta nuevamente",
      });
    };

    recognition.onend = () => {
      setIsListening(false);
    };

    recognition.start();
  }, []);

  // --- Long-press handlers ---
  const handleLongPressStart = useCallback((categoryName: string) => {
    longPressTimer.current = setTimeout(() => {
      setLongPressCategory(categoryName);
      setCategoryBudgetAmount("");
    }, 600);
  }, []);

  const handleLongPressEnd = useCallback(() => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
      longPressTimer.current = null;
    }
  }, []);

  const handleSaveCategoryBudget = () => {
    if (categoryBudgetAmount && longPressCategory) {
      toast.success("Alerta de presupuesto configurada", {
        description: `Se te avisará cuando ${longPressCategory} supere $${categoryBudgetAmount}`,
      });
      setLongPressCategory(null);
      setCategoryBudgetAmount("");
    }
  };

  if (selectedCategory) {
    return (
      <CategoryExpenseDetail
        category={selectedCategory}
        onBack={() => setSelectedCategory(null)}
      />
    );
  }

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""} relative`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Mis Gastos 💸</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>{months[currentMonthIndex]} {currentYear}</p>
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
        <button
          onClick={() => setShowFilterModal(true)}
          className={`${isDark ? "bg-indigo-700 hover:bg-indigo-800" : "bg-indigo-600 hover:bg-indigo-700"} text-white p-3 rounded-2xl transition-all`}
        >
          <Filter className="w-5 h-5" />
        </button>
      </div>

      {/* Month Selector */}
      <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl p-4 mb-6 flex items-center justify-between border shadow-sm`}>
        <button
          onClick={handlePreviousMonth}
          className={`${isDark ? "text-indigo-400 hover:text-indigo-300" : "text-indigo-600 hover:text-indigo-700"} transition-colors`}
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        <button
          onClick={() => setShowMonthYearPicker(true)}
          className="flex items-center gap-2 hover:opacity-80 transition-opacity"
        >
          <Calendar className={`w-5 h-5 ${isDark ? "text-indigo-400" : "text-indigo-600"}`} />
          <span className={`text-sm ${isDark ? "text-white" : ""}`}>{months[currentMonthIndex]} {currentYear}</span>
        </button>
        <button
          onClick={handleNextMonth}
          className={`${isDark ? "text-indigo-400 hover:text-indigo-300" : "text-indigo-600 hover:text-indigo-700"} transition-colors`}
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>

      {/* AI Help Banner (Premium) */}
      <div className={`${isDark ? "bg-gradient-to-r from-indigo-900/40 to-emerald-900/40 border-indigo-800" : "bg-gradient-to-r from-indigo-100 to-emerald-100 border-indigo-200"} rounded-2xl p-4 mb-6 border-2`}>
        <div className="flex items-center gap-3 mb-2">
          <Sparkles className={`w-6 h-6 ${isDark ? "text-indigo-400" : "text-indigo-600"}`} />
          <h3 className={`text-sm flex items-center gap-2 ${isDark ? "text-white" : ""}`}>
            Ayuda con IA para Gastos
            <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
              <Crown className="w-3 h-3" />
              PRO
            </div>
          </h3>
        </div>
        <p className={`text-xs ${isDark ? "text-gray-300" : "text-gray-700"} mb-3`}>
          Obtén consejos personalizados para reducir gastos y optimizar tu presupuesto
        </p>
        <button
          onClick={() => setShowAIChatModal(true)}
          className={`${isDark ? "bg-indigo-700 hover:bg-indigo-800" : "bg-indigo-600 hover:bg-indigo-700"} text-white text-xs px-4 py-2 rounded-xl transition-all`}
        >
          Consultar Ahora
        </button>
      </div>

      {/* Total Expenses Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-rose-900 to-pink-900" : "bg-gradient-to-br from-rose-500 to-pink-600"} rounded-3xl p-6 mb-4 text-white shadow-lg`}>
        <p className="text-sm opacity-90 mb-2">Total de Gastos</p>
        <h2 className="text-4xl mb-4">${totalExpenses.toFixed(2)}</h2>
        <div className={`bg-white/20 rounded-full h-2 overflow-hidden backdrop-blur-sm`}>
          <div className="bg-white h-full transition-all" style={{ width: `${budgetUsedPercent}%` }}></div>
        </div>
        <p className="text-xs opacity-90 mt-2">{budgetUsedPercent}% de tu presupuesto mensual (${monthlyBudget.toFixed(2)})</p>
      </div>

      {/* Budget Alert Banner (Change #4) */}
      <button
        onClick={() => setShowBudgetAlertModal(true)}
        className={`w-full ${budgetUsedPercent >= alertPercentage
          ? isDark ? "bg-gradient-to-r from-amber-900/60 to-red-900/60 border-amber-700" : "bg-gradient-to-r from-amber-50 to-red-50 border-amber-300"
          : isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"
          } border-2 rounded-2xl p-4 mb-6 flex items-center gap-3 transition-all hover:scale-[1.01]`}
      >
        <div className={`w-10 h-10 ${budgetUsedPercent >= alertPercentage
          ? isDark ? "bg-amber-800" : "bg-amber-100"
          : isDark ? "bg-indigo-900/50" : "bg-indigo-100"
          } rounded-xl flex items-center justify-center`}>
          <Bell className={`w-5 h-5 ${budgetUsedPercent >= alertPercentage
            ? isDark ? "text-amber-400" : "text-amber-600"
            : isDark ? "text-indigo-400" : "text-indigo-600"
            }`} />
        </div>
        <div className="flex-1 text-left">
          <p className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
            {budgetUsedPercent >= alertPercentage ? "⚠️ " : ""}Alerta al {alertPercentage}%
          </p>
          <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>
            Aviso cuando gastes ${alertAmount.toFixed(0)} de ${monthlyBudget.toFixed(0)} · Toca para ajustar
          </p>
        </div>
        <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
      </button>

      {/* Expenses by Category (with long-press for budget alerts — Change #3) */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Gastos por Categoría <span className={`text-xs ${isDark ? "text-gray-600" : "text-gray-400"}`}>(mantén presionado para alertas)</span></h3>
        <div className="space-y-3">
          {expenses.map((expense) => (
            <button
              key={expense.category}
              onClick={() => setSelectedCategory(expense)}
              onMouseDown={() => handleLongPressStart(expense.category)}
              onMouseUp={handleLongPressEnd}
              onMouseLeave={handleLongPressEnd}
              onTouchStart={() => handleLongPressStart(expense.category)}
              onTouchEnd={handleLongPressEnd}
              className={`w-full ${isDark ? "bg-gray-800 border-gray-700 hover:border-indigo-700" : "bg-white border-gray-100 hover:border-indigo-400"} rounded-2xl p-4 border shadow-sm transition-all text-left select-none`}
            >
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
            </button>
          ))}
        </div>
      </div>

      {/* Long-press Category Budget Alert Popup (Change #3) */}
      {longPressCategory && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={() => setLongPressCategory(null)}></div>
          <div className={`relative w-full max-w-sm ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"} border-2 rounded-3xl p-6 shadow-2xl`}>
            <button onClick={() => setLongPressCategory(null)} className={`absolute top-4 right-4 ${isDark ? "text-gray-400" : "text-gray-500"}`}>
              <X className="w-5 h-5" />
            </button>
            <div className="flex items-center gap-3 mb-4">
              <Bell className={`w-6 h-6 ${isDark ? "text-indigo-400" : "text-indigo-600"}`} />
              <div>
                <h3 className={`text-lg ${isDark ? "text-white" : "text-gray-900"}`}>Alerta de Presupuesto</h3>
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>{longPressCategory}</p>
              </div>
            </div>
            <p className={`text-sm mb-4 ${isDark ? "text-gray-300" : "text-gray-600"}`}>
              Configura un límite de gasto para esta categoría. Recibirás una alerta cuando lo superes.
            </p>
            <div className="relative mb-4">
              <DollarSign className={`absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type="number"
                step="0.01"
                value={categoryBudgetAmount}
                onChange={(e) => setCategoryBudgetAmount(e.target.value)}
                placeholder="Límite mensual..."
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-gray-50 border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-11 pr-4 rounded-xl focus:outline-none focus:border-indigo-500 transition-all text-lg`}
                autoFocus
              />
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setLongPressCategory(null)}
                className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all text-sm`}
              >
                Cancelar
              </button>
              <button
                onClick={handleSaveCategoryBudget}
                disabled={!categoryBudgetAmount}
                className={`flex-1 ${isDark ? "bg-indigo-700 hover:bg-indigo-600 disabled:bg-gray-700" : "bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300"} text-white py-3 rounded-xl transition-all text-sm disabled:cursor-not-allowed`}
              >
                Guardar Alerta
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Debts Progress Card (Change #5 — visual indicator) */}
      {debtsData.length > 0 && (
        <div className="mb-6">
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Progreso de Deudas 📊</h3>
          <div className={`${isDark ? "bg-gradient-to-br from-indigo-900/30 to-violet-900/30 border-indigo-800" : "bg-gradient-to-br from-indigo-50 to-violet-50 border-indigo-200"} border-2 rounded-2xl p-4`}>
            {/* Totals */}
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className={`text-xs ${isDark ? "text-indigo-300" : "text-indigo-700"}`}>Deuda Total Pendiente</p>
                <p className={`text-2xl font-bold ${isDark ? "text-indigo-400" : "text-indigo-600"}`}>
                  ${debtsData.reduce((sum, d) => sum + (d.totalInstallments - d.paidInstallments) * d.installmentAmount, 0).toLocaleString()}
                </p>
              </div>
              <div className="text-right">
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>Cuotas totales</p>
                <p className={`text-sm font-bold ${isDark ? "text-white" : "text-gray-900"}`}>
                  {debtsData.reduce((sum, d) => sum + d.paidInstallments, 0)} / {debtsData.reduce((sum, d) => sum + d.totalInstallments, 0)} pagadas
                </p>
              </div>
            </div>

            {/* Individual debts */}
            <div className="space-y-3">
              {debtsData.map((debt) => {
                const progress = (debt.paidInstallments / debt.totalInstallments) * 100;
                const remaining = (debt.totalInstallments - debt.paidInstallments) * debt.installmentAmount;
                const isFullyPaid = debt.paidInstallments >= debt.totalInstallments;
                return (
                  <div key={debt.id} className={`${isDark ? "bg-gray-800/60" : "bg-white/80"} rounded-xl p-3`}>
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <span className="text-lg">{debt.category}</span>
                        <span className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>{debt.name} {isFullyPaid && "✅"}</span>
                      </div>
                      <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>
                        ${debt.installmentAmount}/cuota
                      </span>
                    </div>
                    <div className={`${isDark ? "bg-gray-700" : "bg-gray-200"} rounded-full h-2 overflow-hidden mb-1`}>
                      <div
                        className={`h-full rounded-full transition-all ${progress >= 100 ? "bg-emerald-500" : progress >= 75 ? "bg-emerald-500" : progress >= 50 ? "bg-indigo-500" : "bg-amber-500"
                          }`}
                        style={{ width: `${Math.min(progress, 100)}%` }}
                      ></div>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className={`text-xs ${isFullyPaid ? (isDark ? "text-emerald-400" : "text-emerald-600") : (isDark ? "text-gray-500" : "text-gray-500")}`}>
                        {isFullyPaid ? "¡Pagado! 🎉" : `${debt.paidInstallments} de ${debt.totalInstallments} cuotas`}
                      </span>
                      {!isFullyPaid ? (
                        <button
                          onClick={() => {
                            setDebtsData(debtsData.map(d => d.id === debt.id ? { ...d, paidInstallments: d.paidInstallments + 1 } : d));
                            toast.success(`¡Cuota #${debt.paidInstallments + 1} registrada!`, { description: `${debt.name}: ${debt.paidInstallments + 1}/${debt.totalInstallments}` });
                          }}
                          className={`flex items-center gap-1 text-xs px-2.5 py-1 rounded-lg transition-all ${isDark ? "bg-emerald-900/50 text-emerald-400 hover:bg-emerald-800/60" : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"}`}
                        >
                          <ChevronUp className="w-3 h-3" />
                          +1 Cuota
                        </button>
                      ) : (
                        <span className={`text-xs font-medium ${isDark ? "text-emerald-400" : "text-emerald-600"}`}>
                          Completado
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

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

      {/* Extra spacing for FAB */}
      <div className="h-20"></div>

      {/* Voice FAB (Change #2 — Floating Action Button) */}
      <button
        onClick={handleVoiceInput}
        disabled={isListening}
        className={`fixed bottom-28 right-8 z-40 w-16 h-16 rounded-full flex items-center justify-center shadow-2xl transition-all hover:scale-110 active:scale-95 ${isListening
          ? "bg-red-500 hover:bg-red-600 animate-pulse"
          : isDark
            ? "bg-gradient-to-br from-indigo-600 to-emerald-500 hover:from-indigo-500 hover:to-emerald-400"
            : "bg-gradient-to-br from-indigo-600 to-emerald-500 hover:from-indigo-700 hover:to-emerald-600"
          }`}
        title="Agregar gasto por voz"
      >
        {isListening ? (
          <MicOff className="w-7 h-7 text-white" />
        ) : (
          <Mic className="w-7 h-7 text-white" />
        )}
      </button>

      {/* Modals */}
      {showMonthYearPicker && (
        <MonthYearPickerModal
          onClose={() => setShowMonthYearPicker(false)}
          onSelect={handleMonthYearSelect}
          currentMonth={currentMonthIndex}
          currentYear={currentYear}
        />
      )}
      {showFilterModal && (
        <ExpenseFilterModal
          onClose={() => setShowFilterModal(false)}
          onApply={handleApplyFilter}
        />
      )}
      {showAIChatModal && <AIChatModal onClose={() => setShowAIChatModal(false)} />}
      {showExpenseModal && <AddExpenseModal onClose={() => setShowExpenseModal(false)} />}
      {showBudgetAlertModal && <BudgetAlertModal onClose={() => setShowBudgetAlertModal(false)} />}
    </div>
  );
}