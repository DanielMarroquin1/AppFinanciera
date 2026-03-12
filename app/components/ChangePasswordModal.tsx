import { X, Lock, Eye, EyeOff } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface ChangePasswordModalProps {
  onClose: () => void;
}

export function ChangePasswordModal({ onClose }: ChangePasswordModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (newPassword !== confirmPassword) {
      toast.error("Las contraseñas no coinciden", {
        description: "Por favor verifica que ambas contraseñas sean iguales",
      });
      return;
    }

    if (newPassword.length < 8) {
      toast.error("Contraseña muy corta", {
        description: "La contraseña debe tener al menos 8 caracteres",
      });
      return;
    }

    // Aquí iría la lógica real para cambiar la contraseña
    toast.success("Contraseña actualizada", {
      description: "Tu contraseña ha sido cambiada exitosamente",
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-green-700 to-emerald-700" : "bg-gradient-to-r from-green-600 to-emerald-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Lock className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl mb-1">Cambiar Contraseña</h2>
                <p className="text-sm opacity-90">Actualiza tu contraseña</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Current Password */}
          <div>
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Contraseña Actual
            </label>
            <div className="relative">
              <Lock className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type={showCurrentPassword ? "text" : "password"}
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 pl-12 pr-12 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                className={`absolute right-4 top-1/2 -translate-y-1/2 ${isDark ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"} transition-colors`}
              >
                {showCurrentPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          {/* New Password */}
          <div>
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Nueva Contraseña
            </label>
            <div className="relative">
              <Lock className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type={showNewPassword ? "text" : "password"}
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 pl-12 pr-12 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowNewPassword(!showNewPassword)}
                className={`absolute right-4 top-1/2 -translate-y-1/2 ${isDark ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"} transition-colors`}
              >
                {showNewPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
            <p className={`text-xs mt-1 ${isDark ? "text-gray-500" : "text-gray-500"}`}>
              Mínimo 8 caracteres
            </p>
          </div>

          {/* Confirm Password */}
          <div>
            <label className={`block text-sm mb-2 ${isDark ? "text-gray-300" : "text-gray-700"}`}>
              Confirmar Nueva Contraseña
            </label>
            <div className="relative">
              <Lock className={`absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 ${isDark ? "text-gray-500" : "text-gray-400"}`} />
              <input
                type={showConfirmPassword ? "text" : "password"}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                className={`w-full ${isDark ? "bg-gray-700 border-gray-600 text-white" : "bg-white border-gray-300 text-gray-900"} border-2 py-3 pl-12 pr-12 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                className={`absolute right-4 top-1/2 -translate-y-1/2 ${isDark ? "text-gray-500 hover:text-gray-400" : "text-gray-400 hover:text-gray-600"} transition-colors`}
              >
                {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          {/* Actions */}
          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className={`flex-1 ${isDark ? "bg-gradient-to-r from-green-700 to-emerald-700 hover:from-green-600 hover:to-emerald-600" : "bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700"} text-white py-3 rounded-xl transition-all shadow-lg`}
            >
              Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
