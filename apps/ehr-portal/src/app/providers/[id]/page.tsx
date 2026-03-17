// apps/ehr-portal/src/app/providers/[id]/page.tsx

export const dynamic = 'force-dynamic'

import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"

const query = gql`
  query Provider($id: ID!) {
    provider(id: $id) {
      id
      fullName
      npi
      specialty
      clinicName
    }
  }
`

export default async function ProviderPage({ params }: any) {
  const { id } = await params
  const data = await graphql.request(query, { id })

  const provider = data.provider

  return (
    <div>
      <h1>{provider.fullName}</h1>
      <p>NPI: {provider.npi}</p>
      <p>Specialty: {provider.specialty}</p>
      <p>Clinic: {provider.clinicName}</p>
    </div>
  )
}
