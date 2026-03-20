// src/components/protected.tsx
// Client-side guard: renders children only when a token is present in context.
// The middleware.ts handles the server-side redirect before the page renders,
// so this component acts as a client-side safety net and prevents flash.

"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { useAuth } from "@/context/auth-context"

export default function Protected({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (token === null) {
      router.push("/login")
    }
  }, [token, router])

  // Suppress flash while context hydrates from localStorage
  if (token === null) return null

  return <>{children}</>
}
