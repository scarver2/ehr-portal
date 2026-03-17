'use client' // Error components must be Client Components

import { useEffect } from 'react'
import { Honeybadger } from '@honeybadger-io/react'

/**
 * Root-level error boundary that replaces the root layout on error.
 *
 * Catches errors thrown in the root layout or template. Because it
 * replaces the root layout it must define its own <html> and <body> tags.
 *
 * @see https://nextjs.org/docs/app/building-your-application/routing/error-handling#handling-errors-in-layouts
 */
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    Honeybadger.notify(error)
  }, [error])

  return (
    <html>
      <body>
        <h2>Something went wrong!</h2>
        <button
          onClick={
            // Attempt to recover by trying to re-render the segment
            () => reset()
          }
        >
          Try again
        </button>
      </body>
    </html>
  )
}
