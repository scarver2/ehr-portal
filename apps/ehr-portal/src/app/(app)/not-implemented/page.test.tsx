// src/app/not-implemented/page.test.tsx

import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

import NotImplemented from './page'

describe('NotImplemented', () => {
  it('renders heading', () => {
    render(<NotImplemented />)
    expect(screen.getByRole('heading', { name: 'Not Implemented' })).toBeInTheDocument()
  })

  it('renders message about feature not available', () => {
    render(<NotImplemented />)
    expect(screen.getByText(/This feature is not yet available for your role/)).toBeInTheDocument()
  })

  it('renders home link', () => {
    render(<NotImplemented />)
    const link = screen.getByRole('link', { name: 'Back to Home' })
    expect(link).toBeInTheDocument()
    expect(link).toHaveAttribute('href', '/')
  })
})
