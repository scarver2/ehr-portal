// apps/ehr-portal/vitest.setup.ts

import { afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
import '@testing-library/jest-dom/vitest'

// Mock localStorage for all tests
const localStorageMock = (() => {
  let store: Record<string, string> = {}

  return {
    getItem: (key: string) => store[key] || null,
    setItem: (key: string, value: string) => {
      store[key] = value.toString()
    },
    removeItem: (key: string) => {
      delete store[key]
    },
    clear: () => {
      store = {}
    },
  }
})()

Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
})

// Unmount components after every test so DOM is clean for the next one.
// @testing-library/react auto-cleanup only runs when `afterEach` is a global,
// which requires `globals: true` in vitest.config. We wire it up explicitly here.
afterEach(() => {
  cleanup()
  localStorage.clear()
})
