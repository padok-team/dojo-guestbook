FROM golang:1.17-alpine@sha256:02685740eb7129ae4354c04100b19e13b8b38dbe8bbbc6d68fddb5f7b3c19d23 AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

COPY ./public public

EXPOSE 3000
ENTRYPOINT ["/app/main"]