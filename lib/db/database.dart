import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Other people's profiles this device has synced with at least once — one
/// row per remote *profile* (not per device: a device can host several, see
/// [Profiles]). Not versioned: this is local bookkeeping about who we've
/// seen, not content that gets merged.
class KnownUsers extends Table {
  TextColumn get id => text()(); // their Profile.id
  TextColumn get name => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A local, fully read/write identity hosted on this device — see
/// docs/spec-universes-collections.md. A device can host several (e.g. one
/// per family member sharing a tablet); whichever is "active" (tracked by
/// DeviceIdentity, not stored here) owns whatever you create right now, but
/// every profile listed here stays fully editable regardless of which one is
/// active — switching is just about where *new* content goes.
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Shared version/lineage bookkeeping, mixed into every synced entity table
/// below. See lib/sync/entities.dart and lib/sync/sync_service.dart for how
/// these fields are used to merge changes between devices without a server.
mixin VersionedColumns on Table {
  TextColumn get versionId => text()();
  TextColumn get parentVersionId => text().nullable()();
  TextColumn get parentVersionId2 => text().nullable()();
  TextColumn get updatedByDevice => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

/// A themed grouping of collections (e.g. "Marvel", "Disney"), owned by one
/// user. Only its owner may edit it — see docs/spec-universes-collections.md.
class Universes extends Table with VersionedColumns {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A collection with a user-defined schema: which categories/states it
/// allows, and which custom fields its items carry. See
/// lib/models/field_schema.dart for the shape encoded in [schemaJson].
class Collections extends Table with VersionedColumns {
  TextColumn get id => text()();
  TextColumn get universeId => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get schemaJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// An object in a collection. The 7 default fields (see spec §3) are real
/// columns for fast list/search/sort; everything the collection's schema
/// adds beyond those lives in [customValuesJson] as {fieldKey: value}.
class Items extends Table with VersionedColumns {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get ownerId => text()();

  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get photoBase64 => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get estimatedValue => real().nullable()();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Whether you have this item, or just want it — an ordinary want-list
  /// entry rather than something you actually own. Kept as a real column
  /// (not a custom field) so every collection gets this distinction for free.
  BoolColumn get owned => boolean().withDefault(const Constant(true))();

  TextColumn get customValuesJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [KnownUsers, Profiles, Universes, Collections, Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<KnownUser>> watchKnownUsers() {
    return (select(knownUsers)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<Profile>> watchProfiles() {
    return (select(profiles)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<Profile?> profileById(String id) =>
      (select(profiles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Universe>> watchUniversesOf(String ownerId) {
    return (select(universes)
          ..where((t) => t.ownerId.equals(ownerId) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<Collection>> watchCollectionsOf(String universeId) {
    return (select(collections)
          ..where(
              (t) => t.universeId.equals(universeId) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// A live count, not a one-off `Future` — a `FutureBuilder` version of this
  /// only re-queries when its widget rebuilds, so it went stale whenever you
  /// added/removed an item and navigated back to the collections list.
  Stream<int> watchItemCountOf(String collectionId) {
    final countExp = countAll();
    final query = selectOnly(items)
      ..addColumns([countExp])
      ..where(items.collectionId.equals(collectionId) & items.deleted.equals(false));
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  Stream<List<Item>> watchItemsOf(String collectionId) {
    return (select(items)
          ..where(
              (t) => t.collectionId.equals(collectionId) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'collection_sync.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
