import { createContext, useContext, useState, ReactNode, useEffect } from "react";

interface User {
  email: string;
  name: string;
  purpose: string;
  hasCompletedTour: boolean;
  profileComplete: boolean;
  country?: string;
  currency?: string;
  salary?: string;
  salaryType?: "monthly" | "biweekly";
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => void;
  loginWithGoogle: () => void;
  register: (email: string, password: string, purpose: string) => void;
  logout: () => void;
  completeTour: () => void;
  updateProfile: (data: Partial<User>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  // Cargar usuario del localStorage al iniciar
  useEffect(() => {
    const savedUser = localStorage.getItem("user");
    if (savedUser) {
      setUser(JSON.parse(savedUser));
    }
  }, []);

  // Guardar usuario en localStorage cuando cambia
  useEffect(() => {
    if (user) {
      localStorage.setItem("user", JSON.stringify(user));
    } else {
      localStorage.removeItem("user");
    }
  }, [user]);

  const login = (email: string, password: string) => {
    // Simulación de login
    const mockUser: User = {
      email,
      name: email.split("@")[0],
      purpose: "Aprender a ahorrar",
      hasCompletedTour: false,
      profileComplete: false,
    };
    setUser(mockUser);
  };

  const loginWithGoogle = () => {
    // Simulación de login con Google
    const mockUser: User = {
      email: "usuario@gmail.com",
      name: "Usuario Demo",
      purpose: "Aprender a ahorrar",
      hasCompletedTour: false,
      profileComplete: false,
    };
    setUser(mockUser);
  };

  const register = (email: string, password: string, purpose: string) => {
    const mockUser: User = {
      email,
      name: email.split("@")[0],
      purpose,
      hasCompletedTour: false,
      profileComplete: false,
    };
    setUser(mockUser);
  };

  const logout = () => {
    setUser(null);
  };

  const completeTour = () => {
    if (user) {
      setUser({ ...user, hasCompletedTour: true });
    }
  };

  const updateProfile = (data: Partial<User>) => {
    if (user) {
      const updatedUser = { ...user, ...data };
      // Verificar si el perfil está completo
      if (updatedUser.country && updatedUser.currency && updatedUser.salary) {
        updatedUser.profileComplete = true;
      }
      setUser(updatedUser);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        login,
        loginWithGoogle,
        register,
        logout,
        completeTour,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
