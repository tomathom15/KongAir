FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY app.js .
EXPOSE 5057
CMD ["node", "app.js"]
