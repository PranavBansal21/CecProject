FROM node:22.1-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .

EXPOSE 4002
CMD ["node", "index.js"]
