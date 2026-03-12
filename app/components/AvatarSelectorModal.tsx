import { X, Crown, Lock, Check } from "lucide-react";
import { useTheme } from "../context/ThemeContext";
import { useState } from "react";
import { toast } from "sonner";

interface AvatarSelectorModalProps {
  onClose: () => void;
  onSelect: (avatar: string) => void;
  currentAvatar: string;
  isPremiumUser: boolean;
}

interface Avatar {
  emoji: string;
  isPremium: boolean;
}

const avatars: Avatar[] = [
  // Free avatars (5)
  { emoji: "👤", isPremium: false },
  { emoji: "👨", isPremium: false },
  { emoji: "👩", isPremium: false },
  { emoji: "🧑", isPremium: false },
  { emoji: "😊", isPremium: false },
  // Premium avatars
  { emoji: "👴", isPremium: true },
  { emoji: "👵", isPremium: true },
  { emoji: "👨‍💼", isPremium: true },
  { emoji: "👩‍💼", isPremium: true },
  { emoji: "👨‍🎓", isPremium: true },
  { emoji: "👩‍🎓", isPremium: true },
  { emoji: "👨‍⚕️", isPremium: true },
  { emoji: "👩‍⚕️", isPremium: true },
  { emoji: "👨‍🔧", isPremium: true },
  { emoji: "👩‍🔧", isPremium: true },
  { emoji: "👨‍🍳", isPremium: true },
  { emoji: "👩‍🍳", isPremium: true },
  { emoji: "🦸‍♂️", isPremium: true },
  { emoji: "🦸‍♀️", isPremium: true },
  { emoji: "🧙‍♂️", isPremium: true },
  { emoji: "🧙‍♀️", isPremium: true },
  { emoji: "🧝‍♂️", isPremium: true },
  { emoji: "🧝‍♀️", isPremium: true },
  { emoji: "🧚‍♂️", isPremium: true },
  { emoji: "🧚‍♀️", isPremium: true },
  { emoji: "🐶", isPremium: true },
  { emoji: "🐱", isPremium: true },
  { emoji: "🐭", isPremium: true },
  { emoji: "🐹", isPremium: true },
  { emoji: "🐰", isPremium: true },
  { emoji: "🦊", isPremium: true },
  { emoji: "🐻", isPremium: true },
  { emoji: "🐼", isPremium: true },
  { emoji: "🐨", isPremium: true },
  { emoji: "🐯", isPremium: true },
  { emoji: "🦁", isPremium: true },
];

export function AvatarSelectorModal({ onClose, onSelect, currentAvatar, isPremiumUser }: AvatarSelectorModalProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [selectedAvatar, setSelectedAvatar] = useState(currentAvatar);

  const handleSelect = () => {
    onSelect(selectedAvatar);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal */}
      <div className={`relative w-full max-w-md ${isDark ? "bg-gray-800" : "bg-white"} rounded-3xl shadow-2xl transition-all duration-300 max-h-[80vh] overflow-y-auto`}>
        {/* Header */}
        <div className={`${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700" : "bg-gradient-to-r from-purple-600 to-blue-600"} px-6 py-5 rounded-t-3xl sticky top-0 z-10`}>
          <div className="flex items-center justify-between text-white">
            <div>
              <h2 className="text-2xl mb-1">Selecciona tu Avatar 🎭</h2>
              <p className="text-sm opacity-90">Personaliza tu perfil</p>
            </div>
            <button onClick={onClose} className="hover:bg-white/20 rounded-full p-1 transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Selected Avatar Preview */}
          <div className="flex justify-center mb-6">
            <div className={`w-24 h-24 ${isDark ? "bg-gradient-to-br from-purple-900 to-blue-900" : "bg-gradient-to-br from-purple-100 to-blue-100"} rounded-3xl flex items-center justify-center text-5xl shadow-lg`}>
              {selectedAvatar}
            </div>
          </div>

          {/* Avatar Grid */}
          <div className="grid grid-cols-6 gap-2 mb-6">
            {avatars.map((avatar) => {
              const isLocked = avatar.isPremium && !isPremiumUser;
              return (
                <button
                  key={avatar.emoji}
                  onClick={() => {
                    if (isLocked) {
                      toast.error("Avatar Premium", {
                        description: "Necesitas ser Premium o canjearlo en la tienda",
                      });
                    } else {
                      setSelectedAvatar(avatar.emoji);
                    }
                  }}
                  className={`aspect-square p-2 rounded-xl text-2xl transition-all relative ${
                    selectedAvatar === avatar.emoji
                      ? isDark
                        ? "bg-purple-900/50 border-2 border-purple-600"
                        : "bg-purple-100 border-2 border-purple-500"
                      : isLocked
                      ? isDark
                        ? "bg-gray-800 hover:bg-gray-750 opacity-50"
                        : "bg-gray-200 hover:bg-gray-300 opacity-50"
                      : isDark
                      ? "bg-gray-700 hover:bg-gray-650"
                      : "bg-gray-100 hover:bg-gray-200"
                  }`}
                >
                  {isLocked ? (
                    <Lock className={`w-5 h-5 ${isDark ? "text-gray-600" : "text-gray-400"}`} />
                  ) : (
                    avatar.emoji
                  )}
                  {avatar.isPremium && !isLocked && (
                    <div className="absolute -top-1 -right-1 w-4 h-4 bg-amber-500 rounded-full flex items-center justify-center">
                      <Crown className="w-2.5 h-2.5 text-white" />
                    </div>
                  )}
                  {selectedAvatar === avatar.emoji && !isLocked && (
                    <div className={`absolute -top-1 -right-1 w-5 h-5 rounded-full flex items-center justify-center ${isDark ? "bg-purple-600" : "bg-purple-500"}`}>
                      <Check className="w-3 h-3 text-white" />
                    </div>
                  )}
                  {isLocked && (
                    <div className="absolute -top-1 -right-1 w-4 h-4 bg-amber-500 rounded-full flex items-center justify-center">
                      <Crown className="w-2.5 h-2.5 text-white" />
                    </div>
                  )}
                </button>
              );
            })}
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
              onClick={handleSelect}
              className={`flex-1 ${isDark ? "bg-gradient-to-r from-purple-700 to-blue-700 hover:from-purple-600 hover:to-blue-600" : "bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"} text-white py-3 rounded-xl transition-all shadow-lg`}
            >
              Seleccionar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
