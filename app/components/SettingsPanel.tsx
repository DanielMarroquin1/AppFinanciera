import { Bell, Lock, Moon, Globe, CreditCard, Crown, ChevronRight } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

export function SettingsPanel() {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === "dark";

  return (
    <div className={`p-6 ${isDark ? "bg-gray-900" : ""}`}>
      {/* Header */}
      <div className="mb-6">
        <h1 className={`text-3xl mb-1 ${isDark ? "text-white" : ""}`}>Configuración ⚙️</h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-500"}`}>Personaliza tu experiencia</p>
      </div>

      {/* Profile Card */}
      <div className={`${isDark ? "bg-gradient-to-br from-purple-900 to-blue-900" : "bg-gradient-to-br from-purple-600 to-blue-600"} rounded-3xl p-6 mb-6 text-white shadow-lg`}>
        <div className="flex items-center gap-4 mb-4">
          <div className={`w-16 h-16 ${isDark ? "bg-white/10" : "bg-white/20"} rounded-2xl flex items-center justify-center backdrop-blur-sm`}>
            <span className="text-3xl">👤</span>
          </div>
          <div>
            <h2 className="text-xl">María García</h2>
            <p className="text-sm opacity-90">maria.garcia@email.com</p>
          </div>
        </div>
        <button className={`${isDark ? "bg-white/10 hover:bg-white/20" : "bg-white/20 hover:bg-white/30"} text-white text-sm px-4 py-2 rounded-xl transition-all backdrop-blur-sm`}>
          Editar Perfil
        </button>
      </div>

      {/* Premium Banner */}
      <div className={`${isDark ? "bg-gradient-to-r from-amber-600 to-orange-700" : "bg-gradient-to-r from-amber-400 to-orange-500"} rounded-3xl p-5 mb-6 text-white shadow-lg`}>
        <div className="flex items-center gap-3 mb-3">
          <Crown className="w-6 h-6" />
          <h3 className="text-lg">Actualizar a Premium</h3>
        </div>
        <p className="text-sm opacity-90 mb-4">
          Desbloquea todas las funciones: sin anuncios, reportes avanzados, sincronización en la nube y más.
        </p>
        <button className={`${isDark ? "bg-white text-orange-700 hover:bg-gray-100" : "bg-white text-orange-600 hover:bg-gray-100"} text-sm px-6 py-3 rounded-xl transition-all`}>
          Ver Planes
        </button>
      </div>

      {/* Settings Sections */}
      <div className="space-y-6 mb-6">
        {/* General */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>General</h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
              <div className={`w-10 h-10 ${isDark ? "bg-purple-900/50" : "bg-purple-100"} rounded-xl flex items-center justify-center`}>
                <Bell className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Notificaciones</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Alertas y recordatorios</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
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
            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
              <div className={`w-10 h-10 ${isDark ? "bg-green-900/50" : "bg-green-100"} rounded-xl flex items-center justify-center`}>
                <Lock className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"}`} />
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Cambiar Contraseña</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Última actualización hace 3 meses</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}>
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

        {/* Data */}
        <div>
          <h3 className={`text-sm ${isDark ? "text-gray-400" : "text-gray-500"} mb-3`}>Datos</h3>
          <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-100"} rounded-2xl border shadow-sm overflow-hidden`}>
            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
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

            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all border-b ${isDark ? "border-gray-700" : "border-gray-100"}`}>
              <div className={`w-10 h-10 ${isDark ? "bg-purple-900/50" : "bg-purple-100"} rounded-xl flex items-center justify-center`}>
                <span className="text-xl">💾</span>
              </div>
              <div className="flex-1 text-left">
                <p className={`text-sm ${isDark ? "text-white" : ""}`}>Respaldo Local</p>
                <p className={`text-xs ${isDark ? "text-gray-500" : "text-gray-500"}`}>Último respaldo: Hoy</p>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
            </button>

            <button className={`w-full p-4 flex items-center gap-3 ${isDark ? "hover:bg-gray-700" : "hover:bg-gray-50"} transition-all`}>
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
      <button className={`w-full ${isDark ? "bg-red-900/30 border-red-800 text-red-400 hover:bg-red-900/50" : "bg-red-50 border-red-200 text-red-600 hover:bg-red-100"} py-4 rounded-2xl transition-all border-2`}>
        Cerrar Sesión
      </button>
    </div>
  );
}
