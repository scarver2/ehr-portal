// apps/ehr-portal/src/app/(app)/dashboard/page.tsx

"use client"

import { useEffect, useState } from "react"
import Protected from "@/components/protected"
import { useAuth } from "@/context/auth-context"
import { LayoutDashboard } from "lucide-react"

export default function Dashboard() {
  const { user } = useAuth()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    // eslint-disable-next-line
    setMounted(true)
  }, [])

  if (!mounted) return null

  return (
    <Protected>
      <div className="p-8">
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-1">
            <LayoutDashboard className="w-6 h-6 text-blue-600" />
            <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>
          </div>
          {user && (
            <p className="text-sm text-slate-500">Welcome back, {user.email}</p>
          )}
        </div>

        <div className="rounded-xl bg-white border border-slate-200 shadow-sm px-6 py-8 text-center text-slate-400 text-sm">
          Summary widgets coming soon.
        </div>
      </div>
    </Protected>
  )
}
