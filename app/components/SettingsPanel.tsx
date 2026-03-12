import { Bell, Lock, Moon, Globe, CreditCard, Crown, ChevronRight, AlertCircle, X, Palette } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useAuth } from "../context/AuthContext";
import { useState } from "react";
import { PremiumModal } from "./PremiumModal";
import { EditProfileModal } from "./EditProfileModal";
import { ColorPaletteModal, ColorPalette } from "./ColorPaletteModal";
import { CancelSubscriptionModal } from "./CancelSubscriptionModal";
import { NotificationsSettingsModal } from "./NotificationsSettingsModal";
import { LanguageSettingsModal } from "./LanguageSettingsModal";
import { ChangePasswordModal } from "./ChangePasswordModal";
import { TwoFactorAuthModal } from "./TwoFactorAuthModal";
import { CloudSyncModal } from "./CloudSyncModal";
import { LocalBackupModal } from "./LocalBackupModal";
import { ExportDataModal } from "./ExportDataModal";
import { CategoryBudgetModal } from "./CategoryBudgetModal";
import { BudgetAlertModal } from "./BudgetAlertModal";

export function SettingsPanel() {
  const { theme, toggleTheme, colorPalette, setColorPalette } = useTheme();
  const { user, updateProfile, logout } = useAuth();
  const isDark = theme === "dark";
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showPremiumModal, setShowPremiumModal] = useState(false);
  const [showEditProfileModal, setShowEditProfileModal] = useState(false);
  const [showColorPaletteModal, setShowColorPaletteModal] = useState(false);
  const [showCancelSubscriptionModal, setShowCancelSubscriptionModal] = useState(false);
  const [showNotificationsModal, setShowNotificationsModal] = useState(false);
  const [showLanguageModal, setShowLanguageModal] = useState(false);
  const [showChangePasswordModal, setShowChangePasswordModal] = useState(false);
  const [showTwoFactorAuthModal, setShowTwoFactorAuthModal] = useState(false);
  const [showCloudSyncModal, setShowCloudSyncModal] = useState(false);
  const [showLocalBackupModal, setShowLocalBackupModal] = useState(false);
  const [showExportDataModal, setShowExportDataModal] = useState(false);
  const [showCategoryBudgetModal, setShowCategoryBudgetModal] = useState(false);
  const [showBudgetAlertModal, setShowBudgetAlertModal] = useState(false);
  const [country, setCountry] = useState(user?.country || "");
  const [currency, setCurrency] = useState(user?.currency || "");
  const [salary, setSalary] = useState(user?.salary || "");
  const [salaryType, setSalaryType] = useState<"monthly" | "biweekly">(user?.salaryType || "monthly");
  const [showBanner, setShowBanner] = useState(!user?.profileComplete);
  const [isPremium, setIsPremium] = useState(false); // Track premium status
  const [hasUnlockedExport, setHasUnlockedExport] = useState(false); // Track if export is unlocked from shop

  const missingData = [];
  if (!user?.country) missingData.push("País");
  if (!user?.currency) missingData.push("Moneda");
  if (!user?.salary) missingData.push("Salario");

  const handleSaveProfile = () => {
    updateProfile({
      country,
      currency,
      salary,
      salaryType,
    });
    setShowProfileModal(false);
    setShowBanner(false);
  };

  const handleLogout = () => {
    logout();
  };

  const handleUpgradeToPremium = (plan: "monthly" | "annual") => {
    // Aquí iría la lógica de pago real
    console.log("Upgrading to premium:", plan);
    setIsPremium(true);
    setShowPremiumModal(false);
  };

  const handleCancelSubscription = () => {
    setIsPremium(false);
    console.log("Subscription cancelled");
  };

  const handleSaveColorPalette = (palette: ColorPalette) => {
    setColorPalette(palette);
  };

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Missing Data Banner */}
      {showBanner && missingData.length > 0 && (
        <div className={`${isDark ? "bg-gradient-to-r from-orange-900 to-red-900 border-orange-800" : "bg-gradient-to-r from-orange-400 to-red-500 border-orange-600"} rounded-3xl p-5 mb-6 text-white shadow-lg border-2 relative`}>
          <button
            onClick={() => setShowBanner(false)}
            className="absolute top-3 right-3 text-white/80 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
          <div className="flex items-start gap-3 mb-3">
            <AlertCircle className="w-6 h-6 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="text-lg mb-1">¡Completa tu perfil!</h3>
              <p className="text-sm opacity-90 mb-3">
                Necesitamos algunos datos para personalizar tu experiencia y ayudarte a ahorrar:
              </p>
              <ul className="text-sm space-y-1 mb-4">
                {missingData.map((item, index) => (
                  <li key={index} className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-white rounded-full"></div>
                    {item}
                  </li>
                ))}
              </ul>
              <button
                onClick={() => setShowProfileModal(true)}
                className={`${isDark ? "bg-white text-red-700 hover:bg-gray-100" : "bg-white text-red-600 hover:bg-gray-100"} text-sm px-6 py-2.5 rounded-xl transition-all font-medium`}
              >
                Completar Ahora
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Configuración ⚙️</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Personaliza tu experiencia</p>
      </div>

      {/* Profile Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-purple-900 to-blue-900" : "bg-gradient-to-br from-purple-600 to-blue-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <div className="flex items-center gap-4 mb-4">
          <div className={`w-16 h-16 ${isDark ? "bg-white/10" : "bg-white/20"} rounded-2xl flex items-center justify-center backdrop-blur-sm relative`}>
            <span className="text-3xl">👤</span>
            {isPremium && (
              <div className="absolute -top-1 -right-1 w-6 h-6 bg-amber-500 rounded-full flex items-center justify-center border-2 border-white">
                <Crown className="w-3 h-3 text-white" />
              </div>
            )}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-xl">María García</h2>
              {isPremium && (
                <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
                  <Crown className="w-3 h-3" />
                  PRO
                </div>
              )}
            </div>
            <p className="text-sm opacity-90">maria.garcia@email.com</p>
          </div>
        </div>
        <button 
          onClick={() => setShowEditProfileModal(true)}
          className={`${isDark ? "bg-white/10 hover:bg-white/20" : "bg-white/20 hover:bg-white/30"} text-white text-sm px-4 py-2 rounded-xl transition-all backdrop-blur-sm`}
        >
          Editar Perfil
        </button>
      </div>

      {/* Premium Banner */}
      {!isPremium && (
        <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} rounded-3xl p-5 mb-6 text-white shadow-lg`}>
          <div className="flex items-center gap-3 mb-3">
            <Crown className="w-6 h-6" />
            <h3 className="text-lg">Actualizar a Premium</h3>
          </div>
          <p className="text-sm opacity-90 mb-4">
            Desbloquea todas las funciones: sin anuncios, reportes avanzados, sincronización en la nube y más.
          </p>
          <button 
            onClick={() => setShowPremiumModal(true)}
            className={`${isDark ? "bg-white text-orange-700 hover:bg-gray-100" : "bg-white text-orange-600 hover:bg-gray-100"} text-sm px-6 py-3 rounded-xl transition-all`}
          >
            Ver Planes
          </button>
        </div>
      )}

      {/* Settings Sections */}
      <div className="space-y-6 mb-6">
        {/* General */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>General</h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button 
              onClick={() => setShowNotificationsModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-purple-900/50" : "bg-purple-100"} rounded-xl flex items-center justify-center`}>
                <Bell className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Notificaciones</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Alertas y recordatorios</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button 
              onClick={() => setShowLanguageModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-blue-900/50" : "bg-blue-100"} rounded-xl flex items-center justify-center`}>
                <Globe className={`w-5 h-5 ${isDark ? "text-blue-400" : "text-blue-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Idioma</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Español</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button 
              onClick={toggleTheme}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-gray-700" : "bg-gray-100"} rounded-xl flex items-center justify-center`}>
                <Moon className={`w-5 h-5 ${isDark ? "text-yellow-400" : "text-gray-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Tema Oscuro</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Activar modo nocturno</p>
              </div>
              <div 
                className={`w-12 h-6 rounded-full relative transition-all ${isDark ? "bg-purple-600" : "bg-gray-200"}`}
              >
                <div 
                  className={`w-5 h-5 bg-white rounded-full absolute top-0.5 shadow-sm transition-all ${isDark ? "left-6" : "left-0.5"}`}
                ></div>
              </div>
            </button>
          </div>
        </div>

        {/* Security */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Seguridad</h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button
              onClick={() => setShowChangePasswordModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-green-900/50" : "bg-green-100"} rounded-xl flex items-center justify-center`}>
                <Lock className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Cambiar Contraseña</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Última actualización hace 3 meses</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button
              onClick={() => setShowTwoFactorAuthModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-red-900/50" : "bg-red-100"} rounded-xl flex items-center justify-center`}>
                <span className="text-xl">🔐</span>
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Autenticación de Dos Factores</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Protege tu cuenta</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>
          </div>
        </div>

        {/* Appearance (Always visible with Premium tag) */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3 flex items-center gap-2`}>
            Apariencia
            <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
              <Crown className="w-3 h-3" />
              PRO
            </div>
          </h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button 
              onClick={() => isPremium ? setShowColorPaletteModal(true) : setShowPremiumModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-gradient-to-br from-purple-900/50 to-pink-900/50" : "bg-gradient-to-br from-purple-100 to-pink-100"} rounded-xl flex items-center justify-center`}>
                <Palette className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Paleta de Colores</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>{isPremium ? colorPalette.name : "Personaliza tus colores"}</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>
          </div>
        </div>

        {/* Premium Subscription Management */}
        {isPremium && (
          <div>
            <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Suscripción Premium</h3>
            <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
              <div className={`p-4 border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <Crown className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"}`} />
                    <p className={`text-sm ${isDark ? "text-white" : ""}`}>Plan Premium Anual</p>
                  </div>
                  <div className={`${isDark ? "bg-green-900 text-green-300" : "bg-green-100 text-green-700"} text-xs px-2 py-1 rounded-full`}>
                    Activo
                  </div>
                </div>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>
                  Próxima renovación: 24 Feb 2027
                </p>
              </div>
              <button 
                onClick={() => setShowCancelSubscriptionModal(true)}
                className={`w-full p-4 flex items-center justify-center gap-2 ${isDark ? "text-red-400 hover:bg-gray-700" : "text-red-600 hover:bg-gray-50"} transition-all`}
              >
                <span className="text-sm">Cancelar Suscripción</span>
              </button>
            </div>
          </div>
        )}

        {/* Data */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Datos</h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button
              onClick={() => setShowCloudSyncModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-blue-900/50" : "bg-blue-100"} rounded-xl flex items-center justify-center`}>
                <span className="text-xl">☁️</span>
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Sincronización en la Nube</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Premium</p>
              </div>
              <div className={`${isDark ? "bg-amber-900 text-amber-300" : "bg-amber-100 text-amber-700"} text-xs px-2 py-1 rounded-full`}>
                Premium
              </div>
            </button>

            <button
              onClick={() => setShowLocalBackupModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-purple-900/50" : "bg-purple-100"} rounded-xl flex items-center justify-center`}>
                <span className="text-xl">💾</span>
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Respaldo Local</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Último respaldo: Hoy</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button
              onClick={() => setShowExportDataModal(true)}
              className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}
            >
              <div className={`w-10 h-10 ${isDark ? "bg-green-900/50" : "bg-green-100"} rounded-xl flex items-center justify-center`}>
                <CreditCard className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Exportar Datos</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Descargar en formato CSV</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>
          </div>
        </div>
      </div>

      {/* About */}
      <div className={`${isDark ? "bg-gray-800" : "bg-gray-50"} rounded-2xl p-4 mb-6 text-center`}>
        <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"} mb-1`}>Versión 2.5.0</p>
        <p className={`text-xs ${isDark ? "text-gray-600" : "text-gray-400"}`}>© 2026 Tu App de Finanzas</p>
      </div>

      {/* Logout Button */}
      <button className={`w-full ${isDark ? "bg-red-900/30 border-red-800 text-red-400 hover:bg-red-900/50" : "bg-red-50 border-red-200 text-red-600 hover:bg-red-100"} py-4 rounded-2xl transition-all border-2`} onClick={handleLogout}>
        Cerrar Sesión
      </button>

      {/* Profile Completion Modal */}
      {showProfileModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Overlay */}
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowProfileModal(false)}></div>

          {/* Modal */}
          <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl`}>
            <button
              onClick={() => setShowProfileModal(false)}
              className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
            >
              <X className="w-5 h-5" />
            </button>

            <h2 className={`text-2xl mb-4 ${isDark ? "text-white" : "text-gray-900"}`}>
              Completa tu Perfil 🎯
            </h2>
            <p className={`mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Ayúdanos a personalizar tu experiencia financiera
            </p>

            <form onSubmit={(e) => { e.preventDefault(); handleSaveProfile(); }} className="space-y-4">
              {/* Country */}
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  País 🌍
                </label>
                <select
                  value={country}
                  onChange={(e) => setCountry(e.target.value)}
                  required
                  className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                >
                  <option value="">Selecciona tu país</option>
                  <option value="MX">🇲🇽 México</option>
                  <option value="AR">🇦🇷 Argentina</option>
                  <option value="CO">🇨🇴 Colombia</option>
                  <option value="CL">🇨🇱 Chile</option>
                  <option value="PE">🇵🇪 Perú</option>
                  <option value="ES">🇪🇸 España</option>
                  <option value="US">🇺🇸 Estados Unidos</option>
                  <option value="OTHER">🌎 Otro</option>
                </select>
              </div>

              {/* Currency */}
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Moneda 💵
                </label>
                <select
                  value={currency}
                  onChange={(e) => setCurrency(e.target.value)}
                  required
                  className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                >
                  <option value="">Selecciona tu moneda</option>
                  <option value="MXN">MXN - Peso Mexicano</option>
                  <option value="USD">USD - Dólar Estadounidense</option>
                  <option value="EUR">EUR - Euro</option>
                  <option value="ARS">ARS - Peso Argentino</option>
                  <option value="COP">COP - Peso Colombiano</option>
                  <option value="CLP">CLP - Peso Chileno</option>
                  <option value="PEN">PEN - Sol Peruano</option>
                </select>
              </div>

              {/* Salary Type */}
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Frecuencia de Pago 📅
                </label>
                <div className="flex gap-3">
                  <label
                    className={`flex-1 p-4 rounded-xl cursor-pointer transition-all ${
                      salaryType === "monthly"
                        ? isDark
                          ? "bg-purple-900/50 border-2 border-purple-600"
                          : "bg-purple-100 border-2 border-purple-500"
                        : isDark
                        ? "bg-gray-700 border-2 border-gray-600 hover:bg-gray-650"
                        : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="salaryType"
                      value="monthly"
                      checked={salaryType === "monthly"}
                      onChange={(e) => setSalaryType(e.target.value as "monthly")}
                      className="sr-only"
                    />
                    <div className={`text-center text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                      Mensual
                    </div>
                  </label>
                  <label
                    className={`flex-1 p-4 rounded-xl cursor-pointer transition-all ${
                      salaryType === "biweekly"
                        ? isDark
                          ? "bg-purple-900/50 border-2 border-purple-600"
                          : "bg-purple-100 border-2 border-purple-500"
                        : isDark
                        ? "bg-gray-700 border-2 border-gray-600 hover:bg-gray-650"
                        : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="salaryType"
                      value="biweekly"
                      checked={salaryType === "biweekly"}
                      onChange={(e) => setSalaryType(e.target.value as "biweekly")}
                      className="sr-only"
                    />
                    <div className={`text-center text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                      Quincenal
                    </div>
                  </label>
                </div>
              </div>

              {/* Salary */}
              <div>
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Salario {salaryType === "monthly" ? "Mensual" : "Quincenal"} 💰
                </label>
                <input
                  type="number"
                  value={salary}
                  onChange={(e) => setSalary(e.target.value)}
                  placeholder="Ejemplo: 15000"
                  required
                  className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                />
              </div>

              <button
                type="submit"
                className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl`}
              >
                Guardar Información
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Premium Modal */}
      {showPremiumModal && (
        <PremiumModal
          onClose={() => setShowPremiumModal(false)}
          onUpgrade={handleUpgradeToPremium}
        />
      )}

      {/* Edit Profile Modal */}
      {showEditProfileModal && (
        <EditProfileModal
          onClose={() => setShowEditProfileModal(false)}
        />
      )}

      {/* Color Palette Modal */}
      {showColorPaletteModal && (
        <ColorPaletteModal
          onClose={() => setShowColorPaletteModal(false)}
          onSave={handleSaveColorPalette}
          currentPalette={colorPalette}
        />
      )}

      {/* Cancel Subscription Modal */}
      {showCancelSubscriptionModal && (
        <CancelSubscriptionModal
          onClose={() => setShowCancelSubscriptionModal(false)}
          onConfirm={handleCancelSubscription}
        />
      )}

      {/* Notifications Settings Modal */}
      {showNotificationsModal && (
        <NotificationsSettingsModal
          onClose={() => setShowNotificationsModal(false)}
        />
      )}

      {/* Language Settings Modal */}
      {showLanguageModal && (
        <LanguageSettingsModal
          onClose={() => setShowLanguageModal(false)}
        />
      )}

      {/* Change Password Modal */}
      {showChangePasswordModal && (
        <ChangePasswordModal
          onClose={() => setShowChangePasswordModal(false)}
        />
      )}

      {/* Two Factor Auth Modal */}
      {showTwoFactorAuthModal && (
        <TwoFactorAuthModal
          onClose={() => setShowTwoFactorAuthModal(false)}
        />
      )}

      {/* Cloud Sync Modal */}
      {showCloudSyncModal && (
        <CloudSyncModal
          onClose={() => setShowCloudSyncModal(false)}
          isPremium={isPremium}
        />
      )}

      {/* Local Backup Modal */}
      {showLocalBackupModal && (
        <LocalBackupModal
          onClose={() => setShowLocalBackupModal(false)}
        />
      )}

      {/* Export Data Modal */}
      {showExportDataModal && (
        <ExportDataModal
          onClose={() => setShowExportDataModal(false)}
          hasUnlockedExport={hasUnlockedExport}
        />
      )}

      {/* Category Budget Modal */}
      {showCategoryBudgetModal && (
        <CategoryBudgetModal
          onClose={() => setShowCategoryBudgetModal(false)}
        />
      )}

      {/* Budget Alert Modal */}
      {showBudgetAlertModal && (
        <BudgetAlertModal
          onClose={() => setShowBudgetAlertModal(false)}
        />
      )}
    </div>
  );
}