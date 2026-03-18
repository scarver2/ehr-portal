# bin/steps/56_patients_ui.sh

source "$(dirname "$0")/../_lib.sh"

info "Create patient master (search) page"

mkdir -p apps/ehr-portal/src/app/patients

cat << 'EOF' > apps/ehr-portal/src/app/patients/page.tsx
// apps/ehr-portal/src/app/patients/page.tsx
import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"

const query = gql`
  query {
    patients {
      id
      firstName
      lastName
      mrn
      dateOfBirth
    }
  }
`

export default async function PatientsPage() {
  const data = await graphql.request(query)

  return (
    <div>
      <h1>Patients</h1>

      <ul>
        {data.patients.map((p: any) => (
          <li key={p.id}>
            <Link href={`/patients/${p.id}`}>
              {p.lastName}, {p.firstName} — MRN: {p.mrn} — DOB: {p.dateOfBirth}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
EOF

info "Create patient detail (chart) page"

mkdir -p "apps/ehr-portal/src/app/patients/[id]"

cat << 'EOF' > "apps/ehr-portal/src/app/patients/[id]/page.tsx"
// apps/ehr-portal/src/app/patients/[id]/page.tsx
import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"

const query = gql`
  query Patient($id: ID!) {
    patient(id: $id) {
      id
      firstName
      lastName
      dateOfBirth
      gender
      mrn
      phone
      email
      address
      city
      state
      zip
    }
  }
`

export default async function PatientPage({ params }: any) {
  const data = await graphql.request(query, {
    id: params.id
  })

  const patient = data.patient

  return (
    <div>
      <h1>{patient.lastName}, {patient.firstName}</h1>

      <p>MRN: {patient.mrn}</p>
      <p>Date of Birth: {patient.dateOfBirth}</p>
      <p>Gender: {patient.gender}</p>
      <p>Phone: {patient.phone}</p>
      <p>Email: {patient.email}</p>
      <p>Address: {patient.address}, {patient.city}, {patient.state} {patient.zip}</p>
    </div>
  )
}
EOF

# TODO: add Next.js unit and integration tests for Patients
