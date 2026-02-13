import { motion } from "motion/react";
import { useEffect, useState } from "react";

interface BreathingCircleProps {
  pattern: {
    inhale: number;
    hold1: number;
    exhale: number;
    hold2: number;
  };
  isActive: boolean;
}

export function BreathingCircle({ pattern, isActive }: BreathingCircleProps) {
  const [phase, setPhase] = useState<"inhale" | "hold1" | "exhale" | "hold2">("inhale");
  const [cycleCount, setCycleCount] = useState(0);

  useEffect(() => {
    if (!isActive) {
      setPhase("inhale");
      return;
    }

    const totalCycleTime = pattern.inhale + pattern.hold1 + pattern.exhale + pattern.hold2;
    let currentTime = 0;

    const interval = setInterval(() => {
      currentTime += 100;
      const timeInCycle = currentTime % (totalCycleTime * 1000);

      if (timeInCycle < pattern.inhale * 1000) {
        setPhase("inhale");
      } else if (timeInCycle < (pattern.inhale + pattern.hold1) * 1000) {
        setPhase("hold1");
      } else if (timeInCycle < (pattern.inhale + pattern.hold1 + pattern.exhale) * 1000) {
        setPhase("exhale");
      } else {
        setPhase("hold2");
      }

      if (timeInCycle < 100) {
        setCycleCount((prev) => prev + 1);
      }
    }, 100);

    return () => clearInterval(interval);
  }, [isActive, pattern]);

  const getScale = () => {
    if (phase === "inhale") return 1.5;
    if (phase === "exhale") return 0.7;
    return phase === "hold1" ? 1.5 : 0.7;
  };

  const getTransitionDuration = () => {
    if (phase === "inhale") return pattern.inhale;
    if (phase === "exhale") return pattern.exhale;
    return 0;
  };

  const getInstruction = () => {
    if (phase === "inhale") return "Breathe In";
    if (phase === "hold1") return "Hold";
    if (phase === "exhale") return "Breathe Out";
    return "Hold";
  };

  return (
    <div className="flex flex-col items-center justify-center gap-8">
      <div className="relative w-64 h-64 flex items-center justify-center">
        <motion.div
          className="absolute w-32 h-32 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 opacity-30"
          animate={{
            scale: getScale(),
          }}
          transition={{
            duration: getTransitionDuration(),
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute w-32 h-32 rounded-full bg-gradient-to-br from-blue-400 to-purple-500"
          animate={{
            scale: getScale(),
          }}
          transition={{
            duration: getTransitionDuration(),
            ease: "easeInOut",
          }}
        />
      </div>
      <div className="text-center">
        <p className="text-2xl text-white/90">{isActive ? getInstruction() : "Press Start"}</p>
        {isActive && <p className="text-sm text-white/60 mt-2">Cycle {cycleCount}</p>}
      </div>
    </div>
  );
}
