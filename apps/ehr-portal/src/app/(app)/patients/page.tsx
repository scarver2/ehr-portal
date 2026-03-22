// apps/ehr-portal/src/app/(app)/patients/page.tsx

export const dynamic = "force-dynamic"

import { getGraphQLClient } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"
import { Users, ChevronRight, Hash } from "lucide-react"

const query = gql`
  query {
    patients {
      id
      fullName
      dateOfBirth
      age
      gender
      mrn
    }
  }
`

type Patient = {
  id: string
  fullName: string
  dateOfBirth: string | null
  age: number | null
  gender: string | null
  mrn: string | null
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

export default async function PatientsPage() {
  const graphql = await getGraphQLClient()
  const data = await graphql.request<{ patients: Patient[] }>(query)
  const patients = data.patients

  return (
    <div className="p-4 sm:p-6 lg:p-8">

      {/* Page header */}
      <div className="mb-6 sm:mb-8">
        <div className="flex items-center gap-2 sm:gap-3 mb-1">
          <Users className="w-5 h-5 sm:w-6 sm:h-6 text-blue-600 flex-shrink-0" />
          <h1 className="text-xl sm:text-2xl font-semibold text-slate-900">Patients</h1>
          <span className="inline-flex items-center rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
            {patients.length}
          </span>
        </div>
        <p className="text-sm text-slate-500">
          Active patient records at Princeton-Plainsboro
        </p>
      </div>

      {/* Patient cards */}
      <div className="grid gap-3">
        {patients.map((patient) => {
          const initials = patient.fullName.split(" ").map((n) => n[0]).join("").slice(0, 2)
          return (
            <Link
              key={patient.id}
              href={`/patients/${patient.id}`}
              className="group flex items-center justify-between rounded-lg sm:rounded-xl bg-white border border-slate-200 px-3 sm:px-5 py-3 sm:py-4 shadow-sm hover:border-blue-300 hover:shadow-md transition-all active:bg-blue-50 min-h-12 sm:min-h-auto"
            >
              <div className="flex items-center gap-3 sm:gap-4 min-w-0">
                {/* Initials avatar */}
                <div className="flex items-center justify-center w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-slate-100 text-slate-600 font-semibold text-sm shrink-0">
                  {initials}
                </div>

                <div className="min-w-0 flex-1">
                  <p className="font-medium text-slate-900 group-hover:text-blue-600 transition-colors truncate sm:truncate">
                    {patient.fullName}
                  </p>
                  <div className="flex items-center gap-1 sm:gap-2 mt-0.5 flex-wrap">
                    {patient.age !== null && (
                      <span className="text-xs text-slate-500">{patient.age} yrs</span>
                    )}
                    {patient.gender && (
                      <>
                        {patient.age !== null && <span className="text-slate-300">·</span>}
                        <span className="text-xs text-slate-500">{formatGender(patient.gender)}</span>
                      </>
                    )}
                    {patient.mrn && (
                      <>
                        <span className="text-slate-300 hidden sm:inline">·</span>
                        <span className="inline-flex items-center gap-0.5 text-xs font-mono text-slate-400">
                          <Hash className="w-3 h-3 flex-shrink-0" />{patient.mrn}
                        </span>
                      </>
                    )}
                  </div>
                </div>
              </div>

              <ChevronRight className="w-4 h-4 sm:w-5 sm:h-5 text-slate-400 group-hover:text-blue-500 transition-colors shrink-0 ml-2" />
            </Link>
          )
        })}
      </div>
    </div>
  )
}
