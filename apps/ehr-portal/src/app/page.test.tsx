// apps/ehr-portal/src/app/page.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'

// Mock next/navigation before importing Home
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
  }),
}))

// Mock auth context
vi.mock('@/context/auth-context', () => ({
  useAuth: () => ({
    setToken: vi.fn(),
    setUser: vi.fn(),
    user: null,
  }),
}))

vi.mock('@/lib/auth', () => ({
  login: vi.fn(),
}))

import Home from './page'

describe('Home', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders the EHR heading', () => {
    render(<Home />)
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('EHR')
  })

  it('renders the copyright footer', () => {
    render(<Home />)
    expect(screen.getByText(/2026/)).toBeInTheDocument()
  })

  it('links copyright to stancarver.com', () => {
    render(<Home />)
    const link = screen.getByRole('link', { name: 'Stan Carver II' })
    expect(link).toHaveAttribute('href', 'https://stancarver.com')
  })

  it('opens the copyright link in a new tab', () => {
    render(<Home />)
    const link = screen.getByRole('link', { name: 'Stan Carver II' })
    expect(link).toHaveAttribute('target', '_blank')
    expect(link).toHaveAttribute('rel', 'noopener noreferrer')
  })

  it('renders the login form with email and password inputs', () => {
    render(<Home />)
    expect(screen.getByPlaceholderText('Email')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('Password')).toBeInTheDocument()
  })

  it('renders a submit button', () => {
    render(<Home />)
    expect(screen.getByRole('button', { name: /Login/i })).toBeInTheDocument()
  })
})
