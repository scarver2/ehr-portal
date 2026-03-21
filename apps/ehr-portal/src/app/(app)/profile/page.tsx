// apps/ehr-portal/src/app/(app)/profile/page.tsx

"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import { CreditCard, Building2 } from "lucide-react"
import { GraphQLClient, gql } from "graphql-request"
import Protected from "@/components/protected"
import { useAuth } from "@/context/auth-context"

const PROVIDER_QUERY = gql`
  query Provider($id: ID!) {
    provider(id: $id) {
      id
      fullName
      npi
      specialty {
        id
        name
      }
      clinicName
      encounters {
        id
        patient {
          id
          firstName
          lastName
        }
      }
    }
  }
`

type Provider = {
  id: string
  fullName: string
  npi: string
  specialty: { id: string; name: string } | null
  clinicName: string | null
  encounters: Array<{
    id: string
    patient: { id: string; firstName: string; lastName: string }
  }>
}

function LoadingSkeleton() {
  return (
    <div className="p-8 max-w-3xl animate-pulse">
      {/* Hero skeleton */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6">
        <div className="flex items-start gap-5">
          <div className="w-16 h-16 rounded-full bg-slate-200 shrink-0" />
          <div className="flex-1 space-y-3">
            <div className="h-5 bg-slate-200 rounded w-48" />
            <div className="h-4 bg-slate-100 rounded w-24" />
            <div className="grid grid-cols-2 gap-4 mt-4">
              <div className="h-10 bg-slate-100 rounded" />
              <div className="h-10 bg-slate-100 rounded" />
            </div>
          </div>
        </div>
      </div>

      {/* Stats strip skeleton */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3"
          >
            <div className="w-9 h-9 rounded bg-slate-200 shrink-0" />
            <div className="space-y-1.5 flex-1">
              <div className="h-3 bg-slate-100 rounded w-16" />
              <div className="h-5 bg-slate-200 rounded w-10" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function ProfileContent({ user }: { user: { id: number; email: string; role: string; provider_id?: number } }) {
  const [provider, setProvider] = useState<Provider | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const isProvider = user.role === "provider" && user.provider_id != null

  useEffect(() => {
    if (!isProvider || !user.provider_id) return

    async function fetchProvider() {
      setLoading(true)
      setError(null)
      try {
        const token = localStorage.getItem("auth_token")
        const apiUrl = process.env.NEXT_PUBLIC_API_URL + "/graphql"
        const client = new GraphQLClient(apiUrl, {
          headers: token ? { Authorization: `Bearer ${token}` } : {},
        })
        const data = await client.request<{ provider: Provider }>(PROVIDER_QUERY, {
          id: String(user.provider_id),
        })
        setProvider(data.provider)
      } catch (err) {
        setError("Failed to load provider details.")
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    fetchProvider()
  }, [isProvider, user.provider_id])

  if (loading) return <LoadingSkeleton />

  // Derive display values
  const displayName = provider?.fullName ?? user.email
  const initials = provider
    ? provider.fullName
        .split(" ")
        .map((n) => n[0])
        .join("")
        .slice(0, 2)
        .toUpperCase()
    : user.email.slice(0, 2).toUpperCase()

  const uniquePatients = provider
    ? (() => {
        const map = new Map<string, Provider["encounters"][number]["patient"]>()
        provider.encounters.forEach(({ patient }) => {
          if (!map.has(patient.id)) map.set(patient.id, patient)
        })
        return Array.from(map.values())
      })()
    : []

  const roleBadgeLabel =
    user.role === "provider"
      ? "Provider"
      : user.role === "admin"
      ? "Admin"
      : user.role.charAt(0).toUpperCase() + user.role.slice(1)

  return (
    <div className="p-8 max-w-3xl">
      {/* Profile hero card */}
      <div className="relative bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6 overflow-hidden">
        {/* Decorative stethoscope watermark */}
        <div className="absolute right-4 top-4 opacity-[0.07] pointer-events-none select-none">
          <Image
            src="/icons/stethoscope.png"
            alt=""
            width={120}
            height={120}
            className="w-28 h-28"
          />
        </div>

        <div className="flex items-start gap-5">
          {/* Initials avatar */}
          <div className="flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 text-blue-700 font-bold text-xl shrink-0">
            {initials}
          </div>

          <div className="flex-1">
            <div className="flex items-center gap-2.5 flex-wrap">
              <h1 className="text-xl font-semibold text-slate-900">{displayName}</h1>
              <span className="inline-flex items-center rounded-full bg-blue-600 px-2.5 py-0.5 text-xs font-semibold text-white">
                {roleBadgeLabel}
              </span>
            </div>

            <p className="mt-1 text-sm text-slate-500">{user.email}</p>

            {provider?.specialty && (
              <span className="inline-flex items-center mt-2 rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
                {provider.specialty.name}
              </span>
            )}

            {/* NPI + Clinic details */}
            {provider && (
              <dl className="mt-4 grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2 text-sm">
                  <CreditCard className="w-4 h-4 text-slate-400 shrink-0" />
                  <div>
                    <dt className="text-xs text-slate-500">NPI</dt>
                    <dd className="font-mono text-slate-700">{provider.npi}</dd>
                  </div>
                </div>

                <div className="flex items-center gap-2 text-sm">
                  <Building2 className="w-4 h-4 text-slate-400 shrink-0" />
                  <div>
                    <dt className="text-xs text-slate-500">Clinic</dt>
                    <dd className="text-slate-700">{provider.clinicName ?? "—"}</dd>
                  </div>
                </div>
              </dl>
            )}
          </div>
        </div>
      </div>

      {/* Error state */}
      {error && (
        <div className="mb-6 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Stats strip — only for providers */}
      {isProvider && (
        <div className="grid grid-cols-3 gap-3 mb-6">
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
            <Image
              src="/icons/hand-heart.png"
              alt="Patients"
              width={36}
              height={36}
              className="shrink-0"
            />
            <div>
              <p className="text-xs text-slate-400">Patients</p>
              <p className="text-lg font-semibold text-slate-800">
                {provider ? uniquePatients.length : "—"}
              </p>
            </div>
          </div>

          <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
            <Image
              src="/icons/ekg-monitor.png"
              alt="Encounters"
              width={36}
              height={36}
              className="shrink-0"
            />
            <div>
              <p className="text-xs text-slate-400">Encounters</p>
              <p className="text-lg font-semibold text-slate-800">
                {provider ? provider.encounters.length : "—"}
              </p>
            </div>
          </div>

          <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
            <Image
              src="/icons/stethoscope.png"
              alt="Specialty"
              width={36}
              height={36}
              className="shrink-0"
            />
            <div>
              <p className="text-xs text-slate-400">Specialty</p>
              <p className="text-sm font-medium text-slate-800 truncate max-w-[100px]">
                {provider?.specialty?.name ?? "—"}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default function ProfilePage() {
  const { user } = useAuth()

  return (
    <Protected>
      {user ? (
        <ProfileContent user={user} />
      ) : (
        <LoadingSkeleton />
      )}
    </Protected>
  )
}
