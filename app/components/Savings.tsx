import { TrendingUp, Plus, Sparkles, Crown } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { AddSavingsGoalModal } from "./AddSavingsGoalModal";
import { AIChatModal } from "./AIChatModal";
import { SavingsGuideModal } from "./SavingsGuideModal";
import { AddFundsModal } from "./AddFundsModal";

const savingsGoals = [
  {
    id: 1,
    name: "Vacaciones en Cancún",
    icon: "✈️",
    current: 2500,
    goal: 5000,
    color: "from-blue-500 to-cyan-500",
  },
  {
    id: 2,
    name: "Fondo de Emergencia",
    icon: "🏥",
    current: 8500,
    goal: 10000,
    color: "from-green-500 to-emerald-500",
  },
  {
    id: 3,
    name: "Nueva Laptop",
    icon: "💻",
    current: 1200,
    goal: 2500,
    color: "from-purple-500 to-pink-500",
  },
  {
    id: 4,
    name: "Auto Nuevo",
    icon: "🚗",
    current: 15000,
    goal: 50000,
    color: "from-orange-500 to-red-500",
  },
];

export function Savings() {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [showAddGoalModal, setShowAddGoalModal] = useState(false);
  const [showAIChatModal, setShowAIChatModal] = useState(false);
  const [showGuideModal, setShowGuideModal] = useState(false);
  const [showAddFundsModal, setShowAddFundsModal] = useState(false);
  const [selectedGoal, setSelectedGoal] = useState<typeof savingsGoals[0] | null>(null);
  const [goals, setGoals] = useState(savingsGoals);

  const handleAddFunds = (goalId: number, amount: number) => {
    setGoals((prevGoals) =>
      prevGoals.map((goal) =>
        goal.id === goalId
          ? { ...goal, current: Math.min(goal.current + amount, goal.goal) }
          : goal
      )
    );
  };

  const handleOpenAddFunds = (goal: typeof savingsGoals[0]) => {
    setSelectedGoal(goal);
    setShowAddFundsModal(true);
  };

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Mis Ahorros 🎯</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Alcanza tus metas financieras</p>
      </div>

      {/* Total Savings */}
      <div className={`${isDark ? "bg-gradient-to-br from-green-800 to-emerald-900" : "bg-gradient-to-br from-green-600 to-emerald-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <p className="text-sm opacity-90 mb-2">Total Ahorrado</p>
        <h2 className="text-4xl mb-4">$27,200.00</h2>
        <div className="flex items-center gap-2">
          <TrendingUp className="w-5 h-5" />
          <p className="text-sm opacity-90">+12% este mes</p>
        </div>
      </div>

      {/* Savings Guide Banner */}
      <div className={`${isDark ? "bg-gradient-to-r from-purple-900/40 to-blue-900/40 border-purple-800" : "bg-gradient-to-r from-purple-100 to-blue-100 border-purple-200"} rounded-2xl p-4 mb-6 border-2`}>
        <div className="flex items-center gap-3 mb-2">
          <span className="text-2xl">📚</span>
          <h3 className={`text-sm flex items-center gap-2 ${isDark ? "text-white" : ""}`}>
            Plan de Ahorro con Guía
            <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
              <Crown className="w-3 h-3" />
              PRO
            </div>
          </h3>
        </div>
        <p className={`text-xs ${isDark ? "text-gray-300" : "text-gray-700"} mb-3`}>
          Descubre cómo ahorrar más y alcanzar tus metas más rápido
        </p>
        <button 
          onClick={() => setShowGuideModal(true)}
          className={`${isDark ? "bg-purple-700 hover:bg-purple-800" : "bg-purple-600 hover:bg-purple-700"} text-white text-xs px-4 py-2 rounded-xl transition-all`}
        >
          Ver Guía
        </button>
      </div>

      {/* Add New Goal Button */}
      <button className={`w-full ${isDark ? "bg-gray-800 border-gray-700 hover:border-purple-700 text-gray-400 hover:text-purple-400" : "bg-white border-gray-300 hover:border-purple-400 text-gray-500 hover:text-purple-600"} border-2 border-dashed rounded-2xl p-4 mb-6 flex items-center justify-center gap-2 transition-all`} onClick={() => setShowAddGoalModal(true)}>
        <Plus className="w-5 h-5" />
        <span className="text-sm">Agregar Nueva Meta</span>
      </button>

      {/* Savings Goals */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Mis Metas de Ahorro</h3>
        <div className="space-y-4">
          {goals.map((goal) => {
            const percentage = (goal.current / goal.goal) * 100;
            const isComplete = percentage >= 100;

            return (
              <div key={goal.id} className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-3xl p-5 border shadow-sm`}>
                <div className="flex items-start gap-4 mb-4">
                  <div className={`w-14 h-14 bg-gradient-to-br ${goal.color} rounded-2xl flex items-center justify-center text-2xl`}>
                    {goal.icon}
                  </div>
                  <div className="flex-1">
                    <h4 className={`text-sm mb-1 ${isDark ? "text-white" : ""}`}>{goal.name}</h4>
                    <div className="flex items-baseline gap-2">
                      <span className={`text-lg ${isDark ? "text-white" : ""}`}>${goal.current.toLocaleString()}</span>
                      <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>de ${goal.goal.toLocaleString()}</span>
                    </div>
                  </div>
                  {isComplete && (
                    <div className={`${isDark ? "bg-green-900 text-green-300" : "bg-green-100 text-green-700"} text-xs px-3 py-1 rounded-full`}>
                      ¡Logrado!
                    </div>
                  )}
                </div>

                {/* Progress Bar */}
                <div className={`${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-full h-3 overflow-hidden mb-2`}>
                  <div
                    className={`bg-gradient-to-r ${goal.color} h-full transition-all rounded-full`}
                    style={{ width: `${Math.min(percentage, 100)}%` }}
                  ></div>
                </div>
                <div className="flex items-center justify-between">
                  <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{percentage.toFixed(0)}% completado</span>
                  <button 
                    onClick={() => handleOpenAddFunds(goal)}
                    className={`text-xs ${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"}`}
                  >
                    Agregar fondos
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Savings Tips */}
      <div className={`${isDark ? "bg-amber-900/30 border-amber-800" : "bg-amber-50 border-amber-200"} rounded-2xl p-5 border-2`}>
        <div className="flex items-center gap-2 mb-3">
          <span className="text-xl">💡</span>
          <h3 className={`text-sm ${isDark ? "text-white" : ""}`}>Consejo del día</h3>
        </div>
        <p className={`text-xs ${isDark ? "text-gray-300" : "text-gray-700"}`}>
          Ahorra el 20% de tus ingresos cada mes. Pequeños cambios hacen grandes diferencias.
        </p>
      </div>

      {/* Floating AI Assistant Button */}
      <button
        onClick={() => setShowAIChatModal(true)}
        className={`fixed bottom-20 right-6 w-14 h-14 ${isDark ? "bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500" : "bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600"} text-white rounded-full shadow-lg hover:shadow-xl transition-all flex items-center justify-center z-40 animate-pulse hover:animate-none`}
      >
        <Sparkles className="w-6 h-6" />
      </button>

      {/* Modals */}
      {showAddGoalModal && <AddSavingsGoalModal onClose={() => setShowAddGoalModal(false)} />}
      {showAIChatModal && <AIChatModal onClose={() => setShowAIChatModal(false)} />}
      {showGuideModal && <SavingsGuideModal onClose={() => setShowGuideModal(false)} />}
      {showAddFundsModal && selectedGoal && (
        <AddFundsModal
          onClose={() => {
            setShowAddFundsModal(false);
            setSelectedGoal(null);
          }}
          goal={selectedGoal}
          onAddFunds={handleAddFunds}
        />
      )}
    </div>
  );
}