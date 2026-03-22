// src/components/protected.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import Protected from './protected'

// Mock useRouter
vi.mock('next/navigation', () => ({
  useRouter: vi.fn(),
}))

// Mock auth context
vi.mock('@/context/auth-context', () => ({
  useAuth: vi.fn(),
}))

import { useRouter } from 'next/navigation'
import { useAuth } from '@/context/auth-context'

describe('Protected', () => {
  const mockPush = vi.fn()

  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(useRouter).mockReturnValue({
      push: mockPush,
    } as any)
  })

  it('renders children when token exists', () => {
    vi.mocked(useAuth).mockReturnValue({
      token: 'test-token',
      user: null,
      setToken: vi.fn(),
      setUser: vi.fn(),
    } as any)

    render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    expect(screen.getByText('Protected Content')).toBeInTheDocument()
  })

  it('does not render children when token is null', () => {
    vi.mocked(useAuth).mockReturnValue({
      token: null,
      user: null,
      setToken: vi.fn(),
      setUser: vi.fn(),
    } as any)

    render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument()
  })

  it('redirects to login when token is null', async () => {
    vi.mocked(useAuth).mockReturnValue({
      token: null,
      user: null,
      setToken: vi.fn(),
      setUser: vi.fn(),
    } as any)

    render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/login')
    })
  })

  it('does not redirect when token exists', () => {
    vi.mocked(useAuth).mockReturnValue({
      token: 'test-token',
      user: null,
      setToken: vi.fn(),
      setUser: vi.fn(),
    } as any)

    render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    expect(mockPush).not.toHaveBeenCalled()
  })

  it('suppresses flash by returning null during hydration', () => {
    vi.mocked(useAuth).mockReturnValue({
      token: null,
      user: null,
      setToken: vi.fn(),
      setUser: vi.fn(),
    } as any)

    const { container } = render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    // Container should be empty initially (null return)
    expect(container.firstChild).toBeNull()
  })

  it('handles token becoming null after being truthy', async () => {
    const mockSetToken = vi.fn()
    const mockSetUser = vi.fn()
    
    const { rerender } = render(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    // First render with token
    vi.mocked(useAuth).mockReturnValue({
      token: 'test-token',
      user: null,
      setToken: mockSetToken,
      setUser: mockSetUser,
    } as any)

    rerender(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    expect(screen.getByText('Protected Content')).toBeInTheDocument()

    // Then token becomes null
    vi.mocked(useAuth).mockReturnValue({
      token: null,
      user: null,
      setToken: mockSetToken,
      setUser: mockSetUser,
    } as any)

    rerender(
      <Protected>
        <div>Protected Content</div>
      </Protected>
    )

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/login')
    })
  })
})
