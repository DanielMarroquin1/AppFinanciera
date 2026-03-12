import { X, User, Mail, DollarSign, Trash2, Plus, Check, Crown, Lock, ChevronRight, CreditCard, Hash, Pencil, ChevronUp } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useAuth } from "../context/AuthContext";
import { useState } from "react";
import { toast } from "sonner";
import { AvatarSelectorModal } from "./AvatarSelectorModal";

interface EditProfileModalProps {
  onClose: () => void;
}

interface FixedExpense {
  id: string;
  name: string;
  amount: string;
  category: string;
}

interface Debt {
  id: string;
  name: string;
  installmentAmount: string;
  totalInstallments: string;
  paidInstallments: string;
  category: string;
}

interface Avatar {
  emoji: string;
  isPremium: boolean;
}

const avatars: Avatar[] = [
  { emoji: "👤", isPremium: false },
  { emoji: "👨", isPremium: false },
  { emoji: "👩", isPremium: false },
  { emoji: "🧑", isPremium: false },
  { emoji: "😊", isPremium: false },
  { emoji: "👴", isPremium: true },
  { emoji: "👵", isPremium: true },
  { emoji: "👨‍💼", isPremium: true },
  { emoji: "👩‍💼", isPremium: true },
  { emoji: "👨‍🎓", isPremium: true },
  { emoji: "👩‍🎓", isPremium: true },
  { emoji: "👨‍⚕️", isPremium: true },
  { emoji: "👩‍⚕️", isPremium: true },
  { emoji: "👨‍🔧", isPremium: true },
  { emoji: "👩‍🔧", isPremium: true },
  { emoji: "👨‍🍳", isPremium: true },
  { emoji: "👩‍🍳", isPremium: true },
  { emoji: "🦸‍♂️", isPremium: true },
  { emoji: "🦸‍♀️", isPremium: true },
  { emoji: "🧙‍♂️", isPremium: true },
  { emoji: "🧙‍♀️", isPremium: true },
  { emoji: "🧝‍♂️", isPremium: true },
  { emoji: "🧝‍♀️", isPremium: true },
  { emoji: "🧚‍♂️", isPremium: true },
  { emoji: "🧚‍♀️", isPremium: true },
  { emoji: "🐶", isPremium: true },
  { emoji: "🐱", isPremium: true },
  { emoji: "🐭", isPremium: true },
  { emoji: "🐹", isPremium: true },
  { emoji: "🐰", isPremium: true },
  { emoji: "🦊", isPremium: true },
  { emoji: "🐻", isPremium: true },
  { emoji: "🐼", isPremium: true },
  { emoji: "🐨", isPremium: true },
  { emoji: "🐯", isPremium: true },
  { emoji: "🦁", isPremium: true },
];

export function EditProfileModal({ onClose }: EditProfileModalProps) {
  const { theme } = useTheme();
  const { user, updateProfile } = useAuth();
  const isDark = theme === "dark";
  const isPremiumUser = false;

  const [name, setName] = useState(user?.name || "");
  const [email, setEmail] = useState(user?.email || "");
  const [selectedAvatar, setSelectedAvatar] = useState("👤");
  const [showAvatarSelector, setShowAvatarSelector] = useState(false);

  // Active section tab: "expenses" or "debts"
  const [activeSection, setActiveSection] = useState<"expenses" | "debts">("expenses");

  // Section A: Fixed expenses
  const [fixedExpenses, setFixedExpenses] = useState<FixedExpense[]>([
    { id: "1", name: "Renta", amount: "5000", category: "🏠" },
    { id: "2", name: "Internet", amount: "500", category: "📱" },
  ]);
  const [newExpenseName, setNewExpenseName] = useState("");
  const [newExpenseAmount, setNewExpenseAmount] = useState("");
  const [newExpenseCategory, setNewExpenseCategory] = useState("🏠");

  // Section B: Debts
  const [debts, setDebts] = useState<Debt[]>([
    { id: "1", name: "Laptop", installmentAmount: "1500", totalInstallments: "12", paidInstallments: "5", category: "💻" },
    { id: "2", name: "Préstamo Personal", installmentAmount: "3000", totalInstallments: "24", paidInstallments: "8", category: "🏦" },
  ]);
  const [newDebtName, setNewDebtName] = useState("");
  const [newDebtInstallment, setNewDebtInstallment] = useState("");
  const [newDebtTotal, setNewDebtTotal] = useState("");
  const [newDebtPaid, setNewDebtPaid] = useState("");
  const [newDebtCategory, setNewDebtCategory] = useState("🏦");
  const [editingDebtId, setEditingDebtId] = useState<string | null>(null);
  const [confirmAdvanceId, setConfirmAdvanceId] = useState<string | null>(null);

  const categories = [
    { emoji: "🏠", label: "Vivienda" },
    { emoji: "📱", label: "Servicios" },
    { emoji: "🚗", label: "Transporte" },
    { emoji: "🍔", label: "Comida" },
    { emoji: "💊", label: "Salud" },
    { emoji: "📚", label: "Educación" },
    { emoji: "🎮", label: "Suscripciones" },
    { emoji: "💸", label: "Otro" },
  ];

  const debtCategories = [
    { emoji: "🏦", label: "Banco" },
    { emoji: "💳", label: "Tarjeta" },
    { emoji: "🏠", label: "Hipoteca" },
    { emoji: "🚗", label: "Vehículo" },
    { emoji: "💻", label: "Electrónica" },
    { emoji: "📱", label: "Dispositivo" },
    { emoji: "📚", label: "Educación" },
    { emoji: "💸", label: "Otro" },
  ];

  const handleAddExpense = () => {
    if (newExpenseName && newExpenseAmount) {
      setFixedExpenses([
        ...fixedExpenses,
        {
          id: Date.now().toString(),
          name: newExpenseName,
          amount: newExpenseAmount,
          category: newExpenseCategory,
        },
      ]);
      setNewExpenseName("");
      setNewExpenseAmount("");
      setNewExpenseCategory("🏠");
    }
  };

  const handleDeleteExpense = (id: string) => {
    setFixedExpenses(fixedExpenses.filter((expense) => expense.id !== id));
  };

  const handleAddDebt = () => {
    if (newDebtName && newDebtInstallment && newDebtTotal) {
      setDebts([
        ...debts,
        {
          id: Date.now().toString(),
          name: newDebtName,
          installmentAmount: newDebtInstallment,
          totalInstallments: newDebtTotal,
          paidInstallments: newDebtPaid || "0",
          category: newDebtCategory,
        },
      ]);
      setNewDebtName("");
      setNewDebtInstallment("");
      setNewDebtTotal("");
      setNewDebtPaid("");
      setNewDebtCategory("🏦");
      toast.success("Deuda agregada correctamente");
    }
  };

  const handleDeleteDebt = (id: string) => {
    setDebts(debts.filter((debt) => debt.id !== id));
  };

  const handleAdvancePayment = (id: string) => {
    setDebts(debts.map((debt) => {
      if (debt.id === id) {
        const paid = parseFloat(debt.paidInstallments || "0");
        const total = parseFloat(debt.totalInstallments || "0");
        if (paid < total) {
          const newPaid = (paid + 1).toString();
          toast.success(`¡Cuota #${paid + 1} registrada! 🎉`, {
            description: `${debt.name}: ${newPaid}/${debt.totalInstallments} cuotas pagadas`,
          });
          return { ...debt, paidInstallments: newPaid };
        } else {
          toast.info("¡Esta deuda ya está completamente pagada! 🎊");
        }
      }
      return debt;
    }));
    setConfirmAdvanceId(null);
  };

  const handleEditDebt = (id: string, field: keyof Debt, value: string) => {
    setDebts(debts.map((debt) => debt.id === id ? { ...debt, [field]: value } : debt));
  };

  const handleSave = () => {
    updateProfile({ name, email });
    console.log("Fixed expenses:", fixedExpenses);
    console.log("Debts:", debts);
    console.log("Selected avatar:", selectedAvatar);
    toast.success("Perfil actualizado correctamente");
    onClose();
  };

  const totalFixed = fixedExpenses.reduce((sum, exp) => sum + parseFloat(exp.amount || "0"), 0);
  const totalDebtPending = debts.reduce(
    (sum, d) => sum + (parseFloat(d.totalInstallments || "0") - parseFloat(d.paidInstallments || "0")) * parseFloat(d.installmentAmount || "0"),
    0
  );

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
        <div className={`${isDark ? "bg-gradient-to-r from-indigo-800 to-emerald-700" : "bg-gradient-to-r from-indigo-600 to-emerald-500"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <User className="w-6 h-6" />
              </div>
              <h2 className="text-2xl">Editar Perfil</h2>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
          <p className="text-sm text-white/90">Actualiza tu información personal</p>
        </div>

        {/* Form */}
        <div className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 120px)" }}>
          {/* Avatar Selection */}
          <div className="mb-6">
            <h3 className={`text-sm mb-3 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Avatar 🎭
            </h3>

            <button
              onClick={() => setShowAvatarSelector(true)}
              className={`w-full ${isDark ? "bg-gray-700 hover:bg-gray-650 border-gray-600" : "bg-white hover:bg-gray-50 border-gray-200"} border-2 rounded-2xl p-4 transition-all`}
            >
              <div className="flex items-center gap-4">
                <div className={`w-16 h-16 ${isDark ? "bg-gradient-to-br from-indigo-900 to-emerald-900" : "bg-gradient-to-br from-indigo-100 to-emerald-100"} rounded-2xl flex items-center justify-center text-4xl`}>
                  {selectedAvatar}
                </div>
                <div className="flex-1 text-left">
                  <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                    Cambiar Avatar
                  </p>
                  <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                    Toca para ver todos los avatares disponibles
                  </p>
                </div>
                <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              </div>
            </button>
          </div>

          {showAvatarSelector && (
            <AvatarSelectorModal
              onClose={() => setShowAvatarSelector(false)}
              onSelect={setSelectedAvatar}
              currentAvatar={selectedAvatar}
              isPremiumUser={isPremiumUser}
            />
          )}

          {/* Personal Info */}
          <div className="mb-6">
            <h3 className={`text-sm mb-3 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Información Personal
            </h3>

            <div className="space-y-4">
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Nombre
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-indigo-500 transition-all`}
                />
              </div>

              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Correo Electrónico
                </label>
                <div className="relative">
                  <Mail className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-indigo-500 transition-all`}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* ===== Section A & B Tabs (Change #5) ===== */}
          <div className="mb-4">
            <h3 className={`text-sm mb-3 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Gastos Fijos y Deudas 💰
            </h3>

            {/* Tab Switcher */}
            <div className={`${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-2xl p-1 flex mb-4`}>
              <button
                onClick={() => setActiveSection("expenses")}
                className={`flex-1 py-2.5 rounded-xl text-sm transition-all ${activeSection === "expenses"
                  ? isDark
                    ? "bg-indigo-700 text-white shadow-lg"
                    : "bg-white text-indigo-700 shadow-md"
                  : isDark
                    ? "text-gray-400 hover:text-gray-300"
                    : "text-gray-500 hover:text-gray-700"
                  }`}
              >
                📋 Gastos Fijos
              </button>
              <button
                onClick={() => setActiveSection("debts")}
                className={`flex-1 py-2.5 rounded-xl text-sm transition-all ${activeSection === "debts"
                  ? isDark
                    ? "bg-indigo-700 text-white shadow-lg"
                    : "bg-white text-indigo-700 shadow-md"
                  : isDark
                    ? "text-gray-400 hover:text-gray-300"
                    : "text-gray-500 hover:text-gray-700"
                  }`}
              >
                🏦 Deudas
              </button>
            </div>
          </div>

          {/* ===== Section A: Fixed Expenses ===== */}
          {activeSection === "expenses" && (
            <div className="mb-6">
              {/* Total Summary */}
              <div className={`${isDark ? "bg-indigo-900/30 border-indigo-800" : "bg-indigo-50 border-indigo-200"} border-2 rounded-2xl p-4 mb-4`}>
                <p className={`text-xs mb-1 ${isDark ? "text-indigo-300" : "text-indigo-700"}`}>
                  Total de Gastos Fijos
                </p>
                <p className={`text-2xl font-bold ${isDark ? "text-indigo-400" : "text-indigo-600"}`}>
                  ${totalFixed.toFixed(2)}
                </p>
              </div>

              {/* Expenses List */}
              <div className="space-y-2 mb-4">
                {fixedExpenses.map((expense) => (
                  <div
                    key={expense.id}
                    className={`${isDark ? "bg-gray-700 border-gray-600" : "bg-white border-gray-200"} border-2 rounded-xl p-3 flex items-center gap-3`}
                  >
                    <span className="text-2xl">{expense.category}</span>
                    <div className="flex-1">
                      <p className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                        {expense.name}
                      </p>
                      <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                        ${expense.amount}
                      </p>
                    </div>
                    <button
                      onClick={() => handleDeleteExpense(expense.id)}
                      className={`${isDark ? "text-red-400 hover:text-red-300" : "text-red-600 hover:text-red-700"} transition-colors`}
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>

              {/* Add New Expense */}
              <div className={`${isDark ? "bg-gray-700/50 border-gray-600" : "bg-gray-50 border-gray-200"} border-2 rounded-xl p-4`}>
                <p className={`text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Agregar Gasto Fijo
                </p>

                <div className="grid grid-cols-4 gap-2 mb-3">
                  {categories.map((cat) => (
                    <button
                      key={cat.emoji}
                      onClick={() => setNewExpenseCategory(cat.emoji)}
                      className={`p-2 rounded-lg transition-all ${newExpenseCategory === cat.emoji
                        ? isDark
                          ? "bg-indigo-900/50 border-2 border-indigo-600"
                          : "bg-indigo-100 border-2 border-indigo-500"
                        : isDark
                          ? "bg-gray-600 hover:bg-gray-650"
                          : "bg-white hover:bg-gray-50"
                        }`}
                      title={cat.label}
                    >
                      <span className="text-xl">{cat.emoji}</span>
                    </button>
                  ))}
                </div>

                <div className="space-y-2">
                  <input
                    type="text"
                    value={newExpenseName}
                    onChange={(e) => setNewExpenseName(e.target.value)}
                    placeholder="Nombre del gasto"
                    className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 px-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                  />
                  <div className="relative">
                    <DollarSign className={`absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 ${isDark ? "text-gray-400" : "text-gray-500"}`} />
                    <input
                      type="number"
                      step="0.01"
                      value={newExpenseAmount}
                      onChange={(e) => setNewExpenseAmount(e.target.value)}
                      placeholder="0.00"
                      className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 pl-9 pr-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                    />
                  </div>
                  <button
                    onClick={handleAddExpense}
                    disabled={!newExpenseName || !newExpenseAmount}
                    className={`w-full ${isDark ? "bg-indigo-700 hover:bg-indigo-600 disabled:bg-gray-600" : "bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300"} text-white py-2 rounded-lg transition-all text-sm font-medium flex items-center justify-center gap-2 disabled:cursor-not-allowed`}
                  >
                    <Plus className="w-4 h-4" />
                    Agregar
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* ===== Section B: Debts ===== */}
          {activeSection === "debts" && (
            <div className="mb-6">
              {/* Total Debt Summary */}
              <div className={`${isDark ? "bg-rose-900/30 border-rose-800" : "bg-rose-50 border-rose-200"} border-2 rounded-2xl p-4 mb-4`}>
                <p className={`text-xs mb-1 ${isDark ? "text-rose-300" : "text-rose-700"}`}>
                  Deuda Total Pendiente
                </p>
                <p className={`text-2xl font-bold ${isDark ? "text-rose-400" : "text-rose-600"}`}>
                  ${totalDebtPending.toFixed(2)}
                </p>
                <p className={`text-xs mt-1 ${isDark ? "text-rose-400/70" : "text-rose-600/70"}`}>
                  {debts.length} deuda{debts.length !== 1 ? "s" : ""} registrada{debts.length !== 1 ? "s" : ""}
                </p>
              </div>

              {/* Debts List */}
              <div className="space-y-2 mb-4">
                {debts.map((debt) => {
                  const total = parseFloat(debt.totalInstallments || "0");
                  const paid = parseFloat(debt.paidInstallments || "0");
                  const progress = total > 0 ? (paid / total) * 100 : 0;
                  const remaining = (total - paid) * parseFloat(debt.installmentAmount || "0");
                  const isEditing = editingDebtId === debt.id;
                  const isFullyPaid = paid >= total;
                  return (
                    <div
                      key={debt.id}
                      className={`${isDark ? "bg-gray-700 border-gray-600" : "bg-white border-gray-200"} ${isFullyPaid ? isDark ? "border-emerald-700" : "border-emerald-300" : ""} border-2 rounded-xl p-3`}
                    >
                      <div className="flex items-center gap-3 mb-2">
                        <span className="text-2xl">{debt.category}</span>
                        <div className="flex-1">
                          {isEditing ? (
                            <input
                              type="text"
                              value={debt.name}
                              onChange={(e) => handleEditDebt(debt.id, "name", e.target.value)}
                              className={`w-full text-sm ${isDark ? "bg-gray-600 border-gray-500 text-white" : "bg-gray-50 border-gray-300 text-gray-900"} border rounded-lg px-2 py-1 focus:outline-none focus:border-indigo-500`}
                            />
                          ) : (
                            <p className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                              {debt.name} {isFullyPaid && "✅"}
                            </p>
                          )}
                          {isEditing ? (
                            <div className="flex gap-1 mt-1">
                              <input
                                type="number"
                                value={debt.installmentAmount}
                                onChange={(e) => handleEditDebt(debt.id, "installmentAmount", e.target.value)}
                                className={`w-20 text-xs ${isDark ? "bg-gray-600 border-gray-500 text-white" : "bg-gray-50 border-gray-300 text-gray-900"} border rounded px-1 py-0.5 focus:outline-none focus:border-indigo-500`}
                                placeholder="$/cuota"
                              />
                              <input
                                type="number"
                                value={debt.paidInstallments}
                                onChange={(e) => handleEditDebt(debt.id, "paidInstallments", e.target.value)}
                                className={`w-14 text-xs ${isDark ? "bg-gray-600 border-gray-500 text-white" : "bg-gray-50 border-gray-300 text-gray-900"} border rounded px-1 py-0.5 focus:outline-none focus:border-indigo-500`}
                                placeholder="pagadas"
                              />
                              <span className={`text-xs self-center ${isDark ? "text-gray-400" : "text-gray-500"}`}>/{debt.totalInstallments}</span>
                            </div>
                          ) : (
                            <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                              ${debt.installmentAmount}/cuota · {paid}/{total} pagadas
                            </p>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <button
                            onClick={() => setEditingDebtId(isEditing ? null : debt.id)}
                            className={`p-1.5 rounded-lg transition-all ${isEditing ? isDark ? "bg-indigo-700 text-white" : "bg-indigo-100 text-indigo-700" : isDark ? "text-gray-400 hover:text-indigo-400 hover:bg-gray-600" : "text-gray-400 hover:text-indigo-600 hover:bg-gray-100"}`}
                            title={isEditing ? "Guardar" : "Editar"}
                          >
                            {isEditing ? <Check className="w-4 h-4" /> : <Pencil className="w-3.5 h-3.5" />}
                          </button>
                          <button
                            onClick={() => handleDeleteDebt(debt.id)}
                            className={`p-1.5 rounded-lg ${isDark ? "text-red-400 hover:text-red-300 hover:bg-gray-600" : "text-red-500 hover:text-red-700 hover:bg-red-50"} transition-all`}
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>
                      {/* Progress bar */}
                      <div className={`${isDark ? "bg-gray-600" : "bg-gray-200"} rounded-full h-1.5 overflow-hidden mb-1`}>
                        <div
                          className={`h-full rounded-full transition-all ${progress >= 100 ? "bg-emerald-500" : progress >= 75 ? "bg-emerald-500" : progress >= 50 ? "bg-indigo-500" : "bg-amber-500"
                            }`}
                          style={{ width: `${Math.min(progress, 100)}%` }}
                        ></div>
                      </div>
                      <div className="flex items-center justify-between">
                        <p className={`text-xs ${isFullyPaid ? (isDark ? "text-emerald-400" : "text-emerald-600") : (isDark ? "text-rose-400" : "text-rose-600")}`}>
                          {isFullyPaid ? "¡Deuda pagada! 🎉" : `Faltan $${remaining.toLocaleString()}`}
                        </p>
                        {!isFullyPaid && (
                          <button
                            onClick={() => setConfirmAdvanceId(debt.id)}
                            className={`flex items-center gap-1 text-xs px-2.5 py-1 rounded-lg transition-all ${isDark ? "bg-emerald-900/50 text-emerald-400 hover:bg-emerald-800/60" : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"}`}
                          >
                            <ChevronUp className="w-3 h-3" />
                            +1 Cuota
                          </button>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Advance Payment Confirmation */}
              {confirmAdvanceId && (() => {
                const debt = debts.find(d => d.id === confirmAdvanceId);
                if (!debt) return null;
                const nextCuota = parseFloat(debt.paidInstallments || "0") + 1;
                return (
                  <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
                    <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={() => setConfirmAdvanceId(null)}></div>
                    <div className={`relative w-full max-w-xs ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"} border-2 rounded-2xl p-5 shadow-2xl`}>
                      <div className="text-center mb-4">
                        <div className={`w-14 h-14 mx-auto mb-3 ${isDark ? "bg-emerald-900/50" : "bg-emerald-100"} rounded-2xl flex items-center justify-center`}>
                          <ChevronUp className={`w-7 h-7 ${isDark ? "text-emerald-400" : "text-emerald-600"}`} />
                        </div>
                        <h3 className={`text-lg mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>¿Registrar pago?</h3>
                        <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                          Cuota #{nextCuota} de <strong>{debt.name}</strong>
                        </p>
                        <p className={`text-lg mt-2 ${isDark ? "text-emerald-400" : "text-emerald-600"}`}>
                          ${debt.installmentAmount}
                        </p>
                      </div>
                      <div className="flex gap-2">
                        <button
                          onClick={() => setConfirmAdvanceId(null)}
                          className={`flex-1 py-2.5 rounded-xl text-sm ${isDark ? "bg-gray-700 text-white hover:bg-gray-600" : "bg-gray-100 text-gray-900 hover:bg-gray-200"} transition-all`}
                        >
                          Cancelar
                        </button>
                        <button
                          onClick={() => handleAdvancePayment(confirmAdvanceId)}
                          className={`flex-1 py-2.5 rounded-xl text-sm text-white ${isDark ? "bg-emerald-700 hover:bg-emerald-600" : "bg-emerald-600 hover:bg-emerald-700"} transition-all`}
                        >
                          ✓ Confirmar
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })()}

              {/* Add New Debt */}
              <div className={`${isDark ? "bg-gray-700/50 border-gray-600" : "bg-gray-50 border-gray-200"} border-2 rounded-xl p-4`}>
                <p className={`text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Agregar Deuda
                </p>

                <div className="grid grid-cols-4 gap-2 mb-3">
                  {debtCategories.map((cat) => (
                    <button
                      key={cat.emoji}
                      onClick={() => setNewDebtCategory(cat.emoji)}
                      className={`p-2 rounded-lg transition-all ${newDebtCategory === cat.emoji
                        ? isDark
                          ? "bg-indigo-900/50 border-2 border-indigo-600"
                          : "bg-indigo-100 border-2 border-indigo-500"
                        : isDark
                          ? "bg-gray-600 hover:bg-gray-650"
                          : "bg-white hover:bg-gray-50"
                        }`}
                      title={cat.label}
                    >
                      <span className="text-xl">{cat.emoji}</span>
                    </button>
                  ))}
                </div>

                <div className="space-y-2">
                  <input
                    type="text"
                    value={newDebtName}
                    onChange={(e) => setNewDebtName(e.target.value)}
                    placeholder="Nombre de la deuda"
                    className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 px-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                  />
                  <div className="relative">
                    <DollarSign className={`absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 ${isDark ? "text-gray-400" : "text-gray-500"}`} />
                    <input
                      type="number"
                      step="0.01"
                      value={newDebtInstallment}
                      onChange={(e) => setNewDebtInstallment(e.target.value)}
                      placeholder="Monto por cuota"
                      className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 pl-9 pr-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-2">
                    <div className="relative">
                      <Hash className={`absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 ${isDark ? "text-gray-400" : "text-gray-500"}`} />
                      <input
                        type="number"
                        value={newDebtTotal}
                        onChange={(e) => setNewDebtTotal(e.target.value)}
                        placeholder="Cuotas totales"
                        className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 pl-9 pr-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                      />
                    </div>
                    <div className="relative">
                      <Check className={`absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 ${isDark ? "text-gray-400" : "text-gray-500"}`} />
                      <input
                        type="number"
                        value={newDebtPaid}
                        onChange={(e) => setNewDebtPaid(e.target.value)}
                        placeholder="Ya pagadas"
                        className={`w-full ${isDark ? "bg-gray-600 border-gray-500 text-white placeholder-gray-400" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-2 pl-9 pr-3 rounded-lg focus:outline-none focus:border-indigo-500 transition-all text-sm`}
                      />
                    </div>
                  </div>
                  <button
                    onClick={handleAddDebt}
                    disabled={!newDebtName || !newDebtInstallment || !newDebtTotal}
                    className={`w-full ${isDark ? "bg-indigo-700 hover:bg-indigo-600 disabled:bg-gray-600" : "bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-300"} text-white py-2 rounded-lg transition-all text-sm font-medium flex items-center justify-center gap-2 disabled:cursor-not-allowed`}
                  >
                    <Plus className="w-4 h-4" />
                    Agregar Deuda
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Save Button */}
          <button
            onClick={handleSave}
            className={`w-full ${isDark ? "bg-gradient-to-r from-indigo-700 to-emerald-600 hover:from-indigo-600 hover:to-emerald-500" : "bg-gradient-to-r from-indigo-600 to-emerald-500 hover:from-indigo-700 hover:to-emerald-600"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl font-medium`}
          >
            Guardar Cambios
          </button>
        </div>
      </div>
    </div>
  );
}