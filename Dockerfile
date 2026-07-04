FROM node:22-alpine AS build
WORKDIR /app

COPY package.json ./
COPY packages/gelato-core/package.json packages/gelato-core/package.json
RUN npm install

COPY packages/gelato-core packages/gelato-core
RUN npm run build:core

COPY . .
RUN npm run build
RUN npm prune --omit=dev

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3001

COPY --from=build --chown=node:node /app/package.json ./package.json
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/packages/gelato-core ./packages/gelato-core
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/prisma ./prisma

USER node
EXPOSE 3001
CMD ["node", "dist/main.js"]
