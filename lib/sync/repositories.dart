import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/field_schema.dart';
import 'device_identity.dart';
import 'universe_payload.dart';
import 'collection_payload.dart';
import 'item_payload.dart';

/// Thrown when a write is attempted on content owned by another user. The
/// UI should never offer editing on such content, but every repository
/// checks anyway — see docs/spec-universes-collections.md §4.
class NotOwnerException implements Exception {
  @override
  String toString() => "Cannot modify content you don't own.";
}

void _assertOwned(String ownerId, DeviceIdentity identity) {
  if (ownerId != identity.id) throw NotOwnerException();
}

class UniverseRepository {
  final AppDatabase db;
  final DeviceIdentity identity;
  UniverseRepository({required this.db, required this.identity});

  Future<void> create({required String name}) async {
    final payload = UniversePayload(
      id: const Uuid().v4(),
      ownerId: identity.id,
      name: name,
      versionId: const Uuid().v4(),
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.universes).insert(payload.toCompanion());
  }

  Future<void> rename(Universe existing, String name) async {
    _assertOwned(existing.ownerId, identity);
    final payload = UniversePayload(
      id: existing.id,
      ownerId: existing.ownerId,
      name: name,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.universes).insertOnConflictUpdate(payload.toCompanion());
  }

  Future<void> delete(Universe existing) async {
    _assertOwned(existing.ownerId, identity);
    final payload = UniversePayload(
      id: existing.id,
      ownerId: existing.ownerId,
      name: existing.name,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: true,
    );
    await db.into(db.universes).insertOnConflictUpdate(payload.toCompanion());
  }
}

class CollectionRepository {
  final AppDatabase db;
  final DeviceIdentity identity;
  CollectionRepository({required this.db, required this.identity});

  Future<void> create({
    required Universe universe,
    required String name,
    required CollectionSchema schema,
  }) async {
    final payload = CollectionPayload(
      id: const Uuid().v4(),
      universeId: universe.id,
      ownerId: identity.id,
      name: name,
      schemaJson: schema.encode(),
      versionId: const Uuid().v4(),
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.collections).insert(payload.toCompanion());
  }

  Future<void> update(
    Collection existing, {
    required String name,
    required CollectionSchema schema,
  }) async {
    _assertOwned(existing.ownerId, identity);
    final payload = CollectionPayload(
      id: existing.id,
      universeId: existing.universeId,
      ownerId: existing.ownerId,
      name: name,
      schemaJson: schema.encode(),
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.collections).insertOnConflictUpdate(payload.toCompanion());
  }

  Future<void> delete(Collection existing) async {
    _assertOwned(existing.ownerId, identity);
    final payload = CollectionPayload(
      id: existing.id,
      universeId: existing.universeId,
      ownerId: existing.ownerId,
      name: existing.name,
      schemaJson: existing.schemaJson,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: true,
    );
    await db.into(db.collections).insertOnConflictUpdate(payload.toCompanion());
  }
}

class ItemRepository {
  final AppDatabase db;
  final DeviceIdentity identity;
  ItemRepository({required this.db, required this.identity});

  Future<void> create({
    required Collection collection,
    required String name,
    required String category,
    String? photoBase64,
    required int quantity,
    double? estimatedValue,
    required String state,
    required String notes,
    required Map<String, dynamic> customValues,
  }) async {
    final payload = ItemPayload(
      id: const Uuid().v4(),
      collectionId: collection.id,
      ownerId: identity.id,
      name: name,
      category: category,
      photoBase64: photoBase64,
      quantity: quantity,
      estimatedValue: estimatedValue,
      state: state,
      notes: notes,
      customValuesJson: _encodeValues(customValues),
      versionId: const Uuid().v4(),
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.items).insert(payload.toCompanion());
  }

  Future<void> update(
    Item existing, {
    required String name,
    required String category,
    String? photoBase64,
    required int quantity,
    double? estimatedValue,
    required String state,
    required String notes,
    required Map<String, dynamic> customValues,
  }) async {
    _assertOwned(existing.ownerId, identity);
    final payload = ItemPayload(
      id: existing.id,
      collectionId: existing.collectionId,
      ownerId: existing.ownerId,
      name: name,
      category: category,
      photoBase64: photoBase64,
      quantity: quantity,
      estimatedValue: estimatedValue,
      state: state,
      notes: notes,
      customValuesJson: _encodeValues(customValues),
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.items).insertOnConflictUpdate(payload.toCompanion());
  }

  Future<void> delete(Item existing) async {
    _assertOwned(existing.ownerId, identity);
    final payload = ItemPayload(
      id: existing.id,
      collectionId: existing.collectionId,
      ownerId: existing.ownerId,
      name: existing.name,
      category: existing.category,
      photoBase64: existing.photoBase64,
      quantity: existing.quantity,
      estimatedValue: existing.estimatedValue,
      state: existing.state,
      notes: existing.notes,
      customValuesJson: existing.customValuesJson,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: true,
    );
    await db.into(db.items).insertOnConflictUpdate(payload.toCompanion());
  }

  // Kept as a tiny helper so create/update/delete all encode the same way.
  static String _encodeValues(Map<String, dynamic> values) =>
      values.isEmpty ? '{}' : jsonEncode(values);
}
