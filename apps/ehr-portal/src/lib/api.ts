// apps/ehr-portal/src/lib/api.ts

export async function apiFetch(url: string, options: RequestInit = {}) {
  const token = localStorage.getItem("auth_token")

  const headers: HeadersInit = {
    "Content-Type": "application/json",
    ...(token && { Authorization: `Bearer ${token}` }),
    ...((options.headers || {}) as Record<string, string>)
  }

  return fetch(`${process.env.NEXT_PUBLIC_API_URL}${url}`, {
    ...options,
    headers
  })
}

