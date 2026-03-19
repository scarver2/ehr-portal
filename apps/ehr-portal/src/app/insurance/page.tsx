"use client"

import { useState } from "react"
import { useInsuranceVerificationStream, startVerification } from "@/hooks/useInsuranceVerificationStream"

export default function InsurancePage() {
  const liveVerification = useInsuranceVerificationStream()
  const [starting, setStarting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleStart() {
    try {
      setStarting(true)
      setError(null)
      await startVerification()
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error")
    } finally {
      setStarting(false)
    }
  }

  return (
    <main style={{ padding: "2rem", maxWidth: 600, margin: "0 auto" }}>
      <h1>Insurance Verification</h1>

      <button onClick={handleStart} disabled={starting}>
        {starting ? "Starting…" : "Verify Insurance"}
      </button>

      {error && <p style={{ color: "red" }}>Error: {error}</p>}

      {liveVerification && (
        <section style={{ marginTop: "1.5rem", borderTop: "1px solid #ccc", paddingTop: "1rem" }}>
          <p><strong>Status:</strong> {liveVerification.status}</p>
          <p><strong>Payer:</strong> {liveVerification.payer_name ?? "—"}</p>
          <p><strong>Plan:</strong> {liveVerification.plan_name ?? "—"}</p>
          <p>
            <strong>Copay:</strong>{" "}
            {liveVerification.copay_cents != null
              ? `$${(liveVerification.copay_cents / 100).toFixed(2)}`
              : "—"}
          </p>
          <p>
            <strong>Deductible:</strong>{" "}
            {liveVerification.deductible_cents != null
              ? `$${(liveVerification.deductible_cents / 100).toFixed(2)}`
              : "—"}
          </p>
          <p>
            <strong>Out-of-Pocket Max:</strong>{" "}
            {liveVerification.oop_max_cents != null
              ? `$${(liveVerification.oop_max_cents / 100).toFixed(2)}`
              : "—"}
          </p>
          {liveVerification.error_message && (
            <p style={{ color: "red" }}>
              <strong>Error:</strong> {liveVerification.error_message}
            </p>
          )}
        </section>
      )}
    </main>
  )
}
