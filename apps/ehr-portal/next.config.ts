// apps/ehr-portal/next.config.ts

import type { NextConfig } from "next"
import { setupHoneybadger } from "@honeybadger-io/nextjs"

const nextConfig: NextConfig = {
  output: "standalone",
}

// Wraps the Next.js webpack config to upload source maps to Honeybadger at
// build time so that stack traces in production resolve to original source.
// Source map upload is disabled outside of production to keep dev builds fast.
export default setupHoneybadger(nextConfig, {
  disableSourceMapUpload: process.env.NODE_ENV !== "production",
  silent: true,
  webpackPluginOptions: {
    apiKey: process.env.NEXT_PUBLIC_HONEYBADGER_API_KEY,
    assetsUrl: process.env.NEXT_PUBLIC_HONEYBADGER_ASSETS_URL,
    revision: process.env.NEXT_PUBLIC_HONEYBADGER_REVISION,
  },
})
