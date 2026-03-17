// apps/ehr-portal/vitest.setup.ts

import { afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
import '@testing-library/jest-dom/vitest'

// Unmount components after every test so DOM is clean for the next one.
// @testing-library/react auto-cleanup only runs when `afterEach` is a global,
// which requires `globals: true` in vitest.config. We wire it up explicitly here.
afterEach(() => {
  cleanup()
})
