"use client"

import { useState } from "react"
import { useInsuranceVerificationStream, startVerification } from "@/hooks/useInsuranceVerificationStream"

function formatCents(cents: number | null): string {
  if (cents == null) return "—"
  return `$${(cents / 100).toFixed(2)}`
}

export function InsuranceVerificationPanel({ patientId }: { patientId: number }) {
  const liveVerification = useInsuranceVerificationStream()
  const [starting, setStarting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleStart() {
    try {
      setStarting(true)
      setError(null)
      await startVerification(patientId)
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error")
    } finally {
      setStarting(false)
    }
  }

  return (
    <section>
      <h2>Insurance Verification</h2>

      <button onClick={handleStart} disabled={starting}>
        {starting ? "Starting…" : "Verify Insurance"}
      </button>

      {error && <p style={{ color: "red" }}>Error: {error}</p>}

      {liveVerification && (
        <dl style={{ marginTop: "1rem" }}>
          <dt>Status</dt>
          <dd>{liveVerification.status}</dd>
          <dt>Payer</dt>
          <dd>{liveVerification.payer_name ?? "—"}</dd>
          <dt>Plan</dt>
          <dd>{liveVerification.plan_name ?? "—"}</dd>
          <dt>Copay</dt>
          <dd>{formatCents(liveVerification.copay_cents)}</dd>
          <dt>Deductible</dt>
          <dd>{formatCents(liveVerification.deductible_cents)}</dd>
          <dt>Out-of-Pocket Max</dt>
          <dd>{formatCents(liveVerification.oop_max_cents)}</dd>
          {liveVerification.error_message && (
            <dd style={{ color: "red" }}>{liveVerification.error_message}</dd>
          )}
        </dl>
      )}
    </section>
  )
}
