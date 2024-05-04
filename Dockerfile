# Base image with Node.js 20 and Alpine
FROM node:20-alpine AS base

# Install system dependencies
RUN apk add --no-cache libc6-compat python3 py3-pip python3-dev build-base
WORKDIR /app

# Ensure corepack is enabled and pnpm is installed
RUN corepack enable
RUN corepack prepare pnpm@latest --activate

# Install dependencies using pnpm if available
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Copy application code and build
FROM base AS builder
COPY . .
RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Production image setup
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

# Set up non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Copy built files
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy Flask app
COPY --from=builder /app/api ./api

# Set up Python environment and Flask
USER root
RUN python3 -m venv /app/my_venv
RUN source /app/my_venv/bin/activate && pip install flask

# Switch back to application user
USER nextjs

EXPOSE 3000
EXPOSE 5328

ENV PORT 3000

CMD ["sh", "-c", "HOSTNAME='0.0.0.0' node server.js & source /app/my_venv/bin/activate && python3 -m flask --app api/index run -p 5328 --reload"]
