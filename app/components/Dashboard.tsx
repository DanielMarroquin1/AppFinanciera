import { TrendingDown, TrendingUp, Wallet, AlertCircle, Gift, Crown, TrendingUp as InvestIcon, Flame, X, Trophy, Calendar, Zap } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { AddIncomeModal } from "./AddIncomeModal";
import { AddExpenseModal } from "./AddExpenseModal";
import { AchievementsModal } from "./AchievementsModal";
import { AllTransactionsModal } from "./AllTransactionsModal";
import { InvestmentAssistantModal } from "./InvestmentAssistantModal";
import { RewardsShopModal } from "./RewardsShopModal";

export function Dashboard() {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [showIncomeModal, setShowIncomeModal] = useState(false);
  const [showExpenseModal, setShowExpenseModal] = useState(false);
  const [showAchievementsModal, setShowAchievementsModal] = useState(false);
  const [showAllTransactionsModal, setShowAllTransactionsModal] = useState(false);
  const [showInvestmentModal, setShowInvestmentModal] = useState(false);
  const [showRewardsShopModal, setShowRewardsShopModal] = useState(false);
  const [showStreakPopup, setShowStreakPopup] = useState(false);
  const isPremiumUser = false; // TODO: Get from auth context

  // ======= Streak System =======
  // Mock streak data (would come from localStorage/backend in production)
  const currentStreak = 5;
  const bestStreak = 12;
  const streakActive = currentStreak >= 3; // Streak starts after 3 consecutive days
  const weekDays = [
    { day: "L", active: true },
    { day: "M", active: true },
    { day: "X", active: true },
    { day: "J", active: true },
    { day: "V", active: true },
    { day: "S", active: false },
    { day: "D", active: false },
  ];
  const todayIndex = 4; // Friday (0-indexed)

  const motivationalMessages = [
    "¡Increíble! Estás en racha 🔥",
    "¡Sigue así! Cada día cuenta 💪",
    "¡Eres imparable! 🚀",
    "¡Tu disciplina es admirable! ⭐",
    "¡Vas por buen camino! 🎯",
  ];
  const motivationalMessage = motivationalMessages[currentStreak % motivationalMessages.length];

  // Mock data for unlocked badges
  const unlockedBadges = [
    { id: "first-save", emoji: "🎯", name: "Primer Ahorro" },
    { id: "week-streak", emoji: "🔥", name: "Racha Semanal" },
    { id: "budget-control", emoji: "✅", name: "Bajo Control" },
    { id: "profile-complete", emoji: "👤", name: "Perfil Completo" },
  ];

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Streak animation styles */}
      <style>{`
        @keyframes fireGlow {
          0%, 100% { filter: drop-shadow(0 0 4px #f97316) drop-shadow(0 0 8px #ef4444); transform: scale(1); }
          50% { filter: drop-shadow(0 0 8px #f97316) drop-shadow(0 0 16px #ef4444); transform: scale(1.1); }
        }
        @keyframes streakBounce {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-2px); }
        }
        @keyframes streakPulse {
          0%, 100% { box-shadow: 0 0 0 0 rgba(249, 115, 22, 0.4); }
          50% { box-shadow: 0 0 0 8px rgba(249, 115, 22, 0); }
        }
        .fire-animate { animation: fireGlow 2s ease-in-out infinite; }
        .streak-bounce { animation: streakBounce 1.5s ease-in-out infinite; }
        .streak-pulse { animation: streakPulse 2s ease-in-out infinite; }
      `}</style>

      {/* Header with Streak */}
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>¡Hola, María! 👋</h1>
          <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Aquí está tu resumen financiero</p>
        </div>

        {/* Streak Badge — Duolingo/TikTok Style */}
        <button
          onClick={() => setShowStreakPopup(true)}
          className={`relative flex items-center gap-1.5 px-3 py-2 rounded-2xl transition-all active:scale-95 ${streakActive
              ? isDark
                ? "bg-gradient-to-br from-orange-900/60 to-red-900/40 border-2 border-orange-700 streak-pulse"
                : "bg-gradient-to-br from-orange-50 to-red-50 border-2 border-orange-300 streak-pulse"
              : isDark
                ? "bg-gray-800 border-2 border-gray-700"
                : "bg-gray-100 border-2 border-gray-200"
            }`}
        >
          <div className={streakActive ? "fire-animate" : ""}>
            <Flame
              className={`w-6 h-6 ${streakActive
                  ? "text-orange-500 fill-orange-500"
                  : isDark
                    ? "text-gray-600"
                    : "text-gray-300"
                }`}
            />
          </div>
          <span
            className={`text-lg font-bold ${streakActive
                ? isDark
                  ? "text-orange-400"
                  : "text-orange-600"
                : isDark
                  ? "text-gray-500"
                  : "text-gray-400"
              } ${streakActive ? "streak-bounce" : ""}`}
          >
            {currentStreak}
          </span>
        </button>
      </div>

      {/* Streak Popup */}
      {showStreakPopup && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={() => setShowStreakPopup(false)}></div>
          <div className={`relative w-full max-w-sm ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"} border-2 rounded-3xl p-6 shadow-2xl`}>
            <button
              onClick={() => setShowStreakPopup(false)}
              className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
            >
              <X className="w-5 h-5" />
            </button>

            {/* Fire Header */}
            <div className="text-center mb-5">
              <div className={`w-20 h-20 mx-auto mb-3 rounded-3xl flex items-center justify-center ${isDark ? "bg-gradient-to-br from-orange-900/50 to-red-900/40" : "bg-gradient-to-br from-orange-100 to-red-100"}`}>
                <Flame className={`w-12 h-12 text-orange-500 fill-orange-500 ${streakActive ? "fire-animate" : ""}`} />
              </div>
              <h3 className={`text-3xl font-bold ${isDark ? "text-orange-400" : "text-orange-600"}`}>
                {currentStreak} días
              </h3>
              <p className={`text-sm mt-1 ${isDark ? "text-gray-400" : "text-gray-500"}`}>
                {streakActive ? motivationalMessage : "Usa la app 3 días seguidos para iniciar tu racha"}
              </p>
            </div>

            {/* Weekly Calendar */}
            <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4 mb-4`}>
              <div className="flex items-center justify-between mb-3">
                <span className={`text-xs font-medium ${isDark ? "text-gray-400" : "text-gray-500"}`}>Esta semana</span>
                <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-400"}`}>
                  {weekDays.filter(d => d.active).length}/7 días
                </span>
              </div>
              <div className="flex justify-between gap-1">
                {weekDays.map((day, i) => (
                  <div key={i} className="flex flex-col items-center gap-1.5">
                    <span className={`text-xs ${isDark ? "text-gray-500" : "text-gray-400"}`}>{day.day}</span>
                    <div
                      className={`w-9 h-9 rounded-xl flex items-center justify-center transition-all ${day.active
                          ? i === todayIndex
                            ? isDark
                              ? "bg-gradient-to-br from-orange-600 to-red-600 text-white shadow-lg shadow-orange-900/40"
                              : "bg-gradient-to-br from-orange-500 to-red-500 text-white shadow-lg shadow-orange-300"
                            : isDark
                              ? "bg-orange-900/40 text-orange-400"
                              : "bg-orange-100 text-orange-600"
                          : i <= todayIndex
                            ? isDark
                              ? "bg-gray-600 text-gray-500"
                              : "bg-gray-200 text-gray-400"
                            : isDark
                              ? "bg-gray-700 text-gray-600"
                              : "bg-gray-100 text-gray-300"
                        }`}
                    >
                      {day.active ? (
                        <Flame className="w-4 h-4 fill-current" />
                      ) : i <= todayIndex ? (
                        <X className="w-3.5 h-3.5" />
                      ) : (
                        <span className="text-xs">·</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3 text-center`}>
                <div className="flex items-center justify-center gap-1 mb-1">
                  <Zap className={`w-4 h-4 ${isDark ? "text-orange-400" : "text-orange-500"}`} />
                  <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>Actual</span>
                </div>
                <p className={`text-xl font-bold ${isDark ? "text-white" : "text-gray-900"}`}>{currentStreak}</p>
              </div>
              <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-xl p-3 text-center`}>
                <div className="flex items-center justify-center gap-1 mb-1">
                  <Trophy className={`w-4 h-4 ${isDark ? "text-amber-400" : "text-amber-500"}`} />
                  <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-500"}`}>Récord</span>
                </div>
                <p className={`text-xl font-bold ${isDark ? "text-white" : "text-gray-900"}`}>{bestStreak}</p>
              </div>
            </div>

            {/* Progress to next milestone */}
            <div className={`${isDark ? "bg-gradient-to-r from-orange-900/30 to-red-900/20 border-orange-800" : "bg-gradient-to-r from-orange-50 to-red-50 border-orange-200"} border-2 rounded-xl p-3`}>
              <div className="flex items-center justify-between mb-2">
                <span className={`text-xs ${isDark ? "text-orange-300" : "text-orange-700"}`}>Próximo hito: 7 días</span>
                <span className={`text-xs font-medium ${isDark ? "text-orange-400" : "text-orange-600"}`}>{currentStreak}/7</span>
              </div>
              <div className={`${isDark ? "bg-gray-700" : "bg-orange-200"} rounded-full h-2 overflow-hidden`}>
                <div
                  className="h-full rounded-full bg-gradient-to-r from-orange-500 to-red-500 transition-all"
                  style={{ width: `${Math.min((currentStreak / 7) * 100, 100)}%` }}
                ></div>
              </div>
              <p className={`text-xs mt-2 text-center ${isDark ? "text-gray-500" : "text-gray-400"}`}>
                ¡{7 - currentStreak > 0 ? `Te faltan ${7 - currentStreak} días!` : "¡Hito alcanzado! 🎉"}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Balance Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-indigo-900 to-emerald-800" : "bg-gradient-to-br from-indigo-700 to-emerald-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
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

      {/* Badges Section */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-3">
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"}`}>Insignias Desbloqueadas</h3>
          <button
            onClick={() => setShowAchievementsModal(true)}
            className={`text-xs ${isDark ? "text-indigo-400 hover:text-indigo-300" : "text-indigo-600 hover:text-indigo-700"} transition-colors`}
          >
            Ver todas
          </button>
        </div>
        <div className="flex gap-2 overflow-x-auto pb-2">
          {unlockedBadges.map((badge) => (
            <div
              key={badge.id}
              className={`flex-shrink-0 ${isDark ? "bg-gradient-to-br from-amber-900/30 to-orange-900/30 border-amber-700" : "bg-gradient-to-br from-amber-50 to-orange-50 border-amber-300"} border-2 rounded-2xl p-3 min-w-[80px] flex flex-col items-center gap-1`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-amber-900/50" : "bg-amber-100"} rounded-xl flex items-center justify-center text-xl`}>
                {badge.emoji}
              </div>
              <span className={`text-xs text-center ${isDark ? "text-amber-300" : "text-amber-900"}`}>
                {badge.name}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mb-6">
        <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Acciones Rápidas</h3>
        <div className="grid grid-cols-2 gap-3">
          <button className={`${isDark ? "bg-green-900/30 border-green-800 hover:bg-green-900/50" : "bg-green-50 border-green-200 hover:bg-green-100"} border-2 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all`} onClick={() => setShowIncomeModal(true)}>
            <TrendingUp className={`w-6 h-6 ${isDark ? "text-green-400" : "text-green-600"}`} />
            <span className={`text-xs ${isDark ? "text-green-200" : "text-green-900"}`}>Ingreso</span>
          </button>
          <button className={`${isDark ? "bg-red-900/30 border-red-800 hover:bg-red-900/50" : "bg-red-50 border-red-200 hover:bg-red-100"} border-2 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all`} onClick={() => setShowExpenseModal(true)}>
            <TrendingDown className={`w-6 h-6 ${isDark ? "text-red-400" : "text-red-600"}`} />
            <span className={`text-xs ${isDark ? "text-red-200" : "text-red-900"}`}>Gasto</span>
          </button>
        </div>
      </div>

      {/* Investment Assistant (Premium Feature) */}
      <button
        onClick={() => setShowInvestmentModal(true)}
        className={`w-full ${isDark ? "bg-gradient-to-br from-green-700 to-emerald-700 hover:from-green-600 hover:to-emerald-600" : "bg-gradient-to-br from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700"} rounded-3xl p-5 text-white mb-6 text-left transition-all shadow-lg hover:shadow-xl relative overflow-hidden`}
      >
        {/* Premium Badge */}
        <div className="absolute top-3 right-3 bg-amber-500 text-white text-xs px-2 py-1 rounded-full flex items-center gap-1">
          <Crown className="w-3 h-3" />
          PRO
        </div>

        <div className="flex items-start gap-4">
          <div className={`w-14 h-14 ${isDark ? "bg-white/20" : "bg-white/20"} rounded-2xl flex items-center justify-center backdrop-blur-sm flex-shrink-0`}>
            <InvestIcon className="w-7 h-7" />
          </div>
          <div className="flex-1">
            <h3 className="text-lg mb-1">Asistente de Inversión</h3>
            <p className="text-sm opacity-90">
              Descubre cómo invertir tu dinero basado en tu negocio 💰
            </p>
          </div>
        </div>
      </button>

      {/* Recent Transactions */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-3">
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"}`}>Transacciones Recientes</h3>
          <button
            onClick={() => setShowAllTransactionsModal(true)}
            className={`text-xs ${isDark ? "text-indigo-400 hover:text-indigo-300" : "text-indigo-600 hover:text-indigo-700"} transition-colors`}
          >
            Ver todas
          </button>
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
      <button
        onClick={() => setShowAchievementsModal(true)}
        className={`w-full ${isDark ? "bg-gradient-to-br from-amber-600 to-orange-700 hover:from-amber-500 hover:to-orange-600" : "bg-gradient-to-br from-amber-400 to-orange-500 hover:from-amber-500 hover:to-orange-600"} rounded-3xl p-5 text-white mb-6 text-left transition-all shadow-lg hover:shadow-xl`}
      >
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <Gift className="w-6 h-6" />
            <h3 className="text-lg">¡Logro Desbloqueado!</h3>
          </div>
          <span className="text-sm opacity-90">Ver todos →</span>
        </div>
        <p className="text-sm opacity-90 mb-3">
          Has ahorrado por 7 días consecutivos. ¡Sigue así! 🎉
        </p>
        <div className={`${isDark ? "bg-white/20" : "bg-white/20"} rounded-full h-2 overflow-hidden backdrop-blur-sm`}>
          <div className="bg-white h-full w-3/4"></div>
        </div>
        <p className="text-xs opacity-90 mt-2">75% para el próximo nivel</p>
      </button>

      {/* Modals */}
      {showIncomeModal && <AddIncomeModal onClose={() => setShowIncomeModal(false)} />}
      {showExpenseModal && <AddExpenseModal onClose={() => setShowExpenseModal(false)} />}
      {showAchievementsModal && (
        <AchievementsModal
          onClose={() => setShowAchievementsModal(false)}
          onOpenShop={() => setShowRewardsShopModal(true)}
        />
      )}
      {showAllTransactionsModal && <AllTransactionsModal onClose={() => setShowAllTransactionsModal(false)} />}
      {showInvestmentModal && <InvestmentAssistantModal onClose={() => setShowInvestmentModal(false)} isPremium={isPremiumUser} />}
      {showRewardsShopModal && <RewardsShopModal onClose={() => setShowRewardsShopModal(false)} userPoints={100} />}
    </div>
  );
}