// src/lib/auth/logout.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { logout } from './logout'

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

describe('logout', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    document.cookie = 'auth_token='
  })

  it('sends DELETE request to logout endpoint with token', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'test-token-123')
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await logout()

    expect(mockFetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/v1/auth/logout'),
      expect.objectContaining({
        method: 'DELETE',
        headers: { Authorization: 'Bearer test-token-123' },
      })
    )
  })

  it('skips server-side logout if no token exists', async () => {
    const mockFetch = vi.mocked(global.fetch)
    
    await logout()

    expect(mockFetch).not.toHaveBeenCalled()
  })

  it('removes auth_token from localStorage', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'token')
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await logout()

    expect(localStorageMock.getItem('auth_token')).toBeNull()
  })

  it('removes auth_user from localStorage', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_user', JSON.stringify({ id: 1, email: 'test@example.com' }))
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await logout()

    expect(localStorageMock.getItem('auth_user')).toBeNull()
  })

  it('expires the auth_token cookie', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'token')
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    const cookieSpy = vi.spyOn(document, 'cookie', 'set')
    await logout()

    const cookieValue = cookieSpy.mock.calls[0][0] as string
    expect(cookieValue).toContain('auth_token=')
    expect(cookieValue).toContain('max-age=0')
    cookieSpy.mockRestore()
  })

  it('gracefully handles server logout errors', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'token')
    mockFetch.mockRejectedValueOnce(new Error('Network error'))

    // Should not throw despite fetch error
    await expect(logout()).resolves.not.toThrow()
  })

  it('uses NEXT_PUBLIC_API_URL environment variable', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'token')
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await logout()

    const callUrl = mockFetch.mock.calls[0][0] as string
    expect(callUrl).toContain('/api/v1/auth/logout')
  })
})
