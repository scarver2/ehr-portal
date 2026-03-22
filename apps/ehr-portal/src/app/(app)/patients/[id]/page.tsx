// apps/ehr-portal/src/app/(app)/patients/[id]/page.tsx

export const dynamic = "force-dynamic"

import Image from "next/image"
import { getGraphQLClient } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"
import { ChevronLeft, ChevronRight, Phone, MapPin, AlertCircle, Calendar, Hash } from "lucide-react"
import { InsuranceVerificationPanel } from "./InsuranceVerificationPanel"
import { EcgAnimation } from "@/components/ecg-animation"

const query = gql`
  query Patient($id: ID!) {
    patient(id: $id) {
      id
      fullName
      dateOfBirth
      age
      gender
      mrn
      phone
      address
      emergencyContactName
      emergencyContactPhone
      encounters {
        id
        encounterType
        status
        encounteredAt
        chiefComplaint
        provider {
          id
          fullName
        }
      }
    }
  }
`

type Encounter = {
  id: string
  encounterType: string
  status: string
  encounteredAt: string
  chiefComplaint: string | null
  provider: { id: string; fullName: string }
}

type Patient = {
  id: string
  fullName: string
  dateOfBirth: string | null
  age: number | null
  gender: string | null
  mrn: string | null
  phone: string | null
  address: string | null
  emergencyContactName: string | null
  emergencyContactPhone: string | null
  encounters: Encounter[]
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

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  })
}

function formatEncounterType(type: string): string {
  return type.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase())
}

function encounterIconSrc(type: string): string {
  const map: Record<string, string> = {
    office_visit:   "/icons/stethoscope.png",
    checkup:        "/icons/stethoscope.png",
    consultation:   "/icons/stethoscope.png",
    follow_up:      "/icons/stethoscope.png",
    emergency:      "/icons/ekg-monitor.png",
    urgent_care:    "/icons/ekg-monitor.png",
    inpatient:      "/icons/hospital.png",
    hospital:       "/icons/hospital.png",
    surgery:        "/icons/hospital.png",
    injection:      "/icons/syringe.png",
    vaccination:    "/icons/syringe.png",
    procedure:      "/icons/syringe.png",
  }
  return map[type] ?? "/icons/medical-report.png"
}

const statusStyles: Record<string, string> = {
  completed:   "bg-green-50 text-green-700",
  scheduled:   "bg-blue-50 text-blue-700",
  in_progress: "bg-yellow-50 text-yellow-700",
  cancelled:   "bg-red-50 text-red-700",
}

export default async function PatientPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const graphql = await getGraphQLClient()
  const data = await graphql.request<{ patient: Patient }>(query, { id })
  const patient = data.patient

  const initials = patient.fullName.split(" ").map((n) => n[0]).join("").slice(0, 2)

  return (
    <div className="p-8 max-w-3xl">

      {/* Back */}
      <Link
        href="/patients"
        className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-blue-600 transition-colors mb-6"
      >
        <ChevronLeft className="w-4 h-4" />
        Patients
      </Link>

      {/* ECG Waveform Animation */}
      <div className="mb-6 rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <EcgAnimation />
      </div>

      {/* Patient hero */}
      <div className="relative bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6 overflow-hidden">

        {/* Decorative heart-ekg watermark */}
        <div className="absolute right-4 top-4 opacity-[0.07] pointer-events-none select-none">
          <Image
            src="/icons/heart-ekg.png"
            alt=""
            width={120}
            height={120}
            className="w-28 h-28"
          />
        </div>

        <div className="flex items-start gap-5">
          <div className="flex items-center justify-center w-16 h-16 rounded-full bg-slate-100 text-slate-600 font-bold text-xl shrink-0">
            {initials}
          </div>

          <div className="flex-1">
            <h1 className="text-xl font-semibold text-slate-900">{patient.fullName}</h1>

            <div className="flex items-center gap-2 mt-1 flex-wrap">
              {patient.gender && (
                <span className="text-xs text-slate-500">{formatGender(patient.gender)}</span>
              )}
              {patient.age !== null && (
                <>
                  <span className="text-slate-300">·</span>
                  <span className="text-xs text-slate-500">{patient.age} yrs</span>
                </>
              )}
              {patient.mrn && (
                <>
                  <span className="text-slate-300">·</span>
                  <span className="inline-flex items-center gap-1 text-xs font-mono text-slate-500">
                    <Hash className="w-3 h-3" />{patient.mrn}
                  </span>
                </>
              )}
            </div>

            <dl className="mt-4 grid grid-cols-1 gap-2">
              {patient.dateOfBirth && (
                <div className="flex items-center gap-2 text-sm">
                  <Calendar className="w-4 h-4 text-slate-400 shrink-0" />
                  <span className="text-slate-600">DOB: {formatDate(patient.dateOfBirth)}</span>
                </div>
              )}
              {patient.phone && (
                <div className="flex items-center gap-2 text-sm">
                  <Phone className="w-4 h-4 text-slate-400 shrink-0" />
                  <span className="text-slate-600">{patient.phone}</span>
                </div>
              )}
              {patient.address && (
                <div className="flex items-start gap-2 text-sm">
                  <MapPin className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <span className="text-slate-600">{patient.address}</span>
                </div>
              )}
            </dl>
          </div>
        </div>
      </div>

      {/* ECG Waveform Animation - standalone component below demographics */}
      <div className="rounded-xl border border-slate-200 overflow-hidden shadow-sm mb-6">
        <EcgAnimation />
      </div>

      {/* Emergency contact */}
      {(patient.emergencyContactName || patient.emergencyContactPhone) && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl px-5 py-4 mb-6 flex items-start gap-3">
          <AlertCircle className="w-4 h-4 text-amber-500 shrink-0 mt-0.5" />
          <div className="text-sm">
            <p className="font-medium text-amber-800">Emergency Contact</p>
            <p className="text-amber-700 mt-0.5">
              {patient.emergencyContactName ?? "—"}
              {patient.emergencyContactPhone && ` · ${patient.emergencyContactPhone}`}
            </p>
          </div>
        </div>
      )}

      {/* Quick stats strip */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/ekg-monitor.png" alt="Encounters" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Encounters</p>
            <p className="text-lg font-semibold text-slate-800">{patient.encounters.length}</p>
          </div>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/stethoscope.png" alt="Last visit" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Last Visit</p>
            <p className="text-sm font-medium text-slate-800">
              {patient.encounters.length > 0
                ? formatDate(patient.encounters[0].encounteredAt)
                : "—"}
            </p>
          </div>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm px-4 py-3 flex items-center gap-3">
          <Image src="/icons/hand-heart.png" alt="Care" width={36} height={36} className="shrink-0" />
          <div>
            <p className="text-xs text-slate-400">Completed</p>
            <p className="text-lg font-semibold text-slate-800">
              {patient.encounters.filter((e) => e.status === "completed").length}
            </p>
          </div>
        </div>
      </div>

      {/* Insurance verification */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm mb-6 overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center gap-2.5">
          <Image src="/icons/shield-cross.png" alt="" width={28} height={28} className="shrink-0" />
          <h2 className="font-medium text-slate-900">Insurance Verification</h2>
        </div>
        <div className="px-5 py-4">
          <InsuranceVerificationPanel patientId={Number(patient.id)} />
        </div>
      </div>

      {/* Encounters */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
          <div className="flex items-center gap-2.5">
            <Image src="/icons/medical-report.png" alt="" width={28} height={28} className="shrink-0" />
            <h2 className="font-medium text-slate-900">Encounters</h2>
          </div>
          <span className="text-xs text-slate-500">{patient.encounters.length} total</span>
        </div>

        {patient.encounters.length === 0 ? (
          <p className="px-5 py-8 text-sm text-slate-400 text-center">No encounters on record.</p>
        ) : (
          <ul className="divide-y divide-slate-100">
            {patient.encounters.map((enc) => (
              <li key={enc.id}>
                <Link
                  href={`/encounters/${enc.id}`}
                  className="group flex items-center gap-3 px-5 py-4 hover:bg-slate-50 transition-colors"
                >
                  {/* Encounter type icon */}
                  <div className="shrink-0 w-9 h-9 rounded-lg bg-slate-50 border border-slate-100 flex items-center justify-center group-hover:bg-white transition-colors">
                    <Image
                      src={encounterIconSrc(enc.encounterType)}
                      alt={enc.encounterType}
                      width={24}
                      height={24}
                    />
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-sm font-medium text-slate-800">
                        {formatEncounterType(enc.encounterType)}
                      </span>
                      <span className={[
                        "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                        statusStyles[enc.status] ?? "bg-slate-100 text-slate-600",
                      ].join(" ")}>
                        {enc.status.replace(/_/g, " ")}
                      </span>
                    </div>
                    <p className="text-xs text-slate-500 mt-0.5">
                      {formatDate(enc.encounteredAt)}
                      {" · "}
                      {enc.provider.fullName}
                    </p>
                    {enc.chiefComplaint && (
                      <p className="text-xs text-slate-400 mt-0.5 italic truncate">
                        {enc.chiefComplaint}
                      </p>
                    )}
                  </div>

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
