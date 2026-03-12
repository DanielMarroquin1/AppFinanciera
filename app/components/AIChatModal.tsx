import { X, Send, Sparkles, TrendingUp, Target, PiggyBank } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState, useRef, useEffect } from "react";

interface AIChatModalProps {
  onClose: () => void;
}

interface Message {
  id: string;
  text: string;
  sender: "user" | "ai";
  timestamp: Date;
}

export function AIChatModal({ onClose }: AIChatModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "1",
      text: "¡Hola! 👋 Soy tu asistente financiero con IA. Estoy aquí para ayudarte con consejos de ahorro, análisis de gastos y planificación financiera. ¿En qué puedo ayudarte hoy?",
      sender: "ai",
      timestamp: new Date(),
    },
  ]);
  const [inputText, setInputText] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const quickQuestions = [
    { icon: PiggyBank, text: "¿Cómo puedo ahorrar más?", color: "green" },
    { icon: TrendingUp, text: "Analiza mis gastos", color: "blue" },
    { icon: Target, text: "Tips para mis metas", color: "purple" },
  ];

  const aiResponses: Record<string, string> = {
    "¿Cómo puedo ahorrar más?": "¡Excelente pregunta! 💰 Basándome en tus datos, te recomiendo:\n\n1. Aplica la regla 50/30/20: 50% necesidades, 30% gustos, 20% ahorros\n2. Automatiza tus ahorros - transfiere automáticamente al inicio del mes\n3. Revisa tus suscripciones - cancela las que no uses\n4. Compra inteligente - usa listas y evita compras impulsivas\n\n¿Quieres que profundice en alguno de estos puntos?",
    "Analiza mis gastos": "📊 He analizado tus gastos del último mes:\n\n🍔 Comida: $850 (33%)\n🚗 Transporte: $450 (18%)\n🎮 Ocio: $420 (16%)\n📱 Servicios: $500 (20%)\n🏠 Hogar: $330 (13%)\n\nObservo que gastas más en comida. Te sugiero:\n• Planear comidas semanales\n• Cocinar en casa más seguido\n• Usar apps de descuentos\n\nPodrías ahorrar hasta $200/mes optimizando estos gastos. ¿Te gustaría un plan personalizado?",
    "Tips para mis metas": "🎯 Consejos para tus metas de ahorro:\n\n1. Meta de Vacaciones ($2,000)\n   • Faltan 6 meses\n   • Ahorra $333/mes\n   • Consejo: Crea una cuenta separada\n\n2. Fondo de Emergencia ($5,000)\n   • Prioridad alta ⚠️\n   • Meta: 3-6 meses de gastos\n   • Empieza con $100/semana\n\n💡 Tip PRO: Ahorra cada aumento o bono que recibas. ¿Necesitas ajustar tus metas?",
  };

  const handleSendMessage = async () => {
    if (!inputText.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      text: inputText,
      sender: "user",
      timestamp: new Date(),
    };

    setMessages([...messages, userMessage]);
    setInputText("");
    setIsTyping(true);

    // Simulate AI thinking
    setTimeout(() => {
      const aiResponse = aiResponses[inputText] || 
        "Entiendo tu pregunta. 🤔 Basándome en tu perfil financiero, te recomiendo establecer metas claras, hacer un presupuesto realista y revisar tus gastos semanalmente. ¿Hay algo más específico en lo que pueda ayudarte?";
      
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: aiResponse,
        sender: "ai",
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, aiMessage]);
      setIsTyping(false);
    }, 1500);
  };

  const handleQuickQuestion = (question: string) => {
    setInputText(question);
    setTimeout(() => handleSendMessage(), 100);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div
        className={`relative w-full max-w-md ${
          isDark ? "bg-gray-900" : "bg-white"
        } rounded-t-3xl shadow-2xl transition-all duration-300 flex flex-col`}
        style={{ maxHeight: "90vh", height: "90vh" }}
      >
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-600 to-pink-600" : "bg-gradient-to-r from-purple-500 to-pink-500"} px-6 py-5 rounded-t-3xl flex-shrink-0`}>
          <div className="flex items-center justify-between text-white mb-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                <Sparkles className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-xl">Asistente IA</h2>
                <p className="text-xs text-white/80">Siempre disponible para ayudarte</p>
              </div>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${message.sender === "user" ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                  message.sender === "user"
                    ? isDark
                      ? "bg-purple-700 text-white"
                      : "bg-purple-600 text-white"
                    : isDark
                    ? "bg-gray-800 text-white border border-gray-700"
                    : "bg-gray-100 text-gray-900"
                }`}
              >
                {message.sender === "ai" && (
                  <div className="flex items-center gap-2 mb-1">
                    <Sparkles className="w-4 h-4 text-purple-400" />
                    <span className={`text-xs ${isDark ? "text-gray-400" : "text-gray-600"}`}>
                      Asistente IA
                    </span>
                  </div>
                )}
                <p className="text-sm whitespace-pre-line">{message.text}</p>
                <p className={`text-xs mt-1 ${message.sender === "user" ? "text-white/70" : isDark ? "text-gray-500" : "text-gray-500"}`}>
                  {message.timestamp.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                </p>
              </div>
            </div>
          ))}

          {isTyping && (
            <div className="flex justify-start">
              <div className={`max-w-[80%] rounded-2xl px-4 py-3 ${isDark ? "bg-gray-800 border border-gray-700" : "bg-gray-100"}`}>
                <div className="flex items-center gap-2">
                  <Sparkles className="w-4 h-4 text-purple-400" />
                  <div className="flex gap-1">
                    <div className={`w-2 h-2 ${isDark ? "bg-gray-600" : "bg-gray-400"} rounded-full animate-bounce`} style={{ animationDelay: "0ms" }}></div>
                    <div className={`w-2 h-2 ${isDark ? "bg-gray-600" : "bg-gray-400"} rounded-full animate-bounce`} style={{ animationDelay: "150ms" }}></div>
                    <div className={`w-2 h-2 ${isDark ? "bg-gray-600" : "bg-gray-400"} rounded-full animate-bounce`} style={{ animationDelay: "300ms" }}></div>
                  </div>
                </div>
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Quick Questions */}
        {messages.length === 1 && (
          <div className="px-4 pb-3 flex-shrink-0">
            <p className={`text-xs mb-2 ${isDark ? "text-gray-500" : "text-gray-500"}`}>
              Preguntas rápidas:
            </p>
            <div className="flex gap-2 overflow-x-auto pb-2">
              {quickQuestions.map((question, index) => {
                const Icon = question.icon;
                return (
                  <button
                    key={index}
                    onClick={() => handleQuickQuestion(question.text)}
                    className={`flex items-center gap-2 px-4 py-2 rounded-full text-sm whitespace-nowrap transition-all ${
                      isDark
                        ? "bg-gray-800 border border-gray-700 hover:bg-gray-750 text-white"
                        : "bg-white border border-gray-200 hover:bg-gray-50 text-gray-900"
                    }`}
                  >
                    <Icon className="w-4 h-4" />
                    {question.text}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* Input */}
        <div className={`${isDark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} border-t px-4 py-3 flex gap-2 flex-shrink-0`}>
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyPress={(e) => e.key === "Enter" && handleSendMessage()}
            placeholder="Escribe tu pregunta..."
            className={`flex-1 ${isDark ? "bg-gray-700 border-gray-600 text-white placeholder-gray-500" : "bg-white border-gray-300 text-gray-900 placeholder-gray-400"} border-2 py-3 px-4 rounded-xl focus:outline-none focus:border-purple-500 transition-all`}
          />
          <button
            onClick={handleSendMessage}
            disabled={!inputText.trim()}
            className={`${isDark ? "bg-purple-700 hover:bg-purple-600 disabled:bg-gray-700" : "bg-purple-600 hover:bg-purple-700 disabled:bg-gray-300"} text-white p-3 rounded-xl transition-all disabled:cursor-not-allowed flex-shrink-0`}
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}