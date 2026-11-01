import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../database.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final file = await resolveDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
