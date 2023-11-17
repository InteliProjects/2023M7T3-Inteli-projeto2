FROM rust:1.67 AS build

WORKDIR /app

COPY . .

RUN cargo build --release

FROM debian:buster-slim AS runtime

WORKDIR /app

COPY --from=build /app/target/release/logger-api .

EXPOSE 3002

CMD ["./logger-api"]