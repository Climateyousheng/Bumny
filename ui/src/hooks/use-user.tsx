import { createContext, useContext, useState, useCallback, type ReactNode } from "react";
import { getUsername, setUsername as storeUsername } from "@/lib/user-store";

interface UserContextValue {
  readonly username: string;
  readonly setUsername: (name: string) => void;
}

const UserContext = createContext<UserContextValue | null>(null);

interface UserProviderProps {
  readonly children: ReactNode;
  readonly initialUsername?: string;
}

export function UserProvider({ children, initialUsername }: UserProviderProps) {
  const [username, setUsernameState] = useState(() => initialUsername ?? getUsername());

  const setUsername = useCallback((name: string) => {
    storeUsername(name);
    setUsernameState(name);
  }, []);

  return (
    <UserContext.Provider value={{ username, setUsername }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser(): UserContextValue {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error("useUser must be used within a UserProvider");
  }
  return context;
}
