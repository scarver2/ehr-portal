// src/app/insurance/page.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import React from "react"

// ── Mock the hook and startVerification ───────────────────────────────────────

vi.mock("@/hooks/useInsuranceVerificationStream", () => ({
  useInsuranceVerificationStream: vi.fn(() => null),
  startVerification: vi.fn(),
}))

import InsurancePage from "./page"
import {
  useInsuranceVerificationStream,
  startVerification,
} from "@/hooks/useInsuranceVerificationStream"

// ── Fixtures ──────────────────────────────────────────────────────────────────

const mockVerification = {
  id: 1,
  request_uuid: "abc-123",
  status: "verified",
  payer_name: "Aetna",
  plan_name: "Gold PPO",
  copay_cents: 2500,
  deductible_cents: 100_000,
  oop_max_cents: 500_000,
  verified_at: "2026-03-19T08:00:00Z",
  error_message: null,
  updated_at: "2026-03-19T08:00:00Z",
}

// ── Static rendering ──────────────────────────────────────────────────────────

describe("InsurancePage — static", () => {
  it("renders the page heading", () => {
    render(<InsurancePage />)
    expect(screen.getByRole("heading", { name: "Insurance Verification" })).toBeInTheDocument()
  })

  it("renders the verify button with initial label", () => {
    render(<InsurancePage />)
    expect(screen.getByRole("button", { name: "Verify Insurance" })).toBeInTheDocument()
  })

  it("does not render the verification section when no data", () => {
    render(<InsurancePage />)
    expect(screen.queryByText(/Status:/)).toBeNull()
  })
})

// ── With live verification data ───────────────────────────────────────────────

describe("InsurancePage — with verification data", () => {
  beforeEach(() => {
    vi.mocked(useInsuranceVerificationStream).mockReturnValue(mockVerification)
  })

  it("renders the status", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/verified/)).toBeInTheDocument()
  })

  it("renders the payer name", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/Aetna/)).toBeInTheDocument()
  })

  it("renders the plan name", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/Gold PPO/)).toBeInTheDocument()
  })

  it("formats copay_cents as a dollar amount", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/\$25\.00/)).toBeInTheDocument()
  })

  it("formats deductible_cents as a dollar amount", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/\$1000\.00/)).toBeInTheDocument()
  })

  it("formats oop_max_cents as a dollar amount", () => {
    render(<InsurancePage />)
    expect(screen.getByText(/\$5000\.00/)).toBeInTheDocument()
  })

  it("shows dashes when financial fields are null", () => {
    vi.mocked(useInsuranceVerificationStream).mockReturnValue({
      ...mockVerification,
      copay_cents: null,
      deductible_cents: null,
      oop_max_cents: null,
      payer_name: null,
      plan_name: null,
    })
    render(<InsurancePage />)
    // Three dashes for the null financial fields + payer + plan
    expect(screen.getAllByText("—")).toHaveLength(5)
  })

  it("shows error_message when present", () => {
    vi.mocked(useInsuranceVerificationStream).mockReturnValue({
      ...mockVerification,
      error_message: "gateway timeout",
    })
    render(<InsurancePage />)
    expect(screen.getByText(/gateway timeout/)).toBeInTheDocument()
  })

  it("does not render an error_message element when absent", () => {
    render(<InsurancePage />)
    expect(screen.queryByText(/Error:/)).toBeNull()
  })
})

// ── Button interactions ───────────────────────────────────────────────────────

describe("InsurancePage — button", () => {
  it("calls startVerification when the button is clicked", async () => {
    vi.mocked(startVerification).mockResolvedValue(mockVerification)
    render(<InsurancePage />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(startVerification).toHaveBeenCalledTimes(1)
  })

  it("shows loading state while the request is in flight", async () => {
    let settle!: () => void
    vi.mocked(startVerification).mockReturnValue(
      new Promise(resolve => { settle = () => resolve(mockVerification) })
    )
    render(<InsurancePage />)
    const user = userEvent.setup()
    // Start click but don't await — button is in loading state during the pending promise
    const click = user.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(await screen.findByRole("button", { name: "Starting…" })).toBeDisabled()
    settle()
    await click
  })

  it("shows an error message when startVerification throws", async () => {
    vi.mocked(startVerification).mockRejectedValue(new Error("Unable to start verification"))
    render(<InsurancePage />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(screen.getByText(/Unable to start verification/)).toBeInTheDocument()
  })

  it("re-enables the button after an error", async () => {
    vi.mocked(startVerification).mockRejectedValue(new Error("oops"))
    render(<InsurancePage />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(screen.getByRole("button", { name: "Verify Insurance" })).not.toBeDisabled()
  })
})
