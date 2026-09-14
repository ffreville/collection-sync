import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/sync_service.dart';

class ConflictResolutionScreen extends StatelessWidget {
  const ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Conflits à résoudre')),
      body: sync.totalConflicts == 0
          ? const Center(child: Text('Aucun conflit restant ✅'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final conflict in List.of(sync.universeConflicts))
                  _ConflictCard(
                    kind: 'Univers',
                    title: conflict.local.name,
                    local: conflict.local.toJson(),
                    remote: conflict.remote.toJson(),
                    onKeepLocal: () => sync.resolveUniverseConflict(conflict, keepLocal: true),
                    onKeepRemote: () => sync.resolveUniverseConflict(conflict, keepLocal: false),
                  ),
                for (final conflict in List.of(sync.collectionConflicts))
                  _ConflictCard(
                    kind: 'Collection',
                    title: conflict.local.name,
                    local: conflict.local.toJson(),
                    remote: conflict.remote.toJson(),
                    onKeepLocal: () => sync.resolveCollectionConflict(conflict, keepLocal: true),
                    onKeepRemote: () => sync.resolveCollectionConflict(conflict, keepLocal: false),
                  ),
                for (final conflict in List.of(sync.itemConflicts))
                  _ConflictCard(
                    kind: 'Objet',
                    title: conflict.local.name,
                    local: conflict.local.toJson(),
                    remote: conflict.remote.toJson(),
                    onKeepLocal: () => sync.resolveItemConflict(conflict, keepLocal: true),
                    onKeepRemote: () => sync.resolveItemConflict(conflict, keepLocal: false),
                  ),
              ],
            ),
    );
  }
}

/// Fields that are sync/lineage bookkeeping rather than user content — not
/// worth showing in the diff.
const _hiddenFields = {
  'id',
  'ownerId',
  'universeId',
  'collectionId',
  'versionId',
  'parentVersionId',
  'parentVersionId2',
  'updatedByDevice',
  'updatedAt',
  'deleted',
  'schemaJson',
  'customValuesJson',
  'photoBase64',
};

class _ConflictCard extends StatelessWidget {
  final String kind;
  final String title;
  final Map<String, dynamic> local;
  final Map<String, dynamic> remote;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepRemote;

  const _ConflictCard({
    required this.kind,
    required this.title,
    required this.local,
    required this.remote,
    required this.onKeepLocal,
    required this.onKeepRemote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(label: Text(kind), visualDensity: VisualDensity.compact),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _VersionColumn(
                    label: 'Cet appareil',
                    fields: local,
                    onKeep: onKeepLocal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VersionColumn(
                    label: "L'autre appareil",
                    fields: remote,
                    onKeep: onKeepRemote,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  final String label;
  final Map<String, dynamic> fields;
  final VoidCallback onKeep;

  const _VersionColumn({required this.label, required this.fields, required this.onKeep});

  @override
  Widget build(BuildContext context) {
    final visible = fields.entries.where((e) => !_hiddenFields.contains(e.key));
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          for (final entry in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${entry.key} : ${entry.value ?? '—'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onKeep, child: const Text('Garder celui-ci')),
          ),
        ],
      ),
    );
  }
}
