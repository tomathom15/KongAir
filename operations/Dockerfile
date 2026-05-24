FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY app.js .
EXPOSE 5056
CMD ["node", "app.js"]
