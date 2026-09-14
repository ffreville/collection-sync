/// Common shape shared by every entity that syncs between devices
/// (Universes, Collections, Items — see the payload classes next to this
/// file). Each carries a version lineage instead of a server-assigned
/// revision number, so two devices can decide who's ahead of whom without
/// ever talking to a server.
abstract class SyncEntity {
  String get id;
  String get versionId;
  String? get parentVersionId;
  String? get parentVersionId2;

  Map<String, dynamic> toJson();
}

extension SyncEntityLineage on SyncEntity {
  /// Whether this version was created directly from [ancestor] — i.e. it is
  /// safe to replace [ancestor] with this version without asking the user
  /// anything (a "fast-forward").
  bool isDirectSuccessorOf(SyncEntity ancestor) =>
      parentVersionId == ancestor.versionId || parentVersionId2 == ancestor.versionId;
}

/// What to do with an incoming [remote] version, given what we already have
/// locally (`null` when we don't have this entity at all yet).
enum MergeAction { applied, upToDate, conflict }

MergeAction decideMerge(SyncEntity? local, SyncEntity remote) {
  if (local == null) return MergeAction.applied;
  if (local.versionId == remote.versionId) return MergeAction.upToDate;
  if (remote.isDirectSuccessorOf(local)) return MergeAction.applied;
  if (local.isDirectSuccessorOf(remote)) return MergeAction.upToDate;
  return MergeAction.conflict;
}
