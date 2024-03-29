FROM golang:1.17-alpine AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

COPY ./public public

EXPOSE 3000
ENTRYPOINT ["/app/main"]