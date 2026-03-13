# Dockerfile

# Up and running config
# FROM nginx:alpine
# COPY index.html /usr/share/nginx/html/index.html

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

COPY --from=builder /app ./

EXPOSE 3000

CMD ["bun", "run", "start"]