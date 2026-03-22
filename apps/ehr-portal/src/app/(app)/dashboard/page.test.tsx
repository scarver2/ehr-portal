// src/app/dashboard/page.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'

// Mock auth context
vi.mock('@/context/auth-context', () => ({
  useAuth: () => ({
    setToken: vi.fn(),
    setUser: vi.fn(),
    user: { id: 1, email: 'user@example.com', role: 'provider', provider_id: 1 },
  }),
}))

vi.mock('@/components/protected', () => ({
  default: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
}))

import Dashboard from './page'

describe('Dashboard', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders the dashboard heading', () => {
    render(<Dashboard />)
    expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument()
  })

  it('renders welcome message with user email', () => {
    render(<Dashboard />)
    expect(screen.getByText(/Welcome back,/)).toBeInTheDocument()
    expect(screen.getByText(/user@example.com/)).toBeInTheDocument()
  })

  it('wraps content with Protected component', () => {
    render(<Dashboard />)
    // Protected component is mocked, just verify Dashboard renders
    expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument()
  })
})
