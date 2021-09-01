FROM golang:1.10.0

# Install dependencies
RUN go get github.com/codegangsta/negroni \
           github.com/gorilla/mux \
           github.com/xyproto/simpleredis

# Copy and build go app
WORKDIR /app
ADD ./main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Clean dependencies
FROM scratch

# Copy app and front
WORKDIR /app
COPY --from=0 /app/main .
COPY ./public/index.html public/index.html
COPY ./public/script.js public/script.js
COPY ./public/style.css public/style.css

# Start the app
CMD ["/app/main"]

# Open port
EXPOSE 3000
