FROM golang:1.17-alpine AS build

WORKDIR /app

COPY go.* ./
RUN go mod download

COPY main.go main.go
RUN CGO_ENABLED=0 go build -o=main

# =====================================================

FROM scratch AS production

# Copy app and front
WORKDIR /app
COPY ./public public

COPY --from=build /app/main /main

EXPOSE 3000
ENTRYPOINT ["/main"]
