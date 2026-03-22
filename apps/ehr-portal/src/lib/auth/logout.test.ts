import { describe, it, expect, beforeEach, vi } from "vitest"
import { logout } from "./logout"

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

// Mock fetch
global.fetch = vi.fn() as unknown as typeof global.fetch

describe("logout", () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    ;(global.fetch as unknown as typeof global.fetch).mockResolvedValue?.(new Response())
  })

  it("calls logout API endpoint with token", async () => {
    localStorageMock.setItem("auth_token", "valid-token")

    await logout()

    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining("/api/v1/auth/logout"),
      {
        method: "DELETE",
        headers: { Authorization: "Bearer valid-token" },
      }
    )
  })

  it("uses custom API URL from env if provided", async () => {
    const originalEnv = process.env.NEXT_PUBLIC_API_URL
    process.env.NEXT_PUBLIC_API_URL = "https://custom-api.example.com"
    localStorageMock.setItem("auth_token", "token")

    await logout()

    expect(global.fetch).toHaveBeenCalledWith(
      "https://custom-api.example.com/api/v1/auth/logout",
      expect.any(Object)
    )

    process.env.NEXT_PUBLIC_API_URL = originalEnv
  })

  it("removes auth token from localStorage", async () => {
    localStorageMock.setItem("auth_token", "token")

    await logout()

    expect(localStorageMock.getItem("auth_token")).toBeNull()
  })

  it("removes auth user from localStorage", async () => {
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1, email: "test@example.com" }))

    await logout()

    expect(localStorageMock.getItem("auth_user")).toBeNull()
  })

  it("clears localStorage items", async () => {
    localStorageMock.setItem("auth_token", "token")
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1 }))

    await logout()

    expect(localStorageMock.getItem("auth_token")).toBeNull()
    expect(localStorageMock.getItem("auth_user")).toBeNull()
  })

  it("handles fetch errors gracefully", async () => {
    localStorageMock.setItem("auth_token", "token")
    ;(global.fetch as unknown as typeof global.fetch).mockRejectedValueOnce?.(new Error("Network error"))

    // Should not throw
    await expect(logout()).resolves.toBeUndefined()

    // But should still clear localStorage
    expect(localStorageMock.getItem("auth_token")).toBeNull()
  })

  it("works without token in localStorage", async () => {
    localStorageMock.clear()

    // fetch should not be called if no token
    await logout()

    expect(localStorageMock.getItem("auth_token")).toBeNull()
    expect(localStorageMock.getItem("auth_user")).toBeNull()
  })
})
