import 'package:flutter/foundation.dart';

/// Stable string keys for [AppSettings] values. Avoid raw strings elsewhere.
abstract final class SettingsKeys {
  static const modelsDir = 'models_dir';
  static const activeProviderId = 'active_provider_id';
  static const activeModelId = 'active_model_id';
  static const toolMode = 'tool_mode'; // manual | auto | both
  static const themeMode = 'theme_mode'; // system | light | dark
  static const inferenceBackend = 'inference_backend'; // cpu | vulkan | metal
  static const inferenceThreads = 'inference_threads';
  static const inferenceContextSize = 'inference_context_size';
  static const ragEnabled = 'rag_enabled';
  static const ragDirectories = 'rag_directories'; // JSON array
  static const ragChunkSize = 'rag_chunk_size';
  static const ragChunkOverlap = 'rag_chunk_overlap';
  static const ragTopK = 'rag_top_k';
  static const ragEmbeddingModelId = 'rag_embedding_model_id';
}

@immutable
class AppSettings {
  const AppSettings({
    this.modelsDir,
    this.activeProviderId,
    this.activeModelId,
    this.toolMode = 'manual',
    this.themeMode = 'system',
    this.inferenceBackend = 'cpu',
    this.inferenceThreads = 4,
    this.inferenceContextSize = 4096,
    this.ragEnabled = false,
    this.ragDirectories = const [],
    this.ragChunkSize = 512,
    this.ragChunkOverlap = 64,
    this.ragTopK = 4,
    this.ragEmbeddingModelId,
  });

  final String? modelsDir;
  final String? activeProviderId;
  final String? activeModelId;
  final String toolMode;
  final String themeMode;
  final String inferenceBackend;
  final int inferenceThreads;
  final int inferenceContextSize;
  final bool ragEnabled;
  final List<String> ragDirectories;
  final int ragChunkSize;
  final int ragChunkOverlap;
  final int ragTopK;
  final String? ragEmbeddingModelId;

  AppSettings copyWith({
    Object? modelsDir = _sentinel,
    Object? activeProviderId = _sentinel,
    Object? activeModelId = _sentinel,
    String? toolMode,
    String? themeMode,
    String? inferenceBackend,
    int? inferenceThreads,
    int? inferenceContextSize,
    bool? ragEnabled,
    List<String>? ragDirectories,
    int? ragChunkSize,
    int? ragChunkOverlap,
    int? ragTopK,
    Object? ragEmbeddingModelId = _sentinel,
  }) {
    return AppSettings(
      modelsDir: identical(modelsDir, _sentinel)
          ? this.modelsDir
          : modelsDir as String?,
      activeProviderId: identical(activeProviderId, _sentinel)
          ? this.activeProviderId
          : activeProviderId as String?,
      activeModelId: identical(activeModelId, _sentinel)
          ? this.activeModelId
          : activeModelId as String?,
      toolMode: toolMode ?? this.toolMode,
      themeMode: themeMode ?? this.themeMode,
      inferenceBackend: inferenceBackend ?? this.inferenceBackend,
      inferenceThreads: inferenceThreads ?? this.inferenceThreads,
      inferenceContextSize: inferenceContextSize ?? this.inferenceContextSize,
      ragEnabled: ragEnabled ?? this.ragEnabled,
      ragDirectories: ragDirectories ?? this.ragDirectories,
      ragChunkSize: ragChunkSize ?? this.ragChunkSize,
      ragChunkOverlap: ragChunkOverlap ?? this.ragChunkOverlap,
      ragTopK: ragTopK ?? this.ragTopK,
      ragEmbeddingModelId: identical(ragEmbeddingModelId, _sentinel)
          ? this.ragEmbeddingModelId
          : ragEmbeddingModelId as String?,
    );
  }
}

const Object _sentinel = Object();
