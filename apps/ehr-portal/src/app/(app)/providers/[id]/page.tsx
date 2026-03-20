// apps/ehr-portal/src/app/(app)/providers/[id]/page.tsx

export const dynamic = "force-dynamic"

import Image from "next/image"
import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"
import { ChevronLeft, ChevronRight, CreditCard, Building2 } from "lucide-react"

const query = gql`
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
  encounters: Array<{ id: string; patient: { id: string; firstName: string; lastName: string } }>
}

export default async function ProviderPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const data = await graphql.request<{ provider: Provider }>(query, { id })
  const provider = data.provider

  // Unique patients from encounters, sorted alphabetically
  const patientMap = new Map<string, { id: string; firstName: string; lastName: string }>()
  provider.encounters.forEach(({ patient }) => {
    if (!patientMap.has(patient.id)) patientMap.set(patient.id, patient)
  })
  const patients = Array.from(patientMap.values()).sort((a, b) =>
    `${a.lastName} ${a.firstName}`.localeCompare(`${b.lastName} ${b.firstName}`)
  )

  const initials = provider.fullName.split(" ").map((n) => n[0]).join("").slice(0, 2)

  return (
    <div className="p-8 max-w-3xl">

      {/* Back */}
      <Link
        href="/providers"
        className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-blue-600 transition-colors mb-6"
      >
        <ChevronLeft className="w-4 h-4" />
        Providers
      </Link>

      {/* Provider hero */}
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
          <div className="flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 text-blue-700 font-bold text-xl shrink-0">
            {initials}
          </div>

          <div className="flex-1">
            <h1 className="text-xl font-semibold text-slate-900">{provider.fullName}</h1>
            {provider.specialty && (
              <span className="inline-flex items-center mt-1 rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
                {provider.specialty.name}
              </span>
            )}

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
          </div>
        </div>
      </div>

      {/* Quick stats strip */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/hand-heart.png" alt="Patients" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Patients</p>
            <p className="text-lg font-semibold text-slate-800">{patients.length}</p>
          </div>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/ekg-monitor.png" alt="Encounters" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Encounters</p>
            <p className="text-lg font-semibold text-slate-800">{provider.encounters.length}</p>
          </div>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/hospital.png" alt="Clinic" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Clinic</p>
            <p className="text-sm font-medium text-slate-800 truncate">{provider.clinicName ?? "—"}</p>
          </div>
        </div>
      </div>

      {/* Patients list */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
          <div className="flex items-center gap-2.5">
            <Image src="/icons/medical-report.png" alt="" width={28} height={28} className="shrink-0" />
            <h2 className="font-medium text-slate-900">Patients</h2>
          </div>
          <span className="text-xs text-slate-500">{patients.length} total</span>
        </div>

        {patients.length === 0 ? (
          <p className="px-5 py-8 text-sm text-slate-400 text-center">No patients on record.</p>
        ) : (
          <ul className="divide-y divide-slate-100">
            {patients.map((patient) => (
              <li key={patient.id}>
                <Link
                  href={`/patients/${patient.id}`}
                  className="group flex items-center gap-3 px-5 py-4 hover:bg-slate-50 transition-colors"
                >
                  <div className="flex items-center justify-center w-9 h-9 rounded-full bg-slate-100 text-slate-500 text-sm font-medium shrink-0 group-hover:bg-blue-50 group-hover:text-blue-600 transition-colors">
                    {patient.firstName[0]}{patient.lastName[0]}
                  </div>
                  <span className="flex-1 text-sm text-slate-700 group-hover:text-blue-600 transition-colors">
                    {patient.lastName}, {patient.firstName}
                  </span>
                  <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-blue-400 shrink-0 transition-colors" />
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  )
}
