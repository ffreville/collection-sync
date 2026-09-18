import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/pending_change.dart';
import '../sync/sync_service.dart';

class ReviewChangesScreen extends StatelessWidget {
  const ReviewChangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final changes = sync.pendingChanges;

    return Scaffold(
      appBar: AppBar(
        title: Text('${changes.length} modification(s) proposée(s)'),
        actions: [
          if (changes.isNotEmpty)
            TextButton(
              onPressed: () {
                sync.discardPendingChanges();
                Navigator.of(context).pop();
              },
              child: const Text('Tout ignorer'),
            ),
        ],
      ),
      body: changes.isEmpty
          ? const Center(child: Text('Aucune modification en attente ✅'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(title: 'Univers', kind: 'universe', changes: changes),
                _Section(title: 'Collections', kind: 'collection', changes: changes),
                _Section(title: 'Objets', kind: 'item', changes: changes),
              ],
            ),
      bottomNavigationBar: changes.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () async {
                    await sync.applySelectedPendingChanges();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(
                    'Appliquer la sélection (${changes.where((c) => c.selected).length})',
                  ),
                ),
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String kind;
  final List<PendingChange> changes;

  const _Section({required this.title, required this.kind, required this.changes});

  @override
  Widget build(BuildContext context) {
    final ofKind = changes.where((c) => c.kind == kind).toList();
    if (ofKind.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        for (final change in ofKind) _ChangeTile(change: change),
      ],
    );
  }
}

class _ChangeTile extends StatefulWidget {
  final PendingChange change;
  const _ChangeTile({required this.change});

  @override
  State<_ChangeTile> createState() => _ChangeTileState();
}

class _ChangeTileState extends State<_ChangeTile> {
  @override
  Widget build(BuildContext context) {
    final change = widget.change;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: change.selected,
        onChanged: (value) => setState(() => change.selected = value ?? true),
        title: Text(change.title),
        subtitle: Text([
          switch (change.action) {
            ChangeAction.created => 'Nouveau',
            ChangeAction.updated => 'Modifié',
            ChangeAction.deleted => 'Supprimé',
          },
          if (change.parentLabel != null && change.parentLabel!.isNotEmpty) change.parentLabel!,
        ].join(' · ')),
        secondary: Icon(switch (change.action) {
          ChangeAction.created => Icons.add_circle_outline,
          ChangeAction.updated => Icons.edit_outlined,
          ChangeAction.deleted => Icons.delete_outline,
        }),
      ),
    );
  }
}
