import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final log = Logger('stuko_plonk');

void initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    debugPrint(
      '${rec.time.toIso8601String()} ${rec.level.name.padRight(7)} '
      '${rec.loggerName}: ${rec.message}',
    );
  });
}
