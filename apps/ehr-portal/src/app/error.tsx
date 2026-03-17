'use client' // Error components must be Client Components

import { useEffect } from 'react'
import { Honeybadger } from '@honeybadger-io/react'

/**
 * Segment-level error boundary for the app router.
 *
 * Catches errors thrown during rendering, data fetching, or in server
 * actions within the current route segment and its children.
 *
 * @see https://nextjs.org/docs/app/building-your-application/routing/error-handling
 */
export default function Error({
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
    <div>
      <h2>Something went wrong!</h2>
      <button
        onClick={
          // Attempt to recover by trying to re-render the segment
          () => reset()
        }
      >
        Try again
      </button>
    </div>
  )
}
