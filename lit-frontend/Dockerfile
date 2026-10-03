FROM node:20-alpine AS builder

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@9.9.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

# Backend is hosted on its own subdomain (same pattern as before: frontend and
# API are separate origins, talking to each other over CORS).
ARG VITE_API_URL=https://gruha.sarvavidha.in/api
ENV VITE_API_URL=${VITE_API_URL}

RUN pnpm run build

FROM nginx:alpine AS runner

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
