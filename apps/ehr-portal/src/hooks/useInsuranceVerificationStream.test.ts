// src/hooks/useInsuranceVerificationStream.test.ts

import { describe, it, expect, vi, beforeEach } from "vitest"
import { renderHook, act } from "@testing-library/react"

// ── ActionCable mock ──────────────────────────────────────────────────────────

const mockUnsubscribe = vi.fn()
const mockDisconnect  = vi.fn()
const mockCreate      = vi.fn()

vi.mock("@rails/actioncable", () => ({
  createConsumer: vi.fn(() => ({
    subscriptions: { create: mockCreate },
    disconnect: mockDisconnect,
  })),
}))

import { createConsumer } from "@rails/actioncable"
import { useInsuranceVerificationStream, startVerification } from "./useInsuranceVerificationStream"

// ── Helpers ───────────────────────────────────────────────────────────────────

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

// Captures the callbacks passed to subscriptions.create so tests can trigger them
function captureCallbacks() {
  let callbacks: Record<string, (...args: unknown[]) => void> = {}
  mockCreate.mockImplementation((_channel: unknown, cbs: typeof callbacks) => {
    callbacks = cbs
    return { unsubscribe: mockUnsubscribe }
  })
  return () => callbacks
}

// ── useInsuranceVerificationStream ────────────────────────────────────────────

describe("useInsuranceVerificationStream", () => {
  beforeEach(() => {
    mockUnsubscribe.mockClear()
    mockDisconnect.mockClear()
    mockCreate.mockClear()
  })

  it("returns null before any data arrives", () => {
    mockCreate.mockReturnValue({ unsubscribe: mockUnsubscribe })
    const { result } = renderHook(() => useInsuranceVerificationStream())
    expect(result.current).toBeNull()
  })

  it("connects to the correct ActionCable URL", () => {
    mockCreate.mockReturnValue({ unsubscribe: mockUnsubscribe })
    renderHook(() => useInsuranceVerificationStream())
    expect(createConsumer).toHaveBeenCalledWith(expect.stringContaining("/cable"))
  })

  it("subscribes to InsuranceVerificationChannel", () => {
    mockCreate.mockReturnValue({ unsubscribe: mockUnsubscribe })
    renderHook(() => useInsuranceVerificationStream())
    expect(mockCreate).toHaveBeenCalledWith(
      { channel: "InsuranceVerificationChannel" },
      expect.objectContaining({ received: expect.any(Function) })
    )
  })

  it("updates state when a message is received", async () => {
    const getCallbacks = captureCallbacks()
    const { result } = renderHook(() => useInsuranceVerificationStream())

    await act(async () => {
      getCallbacks().received(mockVerification)
    })

    expect(result.current).toEqual(mockVerification)
  })

  it("replaces state with the latest message", async () => {
    const getCallbacks = captureCallbacks()
    const { result } = renderHook(() => useInsuranceVerificationStream())

    await act(async () => { getCallbacks().received(mockVerification) })
    await act(async () => { getCallbacks().received({ ...mockVerification, status: "expired" }) })

    expect(result.current?.status).toBe("expired")
  })

  it("unsubscribes and disconnects on unmount", () => {
    mockCreate.mockReturnValue({ unsubscribe: mockUnsubscribe })
    const { unmount } = renderHook(() => useInsuranceVerificationStream())
    unmount()
    expect(mockUnsubscribe).toHaveBeenCalledTimes(1)
    expect(mockDisconnect).toHaveBeenCalledTimes(1)
  })

  it("connected callback does not throw", () => {
    const getCallbacks = captureCallbacks()
    renderHook(() => useInsuranceVerificationStream())
    expect(() => getCallbacks().connected()).not.toThrow()
  })

  it("disconnected callback does not throw", () => {
    const getCallbacks = captureCallbacks()
    renderHook(() => useInsuranceVerificationStream())
    expect(() => getCallbacks().disconnected()).not.toThrow()
  })
})

// ── startVerification ─────────────────────────────────────────────────────────

describe("startVerification", () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it("POSTs to the insurance verifications endpoint", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify(mockVerification), { status: 202 })
    )
    await startVerification(42)
    expect(fetchSpy).toHaveBeenCalledWith(
      expect.stringContaining("/api/insurance_verifications"),
      expect.objectContaining({ method: "POST", credentials: "include" })
    )
  })

  it("sends patient_id in the request body", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify(mockVerification), { status: 202 })
    )
    await startVerification(42)
    const body = JSON.parse((fetchSpy.mock.calls[0][1] as RequestInit).body as string)
    expect(body).toEqual({ patient_id: 42 })
  })

  it("returns the parsed verification on success", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify(mockVerification), { status: 202 })
    )
    const result = await startVerification(42)
    expect(result).toEqual(mockVerification)
  })

  it("throws when the response is not ok", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response("Unauthorized", { status: 401 })
    )
    await expect(startVerification(42)).rejects.toThrow("Unable to start verification")
  })
})
