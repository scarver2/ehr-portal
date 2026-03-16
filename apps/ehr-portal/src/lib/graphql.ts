// apps/ehr-portal/src/lib/graphql.ts
import { GraphQLClient } from "graphql-request"

export const graphql = new GraphQLClient(
  "http://localhost:3000/graphql"
)
