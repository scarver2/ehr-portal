// src/app/login/page.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'

// Mock next/navigation before importing LoginPage
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

import LoginPage from './page'

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders email input', () => {
    render(<LoginPage />)
    expect(screen.getByPlaceholderText('Email')).toBeInTheDocument()
  })

  it('renders password input', () => {
    render(<LoginPage />)
    expect(screen.getByPlaceholderText('Password')).toBeInTheDocument()
  })

  it('renders submit button', () => {
    render(<LoginPage />)
    expect(screen.getByRole('button', { name: /Login/i })).toBeInTheDocument()
  })

  it('email input accepts text', () => {
    render(<LoginPage />)
    const emailInput = screen.getByPlaceholderText('Email') as HTMLInputElement
    expect(emailInput.type).toBe('email')
    expect(emailInput.required).toBe(true)
  })

  it('password input accepts text', () => {
    render(<LoginPage />)
    const passwordInput = screen.getByPlaceholderText('Password') as HTMLInputElement
    expect(passwordInput.type).toBe('password')
    expect(passwordInput.required).toBe(true)
  })
})
