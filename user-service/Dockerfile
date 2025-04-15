FROM node:22.1-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 4001

CMD ["node", "index.js"]
