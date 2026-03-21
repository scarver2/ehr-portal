// apps/ehr-portal/src/app/providers/[id]/page.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"
import type { GraphQLClient } from "graphql-request"

const mockRequest = vi.fn()

// Mock the GraphQL client before importing the page
vi.mock("@/lib/graphql", () => ({
  getGraphQLClient: vi.fn(async () => ({
    request: mockRequest,
  } as unknown as GraphQLClient)),
}))

import ProviderPage from "./page"

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
    mockRequest.mockResolvedValue({ provider: mockProvider })
  })

  it("renders the provider full name as a heading", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByRole("heading", { name: "Alice Adams" })).toBeInTheDocument()
  })

  it("displays the provider NPI", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("1111111111")).toBeInTheDocument()
  })

  it("displays the provider specialty name", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByText("Cardiology")).toBeInTheDocument()
  })

  it("does not display specialty badge when specialty is null", async () => {
    mockRequest.mockResolvedValue({
      provider: { ...mockProvider, specialty: null },
    })
    render(await ProviderPage(params("1")))
    // The specialty badge should not be present
    expect(screen.queryByText("Cardiology")).toBeNull()
  })

  it("displays the clinic name", async () => {
    render(await ProviderPage(params("1")))
    // Get the clinic name in the main card (first occurrence)
    const clinicNames = screen.getAllByText("Heart Clinic")
    expect(clinicNames.length).toBeGreaterThan(0)
  })

  it("fetches the provider by the id param", async () => {
    await ProviderPage(params("42"))
    expect(mockRequest).toHaveBeenCalledWith(
      expect.anything(), // the GQL document
      { id: "42" }
    )
  })

  it("calls getGraphQLClient().request once per render", async () => {
    await ProviderPage(params("1"))
    expect(mockRequest).toHaveBeenCalledTimes(1)
  })

  it("displays patients from encounters", async () => {
    render(await ProviderPage(params("1")))
    expect(screen.getByRole("heading", { name: /Patients/ })).toBeInTheDocument()
    expect(screen.getByText("Doe, John")).toBeInTheDocument()
    expect(screen.getByText("Smith, Jane")).toBeInTheDocument()
  })

  it("displays no patients message when encounters is empty", async () => {
    mockRequest.mockResolvedValue({
      provider: { ...mockProvider, encounters: [] },
    })
    render(await ProviderPage(params("1")))
    expect(screen.getByText("No patients on record.")).toBeInTheDocument()
  })
})
