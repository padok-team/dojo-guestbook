FROM golang:1.27-alpine@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

COPY ./public public

EXPOSE 3000
ENTRYPOINT ["/app/main"]