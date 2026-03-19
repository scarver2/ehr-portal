// apps/ehr-portal/src/app/patients/[id]/page.tsx

export const dynamic = "force-dynamic"

import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"

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
    month: "long",
    day: "numeric",
    timeZone: "UTC",
  })
}

export default async function PatientPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const data = await graphql.request<{ patient: Patient }>(query, { id })

  const patient = data.patient

  return (
    <div>
      <h1>{patient.fullName}</h1>

      <section>
        <h2>Demographics</h2>
        <p>Date of Birth: {patient.dateOfBirth ? formatDate(patient.dateOfBirth) : "—"}</p>
        <p>Age: {patient.age !== null ? patient.age : "—"}</p>
        <p>Gender: {formatGender(patient.gender)}</p>
        <p>MRN: {patient.mrn ?? "—"}</p>
      </section>

      <section>
        <h2>Contact</h2>
        <p>Phone: {patient.phone ?? "—"}</p>
        <p>Address: {patient.address ?? "—"}</p>
        <p>Emergency Contact: {patient.emergencyContactName ?? "—"}</p>
        <p>Emergency Phone: {patient.emergencyContactPhone ?? "—"}</p>
      </section>

      <section>
        <h2>Encounters</h2>
        {patient.encounters.length === 0 ? (
          <p>No encounters on record.</p>
        ) : (
          <ul>
            {patient.encounters.map((enc) => (
              <li key={enc.id}>
                <Link href={`/encounters/${enc.id}`}>
                  {formatDate(enc.encounteredAt)} — {enc.encounterType} ({enc.status})
                </Link>
                {" "}with {enc.provider.fullName}
                {enc.chiefComplaint ? ` · ${enc.chiefComplaint}` : ""}
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  )
}
