FROM golang:1.25-alpine@sha256:06cdd34bd531b810650e47762c01e025eb9b1c7eadd191553b91c9f2d549fae8 AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

COPY ./public public

EXPOSE 3000
ENTRYPOINT ["/app/main"]