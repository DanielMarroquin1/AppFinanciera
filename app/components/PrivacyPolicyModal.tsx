import { X, Shield, Lock, Eye, Database, UserCheck } from "lucide-react";
import { useTheme } from "../context/ThemeContext";

interface PrivacyPolicyModalProps {
  onClose: () => void;
}

export function PrivacyPolicyModal({ onClose }: PrivacyPolicyModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-900" : "bg-white"
        } rounded-3xl shadow-2xl transition-all duration-300`}
        style={{ maxHeight: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700" : "bg-gradient-to-r from-purple-600 to-blue-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Shield className="w-6 h-6" />
              </div>
              <h2 className="text-2xl">Políticas de Privacidad</h2>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
          <p className="text-sm text-white/90">Última actualización: Marzo 2026</p>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto" style={{ maxHeight: "calc(90vh - 180px)" }}>
          {/* Introduction */}
          <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} border-2 rounded-2xl p-4 mb-6`}>
            <p className={`text-sm ${isDark ? "text-blue-300" : "text-blue-900"}`}>
              En <strong>Finanzas App</strong>, tu privacidad es nuestra prioridad. Esta política describe cómo recopilamos, usamos y protegemos tu información.
            </p>
          </div>

          {/* Sections */}
          <div className="space-y-6">
            {/* Data Collection */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className={`w-10 h-10 ${isDark ? "bg-purple-900/50" : "bg-purple-100"} rounded-xl flex items-center justify-center`}>
                  <Database className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
                </div>
                <h3 className={`text-lg font-semibold ${isDark ? "text-white" : "text-gray-900"}`}>
                  Información que Recopilamos
                </h3>
              </div>
              <ul className={`space-y-2 text-sm ${isDark ? "text-gray-400" : "text-gray-600"} pl-12`}>
                <li>• Información de perfil (nombre, correo electrónico)</li>
                <li>• Datos financieros (ingresos, gastos, metas de ahorro)</li>
                <li>• Preferencias y configuraciones de la aplicación</li>
                <li>• Información de uso y análisis anónimos</li>
              </ul>
            </div>

            {/* Data Usage */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className={`w-10 h-10 ${isDark ? "bg-green-900/50" : "bg-green-100"} rounded-xl flex items-center justify-center`}>
                  <UserCheck className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"}`} />
                </div>
                <h3 className={`text-lg font-semibold ${isDark ? "text-white" : "text-gray-900"}`}>
                  Cómo Usamos tu Información
                </h3>
              </div>
              <ul className={`space-y-2 text-sm ${isDark ? "text-gray-400" : "text-gray-600"} pl-12`}>
                <li>• Proporcionarte servicios personalizados de gestión financiera</li>
                <li>• Generar reportes y análisis de tus finanzas</li>
                <li>• Mejorar y optimizar la aplicación</li>
                <li>• Enviarte notificaciones importantes sobre tu cuenta</li>
                <li>• Cumplir con requisitos legales y de seguridad</li>
              </ul>
            </div>

            {/* Data Protection */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className={`w-10 h-10 ${isDark ? "bg-blue-900/50" : "bg-blue-100"} rounded-xl flex items-center justify-center`}>
                  <Lock className={`w-5 h-5 ${isDark ? "text-blue-400" : "text-blue-600"}`} />
                </div>
                <h3 className={`text-lg font-semibold ${isDark ? "text-white" : "text-gray-900"}`}>
                  Protección de Datos
                </h3>
              </div>
              <ul className={`space-y-2 text-sm ${isDark ? "text-gray-400" : "text-gray-600"} pl-12`}>
                <li>• Encriptación de datos end-to-end</li>
                <li>• Almacenamiento seguro en servidores protegidos</li>
                <li>• Acceso restringido solo a personal autorizado</li>
                <li>• Auditorías de seguridad regulares</li>
                <li>• Cumplimiento con estándares internacionales</li>
              </ul>
            </div>

            {/* Data Sharing */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className={`w-10 h-10 ${isDark ? "bg-amber-900/50" : "bg-amber-100"} rounded-xl flex items-center justify-center`}>
                  <Eye className={`w-5 h-5 ${isDark ? "text-amber-400" : "text-amber-600"}`} />
                </div>
                <h3 className={`text-lg font-semibold ${isDark ? "text-white" : "text-gray-900"}`}>
                  Compartir Información
                </h3>
              </div>
              <ul className={`space-y-2 text-sm ${isDark ? "text-gray-400" : "text-gray-600"} pl-12`}>
                <li>• <strong>NO</strong> vendemos tu información personal a terceros</li>
                <li>• Solo compartimos datos necesarios con proveedores de servicios confiables</li>
                <li>• Podemos compartir datos anónimos para investigación</li>
                <li>• Cumplimiento legal cuando sea requerido por ley</li>
              </ul>
            </div>

            {/* User Rights */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className={`w-10 h-10 ${isDark ? "bg-pink-900/50" : "bg-pink-100"} rounded-xl flex items-center justify-center`}>
                  <Shield className={`w-5 h-5 ${isDark ? "text-pink-400" : "text-pink-600"}`} />
                </div>
                <h3 className={`text-lg font-semibold ${isDark ? "text-white" : "text-gray-900"}`}>
                  Tus Derechos
                </h3>
              </div>
              <ul className={`space-y-2 text-sm ${isDark ? "text-gray-400" : "text-gray-600"} pl-12`}>
                <li>• Acceder y descargar tu información personal</li>
                <li>• Corregir información inexacta</li>
                <li>• Eliminar tu cuenta y datos asociados</li>
                <li>• Optar por no recibir comunicaciones de marketing</li>
                <li>• Presentar quejas ante autoridades de protección de datos</li>
              </ul>
            </div>

            {/* Cookies */}
            <div>
              <h3 className={`text-lg font-semibold mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                Cookies y Tecnologías Similares
              </h3>
              <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Utilizamos cookies y tecnologías similares para mejorar tu experiencia, recordar tus preferencias y analizar el uso de la aplicación. Puedes controlar las cookies a través de la configuración de tu navegador.
              </p>
            </div>

            {/* Changes */}
            <div>
              <h3 className={`text-lg font-semibold mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                Cambios a esta Política
              </h3>
              <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios importantes mediante correo electrónico o un aviso en la aplicación.
              </p>
            </div>

            {/* Contact */}
            <div className={`${isDark ? "bg-purple-900/30 border-purple-800" : "bg-purple-50 border-purple-200"} border-2 rounded-2xl p-4`}>
              <h3 className={`text-sm font-semibold mb-2 ${isDark ? "text-purple-300" : "text-purple-900"}`}>
                Contacto
              </h3>
              <p className={`text-sm ${isDark ? "text-purple-300" : "text-purple-900"}`}>
                Si tienes preguntas sobre esta política, contáctanos en:<br />
                <strong>privacidad@finanzasapp.com</strong>
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} border-t px-6 py-4`}>
          <button
            onClick={onClose}
            className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all font-medium`}
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}
