// src/app/patients/[id]/InsuranceVerificationPanel.test.tsx

import { describe, it, expect, vi, beforeEach } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import React from "react"

// ── Mock the hook and startVerification ───────────────────────────────────────

vi.mock("@/hooks/useInsuranceVerificationStream", () => ({
  useInsuranceVerificationStream: vi.fn(() => null),
  startVerification: vi.fn(),
}))

import { InsuranceVerificationPanel } from "./InsuranceVerificationPanel"
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

describe("InsuranceVerificationPanel — static", () => {
  it("renders the verify button with initial label", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByRole("button", { name: "Verify Insurance" })).toBeInTheDocument()
  })

  it("displays no verification message when none has arrived", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("No verification on record")).toBeInTheDocument()
  })

  it("does not render verification details when none has arrived", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.queryByText("Payer")).toBeNull()
  })
})

// ── With live verification data ───────────────────────────────────────────────

describe("InsuranceVerificationPanel — with verification data", () => {
  beforeEach(() => {
    vi.mocked(useInsuranceVerificationStream).mockReturnValue(mockVerification)
  })

  it("renders the status", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("Verified")).toBeInTheDocument()
  })

  it("renders the payer name", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("Aetna")).toBeInTheDocument()
  })

  it("renders the plan name", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("Gold PPO")).toBeInTheDocument()
  })

  it("formats copay_cents as a dollar amount", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("$25.00")).toBeInTheDocument()
  })

  it("formats deductible_cents as a dollar amount", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("$1000.00")).toBeInTheDocument()
  })

  it("formats oop_max_cents as a dollar amount", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("$5000.00")).toBeInTheDocument()
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
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getAllByText("—")).toHaveLength(5)
  })

  it("shows error_message when present", () => {
    vi.mocked(useInsuranceVerificationStream).mockReturnValue({
      ...mockVerification,
      error_message: "gateway timeout",
    })
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.getByText("gateway timeout")).toBeInTheDocument()
  })

  it("does not render error_message element when absent", () => {
    render(<InsuranceVerificationPanel patientId={1} />)
    expect(screen.queryByText(/Error:/)).toBeNull()
  })
})

// ── Button interactions ───────────────────────────────────────────────────────

describe("InsuranceVerificationPanel — button", () => {
  it("calls startVerification with the patientId when clicked", async () => {
    vi.mocked(startVerification).mockResolvedValue(mockVerification)
    render(<InsuranceVerificationPanel patientId={7} />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(startVerification).toHaveBeenCalledWith(7)
  })

  it("shows loading state while the request is in flight", async () => {
    let settle!: () => void
    vi.mocked(startVerification).mockReturnValue(
      new Promise(resolve => { settle = () => resolve(mockVerification) })
    )
    render(<InsuranceVerificationPanel patientId={1} />)
    const user = userEvent.setup()
    const click = user.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(await screen.findByRole("button", { name: "Starting…" })).toBeDisabled()
    settle()
    await click
  })

  it("shows an error message when startVerification throws", async () => {
    vi.mocked(startVerification).mockRejectedValue(new Error("Unable to start verification"))
    render(<InsuranceVerificationPanel patientId={1} />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(screen.getByText(/Unable to start verification/)).toBeInTheDocument()
  })

  it("re-enables the button after an error", async () => {
    vi.mocked(startVerification).mockRejectedValue(new Error("oops"))
    render(<InsuranceVerificationPanel patientId={1} />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(screen.getByRole("button", { name: "Verify Insurance" })).not.toBeDisabled()
  })

  it("shows 'Unknown error' when startVerification rejects with a non-Error value", async () => {
    vi.mocked(startVerification).mockRejectedValue("plain string rejection")
    render(<InsuranceVerificationPanel patientId={1} />)
    await userEvent.click(screen.getByRole("button", { name: "Verify Insurance" }))
    expect(screen.getByText(/Unknown error/)).toBeInTheDocument()
  })
})
