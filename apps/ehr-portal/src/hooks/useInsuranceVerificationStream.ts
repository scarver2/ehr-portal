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
    const consumer = createConsumer("wss://api.ehr.stancarver.com/cable")

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

export async function startVerification(): Promise<InsuranceVerification> {
  const res = await fetch("https://api.ehr.stancarver.com/api/insurance_verifications", {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
  })
  if (!res.ok) throw new Error("Unable to start verification")
  return res.json()
}
