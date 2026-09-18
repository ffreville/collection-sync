/// One change proposed by a sync session that the *initiating* device holds
/// back for the user to accept or ignore, rather than applying silently —
/// see docs/spec-universes-collections.md and SyncService._runSyncSession.
///
/// Only changes to content owned by the *other* person go through this: the
/// device that received the incoming connection still applies everything
/// automatically, exactly as before, and so does content you own yourself
/// (there's nothing to "review" about your own edits catching up on a peer's
/// mirror of them).
enum ChangeAction { created, updated, deleted }

class PendingChange {
  final String kind; // 'universe' | 'collection' | 'item'
  final ChangeAction action;
  final String title;

  /// Where this lives, for display — e.g. a collection's parent universe
  /// name, or an item's "Univers / Collection" — null for a universe itself.
  final String? parentLabel;

  final Future<void> Function() applyChange;

  bool selected = true;

  PendingChange({
    required this.kind,
    required this.action,
    required this.title,
    required this.applyChange,
    this.parentLabel,
  });
}
