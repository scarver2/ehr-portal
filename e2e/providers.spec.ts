// apps/ehr-portal/e2e/providers.spec.ts

import { test, expect } from '@playwright/test'

async function login(page) {
  await page.goto('/')

  // Wait for form to be ready
  await page.waitForSelector('input[type="email"]')

  // Fill credentials
  await page.fill('input[type="email"]', 'provider@example.com')
  await page.fill('input[type="password"]', 'password')

  // Submit and wait for either success or error
  void page.click('button[type="submit"]')

  // Wait for either token to appear or error message
  await Promise.race([
    page.waitForFunction(() => localStorage.getItem('auth_token') !== null, { timeout: 10000 }),
    page.waitForFunction(() => {
      const error = document.querySelector('p[style*="color: red"]')
      return error && error.textContent?.includes('Invalid')
    }, { timeout: 10000 })
  ]).catch(async () => {
    // If neither condition met, check what's in localStorage
    const token = await page.evaluate(() => localStorage.getItem('auth_token'))
    const user = await page.evaluate(() => localStorage.getItem('auth_user'))
    throw new Error(`Login failed. Token: ${token}, User: ${user}`)
  })
}

test.describe('Providers list page (/providers)', () => {
  test.beforeEach(async ({ page }) => {
    await login(page)
    await page.goto('/providers')
  })

  test('renders the page heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Providers' })).toBeVisible()
  })

  test('lists all providers from the mock API', async ({ page }) => {
    await expect(page.getByText('Alice Adams')).toBeVisible()
    await expect(page.getByText('Bob Brown')).toBeVisible()
    // Specialties are shown as badge pills next to provider names
    await expect(page.getByText('Cardiology')).toBeVisible()
    await expect(page.getByText('Neurology')).toBeVisible()
  })

  test('each provider is a link to their detail page', async ({ page }) => {
    // Provider names are rendered inside <Link> elements
    const link = page.getByRole('link').filter({ hasText: 'Alice Adams' }).first()
    await expect(link).toHaveAttribute('href', '/providers/1')
  })

  test('renders the correct number of providers', async ({ page }) => {
    // Each provider is a <Link> card; filter to provider links (href matches /providers/:id)
    const providerLinks = page.getByRole('link').filter({ hasText: /Adams|Brown/ })
    await expect(providerLinks).toHaveCount(2)
  })
})

test.describe('Provider detail page (/providers/:id)', () => {
  test.beforeEach(async ({ page }) => {
    await login(page)
    await page.goto('/providers/1')
  })

  test('renders the provider name as a heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Alice Adams' })).toBeVisible()
  })

  test('displays the NPI', async ({ page }) => {
    // NPI label and value are in separate <dt>/<dd> elements
    await expect(page.getByText('1111111111')).toBeVisible()
  })

  test('displays the specialty', async ({ page }) => {
    // Specialty is shown as a badge pill
    await expect(page.getByText('Cardiology')).toBeVisible()
  })

  test('displays the clinic name', async ({ page }) => {
    // Clinic name appears in multiple places on the detail page; match first occurrence
    await expect(page.getByText('Heart Clinic').first()).toBeVisible()
  })
})

test.describe('Navigation', () => {
  test('clicking a provider link navigates to their detail page', async ({ page }) => {
    await login(page)
    await page.goto('/providers')
    await page.getByRole('link').filter({ hasText: 'Alice Adams' }).first().click()
    await expect(page).toHaveURL(/\/providers\/1$/)
    await expect(page.getByRole('heading', { name: 'Alice Adams' })).toBeVisible()
  })

  test('the second provider also navigates correctly', async ({ page }) => {
    await login(page)
    await page.goto('/providers')
    await page.getByRole('link').filter({ hasText: 'Bob Brown' }).first().click()
    await expect(page).toHaveURL(/\/providers\/2$/)
    await expect(page.getByRole('heading', { name: 'Bob Brown' })).toBeVisible()
  })
})
