// apps/ehr-portal/src/app/page.test.tsx

import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import Home from './page'

describe('Home', () => {
  it('renders the EHR heading', () => {
    render(<Home />)
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('EHR')
  })

  it('renders the copyright footer', () => {
    render(<Home />)
    expect(screen.getByText(/2026/)).toBeInTheDocument()
  })

  it('links copyright to stancarver.com', () => {
    render(<Home />)
    const link = screen.getByRole('link', { name: 'Stan Carver II' })
    expect(link).toHaveAttribute('href', 'https://stancarver.com')
  })

  it('opens the copyright link in a new tab', () => {
    render(<Home />)
    const link = screen.getByRole('link', { name: 'Stan Carver II' })
    expect(link).toHaveAttribute('target', '_blank')
    expect(link).toHaveAttribute('rel', 'noopener noreferrer')
  })
})
