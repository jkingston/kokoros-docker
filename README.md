# Kokoros Docker

Docker container for [Kokoros Text-to-Speech](https://github.com/lucasjinreal/Kokoros) application.

All credit to @lucasjinreal, this is purely bundling Kokoros into a docker container.

## Features

- Multi-stage build for minimal image size
- Includes pre-downloaded voice models
- Bundles pre-built onnx model for fast container start time

## Usage

### Building the Container

```bash
docker build -t kokoros .
```

### Running the Container

```bash
docker run -p 3000:3000 kokoros --oai
```

The TTS service will be available at `http://localhost:3000` using an OpenAI-compatible API. See [Kokoros Text-to-Speech](https://github.com/lucasjinreal/Kokoros) for more info.

## License

MIT
