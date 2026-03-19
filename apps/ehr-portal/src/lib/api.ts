// apps/ehr-portal/src/lib/api.ts

export async function apiFetch(url: string, options: any = {}) {
  const token = localStorage.getItem("auth_token")

  const headers = {
    "Content-Type": "application/json",
    ...(token && { Authorization: `Bearer ${token}` }),
    ...options.headers
  }

  return fetch(`${process.env.NEXT_PUBLIC_API_URL}${url}`, {
    ...options,
    headers
  })
}

