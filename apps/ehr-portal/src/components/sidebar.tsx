"use client"

// src/components/sidebar.tsx

import Link from "next/link"
import { usePathname, useRouter } from "next/navigation"
import { LayoutDashboard, Users, Stethoscope, UserCircle, LogOut, Cross } from "lucide-react"
import { useAuth } from "@/context/auth-context"
import { logout } from "@/lib/auth/logout"

const navItems = [
  { href: "/dashboard",  label: "Dashboard", icon: LayoutDashboard },
  { href: "/patients",   label: "Patients",  icon: Users           },
  { href: "/providers",  label: "Providers", icon: Stethoscope     },
]

export function Sidebar() {
  const pathname = usePathname()
  const { setToken, setUser } = useAuth()
  const router = useRouter()

  async function handleLogout() {
    await logout()
    setToken(null)
    setUser(null)
    router.push("/login")
  }

  return (
    <aside className="flex flex-col w-60 min-h-screen bg-[#0f172a] text-slate-400">

      {/* Logo */}
      <div className="flex items-center gap-3 px-5 py-5 border-b border-slate-700/50">
        <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-blue-600">
          <Cross className="w-4 h-4 text-white" strokeWidth={2.5} />
        </div>
        <span className="text-white font-semibold text-sm tracking-wide">EHR Portal</span>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-0.5">
        <p className="px-2 py-2 text-xs font-semibold uppercase tracking-widest text-slate-500">
          Clinical
        </p>
        {navItems.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || pathname.startsWith(href + "/")
          return (
            <Link
              key={href}
              href={href}
              className={[
                "flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors",
                active
                  ? "bg-blue-600 text-white"
                  : "text-slate-400 hover:bg-slate-800 hover:text-slate-100",
              ].join(" ")}
            >
              <Icon className="w-4 h-4 shrink-0" />
              {label}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="px-3 py-4 border-t border-slate-700/50 space-y-0.5">
        <Link
          href="/profile"
          className={[
            "flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors",
            pathname === "/profile"
              ? "bg-blue-600 text-white"
              : "text-slate-400 hover:bg-slate-800 hover:text-slate-100",
          ].join(" ")}
        >
          <UserCircle className="w-4 h-4 shrink-0" />
          Profile
        </Link>
        <button
          onClick={handleLogout}
          className="flex w-full items-center gap-3 px-3 py-2 rounded-md text-sm font-medium text-slate-400 hover:bg-slate-800 hover:text-slate-100 transition-colors"
        >
          <LogOut className="w-4 h-4 shrink-0" />
          Logout
        </button>
      </div>
    </aside>
  )
}
