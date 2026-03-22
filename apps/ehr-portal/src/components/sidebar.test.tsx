import { render, screen, fireEvent, waitFor } from "@testing-library/react"
import { describe, it, expect, beforeEach, vi } from "vitest"
import { Sidebar } from "./sidebar"
import { AuthProvider } from "@/context/auth-context"

// Mock next/navigation
const mockPush = vi.fn()
const mockUsePathname = vi.fn()
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
  }),
  usePathname: () => mockUsePathname(),
}))

// Mock auth/logout
vi.mock("@/lib/auth/logout", () => ({
  logout: vi.fn(async () => Promise.resolve()),
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

describe("Sidebar", () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.clear()
    mockPush.mockClear()
    mockUsePathname.mockReturnValue("/dashboard")
  })

  it("renders sidebar with branding", () => {
    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )
    expect(screen.getByText("⚕️ EHR Portal")).toBeInTheDocument()
  })

  it("renders navigation items", () => {
    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )
    expect(screen.getByText("Dashboard")).toBeInTheDocument()
    expect(screen.getByText("Patients")).toBeInTheDocument()
    expect(screen.getByText("Providers")).toBeInTheDocument()
  })

  it("highlights active navigation item", () => {
    mockUsePathname.mockReturnValue("/dashboard")

    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )

    const dashboardLink = screen.getByText("Dashboard").closest("a")
    expect(dashboardLink).toHaveClass("bg-blue-600", "text-white")
  })

  it("renders profile link", () => {
    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )
    expect(screen.getByText("Profile")).toBeInTheDocument()
  })

  it("renders logout button", () => {
    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )
    expect(screen.getByText("Logout")).toBeInTheDocument()
  })

  it("clears auth and redirects on logout click", async () => {
    localStorageMock.setItem("auth_token", "token123")
    localStorageMock.setItem("auth_user", JSON.stringify({ id: 1, email: "test@example.com", role: "provider", provider_id: 1, roles: ["provider"] }))

    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )

    const logoutButton = screen.getByText("Logout")
    fireEvent.click(logoutButton)

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/")
      expect(localStorageMock.getItem("auth_token")).toBeNull()
      expect(localStorageMock.getItem("auth_user")).toBeNull()
    })
  })

  it("navigates to correct route when clicking nav item", () => {
    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )

    const patientsLink = screen.getByText("Patients").closest("a")
    expect(patientsLink).toHaveAttribute("href", "/patients")
  })

  it("highlights nav item for subpath", () => {
    mockUsePathname.mockReturnValue("/patients/123")

    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )

    const patientsLink = screen.getByText("Patients").closest("a")
    expect(patientsLink).toHaveClass("bg-blue-600", "text-white")
  })

  it("shows profile as active when on profile page", () => {
    mockUsePathname.mockReturnValue("/profile")

    render(
      <AuthProvider>
        <Sidebar />
      </AuthProvider>
    )

    const profileLink = screen.getByText("Profile").closest("a")
    expect(profileLink).toHaveClass("bg-blue-600", "text-white")
  })
})
