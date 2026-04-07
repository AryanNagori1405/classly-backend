# ---------- build stage ----------
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ---------- runtime stage ----------
FROM node:20-alpine
WORKDIR /app

# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Ownership
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000

CMD ["node", "src/index.js"]
