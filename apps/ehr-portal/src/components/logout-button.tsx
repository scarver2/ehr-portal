// src/components/logout-button.tsx

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
