import { Volume2, VolumeX } from "lucide-react";
import { useEffect, useRef, useState } from "react";

interface NatureSoundProps {
  name: string;
  icon: React.ReactNode;
  soundUrl: string;
  isActive: boolean;
  onToggle: () => void;
}

export function NatureSound({ name, icon, isActive, onToggle }: NatureSoundProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [volume, setVolume] = useState(0.5);

  useEffect(() => {
    // Create audio context for continuous looping
    if (!audioRef.current) {
      audioRef.current = new Audio();
      audioRef.current.loop = true;
      audioRef.current.volume = volume;
    }

    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, []);

  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = volume;
    }
  }, [volume]);

  useEffect(() => {
    if (audioRef.current) {
      if (isActive) {
        // In a real app, you would use actual sound URLs
        // For demo purposes, we'll just manage the state
        audioRef.current.play().catch(() => {
          // Handle autoplay restrictions
        });
      } else {
        audioRef.current.pause();
      }
    }
  }, [isActive]);

  return (
    <div
      className={`flex items-center gap-3 p-4 rounded-2xl border-2 transition-all cursor-pointer ${
        isActive
          ? "border-blue-400 bg-blue-400/10"
          : "border-white/10 bg-white/5 hover:bg-white/10"
      }`}
      onClick={onToggle}
    >
      <div className="text-white/80">{icon}</div>
      <div className="flex-1">
        <p className="text-white/90">{name}</p>
      </div>
      {isActive ? (
        <Volume2 className="w-5 h-5 text-blue-400" />
      ) : (
        <VolumeX className="w-5 h-5 text-white/40" />
      )}
    </div>
  );
}
