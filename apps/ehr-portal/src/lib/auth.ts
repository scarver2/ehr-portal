// src/lib/auth.ts

import type { AuthUser, LoginResponse } from "@/types/auth"

export async function login(
  email: string,
  password: string
): Promise<LoginResponse> {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"
  const res = await fetch(`${apiUrl}/api/v1/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ user: { email, password } }),
  })

  if (!res.ok) {
    throw new Error("Invalid email or password")
  }

  const data = await res.json()

  // Rodauth returns the token in the response body (not the Authorization header like devise-jwt)
  const token = data.token
  if (!token) {
    throw new Error("No token received from server")
  }

  const user: AuthUser = data.user

  // Persist for context hydration on page reload
  localStorage.setItem("auth_token", token)
  localStorage.setItem("auth_user", JSON.stringify(user))

  // Cookie lets Next.js middleware protect routes server-side
  // JWT TTL is 1 day (86400 seconds)
  document.cookie = `auth_token=${token}; path=/; max-age=86400; SameSite=Lax`

  return { token, user }
}
