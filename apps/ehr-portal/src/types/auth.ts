// src/types/auth.ts
// Canonical auth types shared across context, lib, and components.

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
