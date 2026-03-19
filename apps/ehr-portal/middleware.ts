// src/middleware.ts
// Server-side route protection via the auth_token cookie set by lib/auth.ts

import { NextRequest, NextResponse } from "next/server"

const PROTECTED_ROUTES = ["/dashboard", "/profile"]
const PUBLIC_ONLY_ROUTES = ["/login"]

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const token = request.cookies.get("auth_token")?.value

  // Redirect unauthenticated users away from protected routes
  if (PROTECTED_ROUTES.some(route => pathname.startsWith(route)) && !token) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  // Redirect authenticated users away from login
  if (PUBLIC_ONLY_ROUTES.includes(pathname) && token) {
    return NextResponse.redirect(new URL("/dashboard", request.url))
  }

  return NextResponse.next()
}

export const config = {
  // Run on all routes except Next.js internals and static assets
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
}
