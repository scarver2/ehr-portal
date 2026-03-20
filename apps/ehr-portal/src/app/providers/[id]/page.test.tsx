// apps/ehr-portal/src/app/providers/[id]/page.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"

// Mock the GraphQL client before importing the page
vi.mock("@/lib/graphql", () => ({
  graphql: {
    request: vi.fn(),
  },
}))

import ProviderPage from "./page"
import { graphql } from "@/lib/graphql"

const mockProvider = {
  id: "1",
  fullName: "Alice Adams",
  npi: "1111111111",
  specialty: { id: "1", name: "Cardiology" },
  clinicName: "Heart Clinic",
  encounters: [
    { patient: { id: "p1", firstName: "John", lastName: "Doe" } },
    { patient: { id: "p2", firstName: "Jane", lastName: "Smith" } },
  ],
}

// Helper: build params as an awaitable object matching Next.js App Router signature
const params = (id: string) => ({ params: Promise.resolve({ id }) })

describe("ProviderPage", () => {
  beforeEach(() => {
    vi.mocked(graphql.request).mockResolvedValue({ provider: mockProvider })
  })

  it("renders the provider full name as a heading", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByRole("heading", { name: "Alice Adams" })).toBeInTheDocument()
  })

  it("displays the provider NPI", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("NPI: 1111111111")).toBeInTheDocument()
  })

  it("displays the provider specialty name", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Specialty: Cardiology")).toBeInTheDocument()
  })

  it("displays a dash when specialty is null", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      provider: { ...mockProvider, specialty: null },
    })
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Specialty: —")).toBeInTheDocument()
  })

  it("displays the clinic name", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Clinic: Heart Clinic")).toBeInTheDocument()
  })

  it("fetches the provider by the id param", async () => {
    await ProviderPage(params("42"))
    expect(graphql.request).toHaveBeenCalledWith(
      expect.anything(), // the GQL document
      { id: "42" }
    )
  })

  it("calls graphql.request once per render", async () => {
    await ProviderPage(params("1"))
    expect(graphql.request).toHaveBeenCalledTimes(1)
  })

  it("displays patients from encounters", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Patients (2)")).toBeInTheDocument()
    expect(screen.getByText("John Doe")).toBeInTheDocument()
    expect(screen.getByText("Jane Smith")).toBeInTheDocument()
  })

  it("displays no patients message when encounters is empty", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      provider: { ...mockProvider, encounters: [] },
    })
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Patients (0)")).toBeInTheDocument()
    expect(screen.getByText("No patients found.")).toBeInTheDocument()
  })
})
