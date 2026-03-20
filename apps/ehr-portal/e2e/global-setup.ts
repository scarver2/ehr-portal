// apps/ehr-portal/e2e/global-setup.ts
//
// Starts a lightweight mock GraphQL server before Playwright launches the Next.js
// app. The Next.js webServer is configured (see playwright.config.ts) to point
// NEXT_PUBLIC_API_URL at this mock so all server-component GraphQL calls are
// intercepted without needing the real Rails API to be running.

import { createServer, IncomingMessage, ServerResponse } from 'http'

export const MOCK_API_PORT = 4099

export const mockProviders = [
  {
    id: '1',
    fullName: 'Alice Adams',
    specialty: { id: '1', name: 'Cardiology' },
    npi: '1111111111',
    clinicName: 'Heart Clinic',
  },
  {
    id: '2',
    fullName: 'Bob Brown',
    specialty: { id: '2', name: 'Neurology' },
    npi: '2222222222',
    clinicName: 'Brain Center',
  },
]

function handleRequest(req: IncomingMessage, res: ServerResponse) {
  // Handle login requests
  if (req.method === 'POST' && req.url === '/api/v1/auth/login') {
    let body = ''
    req.on('data', (chunk: Buffer) => (body += chunk.toString()))
    req.on('end', () => {
      const { user } = JSON.parse(body) as { user: { email: string; password: string } }

      // Mock successful login for test credentials
      if (user.email === 'provider@example.com' && user.password === 'password') {
        const mockJWT = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxMDAwMDAwMDAwMH0.test'
        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${mockJWT}`
        })
        res.end(JSON.stringify({
          user: {
            id: '1',
            email: 'provider@example.com',
            role: 'provider',
            provider_id: '1'
          }
        }))
      } else {
        res.writeHead(401, { 'Content-Type': 'application/json' })
        res.end(JSON.stringify({ errors: { base: ['Invalid email or password'] } }))
      }
    })
    return
  }

  if (req.method !== 'POST' || req.url !== '/graphql') {
    res.writeHead(404)
    res.end('Not found')
    return
  }

  let body = ''
  req.on('data', (chunk: Buffer) => (body += chunk.toString()))
  req.on('end', () => {
    const { query, variables } = JSON.parse(body) as {
      query: string
      variables?: Record<string, string>
    }

    let data: Record<string, unknown> = {}

    // `\bproviders\b` matches "providers" but NOT "provider" (no trailing s)
    if (/\bproviders\b/.test(query)) {
      data = { providers: mockProviders }
    } else if (/\bprovider\b/.test(query)) {
      const provider = mockProviders.find((p) => p.id === variables?.id) ?? null
      data = { provider }
    }

    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ data }))
  })
}

export default async function globalSetup() {
  const server = createServer(handleRequest)

  await new Promise<void>((resolve, reject) => {
    server.on('error', reject)
    server.listen(MOCK_API_PORT, resolve)
  })

  console.log(`[e2e] Mock GraphQL API listening on http://localhost:${MOCK_API_PORT}`)

  // Return a teardown function; Playwright calls it automatically after the run
  return async () => {
    await new Promise<void>((resolve) => server.close(() => resolve()))
    console.log('[e2e] Mock GraphQL API stopped')
  }
}
