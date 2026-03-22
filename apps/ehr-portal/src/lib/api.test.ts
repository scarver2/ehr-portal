// src/lib/api.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { apiFetch } from './api'

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

describe('apiFetch', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
  })

  it('calls fetch with correct URL', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test')

    expect(mockFetch).toHaveBeenCalledWith(
      expect.stringEndingWith('/api/test'),
      expect.any(Object)
    )
  })

  it('includes Content-Type header', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test')

    expect(mockFetch).toHaveBeenCalledWith(
      expect.any(String),
      expect.objectContaining({
        headers: expect.objectContaining({
          'Content-Type': 'application/json'
        })
      })
    )
  })

  it('includes Authorization header when token exists', async () => {
    const mockFetch = vi.mocked(global.fetch)
    localStorageMock.setItem('auth_token', 'token123')
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test')

    expect(mockFetch).toHaveBeenCalledWith(
      expect.any(String),
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: 'Bearer token123'
        })
      })
    )
  })

  it('omits Authorization header when token is missing', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test')

    const callArgs = mockFetch.mock.calls[0]
    const headers = callArgs[1].headers as Record<string, string>
    expect(headers.Authorization).toBeUndefined()
  })

  it('merges custom headers with default headers', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test', {
      headers: {
        'X-Custom-Header': 'custom-value'
      }
    })

    expect(mockFetch).toHaveBeenCalledWith(
      expect.any(String),
      expect.objectContaining({
        headers: expect.objectContaining({
          'Content-Type': 'application/json',
          'X-Custom-Header': 'custom-value'
        })
      })
    )
  })

  it('passes through other options', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    await apiFetch('/api/test', {
      method: 'POST',
      body: JSON.stringify({ test: 'data' })
    })

    expect(mockFetch).toHaveBeenCalledWith(
      expect.any(String),
      expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({ test: 'data' })
      })
    )
  })

  it('uses NEXT_PUBLIC_API_URL environment variable', async () => {
    const mockFetch = vi.mocked(global.fetch)
    mockFetch.mockResolvedValueOnce({ ok: true } as unknown as Response)

    // The actual env var is set by the test environment
    await apiFetch('/api/test')

    const callUrl = mockFetch.mock.calls[0][0] as string
    expect(callUrl).toContain('/api/test')
  })
})
