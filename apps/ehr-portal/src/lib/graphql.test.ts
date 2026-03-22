// apps/ehr-portal/src/lib/graphql.test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { GraphQLClient } from 'graphql-request'

vi.mock('graphql-request', () => ({
  GraphQLClient: vi.fn(),
}))

vi.mock('next/headers', () => ({
  cookies: vi.fn(),
}))

describe('getGraphQLClient', () => {
  beforeEach(() => {
    vi.resetModules()
    vi.clearAllMocks()
    vi.stubEnv('NEXT_PUBLIC_API_URL', 'http://test-api:3001')
  })

  afterEach(() => {
    vi.unstubAllEnvs()
  })

  it('exports getGraphQLClient function', async () => {
    const { getGraphQLClient } = await import('./graphql')
    expect(typeof getGraphQLClient).toBe('function')
  })

  it('returns a GraphQLClient instance', async () => {
    const { getGraphQLClient } = await import('./graphql')
    const { cookies } = await import('next/headers')
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    vi.mocked(cookies).mockResolvedValue(new Map() as any)

    const client = await getGraphQLClient()
    expect(client).toBeDefined()
  })

  it('appends /graphql to NEXT_PUBLIC_API_URL', async () => {
    const { getGraphQLClient } = await import('./graphql')
    const { cookies } = await import('next/headers')
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    vi.mocked(cookies).mockResolvedValue(new Map() as any)

    await getGraphQLClient()
    expect(GraphQLClient).toHaveBeenCalledWith(
      'http://test-api:3001/graphql',
      expect.any(Object)
    )
  })

  it('uses a different base URL when the env var changes', async () => {
    vi.stubEnv('NEXT_PUBLIC_API_URL', 'https://api.example.com')
    vi.resetModules()

    const { getGraphQLClient } = await import('./graphql')
    const { cookies } = await import('next/headers')
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    vi.mocked(cookies).mockResolvedValue(new Map() as any)

    await getGraphQLClient()
    expect(GraphQLClient).toHaveBeenCalledWith(
      'https://api.example.com/graphql',
      expect.any(Object)
    )
  })
})
