FROM golang:1.27-alpine@sha256:f92b6ef800e499660581efdabdf25d9d817a9d124eaf900924f0504e7e27e12d AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

COPY ./public public

EXPOSE 3000
ENTRYPOINT ["/app/main"]