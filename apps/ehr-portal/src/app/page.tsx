"use client"

import { useState } from "react"
import { login } from "@/lib/auth"
import { useAuth } from "@/context/auth-context"
import { useRouter } from "next/navigation"

export default function Home() {
  const router = useRouter()
  const { setToken, setUser, user } = useAuth()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError("")
    setLoading(true)

    try {
      const { token, user: newUser } = await login(email, password)
      setToken(token)
      setUser(newUser)

      // Role-based redirect
      if (newUser.role === "provider" && newUser.provider_id) {
        router.push(`/providers/${newUser.provider_id}`)
      } else {
        router.push("/not-implemented")
      }
    } catch {
      setError("Invalid email or password")
    } finally {
      setLoading(false)
    }
  }

  // Don't show form if already logged in
  if (user) {
    return (
      <main style={{ display: "flex", height: "100vh", alignItems: "center", justifyContent: "center" }}>
        <div style={{ textAlign: "center" }}>
          <h1 style={{ fontSize: "20vw", fontWeight: 700, letterSpacing: "-0.05em", lineHeight: 1 }}>EHR</h1>
          <p>Redirecting...</p>
        </div>
      </main>
    )
  }

  return (
    <main style={{ display: "flex", height: "100vh", alignItems: "center", justifyContent: "center" }}>
      <div style={{ width: "100%", maxWidth: "400px", padding: "2rem" }}>
        <h1 style={{ fontSize: "10vw", fontWeight: 700, letterSpacing: "-0.05em", lineHeight: 1, marginBottom: "2rem", textAlign: "center" }}>
          EHR
        </h1>

        <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
          {error && <p style={{ color: "red", margin: 0 }}>{error}</p>}

          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoComplete="email"
            style={{ padding: "0.5rem", fontSize: "1rem", border: "1px solid #ccc", borderRadius: "4px" }}
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            autoComplete="current-password"
            style={{ padding: "0.5rem", fontSize: "1rem", border: "1px solid #ccc", borderRadius: "4px" }}
          />

          <button
            type="submit"
            disabled={loading}
            style={{
              padding: "0.75rem",
              fontSize: "1rem",
              backgroundColor: loading ? "#ccc" : "#000",
              color: "#fff",
              border: "none",
              borderRadius: "4px",
              cursor: loading ? "not-allowed" : "pointer",
            }}
          >
            {loading ? "Signing in…" : "Login"}
          </button>
        </form>
      </div>

      <footer style={{ position: "fixed", bottom: "1.5rem", fontSize: "0.8rem", opacity: 0.4 }}>
        &copy;2026{" "}
        <a href="https://stancarver.com" target="_blank" rel="noopener noreferrer" style={{ color: "inherit" }}>
          Stan Carver II
        </a>
      </footer>
    </main>
  )
}
