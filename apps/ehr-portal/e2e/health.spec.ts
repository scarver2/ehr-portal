// apps/ehr-portal/e2e/health.spec.ts

import { test, expect } from '@playwright/test'

test.describe('Health check endpoint', () => {
  test('GET /api/up returns 200', async ({ request }) => {
    const response = await request.get('/api/up')
    expect(response.status()).toBe(200)
  })

  test('GET /api/up returns "ok"', async ({ request }) => {
    const response = await request.get('/api/up')
    expect(await response.text()).toBe('ok')
  })
})
