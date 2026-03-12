import { X, Download, FileText, Lock, Crown } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface ExportDataModalProps {
  onClose: () => void;
  hasUnlockedExport: boolean;
}

type ExportFormat = "csv" | "excel" | "pdf";

export function ExportDataModal({ onClose, hasUnlockedExport }: ExportDataModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedFormat, setSelectedFormat] = useState<ExportFormat>("csv");
  const [isExporting, setIsExporting] = useState(false);

  const handleExport = () => {
    if (!hasUnlockedExport) {
      toast.error("Función Bloqueada", {
        description: "Desbloquea esta opción con puntos en la tiendita",
      });
      return;
    }

    setIsExporting(true);
    
    // Simular exportación
    setTimeout(() => {
      setIsExporting(false);
      toast.success("Datos exportados", {
        description: `Archivo ${selectedFormat.toUpperCase()} descargado exitosamente`,
      });
      onClose();
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-green-700 to-teal-700" : "bg-gradient-to-r from-green-600 to-teal-600"} px-6 py-5 rounded-t-3xl`}>
          <div className="flex items-center justify-between text-white">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Download className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-2xl mb-1">Exportar Datos</h2>
                <p className="text-sm opacity-90">Descarga tu información</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {!hasUnlockedExport ? (
            // Locked State
            <div className="text-center py-4">
              <div className={`w-20 h-20 mx-auto mb-4 ${isDark ? "bg-orange-900/30" : "bg-orange-100"} rounded-3xl flex items-center justify-center`}>
                <Lock className={`w-10 h-10 ${isDark ? "text-orange-400" : "text-orange-600"}`} />
              </div>
              <h3 className={`text-xl mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
                Función Bloqueada
              </h3>
              <p className={`text-sm mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Esta opción se desbloquea con 150 puntos en la tiendita de recompensas
              </p>
              <div className={`${isDark ? "bg-gray-700/50" : "bg-gray-50"} rounded-2xl p-4 mb-6`}>
                <div className="flex items-center justify-center gap-2 mb-2">
                  <span className="text-2xl">🎁</span>
                  <span className={`text-lg ${isDark ? "text-white" : "text-gray-900"}`}>150 puntos</span>
                </div>
                <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                  Gana puntos completando logros y metas de ahorro
                </p>
              </div>
              <button
                onClick={onClose}
                className={`w-full ${isDark ? "bg-gradient-to-r from-orange-700 to-red-700 hover:from-orange-600 hover:to-red-600" : "bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700"} text-white py-3 rounded-xl transition-all shadow-lg`}
              >
                Ir a la Tiendita
              </button>
            </div>
          ) : (
            // Export Options
            <div>
              <p className={`text-sm mb-6 ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                Selecciona el formato para exportar tus datos:
              </p>

              {/* Format Options */}
              <div className="space-y-3 mb-6">
                {/* CSV */}
                <button
                  onClick={() => setSelectedFormat("csv")}
                  className={`w-full p-4 rounded-2xl transition-all ${
                    selectedFormat === "csv"
                      ? isDark
                        ? "bg-green-900/50 border-2 border-green-600"
                        : "bg-green-50 border-2 border-green-500"
                      : isDark
                      ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                      : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 ${selectedFormat === "csv" ? isDark ? "bg-green-800" : "bg-green-200" : isDark ? "bg-gray-600" : "bg-white"} rounded-xl flex items-center justify-center`}>
                      <FileText className={`w-6 h-6 ${selectedFormat === "csv" ? isDark ? "text-green-400" : "text-green-600" : isDark ? "text-gray-400" : "text-gray-600"}`} />
                    </div>
                    <div className="flex-1 text-left">
                      <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                        CSV (Excel compatible)
                      </p>
                      <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                        Compatible con Excel, Sheets y otras apps
                      </p>
                    </div>
                  </div>
                </button>

                {/* Excel */}
                <button
                  onClick={() => setSelectedFormat("excel")}
                  className={`w-full p-4 rounded-2xl transition-all ${
                    selectedFormat === "excel"
                      ? isDark
                        ? "bg-green-900/50 border-2 border-green-600"
                        : "bg-green-50 border-2 border-green-500"
                      : isDark
                      ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                      : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 ${selectedFormat === "excel" ? isDark ? "bg-green-800" : "bg-green-200" : isDark ? "bg-gray-600" : "bg-white"} rounded-xl flex items-center justify-center`}>
                      <span className="text-2xl">📊</span>
                    </div>
                    <div className="flex-1 text-left">
                      <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                        Excel (.xlsx)
                      </p>
                      <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                        Formato nativo de Microsoft Excel
                      </p>
                    </div>
                  </div>
                </button>

                {/* PDF */}
                <button
                  onClick={() => setSelectedFormat("pdf")}
                  className={`w-full p-4 rounded-2xl transition-all ${
                    selectedFormat === "pdf"
                      ? isDark
                        ? "bg-green-900/50 border-2 border-green-600"
                        : "bg-green-50 border-2 border-green-500"
                      : isDark
                      ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                      : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 ${selectedFormat === "pdf" ? isDark ? "bg-green-800" : "bg-green-200" : isDark ? "bg-gray-600" : "bg-white"} rounded-xl flex items-center justify-center`}>
                      <span className="text-2xl">📄</span>
                    </div>
                    <div className="flex-1 text-left">
                      <p className={`text-sm mb-1 ${isDark ? "text-white" : "text-gray-900"}`}>
                        PDF
                      </p>
                      <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                        Documento para visualizar e imprimir
                      </p>
                    </div>
                  </div>
                </button>
              </div>

              {/* Info */}
              <div className={`${isDark ? "bg-blue-900/30" : "bg-blue-50"} rounded-xl p-3 mb-6`}>
                <p className={`text-xs ${isDark ? "text-blue-300" : "text-blue-800"}`}>
                  📦 Se incluirán todos tus gastos, ingresos y metas de ahorro
                </p>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={onClose}
                  className={`flex-1 ${isDark ? "bg-gray-700 hover:bg-gray-600 text-white" : "bg-gray-100 hover:bg-gray-200 text-gray-900"} py-3 rounded-xl transition-all`}
                >
                  Cancelar
                </button>
                <button
                  onClick={handleExport}
                  disabled={isExporting}
                  className={`flex-1 ${isDark ? "bg-gradient-to-r from-green-700 to-teal-700 hover:from-green-600 hover:to-teal-600" : "bg-gradient-to-r from-green-600 to-teal-600 hover:from-green-700 hover:to-teal-700"} text-white py-3 rounded-xl transition-all shadow-lg disabled:opacity-50 flex items-center justify-center gap-2`}
                >
                  {isExporting ? "Exportando..." : "Exportar"}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
