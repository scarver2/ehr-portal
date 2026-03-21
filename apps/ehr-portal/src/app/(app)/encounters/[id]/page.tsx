// apps/ehr-portal/src/app/(app)/encounters/[id]/page.tsx

export const dynamic = "force-dynamic"

import Image from "next/image"
import Link from "next/link"
import { getGraphQLClient } from "@/lib/graphql"
import { gql } from "graphql-request"
import { ChevronLeft, Hash, CreditCard, Building2, Calendar } from "lucide-react"

const query = gql`
  query Encounter($id: ID!) {
    encounter(id: $id) {
      id
      encounterType
      status
      encounteredAt
      chiefComplaint
      notes
      patient {
        id
        fullName
        dateOfBirth
        age
        gender
        mrn
        phone
      }
      provider {
        id
        fullName
        npi
        specialty {
          name
        }
        clinicName
      }
      vitals {
        id
        vitalType
        value
        unit
        observedAt
        notes
      }
      diagnoses {
        id
        icd10Code
        description
        status
        diagnosedAt
        notes
      }
    }
  }
`

type Specialty = {
  name: string
}

type Patient = {
  id: string
  fullName: string
  dateOfBirth: string | null
  age: number | null
  gender: string | null
  mrn: string | null
  phone: string | null
}

type Provider = {
  id: string
  fullName: string
  npi: string | null
  specialty: Specialty | null
  clinicName: string | null
}

type Vital = {
  id: string
  vitalType: string
  value: string
  unit: string | null
  observedAt: string
  notes: string | null
}

type Diagnosis = {
  id: string
  icd10Code: string
  description: string
  status: string
  diagnosedAt: string
  notes: string | null
}

type Encounter = {
  id: string
  encounterType: string
  status: string
  encounteredAt: string
  chiefComplaint: string | null
  notes: string | null
  patient: Patient
  provider: Provider
  vitals: Vital[]
  diagnoses: Diagnosis[]
}

function formatEncounterType(type: string): string {
  return type.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase())
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  })
}

function formatVitalType(type: string): string {
  const map: Record<string, string> = {
    blood_pressure: "Blood Pressure",
    heart_rate: "Heart Rate",
    temperature: "Temperature",
    weight: "Weight",
    height: "Height",
    oxygen_saturation: "O₂ Sat",
    respiratory_rate: "Resp. Rate",
  }
  return map[type] ?? type.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase())
}

function formatGender(gender: string | null): string {
  if (!gender) return "—"
  const labels: Record<string, string> = {
    male: "Male",
    female: "Female",
    other: "Other",
    prefer_not_to_say: "Prefer not to say",
  }
  return labels[gender] ?? gender
}

function initials(fullName: string): string {
  return fullName
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase()
}

const statusStyles: Record<string, string> = {
  completed: "bg-green-50 text-green-700",
  scheduled: "bg-blue-50 text-blue-700",
  in_progress: "bg-yellow-50 text-yellow-700",
  cancelled: "bg-red-50 text-red-700",
}

const diagnosisStatusStyles: Record<string, string> = {
  active: "bg-red-50 text-red-700",
  resolved: "bg-green-50 text-green-700",
  chronic: "bg-orange-50 text-orange-700",
  inactive: "bg-slate-100 text-slate-500",
}

export default async function EncounterPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const graphql = await getGraphQLClient()
  const data = await graphql.request<{ encounter: Encounter }>(query, { id })
  const encounter = data.encounter

  const patientInitials = initials(encounter.patient.fullName)
  const providerInitials = initials(encounter.provider.fullName)

  return (
    <div className="p-8 max-w-3xl">

      {/* Back link */}
      <Link
        href={`/patients/${encounter.patient.id}`}
        className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-blue-600 transition-colors mb-6"
      >
        <ChevronLeft className="w-4 h-4" />
        {encounter.patient.fullName}
      </Link>

      {/* Encounter hero card */}
      <div className="relative bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6 overflow-hidden">

        {/* Decorative medical-report watermark */}
        <div className="absolute right-4 top-4 opacity-[0.07] pointer-events-none select-none">
          <Image
            src="/icons/medical-report.png"
            alt=""
            width={120}
            height={120}
            className="w-28 h-28"
          />
        </div>

        <div className="flex items-start gap-2 flex-wrap mb-3">
          <h1 className="text-xl font-semibold text-slate-900">
            {formatEncounterType(encounter.encounterType)}
          </h1>
          <span
            className={[
              "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium self-center",
              statusStyles[encounter.status] ?? "bg-slate-100 text-slate-600",
            ].join(" ")}
          >
            {encounter.status.replace(/_/g, " ")}
          </span>
        </div>

        <div className="flex items-center gap-2 text-sm text-slate-500 mb-3">
          <Calendar className="w-4 h-4 text-slate-400 shrink-0" />
          <span>{formatDate(encounter.encounteredAt)}</span>
        </div>

        {encounter.chiefComplaint && (
          <p className="text-sm text-slate-500 italic mb-3">{encounter.chiefComplaint}</p>
        )}

        {encounter.notes && (
          <div className="bg-slate-50 rounded-lg px-4 py-3 text-sm text-slate-600 leading-relaxed">
            {encounter.notes}
          </div>
        )}
      </div>

      {/* Patient + Provider cards side by side */}
      <div className="grid grid-cols-2 gap-4 mb-6">

        {/* Patient card */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
          <p className="text-xs font-medium text-slate-400 uppercase tracking-wide mb-3">Patient</p>
          <div className="flex items-start gap-3">
            <div className="flex items-center justify-center w-10 h-10 rounded-full bg-slate-100 text-slate-600 font-bold text-sm shrink-0">
              {patientInitials}
            </div>
            <div className="flex-1 min-w-0">
              <Link
                href={`/patients/${encounter.patient.id}`}
                className="text-sm font-medium text-slate-900 hover:text-blue-600 transition-colors"
              >
                {encounter.patient.fullName}
              </Link>

              {encounter.patient.dateOfBirth && (
                <p className="text-xs text-slate-500 mt-0.5">
                  DOB: {formatDate(encounter.patient.dateOfBirth)}
                </p>
              )}

              {encounter.patient.gender && (
                <p className="text-xs text-slate-500 mt-0.5">
                  {formatGender(encounter.patient.gender)}
                  {encounter.patient.age !== null && ` · ${encounter.patient.age} yrs`}
                </p>
              )}

              {encounter.patient.mrn && (
                <p className="inline-flex items-center gap-1 text-xs font-mono text-slate-400 mt-1">
                  <Hash className="w-3 h-3" />
                  {encounter.patient.mrn}
                </p>
              )}
            </div>
          </div>
        </div>

        {/* Provider card */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
          <p className="text-xs font-medium text-slate-400 uppercase tracking-wide mb-3">Provider</p>
          <div className="flex items-start gap-3">
            <div className="flex items-center justify-center w-10 h-10 rounded-full bg-blue-100 text-blue-600 font-bold text-sm shrink-0">
              {providerInitials}
            </div>
            <div className="flex-1 min-w-0">
              <Link
                href={`/providers/${encounter.provider.id}`}
                className="text-sm font-medium text-slate-900 hover:text-blue-600 transition-colors"
              >
                {encounter.provider.fullName}
              </Link>

              {encounter.provider.specialty && (
                <span className="inline-block mt-1 rounded-full bg-blue-50 px-2 py-0.5 text-xs text-blue-700 font-medium">
                  {encounter.provider.specialty.name}
                </span>
              )}

              {encounter.provider.npi && (
                <p className="inline-flex items-center gap-1 text-xs font-mono text-slate-400 mt-1 ml-0 block">
                  <CreditCard className="w-3 h-3" />
                  NPI {encounter.provider.npi}
                </p>
              )}

              {encounter.provider.clinicName && (
                <p className="flex items-center gap-1 text-xs text-slate-500 mt-0.5">
                  <Building2 className="w-3 h-3 shrink-0" />
                  {encounter.provider.clinicName}
                </p>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Vitals section */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm mb-6">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center gap-2.5">
          <Image src="/icons/ekg-monitor.png" alt="" width={28} height={28} className="shrink-0" />
          <h2 className="font-medium text-slate-900">Vitals</h2>
          {encounter.vitals.length > 0 && (
            <span className="ml-auto text-xs text-slate-400">{encounter.vitals.length} recorded</span>
          )}
        </div>

        {encounter.vitals.length === 0 ? (
          <p className="px-5 py-8 text-sm text-slate-400 text-center">No vitals recorded.</p>
        ) : (
          <div className="p-5 grid grid-cols-2 gap-3 sm:grid-cols-3">
            {encounter.vitals.map((vital) => (
              <div
                key={vital.id}
                className="bg-slate-50 rounded-lg px-4 py-3 border border-slate-100"
              >
                <p className="text-xs font-medium text-slate-400 mb-1">
                  {formatVitalType(vital.vitalType)}
                </p>
                <p className="text-base font-semibold text-slate-800">
                  {vital.value}
                  {vital.unit && (
                    <span className="text-xs font-normal text-slate-400 ml-1">{vital.unit}</span>
                  )}
                </p>
                <p className="text-xs text-slate-400 mt-1">{formatDate(vital.observedAt)}</p>
                {vital.notes && (
                  <p className="text-xs text-slate-400 italic mt-1">{vital.notes}</p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Diagnoses section */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center gap-2.5">
          <Image src="/icons/shield-cross.png" alt="" width={28} height={28} className="shrink-0" />
          <h2 className="font-medium text-slate-900">Diagnoses</h2>
          {encounter.diagnoses.length > 0 && (
            <span className="ml-auto text-xs text-slate-400">{encounter.diagnoses.length} total</span>
          )}
        </div>

        {encounter.diagnoses.length === 0 ? (
          <p className="px-5 py-8 text-sm text-slate-400 text-center">No diagnoses recorded.</p>
        ) : (
          <ul className="divide-y divide-slate-100">
            {encounter.diagnoses.map((dx) => (
              <li key={dx.id} className="px-5 py-4">
                <div className="flex items-start gap-3 flex-wrap">
                  {/* ICD-10 badge */}
                  <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-0.5 text-xs font-mono font-medium text-blue-700 border border-blue-100 shrink-0 mt-0.5">
                    {dx.icd10Code}
                  </span>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="text-sm font-medium text-slate-800">{dx.description}</p>
                      <span
                        className={[
                          "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                          diagnosisStatusStyles[dx.status] ?? "bg-slate-100 text-slate-500",
                        ].join(" ")}
                      >
                        {dx.status.replace(/_/g, " ")}
                      </span>
                    </div>

                    <p className="text-xs text-slate-400 mt-0.5">
                      Diagnosed {formatDate(dx.diagnosedAt)}
                    </p>

                    {dx.notes && (
                      <p className="text-xs text-slate-500 italic mt-1">{dx.notes}</p>
                    )}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  )
}
