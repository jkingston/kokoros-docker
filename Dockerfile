FROM python:3.12-slim AS prepare
RUN apt-get update && apt-get install -y git wget
ADD Kokoros /Kokoros
WORKDIR /Kokoros
RUN pip install --upgrade pip && pip install -r scripts/requirements.txt
RUN chmod +x scripts/download_voices.sh && scripts/download_voices.sh

FROM rust:1.84-slim AS build
COPY --from=prepare /Kokoros /Kokoros
WORKDIR /Kokoros
RUN apt-get update && apt-get install -y libssl-dev pkg-config libclang-dev cmake clang git
RUN rustup component add rustfmt
RUN cargo build --release

# Download the onnx model
RUN apt-get install wget
RUN chmod +x scripts/download_models.sh && scripts/download_models.sh

FROM bitnami/minideb
RUN apt-get update && apt-get install -y libssl-dev
COPY --from=build /Kokoros/target/release/koko /Kokoros/target/release/koko
COPY --from=build /Kokoros/target/release/build/ /Kokoros/target/release/build/
COPY --from=build /Kokoros/data /Kokoros/data
COPY --from=build /Kokoros/checkpoints /Kokoros/checkpoints
WORKDIR /Kokoros
ENTRYPOINT [ "./target/release/koko" ]
