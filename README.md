<div align="center">

# Stuko Plonk

### Your local AI, in your pocket.

Run private AI models directly on your Android or iOS device. No accounts, no servers, no telemetry. Your data never leaves your phone.

[Features](#features)  ·  [Roadmap](#roadmap)  ·  [Architecture](#architecture)  ·  [Building](#building)  ·  [Contributing](#contributing)  ·  [License](#license)

</div>

---

## About

Stuko Plonk is a mobile client for running large language models and other AI models **entirely on-device**. It is designed for users who care about privacy, want to experiment with local models, or simply need a reliable AI assistant that works offline.

The app is built with Flutter and uses llama.cpp as its inference engine, wrapped through a native FFI bridge. It supports multiple model sources (Ollama registry, Hugging Face, direct URLs, and OpenAI-compatible APIs) and exposes a chat-first interface with extensibility through slash commands and tool calling.

**Core principles:**

- **Local by default.** No login, no cloud requirement, no data collection.
- **No accounts.** The app has no concept of users or profiles. All state stays on the device.
- **Bring your own models.** Pull from Ollama, Hugging Face, a custom URL, or point at any OpenAI-compatible server.
- **Extensible.** Slash commands, custom tool definitions, RAG over local files, multimodal input.
- **Hermes-like UX.** Conversational interface, model switching on the fly, transparent tool execution.

## Features

- **Multi-provider model store** — browse and download models from Ollama, Hugging Face, direct URLs, or any OpenAI-compatible API. Only one provider active at a time.
- **Local inference** — llama.cpp running on-device via FFI. CPU multi-thread by default. Vulkan/Metal accelerators optional.
- **Model filtering** — by status (installed, available, popular, new) and by capability (text, tools, vision, image generation, uncensored, TTS, STT, embedding).
- **Model switcher pill** — quick model switching from the chat header, with size/quantization context.
- **Slash commands** — invoke tools, change settings, or trigger specialized prompts with `/command`. User-defined commands supported.
- **Function calling** — models with tool capabilities can call registered tools automatically. Manual slash and automatic function calling can coexist via a global toggle.
- **On-device RAG** — index local files, query them with `/rag` or in silent mode. Embeddings computed locally.
- **Multimodal** — vision models can process attached images. Optional TTS output and STT input.
- **Private by design** — no analytics, no telemetry, no network calls except those the user explicitly configures.

## Roadmap

The project is in early development. The full plan is in [`docs/plan.md`](docs/plan.md).

| Phase | Status | Scope |
|-------|--------|-------|
| 1. Scaffold | in progress | Flutter project, Drift, go_router, basic settings, CI |
| 2. Providers + Store | planned | Ollama, HF, Custom URL, API adapters. Filtering and download UX |
| 3. Inference engine | planned | FFI bridge to llama.cpp, NDK build, streaming generation |
| 4. Chat core | planned | Message UI, model pill, history, model switching |
| 5. Slash + tools | planned | Command parser, function calling, capability validation |
| 6. Multimodal | planned | Vision input, TTS output, STT input |
| 7. Polish | planned | Onboarding, error handling, metrics, accessibility |

## Architecture

Feature-first monolith. Each feature (`chat`, `store`, `models`, `settings`, `inference`, `rag`) is self-contained with `data/`, `domain/`, and `presentation/` layers. Shared code lives in `core/` and `data/`. State management is Riverpod 2. Persistence is Drift (SQLite). Inference is llama.cpp via FFI.

Full architectural rationale in [`docs/plan.md`](docs/plan.md#16-arquitectura-del-proyecto).

```
lib/
  app/              # MaterialApp, router, theme, dependency injection
  core/             # capabilities, errors, constants, utils
  data/             # shared db, http clients, repositories
  features/
    settings/       # provider selection, models directory
    store/          # model browser with filters
    models/         # installed model management
    chat/           # chat UI, model pill, slash parser
    inference/      # engine wrapper around llama.cpp
    rag/            # local indexer and retriever
  shared/
    widgets/        # reusable UI
    extensions/
```

## Building

### Prerequisites

- Flutter 3.44 or newer (Dart 3.x)
- Android: NDK r28, Android SDK with API 36, Gradle 8.13, AGP 8.11
- iOS: Xcode 15+, CocoaPods
- Linux/macOS host with `git`, `make`, and a C/C++ toolchain for building llama.cpp

### Clone

```bash
git clone https://github.com/Stuko0/stuko-plonk.git
cd stuko-plonk
```

### Get dependencies

```bash
flutter pub get
```

### Run on Android (debug)

```bash
flutter run -d android
```

### Run on iOS (debug, requires macOS)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### Run tests

```bash
flutter test
```

### Build release APK

```bash
flutter build apk --release
```

### Build release IPA

```bash
flutter build ipa --release
```

## Project status

This is a solo project by [@Stuko0](https://github.com/Stuko0). It is not production-ready. Expect breaking changes, missing features, and rough edges. The roadmap is ambitious and the timeline is open.

The architecture is designed to keep the door open for collaboration: each feature is a self-contained module, the CI runs on every push, and the public issue tracker is open.

## Contributing

Bug reports, feature requests, and pull requests are welcome. Before opening a PR:

1. Read the plan in [`docs/plan.md`](docs/plan.md) to understand the direction.
2. Open an issue describing the change you want to make.
3. Fork the repo, create a feature branch, and open a PR against `main`.

CI must pass before merge. The `main` branch is protected; direct pushes require CI green.

## Security

Stuko Plonk is privacy-first by design. The app does not collect telemetry, does not phone home, and does not require any account.

If you discover a security issue, please open a private security advisory on GitHub rather than a public issue.

## License

MIT — see [`LICENSE`](LICENSE) for the full text.

## Acknowledgments

- [llama.cpp](https://github.com/ggerganov/llama.cpp) for the inference engine.
- [Ollama](https://ollama.com) for the model registry protocol.
- [Hugging Face](https://huggingface.co) for the model hub.
- [Flutter](https://flutter.dev) and the Dart team for the cross-platform runtime.
- Everyone who runs models on their own hardware.

---

<div align="center">

Made with stubbornness by [Stuko0](https://github.com/Stuko0)

</div>
