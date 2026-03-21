// apps/ehr-portal/src/app/(app)/profile/page.tsx
// Server Component wrapper — disables SSR for the profile page so that
// localStorage-backed auth state never causes a hydration mismatch.

import dynamic from "next/dynamic"

const ProfileClient = dynamic(() => import("./profile-client"), { ssr: false })

export default function ProfilePage() {
  return <ProfileClient />
}
