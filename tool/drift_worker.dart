// Source of web/drift_worker.js, the web worker that hosts the sqlite3
// (WebAssembly) database on the web build. Rebuild after a drift upgrade:
//
//   dart compile js -O4 -o web/drift_worker.js tool/drift_worker.dart
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
