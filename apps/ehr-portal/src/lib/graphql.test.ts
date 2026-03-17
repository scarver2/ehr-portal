// apps/ehr-portal/src/lib/graphql.test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { GraphQLClient } from 'graphql-request'

// vi.fn() creates a regular (non-arrow) function that can be called with `new`
vi.mock('graphql-request', () => ({
  GraphQLClient: vi.fn(),
}))

describe('graphql client', () => {
  beforeEach(() => {
    vi.resetModules()
    vi.clearAllMocks()
    vi.stubEnv('NEXT_PUBLIC_API_URL', 'http://test-api:3001')
  })

  afterEach(() => {
    vi.unstubAllEnvs()
  })

  it('exports a named graphql client', async () => {
    const mod = await import('./graphql')
    expect(mod.graphql).toBeDefined()
  })

  it('constructs a GraphQLClient instance', async () => {
    await import('./graphql')
    expect(GraphQLClient).toHaveBeenCalledTimes(1)
  })

  it('appends /graphql to NEXT_PUBLIC_API_URL', async () => {
    await import('./graphql')
    expect(GraphQLClient).toHaveBeenCalledWith('http://test-api:3001/graphql')
  })

  it('uses a different base URL when the env var changes', async () => {
    vi.stubEnv('NEXT_PUBLIC_API_URL', 'https://api.example.com')
    await import('./graphql')
    expect(GraphQLClient).toHaveBeenCalledWith('https://api.example.com/graphql')
  })
})
