// src/context/auth-context.tsx

"use client"

import { createContext, useContext, useEffect, useState } from "react"
import type { AuthUser } from "@/types/auth"

export type { AuthUser }

type AuthContextType = {
  token: string | null
  user: AuthUser | null
  setToken: (token: string | null) => void
  setUser: (user: AuthUser | null) => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setTokenState] = useState<string | null>(null)
  const [user, setUserState] = useState<AuthUser | null>(null)

  useEffect(() => {
    const storedToken = localStorage.getItem("auth_token")
    const storedUser = localStorage.getItem("auth_user")

    if (storedToken) setTokenState(storedToken)
    if (storedUser) {
      try {
        setUserState(JSON.parse(storedUser))
      } catch {
        localStorage.removeItem("auth_user")
      }
    }
  }, [])

  function setToken(t: string | null) {
    setTokenState(t)
    if (t) {
      localStorage.setItem("auth_token", t)
    } else {
      localStorage.removeItem("auth_token")
    }
  }

  function setUser(u: AuthUser | null) {
    setUserState(u)
    if (u) {
      localStorage.setItem("auth_user", JSON.stringify(u))
    } else {
      localStorage.removeItem("auth_user")
    }
  }

  return (
    <AuthContext.Provider value={{ token, user, setToken, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)

  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider")
  }

  return context
}
