import 'package:flutter_test/flutter_test.dart';

import 'package:stuko_plonk/core/capabilities.dart';

void main() {
  group('Capability', () {
    test('fromId returns matching enum', () {
      expect(Capability.fromId('text'), Capability.text);
      expect(Capability.fromId('vision'), Capability.vision);
      expect(Capability.fromId('image-generation'), Capability.imageGeneration);
    });

    test('fromId returns null for unknown id', () {
      expect(Capability.fromId('unknown'), isNull);
      expect(Capability.fromId(''), isNull);
    });

    test('every capability has a non-empty id and label', () {
      for (final c in Capability.values) {
        expect(c.id, isNotEmpty);
        expect(c.label, isNotEmpty);
      }
    });
  });
}
