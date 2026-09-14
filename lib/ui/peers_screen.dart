import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/sync_service.dart';
import 'conflict_resolution_screen.dart';

class PeersScreen extends StatelessWidget {
  const PeersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Synchroniser')),
      body: Column(
        children: [
          if (sync.statusMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (sync.status == SyncStatus.connecting ||
                      sync.status == SyncStatus.syncing)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(child: Text(sync.statusMessage!)),
                ],
              ),
            ),
          if (sync.lastConflicts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ConflictResolutionScreen()),
                ),
                child: Text(
                  'Résoudre ${sync.lastConflicts.length} conflit(s)',
                ),
              ),
            ),
          const Divider(height: 32),
          Expanded(
            child: sync.peers.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "Recherche d'appareils sur le même réseau Wi-Fi...\n"
                        "Ouvrez l'app sur l'autre téléphone et vérifiez qu'il "
                        "est sur le même Wi-Fi.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    children: sync.peers
                        .map((peer) => ListTile(
                              leading: const Icon(Icons.phone_iphone),
                              title: Text(peer.deviceName),
                              subtitle: Text('${peer.host}:${peer.port}'),
                              trailing: FilledButton(
                                onPressed:
                                    sync.status == SyncStatus.connecting ||
                                            sync.status == SyncStatus.syncing
                                        ? null
                                        : () => sync.syncWith(peer),
                                child: const Text('Synchroniser'),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
