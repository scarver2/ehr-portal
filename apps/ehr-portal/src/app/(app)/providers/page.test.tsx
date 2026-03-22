// apps/ehr-portal/src/app/providers/page.test.tsx

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

import ProvidersPage from "./page"

const mockProviders = [
  { id: "1", fullName: "Alice Adams", npi: "1111111111", clinicName: "Heart Clinic", specialty: { id: "1", name: "Cardiology" } },
  { id: "2", fullName: "Bob Brown",   npi: "2222222222", clinicName: "Brain Clinic", specialty: { id: "2", name: "Neurology" } },
  { id: "3", fullName: "Carol Chen",  npi: "3333333333", clinicName: null, specialty: null },
]

describe("ProvidersPage", () => {
  beforeEach(() => {
    mockRequest.mockResolvedValue({ providers: mockProviders })
  })

  it("renders the page heading", async () => {
    render(await ProvidersPage())
    expect(screen.getByRole("heading", { name: "Providers" })).toBeInTheDocument()
  })

  it("renders a link for each provider", async () => {
    render(await ProvidersPage())
    expect(screen.getAllByRole("link")).toHaveLength(3)
  })

  it("displays each provider with their full name", async () => {
    render(await ProvidersPage())
    expect(screen.getByText("Alice Adams")).toBeInTheDocument()
    expect(screen.getByText("Bob Brown")).toBeInTheDocument()
    expect(screen.getByText("Carol Chen")).toBeInTheDocument()
  })

  it("displays provider specialty when present", async () => {
    render(await ProvidersPage())
    expect(screen.getByText("Cardiology")).toBeInTheDocument()
    expect(screen.getByText("Neurology")).toBeInTheDocument()
  })

  it("links each provider to their detail page", async () => {
    render(await ProvidersPage())
    const links = screen.getAllByRole("link")
    const aliceLink = links[0]
    expect(aliceLink).toHaveAttribute("href", "/providers/1")
  })

  it("renders an empty list when no providers are returned", async () => {
    mockRequest.mockResolvedValue({ providers: [] })
    render(await ProvidersPage())
    expect(screen.queryByRole("link")).toBeNull()
  })

  it("calls getGraphQLClient().request once per render", async () => {
    await ProvidersPage()
    expect(mockRequest).toHaveBeenCalledTimes(1)
  })
})
