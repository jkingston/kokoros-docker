FROM python:3.12-slim AS prepare
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/lucasjinreal/Kokoros.git
WORKDIR /Kokoros
RUN pip install --upgrade pip
RUN pip install -r scripts/requirements.txt
RUN python scripts/fetch_voices.py

FROM rust:1.84-slim AS build
COPY --from=prepare /Kokoros /Kokoros
WORKDIR /Kokoros
RUN apt-get update && apt-get install -y libssl-dev pkg-config libclang-dev cmake clang git
RUN rustup component add rustfmt
RUN cargo build --release

# Run koko to generate the onnx model at docker build time
# This is to avoid the long wait time when running the container
RUN ./target/release/koko 

FROM bitnami/minideb
COPY --from=build /Kokoros/target/release/koko /Kokoros/target/release/koko
COPY --from=build /Kokoros/target/release/deps/ /Kokoros/target/release/deps/
COPY --from=build /Kokoros/data /Kokoros/data
COPY --from=build /Kokoros/checkpoints /Kokoros/checkpoints
RUN apt-get update && apt-get install -y libssl-dev
WORKDIR /Kokoros
ENTRYPOINT [ "./target/release/koko" ]
