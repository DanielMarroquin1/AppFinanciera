import { X, Save, Download, Loader2, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface LocalBackupModalProps {
  onClose: () => void;
}

export function LocalBackupModal({ onClose }: LocalBackupModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [isCreating, setIsCreating] = useState(false);
  const [lastBackup, setLastBackup] = useState("Hoy a las 10:30 AM");

  const handleCreateBackup = () => {
    setIsCreating(true);
    
    // Simular creación de respaldo
    setTimeout(() => {
      setIsCreating(false);
      const now = new Date();
      setLastBackup(`Hoy a las ${now.getHours()}:${String(now.getMinutes()).padStart(2, "0")}`);
      toast.success("Respaldo creado", {
        description: "Tus datos han sido respaldados localmente",
      });
    }, 1500);
  };

  const handleRestoreBackup = () => {
    toast.info("Restaurar respaldo", {
      description: "Esta función restaurará tus datos desde el último respaldo",
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-700 to-indigo-700" : "bg-gradient-to-r from-purple-600 to-indigo-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Save className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl mb-1">Respaldo Local</h2>
                <p className="text-sm opacity-90">Guarda tus datos en tu dispositivo</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Last Backup Info */}
          <div className={`${isDark ? "bg-gray-700/50" : "bg-purple-50"} rounded-2xl p-4 mb-6`}>
            <div className="flex items-center gap-3 mb-2">
              <Check className={`w-5 h-5 ${isDark ? "text-purple-400" : "text-purple-600"}`} />
              <span className={`text-sm ${isDark ? "text-white" : "text-gray-900"}`}>
                Último Respaldo
              </span>
            </div>
            <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"} ml-8`}>
              {lastBackup}
            </p>
          </div>

          {/* Info Cards */}
          <div className="space-y-3 mb-6">
            <div className={`${isDark ? "bg-gray-700/30" : "bg-blue-50"} rounded-xl p-3 flex items-start gap-3`}>
              <Save className={`w-5 h-5 ${isDark ? "text-blue-400" : "text-blue-600"} flex-shrink-0 mt-0.5`} />
              <div>
                <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                  Respaldo Automático
                </p>
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Se crea un respaldo automático cada 24 horas
                </p>
              </div>
            </div>

            <div className={`${isDark ? "bg-gray-700/30" : "bg-green-50"} rounded-xl p-3 flex items-start gap-3`}>
              <Download className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"} flex-shrink-0 mt-0.5`} />
              <div>
                <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                  Recuperación Rápida
                </p>
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Restaura tus datos en cualquier momento
                </p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-3">
            <button
              onClick={handleCreateBackup}
              disabled={isCreating}
              className={`w-full ${isDark ? "bg-gradient-to-r from-purple-700 to-indigo-700 hover:from-purple-600 hover:to-indigo-600" : "bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700"} text-white py-3 rounded-xl transition-all shadow-lg flex items-center justify-center gap-2 disabled:opacity-50`}
            >
              {isCreating ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Creando Respaldo...
                </>
              ) : (
                <>
                  <Save className="w-5 h-5" />
                  Crear Respaldo Ahora
                </>
              )}
            </button>

            <button
              onClick={handleRestoreBackup}
              className={`w-full ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all flex items-center justify-center gap-2`}
            >
              <Download className="w-5 h-5" />
              Restaurar Último Respaldo
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
