FROM golang:1.22 AS api_build

WORKDIR /opt/src
COPY ./src/go .

RUN go get -d -v ./...
RUN go build -o api


FROM node:20-alpine AS frontend_build

WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY ./src/frontend/.npmrc ./
COPY ./src/frontend/package*.json ./
RUN npm install

COPY ./src/frontend ./
RUN npm run build

CMD ["npm", "start"]


FROM nginx:alpine-slim AS runtime

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=frontend_build /app/build /usr/share/nginx/html
COPY --from=api_build /opt/src/api /app/api

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
RUN apk add libc6-compat

ENV NGINX_PORT=3000
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]