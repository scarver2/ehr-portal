"use client"

import { useEffect, useRef, useState } from "react"
import { createConsumer } from "@rails/actioncable"

interface InsuranceVerification {
  id: number
  request_uuid: string
  status: string
  payer_name: string | null
  plan_name: string | null
  copay_cents: number | null
  deductible_cents: number | null
  oop_max_cents: number | null
  verified_at: string | null
  error_message: string | null
  updated_at: string
}

export function useInsuranceVerificationStream() {
  const [verification, setVerification] = useState<InsuranceVerification | null>(null)
  const subscriptionRef = useRef<ReturnType<ReturnType<typeof createConsumer>["subscriptions"]["create"]> | null>(null)

  useEffect(() => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"
    const wsUrl = apiUrl.replace(/^http/, "ws") + "/cable"
    const consumer = createConsumer(wsUrl)

    subscriptionRef.current = consumer.subscriptions.create(
      { channel: "InsuranceVerificationChannel" },
      {
        connected() {
          console.log("Connected to insurance verification stream")
        },
        disconnected() {
          console.log("Disconnected from insurance verification stream")
        },
        received(data: InsuranceVerification) {
          setVerification(data)
        },
      }
    )

    return () => {
      subscriptionRef.current?.unsubscribe()
      consumer.disconnect()
    }
  }, [])

  return verification
}

export async function startVerification(patientId: number): Promise<InsuranceVerification> {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"
  const res = await fetch(`${apiUrl}/api/insurance_verifications`, {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ patient_id: patientId }),
  })
  if (!res.ok) throw new Error("Unable to start verification")
  return res.json()
}
