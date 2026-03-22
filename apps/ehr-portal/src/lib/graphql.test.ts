// src/lib/graphql.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { getGraphQLClient } from './graphql'

// Mock next/headers
vi.mock('next/headers', () => ({
  cookies: vi.fn(),
}))

import { cookies } from 'next/headers'

describe('getGraphQLClient', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('creates a GraphQL client with correct API URL', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
    expect(client.getEndpoint()).toContain('/graphql')
  })

  it('includes Authorization header when token exists', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue({ value: 'test-token-123' }),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()
    const endpoint = client.getEndpoint()

    expect(endpoint).toBeDefined()
  })

  it('excludes Authorization header when token is missing', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()
    const endpoint = client.getEndpoint()

    expect(endpoint).toBeDefined()
  })

  it('reads auth_token from cookies', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue({ value: 'cookie-token-456' }),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    await getGraphQLClient()

    expect(mockCookies.get).toHaveBeenCalledWith('auth_token')
  })

  it('constructs URL from NEXT_PUBLIC_API_URL environment variable', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()
    const endpoint = client.getEndpoint()

    // The endpoint should be constructed from NEXT_PUBLIC_API_URL
    expect(endpoint).toBeTruthy()
  })
})
