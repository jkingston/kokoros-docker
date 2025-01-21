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

# Download the onnx model
RUN apt-get install wget
RUN wget https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/kokoro-v0_19.onnx -O /Kokoros/checkpoints/kokoro-v0_19.onnx

FROM bitnami/minideb
RUN apt-get update && apt-get install -y libssl-dev
COPY --from=build /Kokoros/target/release/koko /Kokoros/target/release/koko
COPY --from=build /Kokoros/target/release/build/espeak-rs-sys-d86ac823604b2480/out/share/ /Kokoros/target/release/build/espeak-rs-sys-d86ac823604b2480/out/share/
COPY --from=build /Kokoros/data /Kokoros/data
COPY --from=build /Kokoros/checkpoints /Kokoros/checkpoints
WORKDIR /Kokoros
ENTRYPOINT [ "./target/release/koko" ]
