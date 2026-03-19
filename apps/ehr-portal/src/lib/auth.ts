// src/lib/auth.ts

import type { AuthUser, LoginResponse } from "@/types/auth"

export async function login(
  email: string,
  password: string
): Promise<LoginResponse> {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    // Devise expects credentials nested under the resource key
    body: JSON.stringify({ user: { email, password } }),
  })

  if (!res.ok) {
    throw new Error("Invalid email or password")
  }

  // devise-jwt emits the token in the Authorization response header, not the body
  const authHeader = res.headers.get("Authorization") ?? ""
  const token = authHeader.replace("Bearer ", "")

  if (!token) {
    throw new Error("No token received from server")
  }

  const data = await res.json()
  const user: AuthUser = data.user

  // Persist for context hydration on page reload
  localStorage.setItem("auth_token", token)
  localStorage.setItem("auth_user", JSON.stringify(user))

  // Cookie lets Next.js middleware protect routes server-side
  document.cookie = `auth_token=${token}; path=/; max-age=86400; SameSite=Lax`

  return { token, user }
}
