#!/usr/bin/env bash
# bin/steps/20_nextjs.sh

source "$(dirname "$0")/../_lib.sh"

# npx create-next-app@latest next-portal

# cd ../next-portal

# npm install --save-dev vitest @testing-library/react

bunx create-next-app@latest ehr-portal \
  --typescript \
  --app \
  --no-tailwind \
  --src-dir \
  --eslint \
  --use-bun \
  --no-git \
  --yes \
  --import-alias "@/*"


# Create bin/ scripts for standalone app development
mkdir -p apps/ehr-portal/bin

cat << 'EOF' > apps/ehr-portal/bin/_lib.sh
#!/usr/bin/env bash
# apps/ehr-portal/bin/_lib.sh

_APP_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$_APP_BIN_DIR/.." && pwd)"
unset _APP_BIN_DIR

# Tell root's _lib.sh to skip its auto-banner — we call it below after
# correcting COMMAND_NAME and APP_DIR.
_EHR_APP_CONTEXT=1 source "$APP_DIR/../../bin/_lib.sh"
unset _EHR_APP_CONTEXT

COMMAND_NAME="$(basename "${BASH_SOURCE[1]:-$0}")"

cd "$APP_DIR"
banner
EOF
chmod +x apps/ehr-portal/bin/_lib.sh

cat << 'EOF' > apps/ehr-portal/bin/dev
#!/usr/bin/env bash
# apps/ehr-portal/bin/dev

source "$(dirname "$0")/_lib.sh"

require_command bun

NEXT_PUBLIC_API_URL="http://localhost:3000/" PORT=3001 bun dev "$@"
EOF
chmod +x apps/ehr-portal/bin/dev

cat << 'EOF' > apps/ehr-portal/bin/lint
#!/usr/bin/env bash
# apps/ehr-portal/bin/lint
#
# Usage:
#   bin/lint                        # default lint report
#   bin/lint --fix                  # apply auto-fixes

source "$(dirname "$0")/_lib.sh"

require_command bun

exec bunx next lint . "$@"
EOF
chmod +x apps/ehr-portal/bin/lint

cat << 'EOF' > apps/ehr-portal/bin/test
#!/usr/bin/env bash
# apps/ehr-portal/bin/test
# Run the test suite. Defaults to Vitest (unit tests). Pass --e2e to run
# Playwright integration tests instead.
#
# Examples:
#   bin/test                                        # run all unit tests
#   bin/test --watch                                # interactive watch mode
#   bin/test --e2e                                  # run Playwright E2E tests
#   bin/test --e2e --ui                             # Playwright UI mode

source "$(dirname "$0")/_lib.sh"

if [[ "${1:-}" == "--e2e" ]]; then
  shift
  exec bunx playwright test "$@"
else
  exec bunx vitest run "$@"
fi
EOF
chmod +x apps/ehr-portal/bin/test

cat << 'EOF' > apps/ehr-portal/bin/outdated
#!/usr/bin/env bash
# apps/ehr-portal/bin/outdated
#
# Usage:
#   bin/outdated

source "$(dirname "$0")/_lib.sh"

outdated_command bun

exec bunx npm-check-updates "$@"
EOF
chmod +x apps/ehr-portal/bin/outdated

cat << 'EOF' > apps/ehr-portal/bin/update
#!/usr/bin/env bash
# apps/ehr-portal/bin/update
#
# Usage:
#   bin/update           # interactive menu
#   bin/update node      # upgrade Node.js via Homebrew
#   bin/update bun       # upgrade Bun via Homebrew
#   bin/update packages  # bun update
#   bin/update all       # node + bun + packages

source "$(dirname "$0")/_lib.sh"

update_node() {
  info "Upgrading Node.js..."
  brew upgrade node
  success "Node.js upgraded"
}

update_bun() {
  info "Upgrading Bun..."
  brew upgrade bun
  success "Bun upgraded"
}

update_packages() {
  info "Updating packages..."
  bun update
  success "Packages updated"
}

run_update() {
  case "$1" in
    node)     update_node ;;
    bun)      update_bun ;;
    packages) update_packages ;;
    all)
      update_node
      update_bun
      update_packages
      ;;
    *) abort "Unknown target: $1" ;;
  esac
}

if [[ $# -gt 0 ]]; then
  run_update "$1"
else
  selection=$(select_menu "Select what to update:" "node" "bun" "packages" "all")
  run_update "$selection"
fi
EOF
chmod +x apps/ehr-portal/bin/update

cat << 'EOF' > apps/ehr-portal/bin/coverage
#!/usr/bin/env bash
# apps/ehr-portal/bin/coverage
# Run unit tests with code coverage.
#
# Usage:
#   bin/coverage              # run all tests with coverage report
#   bin/coverage --ui         # open coverage in browser UI

source "$(dirname "$0")/_lib.sh"

require_command bun

exec bunx vitest run --coverage "$@"
EOF
chmod +x apps/ehr-portal/bin/coverage

# Install coverage provider
bun add --cwd apps/ehr-portal -d @vitest/coverage-v8

# Update app metadata
cat << 'EOF' > apps/ehr-portal/src/app/layout.tsx
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "EHR Portal",
  description: "Electronic Health Records Portal",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>
        {children}
      </body>
    </html>
  );
}
EOF

# Replace default Next.js landing page
cat << 'EOF' > apps/ehr-portal/src/app/page.tsx
export default function Home() {
  return (
    <main style={{ display: "flex", height: "100vh", alignItems: "center", justifyContent: "center" }}>
      <h1 style={{ fontSize: "20vw", fontWeight: 700, letterSpacing: "-0.05em", lineHeight: 1 }}>
        EHR
      </h1>
      <footer style={{ position: "fixed", bottom: "1.5rem", fontSize: "0.8rem", opacity: 0.4 }}>
        &copy;2026{" "}
        <a href="https://stancarver.com" target="_blank" rel="noopener noreferrer" style={{ color: "inherit" }}>
          Stan Carver II
        </a>
      </footer>
    </main>
  );
}
EOF

# Create health check endpoint
mkdir -p apps/ehr-portal/src/app/api/up
cat << 'EOF' > apps/ehr-portal/src/app/api/up/route.ts
// apps/ehr-portal/src/app/api/up/route.ts

export async function GET() {
  return new Response("ok", { status: 200 });
}
EOF

# TODO: add Next.js unit and integration tests

