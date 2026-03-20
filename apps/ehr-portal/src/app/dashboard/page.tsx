// src/app/dashboard/page.tsx

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
