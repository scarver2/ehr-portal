// src/lib/graphql.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { getGraphQLClient } from './graphql'
import type { RequestCookies } from 'next/dist/compiled/@edge-runtime/cookies'

// Mock next/headers
vi.mock('next/headers', () => ({
  cookies: vi.fn(),
}))

import { cookies } from 'next/headers'

interface MockCookies {
  get: (name: string) => { value: string } | undefined
}

describe('getGraphQLClient', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  const createMockCookies = (tokenValue?: string): MockCookies => ({
    get: vi.fn().mockReturnValue(
      tokenValue ? { value: tokenValue } : undefined
    ),
  })

  it('creates a GraphQL client successfully', async () => {
    const mockCookies = createMockCookies()
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as unknown as RequestCookies)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
    expect(client).toHaveProperty('request')
  })

  it('reads auth_token from cookies', async () => {
    const mockCookies = createMockCookies('test-token-123')
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as unknown as RequestCookies)

    await getGraphQLClient()

    expect(mockCookies.get).toHaveBeenCalledWith('auth_token')
  })

  it('returns client when token exists', async () => {
    const mockCookies = createMockCookies('valid-token')
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as unknown as RequestCookies)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
  })

  it('returns client when token is missing', async () => {
    const mockCookies = createMockCookies()
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as unknown as RequestCookies)

    const client = await getGraphQLClient()

    expect(client).toBeDefined()
  })

  it('client is a GraphQLClient instance', async () => {
    const mockCookies = createMockCookies()
    vi.mocked(cookies).mockResolvedValueOnce(mockCookies as unknown as RequestCookies)

    const client = await getGraphQLClient()

    expect(typeof client.request).toBe('function')
  })
})
