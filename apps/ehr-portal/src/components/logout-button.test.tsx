// src/components/logout-button.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import LogoutButton from './logout-button'

// Mock the logout function
vi.mock('@/lib/auth/logout', () => ({
  logout: vi.fn(),
}))

// Mock useRouter
vi.mock('next/navigation', () => ({
  useRouter: vi.fn(),
}))

// Mock auth context
vi.mock('@/context/auth-context', () => ({
  useAuth: vi.fn(),
}))

import { logout } from '@/lib/auth/logout'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/context/auth-context'
import type { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime'
import type { AuthContextType } from '@/context/auth-context'

describe('LogoutButton', () => {
  const mockPush = vi.fn()
  const mockSetToken = vi.fn()
  const mockSetUser = vi.fn()

  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(useRouter).mockReturnValue({
      push: mockPush,
    } as AppRouterInstance)
    vi.mocked(useAuth).mockReturnValue({
      token: 'test-token',
      user: null,
      setToken: mockSetToken,
      setUser: mockSetUser,
    } as AuthContextType)
    vi.mocked(logout).mockResolvedValue(undefined)
  })

  it('renders a logout button', () => {
    render(<LogoutButton />)
    const button = screen.getByRole('button', { name: /logout/i })
    expect(button).toBeInTheDocument()
  })

  it('calls logout function when clicked', async () => {
    render(<LogoutButton />)
    const button = screen.getByRole('button', { name: /logout/i })

    fireEvent.click(button)

    await waitFor(() => {
      expect(logout).toHaveBeenCalled()
    })
  })

  it('clears token from context when clicked', async () => {
    render(<LogoutButton />)
    const button = screen.getByRole('button', { name: /logout/i })

    fireEvent.click(button)

    await waitFor(() => {
      expect(mockSetToken).toHaveBeenCalledWith(null)
    })
  })

  it('clears user from context when clicked', async () => {
    render(<LogoutButton />)
    const button = screen.getByRole('button', { name: /logout/i })

    fireEvent.click(button)

    await waitFor(() => {
      expect(mockSetUser).toHaveBeenCalledWith(null)
    })
  })

  it('redirects to login page after logout', async () => {
    render(<LogoutButton />)
    const button = screen.getByRole('button', { name: /logout/i })

    fireEvent.click(button)

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/login')
    })
  })
})
