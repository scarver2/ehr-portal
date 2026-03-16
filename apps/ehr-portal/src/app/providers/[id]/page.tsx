// apps/ehr-portal/src/app/providers/[id]/page.tsx
import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"

const query = gql`
  query Provider($id: ID!) {
    provider(id: $id) {
      id
      fullName
      specialty
      clinic
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

      <p>Specialty: {provider.specialty}</p>
      <p>Clinic: {provider.clinic}</p>
    </div>
  )
}
