import { render, screen, waitFor } from "@testing-library/react"
import { describe, it, expect, beforeEach, vi } from "vitest"
import Protected from "./protected"
import { AuthProvider } from "@/context/auth-context"

// Mock next/navigation
const mockPush = vi.fn()
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
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

describe("Protected", () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    mockPush.mockClear()
  })

  it("renders children when token is present", () => {
    localStorageMock.setItem("auth_token", "valid-token")

    render(
      <AuthProvider>
        <Protected>
          <div>Protected Content</div>
        </Protected>
      </AuthProvider>
    )

    expect(screen.getByText("Protected Content")).toBeInTheDocument()
  })

  it("does not render children when token is absent", () => {
    render(
      <AuthProvider>
        <Protected>
          <div>Protected Content</div>
        </Protected>
      </AuthProvider>
    )

    expect(screen.queryByText("Protected Content")).not.toBeInTheDocument()
  })

  it("redirects to login when token is absent", async () => {
    render(
      <AuthProvider>
        <Protected>
          <div>Protected Content</div>
        </Protected>
      </AuthProvider>
    )

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/login")
    })
  })

  it("returns null while token is null to prevent flash", async () => {
    // Start without token
    render(
      <AuthProvider>
        <Protected>
          <div>Protected Content</div>
        </Protected>
      </AuthProvider>
    )

    // Content should not be visible (component returns null)
    expect(screen.queryByText("Protected Content")).not.toBeInTheDocument()

    // Should redirect to login
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/login")
    })
  })
})
