// apps/ehr-portal/playwright.config.ts

import { defineConfig, devices } from '@playwright/test'
import { MOCK_API_PORT } from './e2e/global-setup'

// Next.js dev server port used exclusively for E2E tests (avoids clashing with
// the normal dev port of 3001).
const APP_PORT = 4001

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? 'github' : 'html',

  use: {
    baseURL: `http://localhost:${APP_PORT}`,
    trace: 'on-first-retry',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  // Start the mock GraphQL server before any tests run
  globalSetup: './e2e/global-setup.ts',

  // Start the Next.js dev server pointing at the mock API
  webServer: {
    command: `cd apps/ehr-portal && NEXT_PUBLIC_API_URL=http://localhost:${MOCK_API_PORT} PORT=${APP_PORT} bun dev`,
    url: `http://localhost:${APP_PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    env: {
      NEXT_PUBLIC_API_URL: `http://localhost:${MOCK_API_PORT}`,
    },
  },
})
