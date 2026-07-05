# Plan: Stuko Plonk (stuko-mobile-models)

App móvil 100% local para correr modelos de IA en el dispositivo. Sin cuentas, sin servidor obligatorio, sin telemetría. Producto: **Stuko Plonk** — "your local AI, in your pocket".

## 1. Alcance

- Plataformas: **Android + iOS**. Excluidos: web, desktop.
- Sin login ni perfil. Configuración local en SQLite.
- Inferencia siempre on-device (motor local).

## 2. Stack

| Capa              | Tecnología                              |
| ----------------- | --------------------------------------- |
| Framework         | Flutter (Dart 3.x)                      |
| State             | Riverpod 2                              |
| Routing           | go_router                               |
| DB                | Drift (SQLite)                          |
| Archivos          | path_provider, file_picker              |
| HTTP              | dio                                     |
| Permisos          | permission_handler                      |
| Descargas BG      | workmanager                             |
| Inferencia        | llama.cpp vía FFI                       |
| TTS / STT         | flutter_tts, speech_to_text             |

`pubspec.yaml` declara únicamente `android` e `ios`; web y desktop quedan fuera.

## 3. Arquitectura (feature-first)

```
lib/
  app/              # MaterialApp, theme, router
  core/             # capabilities, constants, utils
  data/
    db/             # Drift schema
    providers/      # adapters: ollama, huggingface, custom_url, openai_api
    repositories/
  features/
    settings/       # provider activo, carpeta modelos
    store/          # browse + filtros + descarga
    models/         # instalados, eliminar, info
    chat/           # UI, pill, slash
    inference/      # engine wrapper (llama.cpp)
    rag/            # indexer + retriever
  shared/widgets/
```

## 4. Modelo de datos (Drift)

- `providers` — id, type, base_url, api_key?, enabled (0/1).
- `models` — id, provider_id, remote_id, filename, size_bytes, capabilities_json, downloaded_path?, sha256?, downloaded_at?, metadata_json.
- `conversations` — id, model_id, title, created_at, updated_at.
- `messages` — id, conversation_id, role, content, tool_calls_json, created_at.
- `slash_commands` — id, name, description, prompt_template, required_capability.
- `app_settings` — key, value (incluye `models_dir`).

## 5. Providers (fuentes de modelos)

| Provider      | Función                                         | Endpoints                                  | Modo    |
| ------------- | ----------------------------------------------- | ------------------------------------------ | ------- |
| Ollama        | Listar y descargar modelos del registry Ollama  | `GET /api/tags`, `POST /api/pull`          | local   |
| HuggingFace   | Buscar y descargar GGUF                         | REST Hub + resolve URL                     | local*  |
| Custom URL    | URL directa a un `.gguf`                        | HTTP GET con progress                      | local*  |
| API           | OpenAI-compatible (LM Studio, llama.cpp server, OpenAI, Groq, etc.) | `/v1/models`, `/v1/chat/completions` | local o red |

\* Descarga al `models_dir` local.

**Solo un provider activo a la vez** para descargar/correlistar. Los providers tipo `API` admiten modo `local` o `red`, marcado con un badge visual "red" cuando la URL no es loopback/privada. Cambiar en Settings recarga la vista Store.

## 6. Vista Store

- Lista filtrada por tamaño ≤ 4 GB y arquitectura arm64.
- **Filtros de estado:** instalados, sin instalar, populares, nuevos.
- **Filtros de capacidad:** `text`, `tools`, `vision`, `image-generation`, `uncensored`, `tts`, `stt`, `embedding`, `code`.
- Capacidades extraídas de: manifest del provider (Ollama), model card de HF (`pipeline_tag` + heurísticas), o anotación manual en el registry local.
- Descarga con progress, validación SHA256, movimiento a `models_dir`.

## 7. Inferencia local

- **Android:** llama.cpp compilado para `arm64-v8a` (NDK), expuesto vía FFI. Backends: `cpu` (default), `vulkan`/`opencl` opcional.
- **iOS:** mismo binario con Metal habilitado. **Riesgo App Store:** la regla anti-JIT puede bloquear modelos que ejecuten código nativo descargado. Mitigación: distribuir por TestFlight/sideload, o pre-empaquetar pesos sin librerías nativas adicionales.
- Quantizaciones objetivo: Q4_K_M, Q5_K_M, Q6_K, Q8_0.
- Streaming token-a-token hacia el chat (SSE interno del engine, no del network).
- API mínima del wrapper:
  ```dart
  class InferenceEngine {
    Future<void> load(Model m, {int contextSize, int threads});
    Stream<String> generate(List<Message> history,
        {double temp, int topK, int topP});
    Future<void> unload();
  }
  ```

## 8. Chat

- UI tipo mensajería con markdown, copy, retry.
- **Pill selector** arriba: muestra el modelo activo; al tap, bottom-sheet con modelos instalados + métricas (size, ctx, quant).
- Historial por conversación persistido.
- Si el modelo activo tiene `vision`, botón de adjuntar imagen → input multimodal al engine.
- Soporte de stop generation y cancelación.

## 9. Slash commands y tools

**Dos modos, toggle global en Settings (`mode = manual | auto | both`):**

- **Manual (slash):** si el texto empieza con `/`, se matchea contra `slash_commands` (built-in + user-defined). Validación contra capabilities del modelo activo, con error inline si falta.
- **Automático (function calling):** el engine expone el tool schema al modelo. El modelo emite tool_calls; el client los ejecuta y re-inyecta el resultado. Formato: el que el engine devuelva (llama.cpp soporta JSON schema en `--json-schema`).
- **Both:** slash manual disponible encima del function calling automático.

Built-in slash mínimo:
- `/help` — lista comandos disponibles.
- `/model` — cambia el modelo activo.
- `/clear` — limpia la conversación actual.
- `/system <texto>` — edita el system prompt.
- `/vision <prompt>` — envía la última imagen adjunta (requiere `vision`).
- `/tts <texto>` — sintetiza la respuesta (requiere `tts`).
- `/stt` — transcribe audio del mic (requiere `stt`).
- `/rag <pregunta>` — consulta el índice RAG local (requiere `embedding`).
- `/summarize`, `/translate`, `/code` — prompts especializados, sin capability extra.

Tools automáticas built-in (registradas cuando el modelo declara `tools`):
- `get_current_time` — devuelve hora del dispositivo.
- `read_file(path, model_dir_only=true)` — lee un fichero dentro de `models_dir` o sandbox de la app.
- `list_files(dir)` — lista un directorio permitido.
- `search_files(query, dir)` — búsqueda por nombre.
- `web_search(query)` — solo si el provider activo es API en modo red.
- `image_generate(prompt)` — solo si el modelo activo tiene `image-generation`.
- `tts(text)` — solo si el modelo activo tiene `tts`.
- `stt(audio_ref)` — solo si el modelo activo tiene `stt`.

El usuario puede registrar slash commands propios (prompt template) y tools propias (declaración de nombre, descripción, JSON schema de parámetros, prompt template) en Settings.

## 10. Permisos

- **Android:** `INTERNET` (descargas), `READ_MEDIA_IMAGES` (adjuntar), `MANAGE_EXTERNAL_STORAGE` solo si el usuario elige carpeta fuera de la app; si no, scoped storage + SAF.
- **iOS:** `NSPhotoLibraryUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSMicrophoneUsageDescription`.

## 11. Fases

1. **Scaffold** — proyecto Flutter, plataformas, theme, Drift, router, settings básicos.
2. **Providers + Store** — adapters Ollama/HF/Custom/API, vista con filtros, descarga con progress.
3. **Inference engine** — FFI a llama.cpp, build NDK + CocoaPod, load/generate/streaming.
4. **Chat core** — UI, pill, history, model switch.
5. **Slash commands + tools** — registry, parser, validación de capabilities.
6. **Multimodal** — vision input, TTS salida, STT entrada.
7. **Polish** — onboarding, métricas en Store, manejo de errores, tests.

## 12. Riesgos principales

- **iOS JIT / App Store:** contenido descargado que ejecute código nativo es rechazado. Distribución por TestFlight o pre-empaquetar pesos.
- **RAM:** un 7B Q4 ≈ 5 GB. Recomendar ≤ 3B en devices de 6 GB, ≤ 1.5B en 4 GB.
- **Almacenamiento externo Android:** SAF obligatorio para carpetas fuera de la app; UX extra de permiso.
- **Capabilities desde HF:** tags no estandarizados → heurísticas + registry curado local.
- **GPU / vulkan:** comportamiento inconsistente entre devices. Default CPU multi-thread; GPU detrás de flag experimental.

## 13. RAG local

Indexación on-device de archivos del usuario. Sin servidor.

- **Chunking:** recursive con overlap configurable (default 512 tokens, overlap 64).
- **Embeddings:** usa el modelo activo si declara `embedding`; si no, requiere descargar un modelo de embedding dedicado (miniLM, bge-small) desde Store, marcado con capability `embedding`.
- **Almacenamiento del índice:** SQLite + vector index (hnswlib o vchord) dentro del sandbox de la app. Directorios origen configurables; default: `models_dir` + carpeta `Documents` seleccionada.
- **Slash command:** `/rag <pregunta>` (built-in). El contexto recuperado se inyecta en el system prompt con citas a los chunks.
- **Modo silent:** al activar, el chat envía primero la query al índice, top-k chunks, luego el modelo responde con grounding.
- **Privacidad:** el índice nunca sale del device. Borrar archivo origen = marcar chunks como huérfanos; purga manual en Settings.

## 14. Open questions resueltas

- ~~¿Provider "API" cubre solo local o también remoto?~~ **Ambos, badge "red" cuando la URL no es loopback/privada.**
- ~~¿Tools automáticas o solo slash?~~ **Ambos, toggle global `manual | auto | both`.**
- ~~¿RAG local?~~ **Sí, on-device con índice vectorial, slash `/rag` y modo silent.**
- ~~¿Marketplace social de slash?~~ **No, rompe el principio de no-perfiles. Solo local.**

## 15. Naming y branding

**Nombre de producto:** Stuko Plonk
**Tagline:** "your local AI, in your pocket"
**Repo:** `stuko-plonk`
**Dominio web:** stuko.dev (registrado en Cloudflare por el founder)

Decisión justificada:
- "Plonk" verificado: único resultado en Play Store es un juego de puzzles (nada AI), único repo en GitHub no relacionado (`nicolas-dufour/plonk`).
- Stuko Plonk combina el nickname del founder con un guiño onomatopéyico a "instalar y empezar a correr".
- En el launcher de Android/iOS el usuario ve "Stuko Plonk".

## 16. Arquitectura del proyecto

Decidido: **Feature-first monolito** con `core/` y `data/` compartidos. Cada feature se subdivide internamente en `data/domain/presentation`. Riverpod 2 como state management.

Justificación: el target es hardware mobile con recursos limitados, lo que hace innecesaria la indirección de Clean Architecture estricta. El monolito modular escala a 4-10 features sin fricción y, si en el futuro aparece sync o multi-device, se introduce Clean solo en las features que lo necesiten. El proyecto se inspira en "hermes agent-like" para mobile, lo que refuerza simplicidad sobre complejidad.

Ver detalle de estructura y reglas en sección 17.

## 17. Arquitectura del proyecto (detalle)

### 17.1 Opciones comparadas

| Opción                       | Pros                                                              | Contras                                                  | Cuándo encaja                                                  |
| ---------------------------- | ----------------------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------- |
| **Feature-first por capas**  | Navegable, escalable, separación clara, equipos por feature      | Más boilerplate al inicio                                | App grande, varios features, quieres testear feature aislado   |
| **Feature-first monolito**   | Simple, menos carpetas, dependencias explícitas                  | Acoplamiento si crece demasiado                          | App mediana (4-10 features), equipo chico                      |
| **Clean Architecture estricta** | Inversión de dependencias pura, dominio 100% testeable         | Mucha indirección para una app sin red                   | Dominio complejo con reglas de negocio densas                  |
| **BLoC modular por feature** | Eventos/estados explícitos, fácil debug                           | Verboso; muchos archivos chicos                          | Equipos grandes, integración con FlutterFire, devs juniors     |
| **Layered (UI/Services/Core)** | Plano, conocido                                                  | Features dispersos, alto acoplamiento entre capas       | Prototipos, MVPs cortos, scripts                               |

### 17.2 Estructura recomendada

```
lib/
  app/                      # MaterialApp, router, theme, DI
  core/                     # capabilities, errors, utils, constants
  data/
    db/                     # Drift schema + DAOs
    sources/                # HTTP clients por provider
    repositories/           # implementaciones
  features/
    settings/
      data/                 # repos locales
      domain/               # entities, use-cases
      presentation/         # widgets, controllers
    store/                  # browse, filtros, descarga
    models/                 # instalados
    chat/                   # UI, pill, slash parser
    inference/              # engine wrapper
    rag/                    # indexer, retriever
  shared/
    widgets/                # pill, model_card, capability_chip
    extensions/
```

- Cada feature autocontenido: `data/`, `domain/`, `presentation/`.
- Dependencias apuntan hacia adentro: presentation → domain → data.
- `core/` y `data/` son compartidos, no específicos de feature.
- `app/` solo hace wiring (Riverpod providers, go_router, MaterialApp).
- Regla: si un widget es usado por 2+ features, va a `shared/`, si no, vive dentro de la feature.

### 17.3 Estructura interna de cada feature

```
features/chat/
  data/
    chat_repository.dart
  domain/
    message.dart
    conversation.dart
  presentation/
    chat_screen.dart
    chat_controller.dart    # Riverpod
    widgets/
      message_bubble.dart
      model_pill.dart
```

- `domain` no importa Flutter (solo Dart puro).
- `data` implementa interfaces definidas en `domain`.
- `presentation` consume `domain` vía Riverpod; nunca importa `data` directo.

### 17.4 Por qué NO Clean Architecture estricta

- Una app 100% local sin backend no tiene inversión de dependencias significativa que defender.
- Las "entities" terminarían siendo DTOs con un rename.
- Coste de indirección sin beneficio claro a esta escala.
- Si en el futuro aparece sync o multi-device, se introduce Clean **solo en las features** que lo necesiten.

### 17.5 Si más adelante hay backend

Cuando aparezca un backend (sync, cuentas, telemetry opcional), el monolito modular escala así:

- Nuevo paquete `packages/api_client/` con cliente generado (OpenAPI/JSON-RPC).
- Las features que necesiten red añaden `data/remote/` y un repository que combina `local + remote`.
- El resto del código no se toca.

## 18. Naming y branding

### 18.1 Criterios

- Corto (1-2 sílabas idealmente, máximo 2 palabras).
- Pronunciable en ES y EN sin generar palabras no deseadas.
- Sin colisión con marcas existentes.
- Dominio `.app` o `.ai` disponible es un plus.
- Evitar nombres que impliquen comunidad, red, cuentas: rompe la promesa "local-only".

### 18.2 Candidatos evaluados

| Nombre          | Riesgo principal                              |
| --------------- | --------------------------------------------- |
| Kai             | Confusión con KaiOS, K.A.I.                   |
| Nodo            | Bastante ocupado en ES                        |
| Kore            | Confusión con Kore.ai (empresa real)          |
| Llama Mobile    | Marca Meta; problema legal                    |
| Edge            | Genérico, muchas marcas                       |
| Plonk           | Juego de mesa (verificado: sin colisión AI)   |
| Lume            | Existe Lume (salud mental)                    |
| Hearth          | Colisión con Hearthstone                      |
| Pocket          | Saturado                                      |
| Onyx            | Confusión con HP Onyx, Onyx Boox              |
| Nimbus          | Muy usado (AWS, Nimbus Notes)                 |
| LocalAI         | Existe proyecto OSS (mudler)                  |
| Glyph           | Algo usado                                    |
| Orb             | Saturado en cripto                            |
| Klein           | Original; botella Klein no es mainstream      |
| Stoa            | Original                                      |
| Nook            | Barnes & Noble Nook                           |

### 18.3 Decisión final: Stuko Plonk

- Verificado: único resultado en Play Store es un juego de puzzles, único repo en GitHub no relacionado.
- Combina el nickname del founder con un guiño onomatopéyico a "instalar y empezar a correr".
- Dominio stuko.dev registrado por el founder.
