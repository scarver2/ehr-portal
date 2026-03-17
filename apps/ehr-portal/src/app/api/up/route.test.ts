// apps/ehr-portal/src/app/api/up/route.test.ts

import { describe, it, expect } from 'vitest'
import { GET } from './route'

describe('GET /api/up', () => {
  it('returns HTTP 200', async () => {
    const response = await GET()
    expect(response.status).toBe(200)
  })

  it('returns "ok" in the response body', async () => {
    const response = await GET()
    const text = await response.text()
    expect(text).toBe('ok')
  })
})
