// src/lib/auth.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { login } from './auth'

// Mock fetch globally
global.fetch = vi.fn()

// Mock localStorage
const localStorageMock = (() => {
  let store: Record<string, string> = {}
  return {
    getItem: (key: string) => store[key] || null,
    setItem: (key: string, value: string) => {
      store[key] = value.toString()
    },
    removeItem: (key: string) => {
      delete store[key]
    },
    clear: () => {
      store = {}
    },
  }
})()

Object.defineProperty(window, 'localStorage', { value: localStorageMock })

describe('login', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    document.cookie = 'auth_token='
  })

  it('sends POST request with email and password', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce(
      new Response(JSON.stringify({ user: { id: 1, email: 'test@example.com', role: 'provider', provider_id: 1 } }), {
        headers: { Authorization: 'Bearer token123' },
      })
    )

    await login('test@example.com', 'password')

    expect(mockFetch).toHaveBeenCalledWith(expect.stringContaining('/api/v1/auth/login'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: { email: 'test@example.com', password: 'password' } }),
    })
  })

  it('extracts token from Authorization header', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce(
      new Response(JSON.stringify({ user: { id: 1, email: 'test@example.com', role: 'provider', provider_id: 1 } }), {
        headers: { Authorization: 'Bearer token123' },
      })
    )

    const result = await login('test@example.com', 'password')

    expect(result.token).toBe('token123')
  })

  it('stores token in localStorage', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce(
      new Response(JSON.stringify({ user: { id: 1, email: 'test@example.com', role: 'provider', provider_id: 1 } }), {
        headers: { Authorization: 'Bearer token123' },
      })
    )

    await login('test@example.com', 'password')

    expect(localStorageMock.getItem('auth_token')).toBe('token123')
  })

  it('throws error on failed login', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce(new Response('Unauthorized', { status: 401 }))

    await expect(login('test@example.com', 'wrong')).rejects.toThrow('Invalid email or password')
  })

  it('returns user data from response', async () => {
    const mockFetch = vi.mocked(global.fetch)
    const userData = { id: 1, email: 'test@example.com', role: 'provider', provider_id: 1 }
    mockFetch.mockResolvedValueOnce(
      new Response(JSON.stringify({ user: userData }), {
        headers: { Authorization: 'Bearer token123' },
      })
    )

    const result = await login('test@example.com', 'password')

    expect(result.user).toEqual(userData)
  })
})
