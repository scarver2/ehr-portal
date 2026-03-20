"use client"

import { useState } from "react"
import { useInsuranceVerificationStream, startVerification } from "@/hooks/useInsuranceVerificationStream"
import { Shield, ShieldCheck, ShieldAlert, Loader2, AlertCircle } from "lucide-react"

function formatCents(cents: number | null): string {
  if (cents == null) return "—"
  return `$${(cents / 100).toFixed(2)}`
}

const statusConfig: Record<string, { label: string; className: string; Icon: typeof Shield }> = {
  verified:   { label: "Verified",   className: "bg-green-50 text-green-700 border-green-200",  Icon: ShieldCheck  },
  failed:     { label: "Failed",     className: "bg-red-50 text-red-700 border-red-200",        Icon: ShieldAlert  },
  pending:    { label: "Pending",    className: "bg-yellow-50 text-yellow-700 border-yellow-200", Icon: Shield      },
  processing: { label: "Processing", className: "bg-blue-50 text-blue-700 border-blue-200",     Icon: Loader2      },
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

  const status = liveVerification?.status
  const cfg = status ? (statusConfig[status] ?? statusConfig.pending) : null

  return (
    <div className="space-y-4">

      {/* Status + trigger row */}
      <div className="flex items-center justify-between gap-4">
        {cfg ? (
          <span className={[
            "inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-medium",
            cfg.className,
          ].join(" ")}>
            <cfg.Icon className={["w-3.5 h-3.5", status === "processing" ? "animate-spin" : ""].join(" ")} />
            {cfg.label}
          </span>
        ) : (
          <span className="text-xs text-slate-400">No verification on record</span>
        )}

        <button
          onClick={handleStart}
          disabled={starting || status === "processing"}
          className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-medium text-white shadow-sm hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {starting ? (
            <Loader2 className="w-3.5 h-3.5 animate-spin" />
          ) : (
            <Shield className="w-3.5 h-3.5" />
          )}
          {starting ? "Starting…" : "Verify Insurance"}
        </button>
      </div>

      {/* API error */}
      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-xs text-red-700">
          <AlertCircle className="w-3.5 h-3.5 shrink-0" />
          {error}
        </div>
      )}

      {/* Verification details */}
      {liveVerification && (
        <>
          {liveVerification.error_message && (
            <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-xs text-red-700">
              <AlertCircle className="w-3.5 h-3.5 shrink-0" />
              {liveVerification.error_message}
            </div>
          )}

          <dl className="grid grid-cols-2 gap-x-6 gap-y-3">
            <div>
              <dt className="text-xs text-slate-400 uppercase tracking-wide">Payer</dt>
              <dd className="mt-0.5 text-sm text-slate-700">{liveVerification.payer_name ?? "—"}</dd>
            </div>
            <div>
              <dt className="text-xs text-slate-400 uppercase tracking-wide">Plan</dt>
              <dd className="mt-0.5 text-sm text-slate-700">{liveVerification.plan_name ?? "—"}</dd>
            </div>
            <div>
              <dt className="text-xs text-slate-400 uppercase tracking-wide">Copay</dt>
              <dd className="mt-0.5 text-sm font-mono text-slate-700">{formatCents(liveVerification.copay_cents)}</dd>
            </div>
            <div>
              <dt className="text-xs text-slate-400 uppercase tracking-wide">Deductible</dt>
              <dd className="mt-0.5 text-sm font-mono text-slate-700">{formatCents(liveVerification.deductible_cents)}</dd>
            </div>
            <div>
              <dt className="text-xs text-slate-400 uppercase tracking-wide">Out-of-Pocket Max</dt>
              <dd className="mt-0.5 text-sm font-mono text-slate-700">{formatCents(liveVerification.oop_max_cents)}</dd>
            </div>
          </dl>
        </>
      )}
    </div>
  )
}
