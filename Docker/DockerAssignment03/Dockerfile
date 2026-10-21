
FROM alpine:latest

LABEL maintainer="Yogesh Indoria"

RUN apk update && apk add --no-cache nodejs

COPY . /app

WORKDIR /app

CMD ["node", "index.js"]
