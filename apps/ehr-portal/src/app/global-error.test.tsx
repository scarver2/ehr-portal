// apps/ehr-portal/src/app/global-error.test.tsx

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import GlobalError from './global-error'

vi.mock('@honeybadger-io/react', () => ({
  Honeybadger: { notify: vi.fn() },
}))

import { Honeybadger } from '@honeybadger-io/react'

describe('GlobalError', () => {
  const error = new globalThis.Error('catastrophe')
  const reset = vi.fn()

  beforeEach(() => {
    vi.mocked(Honeybadger.notify).mockClear()
    reset.mockClear()
  })

  it('renders the error message', () => {
    render(<GlobalError error={error} reset={reset} />)
    expect(screen.getByRole('heading')).toHaveTextContent('Something went wrong!')
  })

  it('renders a retry button', () => {
    render(<GlobalError error={error} reset={reset} />)
    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument()
  })

  it('notifies Honeybadger with the error on mount', () => {
    render(<GlobalError error={error} reset={reset} />)
    expect(Honeybadger.notify).toHaveBeenCalledWith(error)
  })

  it('calls reset when the retry button is clicked', async () => {
    const user = userEvent.setup()
    render(<GlobalError error={error} reset={reset} />)
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(reset).toHaveBeenCalledTimes(1)
  })
})
