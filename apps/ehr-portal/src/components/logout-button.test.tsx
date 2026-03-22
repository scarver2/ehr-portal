import { render, screen, fireEvent, waitFor } from "@testing-library/react"
import { describe, it, expect, beforeEach, vi } from "vitest"
import LogoutButton from "./logout-button"
import { AuthProvider } from "@/context/auth-context"

// Mock next/navigation
const mockPush = vi.fn()
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
  }),
}))

// Mock auth/logout
vi.mock("@/lib/auth/logout", () => ({
  logout: vi.fn(async () => {
    // Simulate logout API call
    return Promise.resolve()
  }),
}))

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

describe("LogoutButton", () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    mockPush.mockClear()
  })

  it("renders a logout button", () => {
    render(
      <AuthProvider>
        <LogoutButton />
      </AuthProvider>
    )
    expect(screen.getByText("Logout")).toBeInTheDocument()
  })

  it("clears auth state and redirects on logout", async () => {
    // Set up initial auth state
    localStorageMock.setItem("auth_token", "token123")
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1, email: "test@example.com", role: "provider", provider_id: 1, roles: ["provider"] }))

    render(
      <AuthProvider>
        <LogoutButton />
      </AuthProvider>
    )

    const logoutButton = screen.getByText("Logout")
    fireEvent.click(logoutButton)

    await waitFor(() => {
      // Should redirect to login
      expect(mockPush).toHaveBeenCalledWith("/login")
      // Auth state should be cleared
      expect(localStorageMock.getItem("auth_token")).toBeNull()
      expect(localStorageMock.getItem("auth_user")).toBeNull()
    })
  })

  it("attempts redirect even if logout API call fails", async () => {
    // Note: logout function catches errors, so button should still work
    render(
      <AuthProvider>
        <LogoutButton />
      </AuthProvider>
    )

    const logoutButton = screen.getByText("Logout")
    fireEvent.click(logoutButton)

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/login")
    })
  })
})
