// apps/ehr-portal/src/app/(app)/patients/page.test.tsx

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

import PatientsPage from "./page"

const mockPatients = [
  { id: "1", fullName: "Jane Doe",   dateOfBirth: "1990-03-15", age: 35, gender: "female",          mrn: "00000001" },
  { id: "2", fullName: "John Smith", dateOfBirth: "1985-07-22", age: 40, gender: "male",            mrn: "00000002" },
  { id: "3", fullName: "Alex Jones", dateOfBirth: null,         age: null, gender: "prefer_not_to_say", mrn: null },
]

describe("PatientsPage", () => {
  beforeEach(() => {
    mockRequest.mockResolvedValue({ patients: mockPatients })
  })

  it("renders the page heading", async () => {
    render(await PatientsPage())
    expect(screen.getByRole("heading", { name: /Patients/ })).toBeInTheDocument()
  })

  it("renders a card for each patient", async () => {
    render(await PatientsPage())
    expect(screen.getAllByRole("link")).toHaveLength(3)
  })

  it("links each patient to their detail page", async () => {
    render(await PatientsPage())
    const link = screen.getByRole("link", { name: /Jane Doe/ })
    expect(link).toHaveAttribute("href", "/patients/1")
  })

  it("displays age for patients with a date of birth", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/35 yrs/)).toBeInTheDocument()
    expect(screen.getByText(/40 yrs/)).toBeInTheDocument()
  })

  it("omits age when date of birth is absent", async () => {
    render(await PatientsPage())
    const links = screen.getAllByRole("link")
    const alexLink = links[2]
    expect(alexLink.textContent).not.toMatch(/yrs/)
  })

  it("displays a human-readable gender label", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/Female/)).toBeInTheDocument()
    expect(screen.getByText(/Male/)).toBeInTheDocument()
    expect(screen.getByText(/Prefer not to say/)).toBeInTheDocument()
  })

  it("displays the MRN when present", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/00000001/)).toBeInTheDocument()
  })

  it("omits MRN when absent", async () => {
    render(await PatientsPage())
    const links = screen.getAllByRole("link")
    const alexLink = links[2]
    expect(alexLink.textContent).not.toMatch(/00000/)
  })

  it("renders cards when patients are returned", async () => {
    render(await PatientsPage())
    expect(screen.getAllByRole("link")).toHaveLength(3)
  })

  it("calls getGraphQLClient().request once per render", async () => {
    await PatientsPage()
    expect(mockRequest).toHaveBeenCalledTimes(1)
  })

  it("falls back to raw gender string for unknown gender values", async () => {
    mockRequest.mockResolvedValue({
      patients: [{ id: "9", fullName: "Sam Rho", dateOfBirth: null, age: null, gender: "nonbinary", mrn: null }],
    })
    render(await PatientsPage())
    expect(screen.getByText(/nonbinary/)).toBeInTheDocument()
  })

  it("omits gender when null", async () => {
    mockRequest.mockResolvedValue({
      patients: [{ id: "9", fullName: "Sam Rho", dateOfBirth: null, age: null, gender: null, mrn: null }],
    })
    render(await PatientsPage())
    const link = screen.getByRole("link")
    expect(link.textContent).not.toMatch(/·/)
  })
})
