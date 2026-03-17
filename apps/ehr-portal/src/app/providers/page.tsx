// apps/ehr-portal/src/app/providers/page.tsx

export const dynamic = 'force-dynamic'

import { graphql } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"

const query = gql`
  query {
    providers {
      id
      fullName
      specialty
    }
  }
`

type Provider = {
  id: string
  fullName: string
  specialty: string
}

export default async function ProvidersPage() {
  const data = await graphql.request<{ providers: Provider[] }>(query)

  return (
    <div>
      <h1>Providers</h1>

      <ul>
        {data.providers.map((p) => (
          <li key={p.id}>
            <Link href={`/providers/${p.id}`}>
              {p.fullName} — {p.specialty}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
