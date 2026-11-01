// Opens the [AppDatabase] storage for the current platform: a sqlite file
// on iOS/Android (see native.dart), sqlite compiled to WebAssembly and kept
// in the browser's storage on the web build (see web.dart).
export 'native.dart' if (dart.library.js_interop) 'web.dart';
