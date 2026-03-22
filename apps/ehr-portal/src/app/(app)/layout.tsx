// src/app/(app)/layout.tsx

import { Sidebar } from "@/components/sidebar"

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col lg:flex-row bg-slate-50 font-sans">
      {/* Sidebar - hidden on mobile, shown on lg screens */}
      <aside className="hidden lg:block lg:w-64 lg:flex-shrink-0">
        <Sidebar />
      </aside>
      {/* Main content - full width on mobile, flex-1 on larger screens */}
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  )
}
