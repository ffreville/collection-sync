import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'device_identity.dart';
import 'item_payload.dart';

/// Every local write goes through here, so that the version/parent
/// bookkeeping the sync protocol relies on (see sync_service.dart) is done
/// in exactly one place.
class ItemRepository {
  final AppDatabase db;
  final DeviceIdentity identity;

  ItemRepository({required this.db, required this.identity});

  Future<void> createItem({
    required String name,
    required String category,
    required String notes,
    required int quantity,
  }) async {
    final payload = ItemPayload(
      id: const Uuid().v4(),
      name: name,
      category: category,
      notes: notes,
      quantity: quantity,
      versionId: const Uuid().v4(),
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.items).insert(payload.toCompanion());
  }

  Future<void> updateItem(
    Item existing, {
    required String name,
    required String category,
    required String notes,
    required int quantity,
  }) async {
    final payload = ItemPayload(
      id: existing.id,
      name: name,
      category: category,
      notes: notes,
      quantity: quantity,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: false,
    );
    await db.into(db.items).insertOnConflictUpdate(payload.toCompanion());
  }

  /// Deletion is just another edit (a tombstone), so it can sync and
  /// conflict with a concurrent edit exactly like any other change.
  Future<void> deleteItem(Item existing) async {
    final payload = ItemPayload(
      id: existing.id,
      name: existing.name,
      category: existing.category,
      notes: existing.notes,
      quantity: existing.quantity,
      versionId: const Uuid().v4(),
      parentVersionId: existing.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: true,
    );
    await db.into(db.items).insertOnConflictUpdate(payload.toCompanion());
  }
}
