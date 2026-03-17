// apps/ehr-portal/e2e/providers.spec.ts

import { test, expect } from '@playwright/test'

test.describe('Providers list page (/providers)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/providers')
  })

  test('renders the page heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Providers' })).toBeVisible()
  })

  test('lists all providers from the mock API', async ({ page }) => {
    await expect(page.getByText('Alice Adams — Cardiology')).toBeVisible()
    await expect(page.getByText('Bob Brown — Neurology')).toBeVisible()
  })

  test('each provider is a link to their detail page', async ({ page }) => {
    const link = page.getByRole('link', { name: 'Alice Adams — Cardiology' })
    await expect(link).toHaveAttribute('href', '/providers/1')
  })

  test('renders the correct number of providers', async ({ page }) => {
    const items = page.getByRole('listitem')
    await expect(items).toHaveCount(2)
  })
})

test.describe('Provider detail page (/providers/:id)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/providers/1')
  })

  test('renders the provider name as a heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Alice Adams' })).toBeVisible()
  })

  test('displays the NPI', async ({ page }) => {
    await expect(page.getByText('NPI: 1111111111')).toBeVisible()
  })

  test('displays the specialty', async ({ page }) => {
    await expect(page.getByText('Specialty: Cardiology')).toBeVisible()
  })

  test('displays the clinic name', async ({ page }) => {
    await expect(page.getByText('Clinic: Heart Clinic')).toBeVisible()
  })
})

test.describe('Navigation', () => {
  test('clicking a provider link navigates to their detail page', async ({ page }) => {
    await page.goto('/providers')
    await page.getByRole('link', { name: 'Alice Adams — Cardiology' }).click()
    await expect(page).toHaveURL(/\/providers\/1$/)
    await expect(page.getByRole('heading', { name: 'Alice Adams' })).toBeVisible()
  })

  test('the second provider also navigates correctly', async ({ page }) => {
    await page.goto('/providers')
    await page.getByRole('link', { name: 'Bob Brown — Neurology' }).click()
    await expect(page).toHaveURL(/\/providers\/2$/)
    await expect(page.getByRole('heading', { name: 'Bob Brown' })).toBeVisible()
  })
})
