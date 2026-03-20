#!/usr/bin/env bash
# bin/steps/21_nextjs_auth.sh
# Wire stateless JWT authentication into the Next.js portal.
# Requires step 17 (devise-jwt on the Rails API) and step 20 (Next.js scaffold).

set -euo pipefail

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-portal

info "Creating canonical auth types..."
mkdir -p src/types
cat << 'EOF' > src/types/auth.ts
// src/types/auth.ts

export type AuthUser = {
  id: number
  email: string
}

export type AuthState = {
  token: string | null
  user: AuthUser | null
}

export type LoginResponse = {
  token: string
  user: AuthUser
}
EOF

info "Creating auth context..."
mkdir -p src/context
cat << 'EOF' > src/context/auth-context.tsx
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
      try { setUserState(JSON.parse(storedUser)) } catch { localStorage.removeItem("auth_user") }
    }
  }, [])

  function setToken(t: string | null) {
    setTokenState(t)
    t ? localStorage.setItem("auth_token", t) : localStorage.removeItem("auth_token")
  }

  function setUser(u: AuthUser | null) {
    setUserState(u)
    u ? localStorage.setItem("auth_user", JSON.stringify(u)) : localStorage.removeItem("auth_user")
  }

  return (
    <AuthContext.Provider value={{ token, user, setToken, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error("useAuth must be used inside AuthProvider")
  return context
}
EOF

info "Creating login/logout utilities..."
mkdir -p src/lib/auth
cat << 'EOF' > src/lib/auth.ts
import type { AuthUser, LoginResponse } from "@/types/auth"

export async function login(email: string, password: string): Promise<LoginResponse> {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ user: { email, password } }),
  })
  if (!res.ok) throw new Error("Invalid email or password")

  const token = (res.headers.get("Authorization") ?? "").replace("Bearer ", "")
  if (!token) throw new Error("No token received from server")

  const data = await res.json()
  const user: AuthUser = data.user

  localStorage.setItem("auth_token", token)
  localStorage.setItem("auth_user", JSON.stringify(user))
  document.cookie = `auth_token=${token}; path=/; max-age=86400; SameSite=Lax`

  return { token, user }
}
EOF

cat << 'EOF' > src/lib/auth/logout.ts
export async function logout(): Promise<void> {
  const token = localStorage.getItem("auth_token")
  if (token) {
    await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/auth/logout`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${token}` },
    }).catch(() => {})
  }
  localStorage.removeItem("auth_token")
  localStorage.removeItem("auth_user")
  document.cookie = "auth_token=; path=/; max-age=0; SameSite=Lax"
}
EOF

info "Creating middleware for server-side route protection..."
cat << 'EOF' > src/middleware.ts
import { NextRequest, NextResponse } from "next/server"

const PROTECTED_ROUTES = ["/dashboard", "/profile"]
const PUBLIC_ONLY_ROUTES = ["/login"]

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const token = request.cookies.get("auth_token")?.value

  if (PROTECTED_ROUTES.some(r => pathname.startsWith(r)) && !token)
    return NextResponse.redirect(new URL("/login", request.url))

  if (PUBLIC_ONLY_ROUTES.includes(pathname) && token)
    return NextResponse.redirect(new URL("/dashboard", request.url))

  return NextResponse.next()
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
}
EOF

info "Creating Protected component..."
mkdir -p src/components
cat << 'EOF' > src/components/protected.tsx
"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { useAuth } from "@/context/auth-context"

export default function Protected({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (token === null) router.push("/login")
  }, [token, router])

  if (token === null) return null
  return <>{children}</>
}
EOF

cat << 'EOF' > src/components/logout-button.tsx
"use client"

import { logout } from "@/lib/auth/logout"
import { useAuth } from "@/context/auth-context"
import { useRouter } from "next/navigation"

export default function LogoutButton() {
  const router = useRouter()
  const { setToken, setUser } = useAuth()

  async function handleLogout() {
    await logout()
    setToken(null)
    setUser(null)
    router.push("/login")
  }

  return <button onClick={handleLogout}>Logout</button>
}
EOF

info "Creating pages..."
mkdir -p src/app/login src/app/dashboard src/app/profile

cat << 'EOF' > src/app/login/page.tsx
"use client"

import { useState } from "react"
import { login } from "@/lib/auth"
import { useAuth } from "@/context/auth-context"
import { useRouter } from "next/navigation"

export default function LoginPage() {
  const router = useRouter()
  const { setToken, setUser } = useAuth()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError("")
    setLoading(true)
    try {
      const { token, user } = await login(email, password)
      setToken(token)
      setUser(user)
      router.push("/dashboard")
    } catch {
      setError("Invalid email or password")
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && <p role="alert">{error}</p>}
      <input type="email" placeholder="Email" value={email}
        onChange={e => setEmail(e.target.value)} required autoComplete="email" />
      <input type="password" placeholder="Password" value={password}
        onChange={e => setPassword(e.target.value)} required autoComplete="current-password" />
      <button type="submit" disabled={loading}>{loading ? "Signing in…" : "Login"}</button>
    </form>
  )
}
EOF

cat << 'EOF' > src/app/dashboard/page.tsx
"use client"

import Protected from "@/components/protected"
import { useAuth } from "@/context/auth-context"

export default function Dashboard() {
  const { user } = useAuth()
  return (
    <Protected>
      <div>
        <h1>Dashboard</h1>
        {user && <p>Welcome, {user.email}</p>}
      </div>
    </Protected>
  )
}
EOF

cat << 'EOF' > src/app/profile/page.tsx
"use client"

import Protected from "@/components/protected"
import { useAuth } from "@/context/auth-context"
import LogoutButton from "@/components/logout-button"

export default function ProfilePage() {
  const { user } = useAuth()
  return (
    <Protected>
      <div>
        <h1>Portal Profile</h1>
        <p><strong>User ID:</strong> {user?.id}</p>
        <p><strong>Email:</strong> {user?.email}</p>
        <LogoutButton />
      </div>
    </Protected>
  )
}
EOF

info "Wrapping layout with AuthProvider..."
cat << 'EOF' > src/app/layout.tsx
import type { Metadata } from "next"
import { AuthProvider } from "@/context/auth-context"
import { Geist, Geist_Mono } from "next/font/google"
import "./globals.css"

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] })
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] })

export const metadata: Metadata = {
  title: "EHR Portal",
  description: "Electronic Health Records Portal",
}

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  )
}
EOF

success "Next.js JWT authentication complete"

# TODO: add Vitest unit tests for login, logout, auth-context, and Protected component
