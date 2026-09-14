import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// A single item in the user's collection.
///
/// Sync/versioning fields (used to merge changes coming from another device
/// without a server — see lib/sync/sync_service.dart):
///  - [versionId] changes every time the item is edited.
///  - [parentVersionId] / [parentVersionId2] point to the version(s) this one
///    was derived from. A normal edit has one parent (the previous version).
///    A manually-resolved conflict has two parents (the two versions the user
///    chose between), which lets both devices recognize the resolution as a
///    direct descendant of what they already have.
///  - [deleted] is a tombstone flag: deletions are just another edit, so they
///    sync and can conflict with a concurrent edit like anything else.
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  TextColumn get versionId => text()();
  TextColumn get parentVersionId => text().nullable()();
  TextColumn get parentVersionId2 => text().nullable()();
  TextColumn get updatedByDevice => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<Item>> watchActiveItems() {
    return (select(items)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<Item?> itemById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'collection_sync.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
