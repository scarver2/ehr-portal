// apps/ehr-portal/src/app/providers/page.tsx
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

export default async function ProvidersPage() {
  const data = await graphql.request(query)

  return (
    <div>
      <h1>Providers</h1>

      <ul>
        {data.providers.map((p: any) => (
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
