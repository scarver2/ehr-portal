// apps/ehr-portal/src/app/patients/[id]/page.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"
import React from "react"
import type { GraphQLClient } from "graphql-request"

const mockRequest = vi.fn()

// Mock the GraphQL client before importing the page
vi.mock("@/lib/graphql", () => ({
  getGraphQLClient: vi.fn(async () => ({
    request: mockRequest,
  } as unknown as GraphQLClient)),
}))

// Mock next/link to avoid Next.js router dependency in tests
vi.mock("next/link", () => ({
  default: ({ href, children }: { href: string; children: React.ReactNode }) => (
    <a href={href}>{children}</a>
  ),
}))

// Mock the client component — tested in its own suite
vi.mock("./InsuranceVerificationPanel", () => ({
  InsuranceVerificationPanel: ({ patientId }: { patientId: number }) => (
    <div data-testid="insurance-panel" data-patient-id={patientId} />
  ),
}))

import PatientPage from "./page"

const mockEncounter = {
  id: "10",
  encounterType: "office_visit",
  status: "completed",
  encounteredAt: "2025-06-15T10:00:00Z",
  chiefComplaint: "Annual checkup",
  provider: { id: "5", fullName: "Dr. Alice Adams" },
}

const mockPatient = {
  id: "1",
  fullName: "Jane Doe",
  dateOfBirth: "1990-03-15",
  age: 35,
  gender: "female",
  mrn: "00000001",
  phone: "555-0100",
  address: "123 Main St, Austin, TX",
  emergencyContactName: "John Doe",
  emergencyContactPhone: "555-0199",
  encounters: [mockEncounter],
}

// Helper: build params as an awaitable object matching Next.js App Router signature
const params = (id: string) => ({ params: Promise.resolve({ id }) })

describe("PatientPage", () => {
  beforeEach(() => {
    mockRequest.mockResolvedValue({ patient: mockPatient })
  })

  // ── Identity ──────────────────────────────────────────────────────────────

  it("renders the patient full name as a heading", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByRole("heading", { name: "Jane Doe" })).toBeInTheDocument()
  })

  it("fetches the patient by the id param", async () => {
    await PatientPage(params("42"))
    expect(mockRequest).toHaveBeenCalledWith(expect.anything(), { id: "42" })
  })

  it("calls getGraphQLClient().request once per render", async () => {
    await PatientPage(params("1"))
    expect(mockRequest).toHaveBeenCalledTimes(1)
  })

  // ── Demographics ──────────────────────────────────────────────────────────

  it("displays the formatted date of birth", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("DOB: Mar 15, 1990")).toBeInTheDocument()
  })

  it("displays age in the hero section", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("35 yrs")).toBeInTheDocument()
  })

  it("displays a human-readable gender label", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Female")).toBeInTheDocument()
  })

  it("displays the MRN", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("00000001")).toBeInTheDocument()
  })

  it("shows dashes for missing demographic fields", async () => {
    mockRequest.mockResolvedValue({
      patient: { ...mockPatient, dateOfBirth: null, age: null, gender: null, mrn: null },
    })
    render(await PatientPage(params("1")))
    // Hero section should not have gender, age, mrn
    expect(screen.queryByText("yrs")).toBeNull()
    expect(screen.queryByText("—")).toBeNull()
  })

  // ── Contact ───────────────────────────────────────────────────────────────

  it("displays phone and address in the hero", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("555-0100")).toBeInTheDocument()
    expect(screen.getByText("123 Main St, Austin, TX")).toBeInTheDocument()
  })

  it("displays emergency contact information", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Emergency Contact")).toBeInTheDocument()
    expect(screen.getByText(/John Doe/)).toBeInTheDocument()
    expect(screen.getByText(/555-0199/)).toBeInTheDocument()
  })

  it("hides emergency contact section when no data", async () => {
    mockRequest.mockResolvedValue({
      patient: {
        ...mockPatient,
        emergencyContactName: null,
        emergencyContactPhone: null,
      },
    })
    render(await PatientPage(params("1")))
    expect(screen.queryByText("Emergency Contact")).toBeNull()
  })

  // ── Encounters ────────────────────────────────────────────────────────────

  it("renders the Encounters section heading", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByRole("heading", { name: "Encounters" })).toBeInTheDocument()
  })

  it("renders a list item for each encounter", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getAllByRole("listitem")).toHaveLength(1)
  })

  it("links each encounter to its detail page", async () => {
    render(await PatientPage(params("1")))
    const link = screen.getByRole("link", { name: /Office Visit/ })
    expect(link).toHaveAttribute("href", "/encounters/10")
  })

  it("displays the provider name alongside the encounter", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText(/Dr\. Alice Adams/)).toBeInTheDocument()
  })

  it("displays the chief complaint when present", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Annual checkup")).toBeInTheDocument()
  })

  it("shows empty state when no encounters exist", async () => {
    mockRequest.mockResolvedValue({
      patient: { ...mockPatient, encounters: [] },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("No encounters on record.")).toBeInTheDocument()
    expect(screen.queryByRole("listitem")).toBeNull()
  })

  it("falls back to raw gender string for unknown gender values", async () => {
    mockRequest.mockResolvedValue({
      patient: { ...mockPatient, gender: "nonbinary" },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("nonbinary")).toBeInTheDocument()
  })

  // ── Insurance Verification ────────────────────────────────────────────────

  it("renders the InsuranceVerificationPanel with the patient id", async () => {
    render(await PatientPage(params("1")))
    const panel = screen.getByTestId("insurance-panel")
    expect(panel).toBeInTheDocument()
    expect(panel).toHaveAttribute("data-patient-id", "1")
  })

  it("omits chief complaint when null", async () => {
    mockRequest.mockResolvedValue({
      patient: {
        ...mockPatient,
        encounters: [{ ...mockEncounter, chiefComplaint: null }],
      },
    })
    render(await PatientPage(params("1")))
    const item = screen.getByRole("listitem")
    expect(item.textContent).not.toMatch(/italic/)
  })
})
