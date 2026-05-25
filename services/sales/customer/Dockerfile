FROM node:20

ENV TINI_VERSION v0.19.0

RUN ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') && \
    if [ "$ARCH" = "arm64" ]; then \
      curl -L -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64; \
    else \
      curl -L -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini; \
    fi && \
    chmod +x /tini

WORKDIR /usr/src/app
COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 3000
ENTRYPOINT ["/tini", "--"]
CMD [ "node", "main.js" ]