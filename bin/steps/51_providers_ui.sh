# bin/steps/51_providers_ui.sh

source "$(dirname "$0")/../_lib.sh"

info "Creating the GraphQL client"
mkdir -p apps/ehr-portal/src/lib

cat << 'EOF' > apps/ehr-portal/src/lib/graphql.ts
// apps/ehr-portal/src/lib/graphql.ts
import { GraphQLClient } from "graphql-request"

export const graphql = new GraphQLClient(
  "http://localhost:3000/graphql"
)
EOF

# TODO: Eventually switch the hard-coded URL to use the environment variable
# process.env.NEXT_PUBLIC_API_URL

# cat << 'EOF' > apps/ehr-portal/lib/graphql.ts
# //apps/ehr-portal/lib/graphql.ts

# export const graphql = new GraphQLClient(
#   `${process.env.NEXT_PUBLIC_API_URL}/graphql`
# )
# EOF

info "Create your provider master page"

mkdir -p apps/ehr-portal/src/app/providers

cat << 'EOF' > apps/ehr-portal/src/app/providers/page.tsx
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
EOF

info "Create your provider detail page"

mkdir -p "apps/ehr-portal/src/app/providers/[id]"

cat << 'EOF' > "apps/ehr-portal/src/app/providers/[id]/page.tsx"
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
  const data = await graphql.request(query, {
    id: params.id
  })

  const provider = data.provider

  return (
    <div>
      <h1>{provider.fullName}</h1>

      <p>Specialty: {provider.specialty}</p>
      <p>Clinic: {provider.clinic}</p>
    </div>
  )
}
EOF
