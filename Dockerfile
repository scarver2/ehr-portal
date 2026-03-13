# Dockerfile

# Up and running config
# FROM nginx:alpine
# COPY index.html /usr/share/nginx/html/index.html

FROM oven/bun:1

WORKDIR /app

COPY apps/ehr-portal/package.json apps/ehr-portal/bun.lockb* ./

RUN bun install

COPY apps/ehr-portal .

RUN bun run build

EXPOSE 3000

CMD ["bun", "run", "start"]