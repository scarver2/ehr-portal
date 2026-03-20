// apps/ehr-portal/src/app/profile/page.tsx

"use client"

import Protected from "@/components/protected"
import { useAuth } from "@/context/auth-context"
import LogoutButton from "@/components/logout-button"

export default function ProfilePage() {
  const { user } = useAuth()

  return (
    <Protected>
      <div>
        <h1>Portal Profile</h1>

        <p>
          <strong>User ID:</strong> {user?.id}
        </p>

        <p>
          <strong>Email:</strong> {user?.email}
        </p>

        <LogoutButton />
      </div>
    </Protected>
  )
}

