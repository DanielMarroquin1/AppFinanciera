import { useState } from "react";
import { Mail, Lock, Eye, EyeOff } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { useTheme } from "../context/ThemeContext";
import { ForgotPasswordModal } from "./ForgotPasswordModal";
import { PrivacyPolicyModal } from "./PrivacyPolicyModal";

export function Login() {
  const [isLogin, setIsLogin] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [purpose, setPurpose] = useState("");
  const [acceptedPolicies, setAcceptedPolicies] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showPrivacyPolicy, setShowPrivacyPolicy] = useState(false);
  const { login, register, loginWithGoogle } = useAuth();
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const purposes = [
    { value: "save", label: "Aprender a ahorrar", emoji: "💰" },
    { value: "finance", label: "Saber más de finanzas", emoji: "📈" },
    { value: "expenses", label: "Aprender a llevar mis gastos", emoji: "📊" },
    { value: "invest", label: "Aprender a invertir", emoji: "💎" },
    { value: "debts", label: "Salir de deudas", emoji: "🎯" },
    { value: "goals", label: "Cumplir metas financieras", emoji: "🏆" },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (isLogin) {
      login(email, password);
    } else {
      if (purpose && acceptedPolicies) {
        const selectedPurpose = purposes.find(p => p.value === purpose)?.label || "";
        register(email, password, selectedPurpose);
      }
    }
  };

  const handleGoogleLogin = () => {
    loginWithGoogle();
  };

  return (
    <div className={`h-full ${isDark ? "bg-gray-900" : "bg-gradient-to-br from-purple-50 to-blue-50"} flex flex-col justify-center items-center p-6 overflow-y-auto`}>
      {/* Logo y Header */}
      <div className="text-center mb-8">
        <div className={`w-20 h-20 ${isDark ? "bg-gradient-to-br from-purple-700 to-blue-700" : "bg-gradient-to-br from-purple-600 to-blue-600"} rounded-3xl flex items-center justify-center mx-auto mb-4 shadow-lg`}>
          <span className="text-4xl">💸</span>
        </div>
        <h1 className={`text-3xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
          {isLogin ? "¡Bienvenido!" : "Crear Cuenta"}
        </h1>
        <p className={`${isDark ? "text-gray-400" : "text-gray-600"}`}>
          {isLogin ? "Inicia sesión para continuar" : "Únete y empieza a ahorrar"}
        </p>
      </div>

      {/* Google Sign In */}
      <button
        onClick={handleGoogleLogin}
        className={`w-full ${isDark ? "bg-gray-800 border-gray-700 hover:bg-gray-750" : "bg-white border-gray-300 hover:bg-gray-50"} border-2 py-4 rounded-2xl mb-4 flex items-center justify-center gap-3 transition-all shadow-sm`}
      >
        <svg viewBox="0 0 24 24" className="w-6 h-6">
          <path
            fill="#4285F4"
            d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
          />
          <path
            fill="#34A853"
            d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
          />
          <path
            fill="#FBBC05"
            d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
          />
          <path
            fill="#EA4335"
            d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
          />
        </svg>
        <span className={`${isDark ? "text-white" : "text-gray-900"}`}>
          Continuar con Google
        </span>
      </button>

      {/* Divider */}
      <div className="flex items-center w-full mb-4">
        <div className={`flex-1 h-px ${isDark ? "bg-gray-700" : "bg-gray-300"}`}></div>
        <span className={`px-4 text-sm ${isDark ? "text-gray-500" : "text-gray-500"}`}>o</span>
        <div className={`flex-1 h-px ${isDark ? "bg-gray-700" : "bg-gray-300"}`}></div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="w-full space-y-4">
        {/* Email Input */}
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
              placeholder="tu@email.com"
              required
              className={`w-full ${isDark ? "bg-gray-800 border-gray-700 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3.5 pl-12 pr-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
            />
          </div>
        </div>

        {/* Password Input */}
        <div>
          <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
            Contraseña
          </label>
          <div className="relative">
            <Lock className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
            <input
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
              className={`w-full ${isDark ? "bg-gray-800 border-gray-700 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3.5 pl-12 pr-12 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className={`absolute right-4 top-1/2 -translate-y-1/2 ${isDark ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"}`}
            >
              {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Purpose Selection (only for registration) */}
        {!isLogin && (
          <div>
            <label className={`block text-sm mb-3 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              ¿Cuál es tu propósito para usar esta app?
            </label>
            <div className="space-y-2">
              {purposes.map((p) => (
                <label
                  key={p.value}
                  className={`flex items-center gap-3 p-4 rounded-xl cursor-pointer transition-all ${
                    purpose === p.value
                      ? isDark
                        ? "bg-purple-900/50 border-2 border-purple-600"
                        : "bg-purple-100 border-2 border-purple-500"
                      : isDark
                      ? "bg-gray-800 border-2 border-gray-700 hover:bg-gray-750"
                      : "bg-white border-2 border-gray-200 hover:bg-gray-50"
                  }`}
                >
                  <input
                    type="radio"
                    name="purpose"
                    value={p.value}
                    checked={purpose === p.value}
                    onChange={(e) => setPurpose(e.target.value)}
                    className="sr-only"
                    required
                  />
                  <span className="text-2xl">{p.emoji}</span>
                  <span className={`flex-1 text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                    {p.label}
                  </span>
                  {purpose === p.value && (
                    <div className="w-5 h-5 bg-purple-600 rounded-full flex items-center justify-center">
                      <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  )}
                </label>
              ))}
            </div>
          </div>
        )}

        {/* Privacy Policy Checkbox (only for registration) */}
        {!isLogin && (
          <div className="flex items-start gap-3">
            <input
              type="checkbox"
              id="privacy-policy"
              checked={acceptedPolicies}
              onChange={(e) => setAcceptedPolicies(e.target.checked)}
              required
              className="mt-1 w-4 h-4 rounded border-gray-300 text-purple-600 focus:ring-purple-500"
            />
            <label htmlFor="privacy-policy" className={`text-sm ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Acepto las{" "}
              <button
                type="button"
                onClick={() => setShowPrivacyPolicy(true)}
                className={`${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"} underline`}
              >
                Políticas de Privacidad
              </button>
              {" "}y los Términos y Condiciones
            </label>
          </div>
        )}

        {/* Submit Button */}
        <button
          type="submit"
          disabled={!isLogin && !acceptedPolicies}
          className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600 disabled:from-gray-700 disabled:to-gray-700" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 disabled:from-gray-300 disabled:to-gray-300"} text-white py-4 rounded-xl transition-all shadow-lg hover:shadow-xl disabled:cursor-not-allowed`}
        >
          {isLogin ? "Iniciar Sesión" : "Crear Cuenta"}
        </button>
      </form>

      {/* Toggle Login/Register */}
      <div className="mt-6 text-center">
        <button
          onClick={() => {
            setIsLogin(!isLogin);
            setPurpose("");
            setAcceptedPolicies(false);
          }}
          className={`text-sm ${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"}`}
        >
          {isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión"}
        </button>
      </div>

      {/* Forgot Password (only in login mode) */}
      {isLogin && (
        <button 
          onClick={() => setShowForgotPassword(true)}
          className={`mt-2 text-sm ${isDark ? "text-gray-500 hover:text-gray-400" : "text-gray-500 hover:text-gray-600"}`}
        >
          ¿Olvidaste tu contraseña?
        </button>
      )}

      {/* Modals */}
      {showForgotPassword && (
        <ForgotPasswordModal onClose={() => setShowForgotPassword(false)} />
      )}
      {showPrivacyPolicy && (
        <PrivacyPolicyModal onClose={() => setShowPrivacyPolicy(false)} />
      )}
    </div>
  );
}