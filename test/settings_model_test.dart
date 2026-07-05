import 'package:flutter_test/flutter_test.dart';

import 'package:stuko_plonk/core/settings_model.dart';

void main() {
  group('AppSettings', () {
    test('defaults are sensible', () {
      const s = AppSettings();
      expect(s.toolMode, 'manual');
      expect(s.themeMode, 'system');
      expect(s.inferenceBackend, 'cpu');
      expect(s.inferenceThreads, 4);
      expect(s.inferenceContextSize, 4096);
      expect(s.ragEnabled, isFalse);
      expect(s.ragDirectories, isEmpty);
      expect(s.ragTopK, 4);
    });

    test('copyWith preserves unspecified values', () {
      const a = AppSettings(modelsDir: '/storage/models');
      final b = a.copyWith(activeProviderId: 'prov_1');
      expect(b.modelsDir, '/storage/models');
      expect(b.activeProviderId, 'prov_1');
      expect(b.toolMode, a.toolMode);
    });

    test('copyWith can null-out an optional field with sentinel', () {
      const a = AppSettings(activeModelId: 'm1');
      final b = a.copyWith(activeModelId: null);
      expect(b.activeModelId, isNull);
    });
  });
}
