import { useState } from "react";
import { Home, TrendingUp, Target, BarChart3, Settings, Plus } from "lucide-react";
import { Dashboard } from "./components/Dashboard";
import { Expenses } from "./components/Expenses";
import { Savings } from "./components/Savings";
import { Statistics } from "./components/Statistics";
import { SettingsPanel } from "./components/SettingsPanel";
import { Login } from "./components/Login";
import { OnboardingTour } from "./components/OnboardingTour";
import { QuickActionsMenu } from "./components/QuickActionsMenu";
import { AddIncomeModal } from "./components/AddIncomeModal";
import { AddExpenseModal } from "./components/AddExpenseModal";
import { AddSavingsGoalModal } from "./components/AddSavingsGoalModal";
import { AIChatModal } from "./components/AIChatModal";
import { RewardsShopModal } from "./components/RewardsShopModal";
import { ThemeProvider, useTheme } from "./context/ThemeContext";
import { AuthProvider, useAuth } from "./context/AuthContext";
import { Toaster } from "sonner";

type Screen = "dashboard" | "expenses" | "savings" | "statistics" | "settings";

function AppContent() {
  const [currentScreen, setCurrentScreen] = useState<Screen>("dashboard");
  const [showQuickActionsMenu, setShowQuickActionsMenu] = useState(false);
  const [showIncomeModal, setShowIncomeModal] = useState(false);
  const [showExpenseModal, setShowExpenseModal] = useState(false);
  const [showSavingsGoalModal, setShowSavingsGoalModal] = useState(false);
  const [showAIChatModal, setShowAIChatModal] = useState(false);
  const [showRewardsShopModal, setShowRewardsShopModal] = useState(false);
  const { theme } = useTheme();
  const { isAuthenticated, user } = useAuth();

  const handleQuickAction = (action: "income" | "expense" | "savings-goal" | "fixed-expense" | "ai-chat" | "rewards-shop") => {
    switch (action) {
      case "income":
        setShowIncomeModal(true);
        break;
      case "expense":
        setShowExpenseModal(true);
        break;
      case "savings-goal":
        setShowSavingsGoalModal(true);
        break;
      case "fixed-expense":
        // Este abrirá el edit profile modal con los gastos fijos
        setShowExpenseModal(true);
        break;
      case "ai-chat":
        setShowAIChatModal(true);
        break;
      case "rewards-shop":
        setShowRewardsShopModal(true);
        break;
    }
  };

  // If not authenticated, show login
  if (!isAuthenticated) {
    return (
      <div className={`h-screen w-full ${theme === "dark" ? "bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900" : "bg-gradient-to-br from-slate-50 to-indigo-50"} flex items-center justify-center p-4`}>
        {/* Phone Frame */}
        <div className={`w-full max-w-md h-[800px] ${theme === "dark" ? "bg-gray-900" : "bg-white"} rounded-[3rem] shadow-2xl overflow-hidden flex flex-col border-8 ${theme === "dark" ? "border-gray-950" : "border-gray-800"}`}>
          {/* Status Bar */}
          <div className={`${theme === "dark" ? "bg-gradient-to-r from-indigo-950 to-emerald-900" : "bg-gradient-to-r from-indigo-600 to-emerald-500"} px-6 py-3 flex items-center justify-between text-white text-xs`}>
            <span>9:41</span>
            <div className="flex gap-1">
              <div className="w-4 h-3 bg-white/30 rounded-sm"></div>
              <div className="w-4 h-3 bg-white/50 rounded-sm"></div>
              <div className="w-4 h-3 bg-white/70 rounded-sm"></div>
              <div className="w-4 h-3 bg-white rounded-sm"></div>
            </div>
          </div>

          {/* Content Area */}
          <div className="flex-1 overflow-y-auto">
            <Login />
          </div>
        </div>
      </div>
    );
  }

  const renderScreen = () => {
    switch (currentScreen) {
      case "dashboard":
        return <Dashboard />;
      case "expenses":
        return <Expenses />;
      case "savings":
        return <Savings />;
      case "statistics":
        return <Statistics />;
      case "settings":
        return <SettingsPanel />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className={`h-screen w-full ${theme === "dark" ? "bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900" : "bg-gradient-to-br from-purple-50 to-blue-50"} flex items-center justify-center p-4`}>
      {/* Phone Frame */}
      <div className={`w-full max-w-md h-[800px] ${theme === "dark" ? "bg-gray-900" : "bg-white"} rounded-[3rem] shadow-2xl overflow-hidden flex flex-col border-8 ${theme === "dark" ? "border-gray-950" : "border-gray-800"}`}>
        {/* Status Bar */}
        <div className={`${theme === "dark" ? "bg-gradient-to-r from-purple-900 to-blue-900" : "bg-gradient-to-r from-purple-600 to-blue-600"} px-6 py-3 flex items-center justify-between text-white text-xs`}>
          <span>9:41</span>
          <div className="flex gap-1">
            <div className="w-4 h-3 bg-white/30 rounded-sm"></div>
            <div className="w-4 h-3 bg-white/50 rounded-sm"></div>
            <div className="w-4 h-3 bg-white/70 rounded-sm"></div>
            <div className="w-4 h-3 bg-white rounded-sm"></div>
          </div>
        </div>

        {/* Content Area */}
        <div className="flex-1 overflow-y-auto">
          {renderScreen()}
        </div>

        {/* Bottom Navigation */}
        <div className={`${theme === "dark" ? "bg-gray-900 border-gray-800" : "bg-white border-gray-100"} border-t px-4 py-3 flex items-center justify-around shadow-lg`}>
          <button
            onClick={() => setCurrentScreen("dashboard")}
            className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-all ${currentScreen === "dashboard"
                ? "text-indigo-600"
                : theme === "dark" ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"
              }`}
          >
            <Home className="w-6 h-6" />
            <span className="text-xs">Inicio</span>
          </button>

          <button
            onClick={() => setCurrentScreen("expenses")}
            className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-all ${currentScreen === "expenses"
                ? "text-indigo-600"
                : theme === "dark" ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"
              }`}
          >
            <TrendingUp className="w-6 h-6" />
            <span className="text-xs">Gastos</span>
          </button>

          <button
            className="flex flex-col items-center gap-1 p-2 -mt-8"
            onClick={() => setShowQuickActionsMenu(true)}
          >
            <div className={`w-14 h-14 ${theme === "dark" ? "bg-gradient-to-r from-indigo-700 to-emerald-600 hover:from-indigo-600 hover:to-emerald-500" : "bg-gradient-to-r from-indigo-600 to-emerald-500 hover:from-indigo-700 hover:to-emerald-600"} rounded-full flex items-center justify-center shadow-lg hover:shadow-xl transition-all cursor-pointer`}>
              <Plus className="w-7 h-7 text-white" />
            </div>
          </button>

          <button
            onClick={() => setCurrentScreen("savings")}
            className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-all ${currentScreen === "savings"
                ? "text-indigo-600"
                : theme === "dark" ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"
              }`}
          >
            <Target className="w-6 h-6" />
            <span className="text-xs">Ahorros</span>
          </button>

          <button
            onClick={() => setCurrentScreen("settings")}
            className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-all ${currentScreen === "settings"
                ? "text-indigo-600"
                : theme === "dark" ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"
              }`}
          >
            <Settings className="w-6 h-6" />
            <span className="text-xs">Ajustes</span>
          </button>
        </div>
      </div>

      {/* Onboarding Tour - Show if user hasn't completed it */}
      {user && !user.hasCompletedTour && <OnboardingTour />}

      {/* Quick Actions Menu */}
      {showQuickActionsMenu && (
        <QuickActionsMenu
          onClose={() => setShowQuickActionsMenu(false)}
          onSelectAction={handleQuickAction}
        />
      )}

      {/* Modals */}
      {showIncomeModal && <AddIncomeModal onClose={() => setShowIncomeModal(false)} />}
      {showExpenseModal && <AddExpenseModal onClose={() => setShowExpenseModal(false)} />}
      {showSavingsGoalModal && <AddSavingsGoalModal onClose={() => setShowSavingsGoalModal(false)} />}
      {showAIChatModal && <AIChatModal onClose={() => setShowAIChatModal(false)} />}
      {showRewardsShopModal && <RewardsShopModal onClose={() => setShowRewardsShopModal(false)} userPoints={100} />}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <ThemeProvider>
        <AppContent />
        <Toaster position="top-center" richColors />
      </ThemeProvider>
    </AuthProvider>
  );
}