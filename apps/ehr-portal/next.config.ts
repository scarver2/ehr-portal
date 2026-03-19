// apps/ehr-portal/next.config.ts

import type { NextConfig } from "next"
import { setupHoneybadger } from "@honeybadger-io/nextjs"

const nextConfig: NextConfig = {
  output: "standalone",
  // Turbopack is the default dev server in Next.js 16. The empty config tells
  // Next.js we're aware of it, which silences the hard error produced when a
  // custom webpack config exists (added by setupHoneybadger below) but no
  // turbopack config is present. Source-map upload is disabled outside of
  // production so the webpack plugin is a no-op during dev/test either way.
  turbopack: {
    // Monorepo has multiple bun.lock files; pin the root to this app so
    // Turbopack doesn't pick up the workspace-level lockfile by mistake.
    root: __dirname,
  },
}

// Wraps the Next.js webpack config to upload source maps to Honeybadger at
// build time so that stack traces in production resolve to original source.
// Source map upload is disabled outside of production to keep dev builds fast.
export default setupHoneybadger(nextConfig, {
  disableSourceMapUpload: process.env.NODE_ENV !== "production",
  silent: true,
  webpackPluginOptions: {
    apiKey: process.env.NEXT_PUBLIC_HONEYBADGER_API_KEY ?? "",
    assetsUrl: process.env.NEXT_PUBLIC_HONEYBADGER_ASSETS_URL ?? "",
    revision: process.env.NEXT_PUBLIC_HONEYBADGER_REVISION ?? "",
  },
})
