# Build image
FROM crystallang/crystal:1.7.2-alpine as builder
WORKDIR /opt
# Cache dependencies
COPY ./shard.yml ./shard.lock /opt/
RUN shards install -v
RUN apk add yarn
# Build a binary
COPY . /opt/
RUN yarn install
RUN NODE_ENV=production yarn run build && NODE_ENV=production yarn run build:css
RUN crystal build --static --release ./src/app.cr
RUN crystal build --static --release ./src/worker.cr
RUN crystal build --static --release ./src/bundle.cr
# ===============
# Result image with one layer
FROM alpine:latest
WORKDIR /
# TODO: Check if `public` dir is needed or if executables are good as-is
COPY --from=builder /opt/app .
COPY --from=builder /opt/worker .
COPY --from=builder /opt/bundle .
ENTRYPOINT ["./bundle"]