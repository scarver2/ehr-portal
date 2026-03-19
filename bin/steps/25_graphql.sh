# bin/steps/25_graphql.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-portal

info "Adding graphql-request dependency..."
bun add graphql-request

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

# TODO: add GraphQL unit and integration tests
