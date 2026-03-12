import { createContext, useContext, useState, ReactNode } from "react";

type Theme = "light" | "dark";

export interface ColorPalette {
  primary: string;
  secondary: string;
  accent: string;
  name: string;
}

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
  colorPalette: ColorPalette;
  setColorPalette: (palette: ColorPalette) => void;
  unlockedPalettes: string[];
  unlockPalette: (name: string) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<Theme>("light");
  const [colorPalette, setColorPaletteState] = useState<ColorPalette>({
    name: "Índigo Esmeralda",
    primary: "indigo",
    secondary: "emerald",
    accent: "violet",
  });
  const [unlockedPalettes, setUnlockedPalettes] = useState<string[]>(["Índigo Esmeralda"]);

  const toggleTheme = () => {
    setTheme((prev) => (prev === "light" ? "dark" : "light"));
  };

  const setColorPalette = (palette: ColorPalette) => {
    setColorPaletteState(palette);
  };

  const unlockPalette = (name: string) => {
    setUnlockedPalettes((prev) => prev.includes(name) ? prev : [...prev, name]);
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme, colorPalette, setColorPalette, unlockedPalettes, unlockPalette }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}