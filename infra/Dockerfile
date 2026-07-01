FROM alpine:3.24.1 AS build
WORKDIR /app
COPY . .
RUN echo "Build stage placeholder"

FROM alpine:3.24.1 AS runtime
WORKDIR /app
RUN addgroup -S app && adduser -S -G app app
COPY --from=build --chown=app:app /app .
USER app
CMD ["echo", "Hello from Docker"]
