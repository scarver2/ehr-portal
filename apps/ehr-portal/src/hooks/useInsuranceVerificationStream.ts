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
    // Get JWT token from localStorage (set by auth context)
    const token = typeof window !== "undefined" ? localStorage.getItem("auth_token") : null

    const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"
    const wsUrl = apiUrl.replace(/^http/, "ws") + "/cable"

    // Pass token as query parameter for WebSocket authentication
    const wsUrlWithAuth = token ? `${wsUrl}?token=${encodeURIComponent(token)}` : wsUrl

    const consumer = createConsumer(wsUrlWithAuth)

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
  // Get JWT token from localStorage (set by auth context)
  const token = typeof window !== "undefined" ? localStorage.getItem("auth_token") : null

  if (!token) {
    throw new Error("Not authenticated. Please login first.")
  }

  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"
  const url = `${apiUrl}/api/insurance_verifications`

  try {
    const res = await fetch(url, {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,
      },
      body: JSON.stringify({ patient_id: patientId }),
    })

    if (!res.ok) {
      const error = await res.text()
      throw new Error(`Insurance verification failed: ${res.status} ${res.statusText}. ${error}`)
    }

    return res.json()
  } catch (error) {
    if (error instanceof TypeError && error.message.includes("Failed to fetch")) {
      console.error("Network error when connecting to:", url)
      console.error("API URL configured as:", apiUrl)
      throw new Error(
        `Failed to reach API at ${apiUrl}. Is the API server running? Check that NEXT_PUBLIC_API_URL is set correctly.`
      )
    }
    throw error
  }
}
