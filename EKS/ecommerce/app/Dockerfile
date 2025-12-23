# Use Node.js official image
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
