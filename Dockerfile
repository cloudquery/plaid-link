FROM golang:1.22 AS api_build

WORKDIR /opt/src
COPY ./go .

RUN go get -d -v ./...
RUN go build -o api


FROM node:20-alpine AS frontend_build

WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY ./frontend/.npmrc ./
COPY ./frontend/package*.json ./
RUN npm install

COPY ./frontend ./
RUN npm run build

CMD ["npm", "start"]


FROM nginx:alpine-slim AS runtime

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=frontend_build /app/build /usr/share/nginx/html
COPY --from=api_build /opt/src/api /app/api

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
RUN apk add libc6-compat openssl

EXPOSE 443
ENTRYPOINT ["/entrypoint.sh"]