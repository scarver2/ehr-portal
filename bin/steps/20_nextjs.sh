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


# Create health check endpoint
mkdir -p apps/ehr-portal/src/app/api/up
cat << 'EOF' > apps/ehr-portal/src/app/api/up/route.ts
// apps/ehr-portal/src/app/api/up/route.ts

export async function GET() {
  return new Response("ok", { status: 200 });
}
EOF

# TODO: add Next.js unit and integration tests

