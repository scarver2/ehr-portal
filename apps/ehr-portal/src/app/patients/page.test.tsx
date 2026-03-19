// apps/ehr-portal/src/app/patients/page.test.tsx

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

import PatientsPage from "./page"
import { graphql } from "@/lib/graphql"

const mockPatients = [
  { id: "1", fullName: "Jane Doe",   dateOfBirth: "1990-03-15", age: 35, gender: "female",          mrn: "00000001" },
  { id: "2", fullName: "John Smith", dateOfBirth: "1985-07-22", age: 40, gender: "male",            mrn: "00000002" },
  { id: "3", fullName: "Alex Jones", dateOfBirth: null,         age: null, gender: "prefer_not_to_say", mrn: null },
]

describe("PatientsPage", () => {
  beforeEach(() => {
    vi.mocked(graphql.request).mockResolvedValue({ patients: mockPatients })
  })

  it("renders the page heading", async () => {
    render(await PatientsPage())
    expect(screen.getByRole("heading", { name: "Patients" })).toBeInTheDocument()
  })

  it("renders a list item for each patient", async () => {
    render(await PatientsPage())
    expect(screen.getAllByRole("listitem")).toHaveLength(3)
  })

  it("links each patient to their detail page", async () => {
    render(await PatientsPage())
    const link = screen.getByRole("link", { name: "Jane Doe" })
    expect(link).toHaveAttribute("href", "/patients/1")
  })

  it("displays age for patients with a date of birth", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/Age 35/)).toBeInTheDocument()
    expect(screen.getByText(/Age 40/)).toBeInTheDocument()
  })

  it("omits age when date of birth is absent", async () => {
    render(await PatientsPage())
    const items = screen.getAllByRole("listitem")
    expect(items[2].textContent).not.toMatch(/Age/)
  })

  it("displays a human-readable gender label", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/Female/)).toBeInTheDocument()
    expect(screen.getByText(/Male/)).toBeInTheDocument()
    expect(screen.getByText(/Prefer not to say/)).toBeInTheDocument()
  })

  it("displays the MRN when present", async () => {
    render(await PatientsPage())
    expect(screen.getByText(/MRN 00000001/)).toBeInTheDocument()
  })

  it("omits MRN when absent", async () => {
    render(await PatientsPage())
    const items = screen.getAllByRole("listitem")
    expect(items[2].textContent).not.toMatch(/MRN/)
  })

  it("renders an empty list when no patients are returned", async () => {
    vi.mocked(graphql.request).mockResolvedValue({ patients: [] })
    render(await PatientsPage())
    expect(screen.queryByRole("listitem")).toBeNull()
  })

  it("calls graphql.request once per render", async () => {
    await PatientsPage()
    expect(graphql.request).toHaveBeenCalledTimes(1)
  })
})
