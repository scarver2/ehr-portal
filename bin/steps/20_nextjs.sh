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


# Create bin/dev for standalone app development
mkdir -p apps/ehr-portal/bin
cat << 'EOF' > apps/ehr-portal/bin/dev
#!/usr/bin/env bash
# apps/ehr-portal/bin/dev
# Starts the Next.js portal on port 3001.
# Run from the repo root with bin/dev for the full stack.

NEXT_PUBLIC_API_URL="http://localhost:3000/" PORT=3001 bun dev
EOF
chmod +x apps/ehr-portal/bin/dev

# Create health check endpoint
mkdir -p apps/ehr-portal/src/app/api/up
cat << 'EOF' > apps/ehr-portal/src/app/api/up/route.ts
// apps/ehr-portal/src/app/api/up/route.ts

export async function GET() {
  return new Response("ok", { status: 200 });
}
EOF

# TODO: add Next.js unit and integration tests

