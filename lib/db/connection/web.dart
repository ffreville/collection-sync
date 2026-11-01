import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

/// Both files live in web/: sqlite3.wasm comes from the sqlite3.dart GitHub
/// release matching the `sqlite3` package version, drift_worker.js is
/// compiled from tool/drift_worker.dart. Relative URIs, so the app also works
/// when served from a sub-path (e.g. GitHub Pages' /collection-sync/).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'collection_sync',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    if (result.missingFeatures.isNotEmpty) {
      debugPrint('Web storage: using ${result.chosenImplementation}, '
          'missing ${result.missingFeatures}');
    }
    return result.resolvedExecutor;
  });
}
