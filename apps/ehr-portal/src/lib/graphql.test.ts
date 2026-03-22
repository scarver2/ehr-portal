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

  it('creates a GraphQL client successfully', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
    expect(client).toHaveProperty('request')
  })

  it('reads auth_token from cookies', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue({ value: 'test-token-123' }),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    await getGraphQLClient()

    expect(mockCookies.get).toHaveBeenCalledWith('auth_token')
  })

  it('returns client when token exists', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue({ value: 'valid-token' }),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
  })

  it('returns client when token is missing', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
  })

  it('client is a GraphQLClient instance', async () => {
    const mockCookies = {
      get: vi.fn().mockReturnValue(undefined),
    }
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as any)

    const client = await getGraphQLClient()

    expect(typeof client.request).toBe('function')
  })
})
