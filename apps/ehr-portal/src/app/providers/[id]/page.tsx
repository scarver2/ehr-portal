// apps/ehr-portal/src/app/providers/[id]/page.tsx

export const dynamic = "force-dynamic"

import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"

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
        patient {
          id
          firstName
          lastName
        }
      }
    }
  }
`

export default async function ProviderPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const data = await graphql.request<{
    provider: {
      id: string
      fullName: string
      npi: string
      specialty: { id: string; name: string } | null
      clinicName: string | null
      encounters: Array<{ patient: { id: string; firstName: string; lastName: string } }>
    }
  }>(query, { id })

  const provider = data.provider

  // Get unique patients from encounters
  const patientMap = new Map<string, { id: string; firstName: string; lastName: string }>()
  provider.encounters.forEach(({ patient }) => {
    if (!patientMap.has(patient.id)) {
      patientMap.set(patient.id, patient)
    }
  })
  const patients = Array.from(patientMap.values()).sort((a, b) =>
    `${a.lastName} ${a.firstName}`.localeCompare(`${b.lastName} ${b.firstName}`)
  )

  return (
    <div style={{ padding: "2rem" }}>
      <h1>{provider.fullName}</h1>
      <p>NPI: {provider.npi}</p>
      <p>Specialty: {provider.specialty?.name ?? "—"}</p>
      <p>Clinic: {provider.clinicName}</p>

      <h2>Patients ({patients.length})</h2>
      {patients.length === 0 ? (
        <p>No patients found.</p>
      ) : (
        <ul>
          {patients.map((patient) => (
            <li key={patient.id}>
              <Link href={`/patients/${patient.id}`}>
                {patient.firstName} {patient.lastName}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
