# Reliora

> **Your Universal AI Client**
>
> Connect to local and cloud AI models through a single, modern interface.

Reliora is a Flutter-based AI chat client designed for developers, enthusiasts, and power users who want a unified experience across multiple AI providers.

Whether you're running models locally with LM Studio or using cloud-hosted models through OpenRouter, Reliora provides a clean and extensible interface without locking you into a single ecosystem.

---

## ✨ Features

- 🤖 Multiple AI provider support
- 🖥️ LM Studio integration
- ☁️ OpenRouter integration
- 📝 Markdown rendering
- 🔒 Secure API key storage
- 📁 File attachment support
- 🖼️ Image attachment groundwork
- 🎨 Light / Dark / System themes
- ⚡ Riverpod-powered state management
- 📱 Cross-platform Flutter application
- 🔧 Extensible architecture for new providers.

---

## Supported Providers

### Local Providers

#### LM Studio

Run models locally through LM Studio's OpenAI-compatible API.

**Examples:**

- Gemma
- Qwen
- DeepSeek
- Llama
- Mistral
- Phi
- Any GGUF model supported by LM Studio

**Default Endpoint**

```text
http://localhost:1234/v1
```

**API Key Required:** No

---

#### Ollama *(Planned)*

Run models locally using Ollama.

**Examples:**

- Llama
- Qwen
- Gemma
- DeepSeek
- Mistral
- Phi
- CodeLlama

**Default Endpoint**

```text
http://localhost:11434
```

**API Key Required:** No

---

#### vLLM *(Planned)*

Connect to self-hosted OpenAI-compatible inference servers.

Example:

```text
http://your-server:8000/v1
```

---

## Cloud Providers

### OpenRouter

Access hundreds of models through a single API.

**Examples:**

- GPT-5
- GPT-4.1
- Claude Sonnet
- Claude Opus
- Gemini 2.5 Pro
- Gemini 2.5 Flash
- DeepSeek V3
- DeepSeek R1
- Qwen 3
- Kimi
- Grok
- Nemotron Ultra
- Llama models

**API Key Required:** Yes

---

### Planned Providers

- OpenAI
- Anthropic
- Google Gemini
- Groq
- Together AI
- Fireworks AI
- DeepInfra
- Nebius

---

## Provider Support Matrix

| Provider | Text | Vision | Streaming | Planned |
|----------|------|---------|------------|----------|
| LM Studio | ✅ | 🚧 | 🚧 | Available |
| OpenRouter | ✅ | 🚧 | 🚧 | Available |
| Ollama | ⏳ | ⏳ | ⏳ | Planned |
| OpenAI | ⏳ | ⏳ | ⏳ | Planned |
| Anthropic | ⏳ | ⏳ | ⏳ | Planned |
| Gemini | ⏳ | ⏳ | ⏳ | Planned |
| Groq | ⏳ | ⏳ | ⏳ | Planned |

---

## Screenshots

Coming soon.

```text
assets/screenshots/chat.png
assets/screenshots/settings.png
```

---

## Installation

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / VS Code

Verify your setup:

```bash
flutter doctor
```

Clone the repository:

```bash
git clone https://github.com/xdbhavik/chatbot-client.git
cd chatbot-client
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Configuration

### OpenRouter

1. Create an OpenRouter account.
2. Generate an API key.
3. Open Reliora Settings.
4. Select OpenRouter.
5. Enter your API key.
6. Choose a model.

---

### LM Studio

1. Install LM Studio.
2. Download a model.
3. Start the local server.
4. Ensure the endpoint is:

```text
http://localhost:1234/v1
```

5. Select LM Studio inside Reliora.

No API key required.

---

## Architecture

```text
lib/
├── app/
├── features/
│   ├── chat/
│   ├── settings/
│   └── providers/
├── services/
├── models/
└── widgets/
```

### Core Technologies

| Technology | Purpose |
|------------|----------|
| Flutter | UI Framework |
| Riverpod | State Management |
| Dio | HTTP Client |
| SharedPreferences | App Settings |
| Flutter Secure Storage | API Key Storage |
| Flutter Markdown | Markdown Rendering |

---

## Roadmap

### 🚧 In Progress

- Vision support
- Voice input
- Voice output
- Streaming responses

### 📌 Planned

- Ollama integration
- OpenAI integration
- Anthropic integration
- Gemini integration
- Conversation history
- Chat export
- Prompt library
- MCP support
- RAG support
- Multi-provider conversations
- Local chat indexing

---

## Why Reliora?

Most AI clients are tied to a single provider.

Reliora is designed to be a universal front-end that lets you switch between local and cloud models without changing your workflow.

Use:
- Local models with LM Studio
- Cloud models through OpenRouter
- Future providers through a single interface

One application. Any model.

---

## Contributing

Contributions, ideas, bug reports, and pull requests are welcome.

If you have suggestions for new providers or features, open an issue.

---

## License

MIT License

---

## Acknowledgements

Built with:

- Flutter
- Riverpod
- Dio
- OpenRouter
- LM Studio

---

# Reliora

### One Chat Interface. Any Model.