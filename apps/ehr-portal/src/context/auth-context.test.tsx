// src/context/auth-context.test.tsx

import { describe, it, expect, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { AuthProvider, useAuth } from './auth-context'

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

// Test component that uses auth context
function TestComponent() {
  const { token, user, setToken, setUser } = useAuth()
  return (
    <div>
      <div data-testid="token">{token || 'no-token'}</div>
      <div data-testid="user">{user?.email || 'no-user'}</div>
      <button onClick={() => setToken('new-token')}>Set Token</button>
      <button onClick={() => setUser({ id: 1, email: 'test@example.com', role: 'patient', provider_id: null, roles: ['patient'] })}>Set User</button>
      <button onClick={() => setToken(null)}>Clear Token</button>
      <button onClick={() => setUser(null)}>Clear User</button>
    </div>
  )
}

describe('AuthContext', () => {
  beforeEach(() => {
    localStorageMock.clear()
  })

  it('provides initial null values when localStorage is empty', () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('token')).toHaveTextContent('no-token')
    expect(screen.getByTestId('user')).toHaveTextContent('no-user')
  })

  it('initializes token from localStorage', () => {
    localStorageMock.setItem('auth_token', 'stored-token')

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('token')).toHaveTextContent('stored-token')
  })

  it('initializes user from localStorage', () => {
    const userData = { id: 1, email: 'stored@example.com', role: 'provider', provider_id: 1, roles: ['provider'] }
    localStorageMock.setItem('auth_user', JSON.stringify(userData))

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('user')).toHaveTextContent('stored@example.com')
  })

  it('persists token to localStorage when setToken is called', async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    screen.getByRole('button', { name: /set token/i }).click()

    await waitFor(() => {
      expect(localStorageMock.getItem('auth_token')).toBe('new-token')
    })
  })

  it('persists user to localStorage when setUser is called', async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    screen.getByRole('button', { name: /set user/i }).click()

    await waitFor(() => {
      const stored = localStorageMock.getItem('auth_user')
      expect(stored).toBeTruthy()
      const parsed = JSON.parse(stored!)
      expect(parsed.email).toBe('test@example.com')
    })
  })

  it('removes token from localStorage when setToken(null) is called', async () => {
    localStorageMock.setItem('auth_token', 'token')

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    screen.getByRole('button', { name: /clear token/i }).click()

    await waitFor(() => {
      expect(localStorageMock.getItem('auth_token')).toBeNull()
    })
  })

  it('removes user from localStorage when setUser(null) is called', async () => {
    const userData = { id: 1, email: 'test@example.com', role: 'patient', provider_id: null, roles: ['patient'] }
    localStorageMock.setItem('auth_user', JSON.stringify(userData))

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    screen.getByRole('button', { name: /clear user/i }).click()

    await waitFor(() => {
      expect(localStorageMock.getItem('auth_user')).toBeNull()
    })
  })

  it('handles invalid JSON in localStorage gracefully', () => {
    localStorageMock.setItem('auth_user', 'invalid-json')

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('user')).toHaveTextContent('no-user')
    // Should remove the invalid entry
    expect(localStorageMock.getItem('auth_user')).toBeNull()
  })

  it('throws error when useAuth is used outside AuthProvider', () => {
    const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {})

    expect(() => {
      render(<TestComponent />)
    }).toThrow('useAuth must be used inside AuthProvider')

    consoleError.mockRestore()
  })

  it('updates UI when token changes', async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('token')).toHaveTextContent('no-token')

    screen.getByRole('button', { name: /set token/i }).click()

    await waitFor(() => {
      expect(screen.getByTestId('token')).toHaveTextContent('new-token')
    })
  })

  it('updates UI when user changes', async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    expect(screen.getByTestId('user')).toHaveTextContent('no-user')

    screen.getByRole('button', { name: /set user/i }).click()

    await waitFor(() => {
      expect(screen.getByTestId('user')).toHaveTextContent('test@example.com')
    })
  })
})
