import { X, Cloud, Check, Loader2, Crown } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface CloudSyncModalProps {
  onClose: () => void;
  isPremium: boolean;
}

export function CloudSyncModal({ onClose, isPremium }: CloudSyncModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [isSyncing, setIsSyncing] = useState(false);
  const [syncEnabled, setSyncEnabled] = useState(true);
  const [lastSync, setLastSync] = useState("Hace 5 minutos");

  const handleSync = () => {
    if (!isPremium) {
      toast.error("Función Premium", {
        description: "Actualiza a Premium para usar sincronización en la nube",
      });
      return;
    }

    setIsSyncing(true);
    
    // Simular sincronización
    setTimeout(() => {
      setIsSyncing(false);
      setLastSync("Ahora mismo");
      toast.success("Sincronización completa", {
        description: "Tus datos están actualizados en la nube",
      });
    }, 2000);
  };

  const handleToggleSync = () => {
    if (!isPremium) {
      toast.error("Función Premium", {
        description: "Actualiza a Premium para usar sincronización en la nube",
      });
      return;
    }

    setSyncEnabled(!syncEnabled);
    toast.success(syncEnabled ? "Sincronización pausada" : "Sincronización activada", {
      description: syncEnabled ? "No se sincronizará automáticamente" : "Tus datos se sincronizarán automáticamente",
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-blue-700 to-cyan-700" : "bg-gradient-to-r from-blue-600 to-cyan-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Cloud className="w-6 h-6" />
              </div>
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-2xl">Sincronización</h2>
                  {!isPremium && (
                    <div className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full flex items-center gap-1">
                      <Crown className="w-3 h-3" />
                      PRO
                    </div>
                  )}
                </div>
                <p className="text-sm opacity-90">Guarda tus datos en la nube</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {!isPremium ? (
            // Premium Required
            <div className="text-center py-4">
              <div className={`w-20 h-20 mx-auto mb-4 ${isDark ? "bg-amber-900/30" : "bg-amber-100"} rounded-3xl flex items-center justify-center`}>
                <Crown className={`w-10 h-10 ${isDark ? "text-amber-400" : "text-amber-600"}`} />
              </div>
              <h3 className={`text-xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                Función Premium
              </h3>
              <p className={`text-sm mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Actualiza a Premium para sincronizar tus datos en la nube y acceder desde cualquier dispositivo
              </p>
              <button
                onClick={onClose}
                className={`w-full ${isDark ? "bg-gradient-to-r from-amber-700 to-orange-700 hover:from-amber-600 hover:to-orange-600" : "bg-gradient-to-r from-amber-600 to-orange-600 hover:from-amber-700 hover:to-orange-700"} text-white py-3 rounded-xl transition-all shadow-lg`}
              >
                Ver Planes Premium
              </button>
            </div>
          ) : (
            // Sync Controls
            <div>
              {/* Status */}
              <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4 mb-6`}>
                <div className="flex items-center justify-between mb-3">
                  <span className={`text-sm ${isDark ? "text-gray-300" : "text-gray-700"}`}>
                    Sincronización Automática
                  </span>
                  <button
                    onClick={handleToggleSync}
                    className={`w-12 h-6 rounded-full relative transition-all ${syncEnabled ? isDark ? "bg-blue-600" : "bg-blue-500" : isDark ? "bg-gray-600" : "bg-gray-300"}`}
                  >
                    <div
                      className={`w-5 h-5 bg-white rounded-full absolute top-0.5 shadow-sm transition-all ${syncEnabled ? "left-6" : "left-0.5"}`}
                    ></div>
                  </button>
                </div>
                <div className="flex items-center gap-2">
                  <Check className={`w-4 h-4 ${isDark ? "text-green-400" : "text-green-600"}`} />
                  <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                    Última sincronización: {lastSync}
                  </span>
                </div>
              </div>

              {/* Sync Info */}
              <div className="space-y-3 mb-6">
                <div className={`${isDark ? "bg-gray-700/30" : "bg-blue-50"} rounded-xl p-3 flex items-start gap-3`}>
                  <Cloud className={`w-5 h-5 ${isDark ? "text-blue-400" : "text-blue-600"} flex-shrink-0 mt-0.5`} />
                  <div>
                    <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      Datos Respaldados
                    </p>
                    <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      Gastos, ingresos, metas de ahorro y configuración
                    </p>
                  </div>
                </div>

                <div className={`${isDark ? "bg-gray-700/30" : "bg-green-50"} rounded-xl p-3 flex items-start gap-3`}>
                  <Check className={`w-5 h-5 ${isDark ? "text-green-400" : "text-green-600"} flex-shrink-0 mt-0.5`} />
                  <div>
                    <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                      Acceso Multiplataforma
                    </p>
                    <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      Accede desde cualquier dispositivo con tu cuenta
                    </p>
                  </div>
                </div>
              </div>

              {/* Actions */}
              <button
                onClick={handleSync}
                disabled={isSyncing}
                className={`w-full ${isDark ? "bg-gradient-to-r from-blue-700 to-cyan-700 hover:from-blue-600 hover:to-cyan-600" : "bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700"} text-white py-3 rounded-xl transition-all shadow-lg flex items-center justify-center gap-2 disabled:opacity-50`}
              >
                {isSyncing ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Sincronizando...
                  </>
                ) : (
                  <>
                    <Cloud className="w-5 h-5" />
                    Sincronizar Ahora
                  </>
                )}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
