// src/app/login/page.tsx

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

      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={e => setEmail(e.target.value)}
        required
        autoComplete="email"
      />

      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        required
        autoComplete="current-password"
      />

      <button type="submit" disabled={loading}>
        {loading ? "Signing in…" : "Login"}
      </button>
    </form>
  )
}
