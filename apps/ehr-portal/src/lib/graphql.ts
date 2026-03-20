// apps/ehr-portal/src/lib/graphql.ts

import { GraphQLClient } from "graphql-request"
import { cookies } from "next/headers"

const API_URL = `${process.env.NEXT_PUBLIC_API_URL}/graphql`

/**
 * Returns an authenticated GraphQLClient for use in Server Components.
 * Reads the auth_token cookie set at login — no localStorage needed server-side.
 */
export async function getGraphQLClient(): Promise<GraphQLClient> {
  const cookieStore = await cookies()
  const token = cookieStore.get("auth_token")?.value
  return new GraphQLClient(API_URL, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  })
}
