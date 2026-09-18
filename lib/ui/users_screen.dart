import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/sync_service.dart';
import 'conflict_resolution_screen.dart';
import 'peers_screen.dart';
import 'review_changes_screen.dart';
import 'universes_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: [
          if (sync.pendingChanges.isNotEmpty)
            IconButton(
              tooltip: '${sync.pendingChanges.length} modification(s) proposée(s)',
              icon: Badge(
                label: Text('${sync.pendingChanges.length}'),
                child: const Icon(Icons.playlist_add_check_outlined),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReviewChangesScreen()),
              ),
            ),
          if (sync.totalConflicts > 0)
            IconButton(
              tooltip: '${sync.totalConflicts} conflit(s) à résoudre',
              icon: Badge(
                label: Text('${sync.totalConflicts}'),
                child: const Icon(Icons.warning_amber_rounded),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConflictResolutionScreen()),
              ),
            ),
          IconButton(
            tooltip: 'Synchroniser',
            icon: const Icon(Icons.sync),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PeersScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<KnownUser>>(
        stream: db.watchKnownUsers(),
        builder: (context, snapshot) {
          final knownUsers = snapshot.data ?? const [];
          return ListView(
            children: [
              const _SectionLabel('Vous'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    sync.identity.name.isEmpty ? '?' : sync.identity.name[0].toUpperCase(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                title: Text(sync.identity.name),
                subtitle: const Text('Accès complet'),
                trailing: Chip(label: const Text('Vous')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UniversesScreen(
                      ownerId: sync.identity.id,
                      ownerName: sync.identity.name,
                      isMine: true,
                    ),
                  ),
                ),
              ),
              if (knownUsers.isNotEmpty) const _SectionLabel('Synchronisé avec vous'),
              for (final user in knownUsers)
                ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(sync.isOnline(user.id) ? 'En ligne' : 'Hors ligne'),
                  trailing: const Chip(label: Text('Lecture seule')),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UniversesScreen(
                        ownerId: user.id,
                        ownerName: user.name,
                        isMine: false,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PeersScreen()),
                  ),
                  icon: const Icon(Icons.sync),
                  label: const Text('Synchroniser un nouvel appareil'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
