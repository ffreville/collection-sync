import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/item_payload.dart';
import '../sync/sync_service.dart';

class ConflictResolutionScreen extends StatelessWidget {
  const ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final conflicts = sync.lastConflicts;

    return Scaffold(
      appBar: AppBar(title: const Text('Conflits à résoudre')),
      body: conflicts.isEmpty
          ? const Center(child: Text('Aucun conflit restant ✅'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: conflicts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conflict.local.name.isEmpty
                              ? conflict.remote.name
                              : conflict.local.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _VersionCard(
                                label: 'Cet appareil',
                                item: conflict.local,
                                onKeep: () => sync.resolveConflict(
                                  conflict,
                                  keepLocal: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _VersionCard(
                                label: "L'autre appareil",
                                item: conflict.remote,
                                onKeep: () => sync.resolveConflict(
                                  conflict,
                                  keepLocal: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String label;
  final ItemPayload item;
  final VoidCallback onKeep;

  const _VersionCard({
    required this.label,
    required this.item,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
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
          if (item.deleted)
            const Text('(supprimé)', style: TextStyle(fontStyle: FontStyle.italic))
          else ...[
            Text('Nom : ${item.name}'),
            if (item.category.isNotEmpty) Text('Catégorie : ${item.category}'),
            Text('Quantité : ${item.quantity}'),
            if (item.notes.isNotEmpty) Text('Notes : ${item.notes}'),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onKeep,
              child: const Text('Garder celui-ci'),
            ),
          ),
        ],
      ),
    );
  }
}
