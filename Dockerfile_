# Dockerfile

# ---------- Base ----------
FROM oven/bun:1 AS base
WORKDIR /app

# ---------- Dependencies ----------
FROM base AS deps
COPY apps/ehr-portal/package.json apps/ehr-portal/bun.lockb* ./
RUN bun install --frozen-lockfile

# ---------- Builder ----------
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY apps/ehr-portal .

RUN bun run build

# ---------- Runtime ----------
FROM oven/bun:1-slim AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# copy standalone output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000

CMD ["bun", "server.js"]
