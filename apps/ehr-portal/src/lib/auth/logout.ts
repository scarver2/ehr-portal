// src/lib/auth/logout.ts

export async function logout(): Promise<void> {
  const token = localStorage.getItem("auth_token")
  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "https://api.ehr.stancarver.com"

  if (token) {
    // Best-effort server-side revocation — ignore errors (token expires anyway)
    await fetch(`${apiUrl}/api/v1/auth/logout`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${token}` },
    }).catch(() => {})
  }

  localStorage.removeItem("auth_token")
  localStorage.removeItem("auth_user")

  // Expire the cookie so middleware stops protecting routes
  document.cookie = "auth_token=; path=/; max-age=0; SameSite=Lax"
}
