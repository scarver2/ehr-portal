import { render, screen, waitFor } from "@testing-library/react"
import { describe, it, expect, beforeEach, vi } from "vitest"
import { AuthProvider, useAuth } from "./auth-context"

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

Object.defineProperty(window, "localStorage", { value: localStorageMock })

function TestComponent() {
  const { token, user, setToken, setUser } = useAuth()
  return (
    <div>
      <div data-testid="token">{token}</div>
      <div data-testid="user">{user?.email}</div>
      <button onClick={() => setToken("new-token")}>Set Token</button>
      <button onClick={() => setUser({ id: 1, email: "test@example.com", role: "provider", provider_id: 1, roles: ["provider"] })}>Set User</button>
      <button onClick={() => setToken(null)}>Clear Token</button>
      <button onClick={() => setUser(null)}>Clear User</button>
    </div>
  )
}

describe("AuthContext", () => {
  beforeEach(() => {
    localStorageMock.clear()
  })

  it("provides initial null token and user", () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    expect(screen.getByTestId("token")).toHaveTextContent("")
    expect(screen.getByTestId("user")).toHaveTextContent("")
  })

  it("initializes from localStorage if present", () => {
    localStorageMock.setItem("auth_token", "stored-token")
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1, email: "stored@example.com", role: "patient", provider_id: null, roles: ["patient"] }))

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    expect(screen.getByTestId("token")).toHaveTextContent("stored-token")
    expect(screen.getByTestId("user")).toHaveTextContent("stored@example.com")
  })

  it("updates localStorage when token is set", async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    screen.getByText("Set Token").click()

    await waitFor(() => {
      expect(localStorageMock.getItem("auth_token")).toBe("new-token")
    })
  })

  it("updates localStorage when user is set", async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    screen.getByText("Set User").click()

    await waitFor(() => {
      const stored = localStorageMock.getItem("auth_user")
      expect(stored).toBeDefined()
      const parsed = JSON.parse(stored!)
      expect(parsed.email).toBe("test@example.com")
    })
  })

  it("clears localStorage when token is cleared", async () => {
    localStorageMock.setItem("auth_token", "token-to-clear")
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    screen.getByText("Clear Token").click()

    await waitFor(() => {
      expect(localStorageMock.getItem("auth_token")).toBeNull()
    })
  })

  it("clears localStorage when user is cleared", async () => {
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1, email: "test@example.com" }))
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )
    screen.getByText("Clear User").click()

    await waitFor(() => {
      expect(localStorageMock.getItem("auth_user")).toBeNull()
    })
  })

  it("throws error when useAuth is used outside AuthProvider", () => {
    // Suppress console.error for this test
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {})

    expect(() => {
      render(<TestComponent />)
    }).toThrow("useAuth must be used inside AuthProvider")

    consoleSpy.mockRestore()
  })

  it("handles invalid JSON in localStorage", () => {
    localStorageMock.setItem("auth_user", "invalid-json{")

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    )

    // Should not crash and should have cleared the invalid item
    expect(screen.getByTestId("user")).toHaveTextContent("")
    expect(localStorageMock.getItem("auth_user")).toBeNull()
  })
})
