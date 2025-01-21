FROM python:3.12-slim AS build_python
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/lucasjinreal/Kokoros.git
WORKDIR /Kokoros
RUN pip install --upgrade pip
RUN pip install -r scripts/requirements.txt
RUN python scripts/fetch_voices.py

FROM rust:1.84-slim AS build_rust
COPY --from=build_python /Kokoros /Kokoros
WORKDIR /Kokoros
RUN apt-get update && apt-get install -y libssl-dev pkg-config libclang-dev
RUN rustup component add rustfmt
RUN apt-get install -y cmake
RUN apt-get install -y clang
RUN apt-get install -y git
RUN cargo build --release

# Run koko to generate the onnx model at docker build time
# This is to avoid the long wait time when running the container
RUN ./target/release/koko 

FROM bitnami/minideb
COPY --from=build /Kokoros/target/release/ /Kokoros/target/release/
COPY --from=build /Kokoros/data /Kokoros/data
COPY --from=build /Kokoros/checkpoints /Kokoros/checkpoints
RUN apt-get update && apt-get install -y libssl-dev
WORKDIR /Kokoros
ENTRYPOINT [ "./target/release/koko" ]
