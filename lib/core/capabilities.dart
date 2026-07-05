/// Capability flags that a model or feature can declare.
enum Capability {
  text('text', 'Text generation'),
  tools('tools', 'Tool / function calling'),
  vision('vision', 'Image input'),
  imageGeneration('image-generation', 'Image generation'),
  tts('tts', 'Text to speech'),
  stt('stt', 'Speech to text'),
  embedding('embedding', 'Embeddings for RAG'),
  code('code', 'Code-specialized'),
  uncensored('uncensored', 'Uncensored / abliterated');

  const Capability(this.id, this.label);

  final String id;
  final String label;

  static Capability? fromId(String id) {
    for (final c in Capability.values) {
      if (c.id == id) return c;
    }
    return null;
  }
}
