import { useState } from "react";
import { X, ChevronRight, ChevronLeft } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { useTheme } from "../context/ThemeContext";

interface TourStep {
  title: string;
  description: string;
  emoji: string;
  position: "top" | "center" | "bottom";
}

const tourSteps: TourStep[] = [
  {
    title: "¡Bienvenido! 🎉",
    description: "Estamos felices de tenerte aquí. Te mostraremos cómo funciona la app en segundos.",
    emoji: "👋",
    position: "center",
  },
  {
    title: "Dashboard",
    description: "Aquí verás tu resumen financiero: gastos, ahorros y balance general.",
    emoji: "🏠",
    position: "top",
  },
  {
    title: "Mis Gastos",
    description: "Registra y categoriza todos tus gastos para saber en qué gastas tu dinero.",
    emoji: "📊",
    position: "top",
  },
  {
    title: "Mis Ahorros",
    description: "Crea metas de ahorro y trackea tu progreso. ¡Gamifica tus finanzas!",
    emoji: "🎯",
    position: "top",
  },
  {
    title: "Estadísticas",
    description: "Visualiza reportes detallados con gráficos y obtén insights sobre tus finanzas.",
    emoji: "📈",
    position: "top",
  },
  {
    title: "¡Listo para empezar! 🚀",
    description: "Completa tu perfil en Ajustes para personalizar tu experiencia.",
    emoji: "✨",
    position: "center",
  },
];

export function OnboardingTour() {
  const [currentStep, setCurrentStep] = useState(0);
  const { completeTour } = useAuth();
  const { theme } = useTheme();
  const isDark = theme === "dark";

  const handleNext = () => {
    if (currentStep < tourSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      completeTour();
    }
  };

  const handlePrev = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleSkip = () => {
    completeTour();
  };

  const step = tourSteps[currentStep];
  const isFirst = currentStep === 0;
  const isLast = currentStep === tourSteps.length - 1;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={handleSkip}></div>

      {/* Tour Card */}
      <div
        className={`relative max-w-sm w-full ${
          isDark
            ? "bg-gray-800 border-gray-700"
            : "bg-white border-white/20"
        } border-2 rounded-3xl p-6 shadow-2xl transition-all duration-300`}
      >
        {/* Close Button */}
        <button
          onClick={handleSkip}
          className={`absolute top-4 right-4 ${
            isDark
              ? "text-gray-400 hover:text-gray-300"
              : "text-gray-400 hover:text-gray-600"
          } transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>

        {/* Emoji */}
        <div className="text-center mb-4">
          <div
            className={`w-20 h-20 ${
              isDark
                ? "bg-gradient-to-br from-purple-700 to-blue-700"
                : "bg-gradient-to-br from-purple-600 to-blue-600"
            } rounded-3xl flex items-center justify-center mx-auto shadow-lg`}
          >
            <span className="text-4xl">{step.emoji}</span>
          </div>
        </div>

        {/* Content */}
        <h2
          className={`text-2xl text-center mb-3 ${
            isDark ? "text-white" : "text-gray-900"
          }`}
        >
          {step.title}
        </h2>
        <p
          className={`text-center mb-6 ${
            isDark ? "text-gray-400" : "text-gray-600"
          }`}
        >
          {step.description}
        </p>

        {/* Progress Dots */}
        <div className="flex justify-center gap-2 mb-6">
          {tourSteps.map((_, index) => (
            <div
              key={index}
              className={`h-2 rounded-full transition-all ${
                index === currentStep
                  ? isDark
                    ? "w-8 bg-purple-600"
                    : "w-8 bg-purple-600"
                  : isDark
                  ? "w-2 bg-gray-700"
                  : "w-2 bg-gray-300"
              }`}
            ></div>
          ))}
        </div>

        {/* Navigation Buttons */}
        <div className="flex gap-3">
          {!isFirst && (
            <button
              onClick={handlePrev}
              className={`flex-1 ${
                isDark
                  ? "bg-gray-700 hover:bg-gray-600 text-white"
                  : "bg-gray-200 hover:bg-gray-300 text-gray-900"
              } py-3 rounded-xl transition-all flex items-center justify-center gap-2`}
            >
              <ChevronLeft className="w-5 h-5" />
              Anterior
            </button>
          )}
          <button
            onClick={handleNext}
            className={`${isFirst ? "w-full" : "flex-1"} ${
              isDark
                ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600"
                : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"
            } text-white py-3 rounded-xl transition-all shadow-lg hover:shadow-xl flex items-center justify-center gap-2`}
          >
            {isLast ? "¡Comenzar!" : "Siguiente"}
            {!isLast && <ChevronRight className="w-5 h-5" />}
          </button>
        </div>

        {/* Skip Button */}
        {!isLast && (
          <button
            onClick={handleSkip}
            className={`w-full mt-3 text-sm ${
              isDark
                ? "text-gray-500 hover:text-gray-400"
                : "text-gray-500 hover:text-gray-600"
            } transition-colors`}
          >
            Saltar tutorial
          </button>
        )}
      </div>
    </div>
  );
}