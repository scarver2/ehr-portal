// apps/ehr-portal/src/app/patients/[id]/page.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"
import React from "react"

// Mock the GraphQL client before importing the page
vi.mock("@/lib/graphql", () => ({
  graphql: {
    request: vi.fn(),
  },
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
import { graphql } from "@/lib/graphql"

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
    vi.mocked(graphql.request).mockResolvedValue({ patient: mockPatient })
  })

  // ── Identity ──────────────────────────────────────────────────────────────

  it("renders the patient full name as a heading", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByRole("heading", { name: "Jane Doe" })).toBeInTheDocument()
  })

  it("fetches the patient by the id param", async () => {
    await PatientPage(params("42"))
    expect(graphql.request).toHaveBeenCalledWith(expect.anything(), { id: "42" })
  })

  it("calls graphql.request once per render", async () => {
    await PatientPage(params("1"))
    expect(graphql.request).toHaveBeenCalledTimes(1)
  })

  // ── Demographics ──────────────────────────────────────────────────────────

  it("renders the Demographics section heading", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByRole("heading", { name: "Demographics" })).toBeInTheDocument()
  })

  it("displays the formatted date of birth", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Date of Birth: March 15, 1990")).toBeInTheDocument()
  })

  it("displays age", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Age: 35")).toBeInTheDocument()
  })

  it("displays a human-readable gender label", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Gender: Female")).toBeInTheDocument()
  })

  it("displays the MRN", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("MRN: 00000001")).toBeInTheDocument()
  })

  it("shows dashes for missing demographic fields", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      patient: { ...mockPatient, dateOfBirth: null, age: null, gender: null, mrn: null },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("Date of Birth: —")).toBeInTheDocument()
    expect(screen.getByText("Age: —")).toBeInTheDocument()
    expect(screen.getByText("Gender: —")).toBeInTheDocument()
    expect(screen.getByText("MRN: —")).toBeInTheDocument()
  })

  // ── Contact ───────────────────────────────────────────────────────────────

  it("renders the Contact section heading", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByRole("heading", { name: "Contact" })).toBeInTheDocument()
  })

  it("displays phone, address, and emergency contact", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText("Phone: 555-0100")).toBeInTheDocument()
    expect(screen.getByText("Address: 123 Main St, Austin, TX")).toBeInTheDocument()
    expect(screen.getByText("Emergency Contact: John Doe")).toBeInTheDocument()
    expect(screen.getByText("Emergency Phone: 555-0199")).toBeInTheDocument()
  })

  it("shows dashes for missing contact fields", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      patient: {
        ...mockPatient,
        phone: null,
        address: null,
        emergencyContactName: null,
        emergencyContactPhone: null,
      },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("Phone: —")).toBeInTheDocument()
    expect(screen.getByText("Address: —")).toBeInTheDocument()
    expect(screen.getByText("Emergency Contact: —")).toBeInTheDocument()
    expect(screen.getByText("Emergency Phone: —")).toBeInTheDocument()
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
    const link = screen.getByRole("link", { name: /June 15, 2025/ })
    expect(link).toHaveAttribute("href", "/encounters/10")
  })

  it("displays the provider name alongside the encounter", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText(/Dr\. Alice Adams/)).toBeInTheDocument()
  })

  it("displays the chief complaint when present", async () => {
    render(await PatientPage(params("1")))
    expect(screen.getByText(/Annual checkup/)).toBeInTheDocument()
  })

  it("shows empty state when no encounters exist", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      patient: { ...mockPatient, encounters: [] },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("No encounters on record.")).toBeInTheDocument()
    expect(screen.queryByRole("listitem")).toBeNull()
  })

  it("falls back to raw gender string for unknown gender values", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      patient: { ...mockPatient, gender: "nonbinary" },
    })
    render(await PatientPage(params("1")))
    expect(screen.getByText("Gender: nonbinary")).toBeInTheDocument()
  })

  // ── Insurance Verification ────────────────────────────────────────────────

  it("renders the InsuranceVerificationPanel with the patient id", async () => {
    render(await PatientPage(params("1")))
    const panel = screen.getByTestId("insurance-panel")
    expect(panel).toBeInTheDocument()
    expect(panel).toHaveAttribute("data-patient-id", "1")
  })

  it("omits chief complaint when null", async () => {
    vi.mocked(graphql.request).mockResolvedValue({
      patient: {
        ...mockPatient,
        encounters: [{ ...mockEncounter, chiefComplaint: null }],
      },
    })
    render(await PatientPage(params("1")))
    const item = screen.getByRole("listitem")
    expect(item.textContent).not.toMatch(/·/)
  })
})
