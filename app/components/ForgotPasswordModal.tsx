import { X, Mail, CheckCircle } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface ForgotPasswordModalProps {
  onClose: () => void;
}

export function ForgotPasswordModal({ onClose }: ForgotPasswordModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Simulate sending email
    setSent(true);
    setTimeout(() => {
      onClose();
    }, 3000);
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

        {!sent ? (
          <>
            <div className={`w-16 h-16 ${isDark ? "bg-purple-900/30" : "bg-purple-100"} rounded-2xl flex items-center justify-center mx-auto mb-4`}>
              <Mail className={`w-8 h-8 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
            </div>

            <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
              ¿Olvidaste tu contraseña?
            </h2>
            <p className={`text-sm text-center mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Ingresa tu correo y te enviaremos un enlace para recuperar tu cuenta
            </p>

            <form onSubmit={handleSubmit}>
              <div className="mb-6">
                <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  Correo Electrónico
                </label>
                <div className="relative">
                  <Mail className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="tu@email.com"
                    required
                    className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 pl-12 pr-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                  />
                </div>
              </div>

              <button
                type="submit"
                className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
              >
                Enviar Enlace de Recuperación
              </button>
            </form>
          </>
        ) : (
          <>
            <div className={`w-16 h-16 ${isDark ? "bg-green-900/30" : "bg-green-100"} rounded-2xl flex items-center justify-center mx-auto mb-4`}>
              <CheckCircle className={`w-8 h-8 ${isDark ? "text-green-400" : "text-green-600"}`} />
            </div>

            <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
              ¡Correo Enviado!
            </h2>
            <p className={`text-sm text-center mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
              Hemos enviado un enlace de recuperación a <strong>{email}</strong>
            </p>

            <button
              onClick={onClose}
              className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all`}
            >
              Entendido
            </button>
          </>
        )}
      </div>
    </div>
  );
}
