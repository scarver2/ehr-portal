// apps/ehr-portal/src/app/(app)/profile/page.tsx
// Thin client wrapper — disables SSR so localStorage-backed auth state
// never causes a hydration mismatch. ssr:false requires "use client".
"use client"

import dynamic from "next/dynamic"

const ProfileClient = dynamic(() => import("./profile-client"), { ssr: false })

export default function ProfilePage() {
  return <ProfileClient />
}
