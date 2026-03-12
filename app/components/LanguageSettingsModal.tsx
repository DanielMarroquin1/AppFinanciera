import { X, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";

interface LanguageSettingsModalProps {
  onClose: () => void;
}

const languages = [
  { code: "es", name: "Español", flag: "🇪🇸", native: "Español" },
  { code: "en", name: "English", flag: "🇺🇸", native: "English" },
  { code: "pt", name: "Portuguese", flag: "🇧🇷", native: "Português" },
  { code: "fr", name: "French", flag: "🇫🇷", native: "Français" },
  { code: "de", name: "German", flag: "🇩🇪", native: "Deutsch" },
  { code: "it", name: "Italian", flag: "🇮🇹", native: "Italiano" },
  { code: "ja", name: "Japanese", flag: "🇯🇵", native: "日本語" },
  { code: "ko", name: "Korean", flag: "🇰🇷", native: "한국어" },
  { code: "zh", name: "Chinese", flag: "🇨🇳", native: "中文" },
];

export function LanguageSettingsModal({ onClose }: LanguageSettingsModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedLanguage, setSelectedLanguage] = useState("es");

  const handleSelect = (code: string) => {
    setSelectedLanguage(code);
    // Aquí iría la lógica para cambiar el idioma de la app
    setTimeout(() => {
      onClose();
    }, 500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800 border-gray-700" : "bg-white border-white/20"} border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300 max-h-[85vh] overflow-y-auto`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${isDark ? "text-gray-400 hover:text-gray-300" : "text-gray-400 hover:text-gray-600"} transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>

        <div className="mb-6">
          <div className="text-4xl mb-3 text-center">🌍</div>
          <h2 className={`text-2xl text-center mb-2 ${isDark ? "text-white" : "text-gray-900"}`}>
            Idioma
          </h2>
          <p className={`text-sm text-center ${isDark ? "text-gray-400" : "text-gray-600"}`}>
            Selecciona tu idioma preferido
          </p>
        </div>

        {/* Language List */}
        <div className="space-y-2">
          {languages.map((language) => (
            <button
              key={language.code}
              onClick={() => handleSelect(language.code)}
              className={`w-full p-4 rounded-2xl flex items-center justify-between transition-all ${
                selectedLanguage === language.code
                  ? isDark
                    ? "bg-purple-900/50 border-2 border-purple-600"
                    : "bg-purple-100 border-2 border-purple-500"
                  : isDark
                  ? "bg-gray-700 border-2 border-gray-600 hover:border-gray-500"
                  : "bg-gray-50 border-2 border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="flex items-center gap-3">
                <span className="text-3xl">{language.flag}</span>
                <div className="text-left">
                  <p className={`text-sm font-medium ${isDark ? "text-white" : "text-gray-900"}`}>
                    {language.native}
                  </p>
                  <p className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                    {language.name}
                  </p>
                </div>
              </div>
              {selectedLanguage === language.code && (
                <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isDark ? "bg-purple-600" : "bg-purple-500"}`}>
                  <Check className="w-4 h-4 text-white" />
                </div>
              )}
            </button>
          ))}
        </div>

        {/* Info */}
        <div className={`${isDark ? "bg-blue-900/30 border-blue-800" : "bg-blue-50 border-blue-200"} rounded-xl p-3 mt-6 border`}>
          <p className={`text-xs ${isDark ? "text-blue-300" : "text-blue-700"}`}>
            💡 El idioma se aplicará inmediatamente en toda la aplicación
          </p>
        </div>
      </div>
    </div>
  );
}
