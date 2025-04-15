FROM node:22.1-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

EXPOSE 4001

CMD ["node", "index.js"]
