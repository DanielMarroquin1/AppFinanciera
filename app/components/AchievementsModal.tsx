import { X, Trophy, Star, Target, TrendingUp, Zap, Award, Crown, Lock, ShoppingBag } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface AchievementsModalProps {
  onClose: () => void;
  onOpenShop?: () => void;
}

interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  progress: number;
  maxProgress: number;
  unlocked: boolean;
  points: number;
  category: "savings" | "expenses" | "streak" | "goals" | "special";
}

export function AchievementsModal({ onClose, onOpenShop }: AchievementsModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const achievements: Achievement[] = [
    // Unlocked achievements
    {
      id: "first-save",
      title: "Primer Ahorro",
      description: "Guardaste tu primer dinero",
      icon: "🎯",
      color: "green",
      progress: 1,
      maxProgress: 1,
      unlocked: true,
      points: 10,
      category: "savings",
    },
    {
      id: "week-streak",
      title: "Racha Semanal",
      description: "7 días registrando gastos",
      icon: "🔥",
      color: "orange",
      progress: 7,
      maxProgress: 7,
      unlocked: true,
      points: 25,
      category: "streak",
    },
    {
      id: "budget-control",
      title: "Bajo Control",
      description: "Un mes sin exceder presupuesto",
      icon: "✅",
      color: "blue",
      progress: 1,
      maxProgress: 1,
      unlocked: true,
      points: 50,
      category: "expenses",
    },
    {
      id: "profile-complete",
      title: "Perfil Completo",
      description: "Completaste toda tu información",
      icon: "👤",
      color: "purple",
      progress: 1,
      maxProgress: 1,
      unlocked: true,
      points: 15,
      category: "special",
    },
    // In progress
    {
      id: "first-goal",
      title: "Meta Alcanzada",
      description: "Completa tu primera meta de ahorro",
      icon: "🎊",
      color: "pink",
      progress: 750,
      maxProgress: 1000,
      unlocked: false,
      points: 100,
      category: "goals",
    },
    {
      id: "saver-1000",
      title: "Ahorrador $1,000",
      description: "Ahorra $1,000 en total",
      icon: "💰",
      color: "yellow",
      progress: 450,
      maxProgress: 1000,
      unlocked: false,
      points: 75,
      category: "savings",
    },
    {
      id: "month-streak",
      title: "Racha de 30 Días",
      description: "30 días consecutivos registrando",
      icon: "⚡",
      color: "orange",
      progress: 7,
      maxProgress: 30,
      unlocked: false,
      points: 150,
      category: "streak",
    },
    {
      id: "no-unnecessary",
      title: "Disciplinado",
      description: "30 días sin gastos innecesarios",
      icon: "🧘",
      color: "teal",
      progress: 12,
      maxProgress: 30,
      unlocked: false,
      points: 200,
      category: "expenses",
    },
    // Locked achievements
    {
      id: "saver-expert",
      title: "Ahorrador Experto",
      description: "Ahorra $10,000 en total",
      icon: "🏆",
      color: "gold",
      progress: 450,
      maxProgress: 10000,
      unlocked: false,
      points: 500,
      category: "savings",
    },
    {
      id: "investor",
      title: "Inversionista",
      description: "Empieza a invertir tu dinero",
      icon: "📈",
      color: "green",
      progress: 0,
      maxProgress: 1,
      unlocked: false,
      points: 300,
      category: "special",
    },
    {
      id: "master-budget",
      title: "Maestro del Presupuesto",
      description: "6 meses sin exceder presupuesto",
      icon: "👑",
      color: "purple",
      progress: 1,
      maxProgress: 6,
      unlocked: false,
      points: 1000,
      category: "expenses",
    },
    {
      id: "year-streak",
      title: "Año Completo",
      description: "365 días de racha",
      icon: "🎆",
      color: "rainbow",
      progress: 7,
      maxProgress: 365,
      unlocked: false,
      points: 2000,
      category: "streak",
    },
  ];

  const totalPoints = achievements.filter((a) => a.unlocked).reduce((sum, a) => sum + a.points, 0);
  const unlockedCount = achievements.filter((a) => a.unlocked).length;

  const getColorClasses = (color: string, unlocked: boolean) => {
    if (!unlocked) {
      return isDark
        ? "bg-gray-800 border-gray-700"
        : "bg-gray-100 border-gray-300";
    }
    
    const colors: Record<string, string> = {
      green: isDark ? "bg-green-900/30 border-green-700" : "bg-green-100 border-green-400",
      orange: isDark ? "bg-orange-900/30 border-orange-700" : "bg-orange-100 border-orange-400",
      blue: isDark ? "bg-blue-900/30 border-blue-700" : "bg-blue-100 border-blue-400",
      purple: isDark ? "bg-purple-900/30 border-purple-700" : "bg-purple-100 border-purple-400",
      pink: isDark ? "bg-pink-900/30 border-pink-700" : "bg-pink-100 border-pink-400",
      yellow: isDark ? "bg-yellow-900/30 border-yellow-700" : "bg-yellow-100 border-yellow-400",
      teal: isDark ? "bg-teal-900/30 border-teal-700" : "bg-teal-100 border-teal-400",
      gold: isDark ? "bg-amber-900/30 border-amber-700" : "bg-amber-100 border-amber-400",
      rainbow: isDark ? "bg-gradient-to-r from-purple-900/30 to-pink-900/30 border-purple-700" : "bg-gradient-to-r from-purple-100 to-pink-100 border-purple-400",
    };
    return colors[color] || colors.blue;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-900" : "bg-white"
        } rounded-t-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-3">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Trophy className="w-7 h-7" />
              </div>
              <div>
                <h2 className="text-2xl">Logros</h2>
                <p className="text-sm text-white/90">{unlockedCount} de {achievements.length} desbloqueados</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Stats */}
          <div className="flex gap-3">
            <div className="flex-1 bg-white/20 rounded-xl p-3 backdrop-blur-sm">
              <div className="flex items-center gap-2 mb-1">
                <Star className="w-4 h-4" />
                <p className="text-xs text-white/90">Puntos</p>
              </div>
              <p className="text-xl font-bold">{totalPoints}</p>
            </div>
            <div className="flex-1 bg-white/20 rounded-xl p-3 backdrop-blur-sm">
              <div className="flex items-center gap-2 mb-1">
                <Award className="w-4 h-4" />
                <p className="text-xs text-white/90">Nivel</p>
              </div>
              <p className="text-xl font-bold">{Math.floor(totalPoints / 100)}</p>
            </div>
          </div>
        </div>

        {/* Achievements List */}
        <div className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 200px)" }}>
          <div className="space-y-3">
            {achievements.map((achievement) => (
              <div
                key={achievement.id}
                className={`${getColorClasses(achievement.color, achievement.unlocked)} border-2 rounded-2xl p-4 transition-all ${achievement.unlocked ? "shadow-sm" : "opacity-60"}`}
              >
                <div className="flex items-start gap-4">
                  {/* Icon */}
                  <div className="relative flex-shrink-0">
                    <div className={`w-14 h-14 ${achievement.unlocked ? (isDark ? "bg-white/10" : "bg-white/50") : (isDark ? "bg-gray-700" : "bg-gray-300")} rounded-2xl flex items-center justify-center text-2xl`}>
                      {achievement.unlocked ? achievement.icon : <Lock className={`w-6 h-6 ${isDark ? "text-gray-600" : "text-gray-400"}`} />}
                    </div>
                    {achievement.unlocked && (
                      <div className="absolute -top-1 -right-1 w-5 h-5 bg-green-500 rounded-full flex items-center justify-center border-2 border-white">
                        <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                    )}
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-1">
                      <h3 className={`text-sm font-semibold ${achievement.unlocked ? (isDark ? "text-white" : "text-gray-900") : (isDark ? "text-gray-500" : "text-gray-600")}`}>
                        {achievement.title}
                      </h3>
                      <div className={`text-xs px-2 py-0.5 rounded-full ${achievement.unlocked ? (isDark ? "bg-amber-900 text-amber-300" : "bg-amber-200 text-amber-800") : (isDark ? "bg-gray-800 text-gray-600" : "bg-gray-200 text-gray-500")}`}>
                        {achievement.points} pts
                      </div>
                    </div>
                    <p className={`text-xs mb-2 ${achievement.unlocked ? (isDark ? "text-gray-400" : "text-gray-600") : (isDark ? "text-gray-600" : "text-gray-500")}`}>
                      {achievement.description}
                    </p>

                    {/* Progress Bar */}
                    {!achievement.unlocked && (
                      <div>
                        <div className={`${isDark ? "bg-gray-700" : "bg-gray-200"} rounded-full h-2 overflow-hidden mb-1`}>
                          <div
                            className={`${achievement.color === "rainbow" ? "bg-gradient-to-r from-purple-500 to-pink-500" : "bg-current"} h-full transition-all`}
                            style={{
                              width: `${(achievement.progress / achievement.maxProgress) * 100}%`,
                              color: achievement.unlocked ? "#10b981" : "#9ca3af",
                            }}
                          ></div>
                        </div>
                        <p className={`text-xs ${isDark ? "text-gray-600" : "text-gray-500"}`}>
                          {achievement.maxProgress <= 10
                            ? `${achievement.progress} / ${achievement.maxProgress}`
                            : `${Math.round((achievement.progress / achievement.maxProgress) * 100)}%`}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} border-t px-6 py-4`}>
          {onOpenShop && (
            <button
              onClick={() => {
                onClose();
                onOpenShop();
              }}
              className={`w-full mb-3 ${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700 hover:from-amber-500 hover:to-orange-600" : "bg-gradient-to-r from-amber-400 to-orange-500 hover:from-amber-500 hover:to-orange-600"} text-white py-3 rounded-xl transition-all font-medium flex items-center justify-center gap-2`}
            >
              <ShoppingBag className="w-5 h-5" />
              Ir a la Tienda ({totalPoints} pts)
            </button>
          )}
          <p className={`text-xs text-center ${isDark ? "text-gray-500" : "text-gray-500"}`}>
            ¡Completa más desafíos para desbloquear todos los logros! 🎯
          </p>
        </div>
      </div>
    </div>
  );
}