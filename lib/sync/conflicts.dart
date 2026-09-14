import 'collection_payload.dart';
import 'item_payload.dart';
import 'universe_payload.dart';

/// A pair of versions that diverged (both were edited independently since
/// they last agreed) and that the user must pick between by hand — see
/// SyncService._applyIncoming and ConflictResolutionScreen.
class UniverseConflict {
  final UniversePayload local;
  final UniversePayload remote;
  const UniverseConflict({required this.local, required this.remote});
}

class CollectionConflict {
  final CollectionPayload local;
  final CollectionPayload remote;
  const CollectionConflict({required this.local, required this.remote});
}

class ItemConflict {
  final ItemPayload local;
  final ItemPayload remote;
  const ItemConflict({required this.local, required this.remote});
}
