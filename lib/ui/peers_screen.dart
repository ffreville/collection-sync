import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/sync_service.dart';
import 'conflict_resolution_screen.dart';
import 'qr_sync_screen.dart';
import 'review_changes_screen.dart';
import 'sync_history_screen.dart';

class PeersScreen extends StatelessWidget {
  const PeersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchroniser'),
        actions: [
          IconButton(
            tooltip: 'Historique',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SyncHistoryScreen()),
            ),
          ),
        ],
      ),
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
          if (sync.pendingChanges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReviewChangesScreen()),
                ),
                child: Text(
                  'Voir ${sync.pendingChanges.length} modification(s) proposée(s)',
                ),
              ),
            ),
          if (sync.totalConflicts > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ConflictResolutionScreen()),
                ),
                child: Text(
                  'Résoudre ${sync.totalConflicts} conflit(s)',
                ),
              ),
            ),
          const _QrPairingCard(),
          if (sync.lan.isSupported) ...[
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
                          .map((peer) => _PeerCard(peer: peer, sync: sync))
                          .toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pairing by QR code (WebRTC) — the only way for the web version, and a
/// fallback for the app when automatic discovery doesn't find the other
/// device (e.g. a browser on the other end, or a network blocking mDNS).
class _QrPairingCard extends StatelessWidget {
  const _QrPairingCard();

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final busy = sync.status == SyncStatus.connecting || sync.status == SyncStatus.syncing;
    void open(QrSyncRole role) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QrSyncScreen(role: role)),
        );
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Par QR code', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              sync.lan.isSupported
                  ? "Avec la version web, ou si l'autre appareil n'apparaît pas "
                      'ci-dessous. Même Wi-Fi requis.'
                  : "Avec l'application ou une autre version web, sur le même "
                      "Wi-Fi. L'un démarre, l'autre rejoint.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : () => open(QrSyncRole.start),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Démarrer une synchro'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => open(QrSyncRole.join),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Rejoindre une synchro'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A discovered device, expanded into one row per profile it hosts — each
/// with its own sync button, so you can pick which of its profiles to pull
/// from instead of syncing "the device" as a whole. See
/// [SyncService.syncWith]'s `focusProfileId`.
class _PeerCard extends StatelessWidget {
  final DiscoveredPeer peer;
  final SyncService sync;
  const _PeerCard({required this.peer, required this.sync});

  @override
  Widget build(BuildContext context) {
    final busy = sync.status == SyncStatus.connecting || sync.status == SyncStatus.syncing;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_iphone),
              title: Text(peer.deviceName),
              subtitle: Text('${peer.host}:${peer.port}'),
              trailing: FilledButton(
                onPressed: busy ? null : () => sync.syncWith(peer),
                child: const Text('Tout synchroniser'),
              ),
            ),
            if (peer.profiles.isNotEmpty) const Divider(height: 1),
            for (final profile in peer.profiles)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                leading: const Icon(Icons.person_outline),
                title: Text(profile.name),
                trailing: OutlinedButton(
                  onPressed: busy ? null : () => sync.syncWith(peer, focusProfileId: profile.id),
                  child: const Text('Synchroniser'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
