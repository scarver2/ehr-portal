// apps/ehr-portal/src/app/providers/page.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import React from 'react'

// Mock the GraphQL client before importing the page
vi.mock('@/lib/graphql', () => ({
  graphql: {
    request: vi.fn(),
  },
}))

// Mock next/link to avoid Next.js router dependency in tests
vi.mock('next/link', () => ({
  default: ({ href, children }: { href: string; children: React.ReactNode }) => (
    <a href={href}>{children}</a>
  ),
}))

import ProvidersPage from './page'
import { graphql } from '@/lib/graphql'

const mockProviders = [
  { id: '1', fullName: 'Alice Adams', specialty: 'Cardiology' },
  { id: '2', fullName: 'Bob Brown', specialty: 'Neurology' },
  { id: '3', fullName: 'Carol Chen', specialty: 'Dermatology' },
]

describe('ProvidersPage', () => {
  beforeEach(() => {
    vi.mocked(graphql.request).mockResolvedValue({ providers: mockProviders })
  })

  it('renders the page heading', async () => {
    render(await ProvidersPage())
    expect(screen.getByRole('heading', { name: 'Providers' })).toBeInTheDocument()
  })

  it('renders a list item for each provider', async () => {
    render(await ProvidersPage())
    const items = screen.getAllByRole('listitem')
    expect(items).toHaveLength(3)
  })

  it('displays each provider with their specialty', async () => {
    render(await ProvidersPage())
    expect(screen.getByText('Alice Adams — Cardiology')).toBeInTheDocument()
    expect(screen.getByText('Bob Brown — Neurology')).toBeInTheDocument()
    expect(screen.getByText('Carol Chen — Dermatology')).toBeInTheDocument()
  })

  it('links each provider to their detail page', async () => {
    render(await ProvidersPage())
    const link = screen.getByRole('link', { name: 'Alice Adams — Cardiology' })
    expect(link).toHaveAttribute('href', '/providers/1')
  })

  it('renders an empty list when no providers are returned', async () => {
    vi.mocked(graphql.request).mockResolvedValue({ providers: [] })
    render(await ProvidersPage())
    expect(screen.queryByRole('listitem')).toBeNull()
  })

  it('calls graphql.request once per render', async () => {
    await ProvidersPage()
    expect(graphql.request).toHaveBeenCalledTimes(1)
  })
})
