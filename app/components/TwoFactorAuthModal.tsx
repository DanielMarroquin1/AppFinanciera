import { X, Shield, Smartphone, Mail, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface TwoFactorAuthModalProps {
  onClose: () => void;
}

type AuthMethod = "sms" | "email" | null;
type Step = "select" | "verify";

export function TwoFactorAuthModal({ onClose }: TwoFactorAuthModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedMethod, setSelectedMethod] = useState<AuthMethod>(null);
  const [step, setStep] = useState<Step>("select");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [email, setEmail] = useState("maria.garcia@email.com");
  const [verificationCode, setVerificationCode] = useState("");
  const [isEnabled, setIsEnabled] = useState(false);

  const handleSendCode = () => {
    if (selectedMethod === "sms" && !phoneNumber) {
      toast.error("Número requerido", {
        description: "Por favor ingresa tu número de teléfono",
      });
      return;
    }

    // Aquí iría la lógica real para enviar el código
    toast.success("Código enviado", {
      description: `Hemos enviado un código a tu ${selectedMethod === "sms" ? "teléfono" : "correo"}`,
    });
    setStep("verify");
  };

  const handleVerify = () => {
    if (verificationCode.length !== 6) {
      toast.error("Código inválido", {
        description: "El código debe tener 6 dígitos",
      });
      return;
    }

    // Aquí iría la lógica real para verificar el código
    setIsEnabled(true);
    toast.success("Autenticación activada", {
      description: "La autenticación de dos factores está ahora activa",
    });
    setTimeout(() => onClose(), 1500);
  };

  const handleDisable = () => {
    setIsEnabled(false);
    setStep("select");
    setSelectedMethod(null);
    setVerificationCode("");
    toast.success("Autenticación desactivada", {
      description: "La autenticación de dos factores ha sido desactivada",
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-red-700 to-orange-700" : "bg-gradient-to-r from-red-600 to-orange-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Shield className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl mb-1">Autenticación 2FA</h2>
                <p className="text-sm opacity-90">Protege tu cuenta</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {isEnabled ? (
            // 2FA Enabled Status
            <div className="text-center">
              <div className={`w-20 h-20 mx-auto mb-4 ${isDark ? "bg-green-900/30" : "bg-green-100"} rounded-3xl flex items-center justify-center`}>
                <Check className={`w-10 h-10 ${isDark ? "text-green-400" : "text-green-600"}`} />
              </div>
              <h3 className={`text-xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                Autenticación Activa
              </h3>
              <p className={`text-sm mb-4 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Tu cuenta está protegida con autenticación de dos factores por{" "}
                {selectedMethod === "sms" ? "SMS" : "correo electrónico"}
              </p>
              <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4 mb-6`}>
                <p className={`text-sm ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                  {selectedMethod === "sms" ? `📱 ${phoneNumber}` : `📧 ${email}`}
                </p>
              </div>
              <button
                onClick={handleDisable}
                className={`w-full ${isDark ? "bg-red-900/30 hover:bg-red-900/50 text-red-400 border-red-800" : "bg-red-50 hover:bg-red-100 text-red-600 border-red-200"} border-2 py-3 rounded-xl transition-all`}
              >
                Desactivar 2FA
              </button>
            </div>
          ) : step === "select" ? (
            // Method Selection
            <div>
              <p className={`text-sm mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Selecciona cómo quieres recibir los códigos de verificación:
              </p>

              {/* SMS Option */}
              <button
                onClick={() => setSelectedMethod("sms")}
                className={`w-full p-4 rounded-2xl mb-3 transition-all ${
                  selectedMethod === "sms"
                    ? isDark
                      ? "bg-purple-900/50 border-2 border-purple-600"
                      : "bg-purple-50 border-2 border-purple-500"
                    : isDark
                    ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                    : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`w-12 h-12 ${selectedMethod === "sms" ? isDark ? "bg-purple-800" : "bg-purple-200" : isDark ? "bg-gray-600" : "bg-white"} rounded-xl flex items-center justify-center`}>
                    <Smartphone className={`w-6 h-6 ${selectedMethod === "sms" ? isDark ? "text-purple-400" : "text-purple-600" : isDark ? "text-gray-400" : "text-gray-600"}`} />
                  </div>
                  <div className="flex-1 text-left">
                    <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      Mensaje SMS
                    </p>
                    <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      Recibe códigos por mensaje de texto
                    </p>
                  </div>
                  {selectedMethod === "sms" && (
                    <Check className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
                  )}
                </div>
              </button>

              {/* Email Option */}
              <button
                onClick={() => setSelectedMethod("email")}
                className={`w-full p-4 rounded-2xl mb-6 transition-all ${
                  selectedMethod === "email"
                    ? isDark
                      ? "bg-purple-900/50 border-2 border-purple-600"
                      : "bg-purple-50 border-2 border-purple-500"
                    : isDark
                    ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                    : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`w-12 h-12 ${selectedMethod === "email" ? isDark ? "bg-purple-800" : "bg-purple-200" : isDark ? "bg-gray-600" : "bg-white"} rounded-xl flex items-center justify-center`}>
                    <Mail className={`w-6 h-6 ${selectedMethod === "email" ? isDark ? "text-purple-400" : "text-purple-600" : isDark ? "text-gray-400" : "text-gray-600"}`} />
                  </div>
                  <div className="flex-1 text-left">
                    <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      Correo Electrónico
                    </p>
                    <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      Recibe códigos por email
                    </p>
                  </div>
                  {selectedMethod === "email" && (
                    <Check className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
                  )}
                </div>
              </button>

              {/* Phone Number Input (if SMS selected) */}
              {selectedMethod === "sms" && (
                <div className="mb-6">
                  <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                    Número de Teléfono
                  </label>
                  <input
                    type="tel"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    placeholder="+52 123 456 7890"
                    className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                  />
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={onClose}
                  className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
                >
                  Cancelar
                </button>
                <button
                  onClick={handleSendCode}
                  disabled={!selectedMethod}
                  className={`flex-1 ${isDark ? "bg-gradient-to-r from-red-700 to-orange-700 hover:from-red-600 hover:to-orange-600 disabled:from-gray-700 disabled:to-gray-700" : "bg-gradient-to-r from-red-600 to-orange-600 hover:from-red-700 hover:to-orange-700 disabled:bg-gray-300"} text-white py-3 rounded-xl transition-all shadow-lg disabled:cursor-not-allowed`}
                >
                  Continuar
                </button>
              </div>
            </div>
          ) : (
            // Verification Code
            <div>
              <div className="text-center mb-6">
                <div className={`w-16 h-16 mx-auto mb-3 ${isDark ? "bg-red-900/30" : "bg-red-100"} rounded-3xl flex items-center justify-center`}>
                  {selectedMethod === "sms" ? (
                    <Smartphone className={`w-8 h-8 ${isDark ? "text-red-400" : "text-red-600"}`} />
                  ) : (
                    <Mail className={`w-8 h-8 ${isDark ? "text-red-400" : "text-red-600"}`} />
                  )}
                </div>
                <h3 className={`text-lg mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                  Ingresa el Código
                </h3>
                <p className={`text-sm ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Hemos enviado un código de 6 dígitos a{" "}
                  {selectedMethod === "sms" ? phoneNumber : email}
                </p>
              </div>

              {/* Code Input */}
              <div className="mb-6">
                <input
                  type="text"
                  value={verificationCode}
                  onChange={(e) => setVerificationCode(e.target.value.replace(/\D/g, "").slice(0, 6))}
                  placeholder="000000"
                  className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-4 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all text-center text-2xl tracking-widest font-mono`}
                  maxLength={6}
                />
              </div>

              <button
                onClick={() => {
                  toast.info("Código reenviado", {
                    description: "Hemos enviado un nuevo código",
                  });
                }}
                className={`w-full mb-4 text-sm ${isDark ? "text-purple-400 hover:text-purple-300" : "text-purple-600 hover:text-purple-700"} transition-colors`}
              >
                Reenviar código
              </button>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => setStep("select")}
                  className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
                >
                  Atrás
                </button>
                <button
                  onClick={handleVerify}
                  disabled={verificationCode.length !== 6}
                  className={`flex-1 ${isDark ? "bg-gradient-to-r from-red-700 to-orange-700 hover:from-red-600 hover:to-orange-600 disabled:from-gray-700 disabled:to-gray-700" : "bg-gradient-to-r from-red-600 to-orange-600 hover:from-red-700 hover:to-orange-700 disabled:bg-gray-300"} text-white py-3 rounded-xl transition-all shadow-lg disabled:cursor-not-allowed`}
                >
                  Verificar
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
