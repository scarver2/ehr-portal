# bin/steps/29_dock_nextjs.sh

cat << 'EOF' > apps/ehr-portal/Dockerfile
# apps/ehr-portal/Dockerfile
FROM oven/bun:1

WORKDIR /app

COPY package.json bun.lockb* ./

RUN bun install

COPY . .

RUN bun run build

EXPOSE 3000

CMD ["bun", "run", "start"]

EOF
