// apps/ehr-portal/src/app/patients/page.tsx

export const dynamic = "force-dynamic"

import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"

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
  const data = await graphql.request<{ patients: Patient[] }>(query)

  return (
    <div>
      <h1>Patients</h1>

      <ul>
        {data.patients.map((p) => (
          <li key={p.id}>
            <Link href={`/patients/${p.id}`}>
              {p.fullName}
            </Link>
            {" "}
            {p.age !== null ? `Age ${p.age}` : ""}
            {p.gender ? ` · ${formatGender(p.gender)}` : ""}
            {p.mrn ? ` · MRN ${p.mrn}` : ""}
          </li>
        ))}
      </ul>
    </div>
  )
}
