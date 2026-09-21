import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';
import 'conflict_resolution_screen.dart';
import 'global_search_screen.dart';
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
          IconButton(
            tooltip: 'Rechercher un objet',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
            ),
          ),
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
        builder: (context, knownSnapshot) {
          final knownUsers = knownSnapshot.data ?? const [];
          return StreamBuilder<List<Profile>>(
            stream: db.watchProfiles(),
            builder: (context, profileSnapshot) {
              final profiles = profileSnapshot.data ?? const [];
              return ListView(
                children: [
                  const _SectionLabel('Vos profils'),
                  for (final profile in profiles)
                    _ProfileTile(profile: profile, sync: sync),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _addProfile(context, db),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Ajouter un profil'),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Chip(label: Text('Lecture seule')),
                          IconButton(
                            tooltip: 'Oublier ce profil',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _forgetUser(context, db, user),
                          ),
                        ],
                      ),
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
          );
        },
      ),
    );
  }

  Future<void> _forgetUser(BuildContext context, AppDatabase db, KnownUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oublier ce profil ?'),
        content: Text(
          "${user.name} et tout ce qu'il vous a partagé (univers, collections, "
          "objets) seront retirés de cet appareil. Vous pourrez de nouveau "
          'synchroniser avec lui plus tard si besoin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oublier'),
          ),
        ],
      ),
    );
    if (confirmed == true) await db.forgetKnownUser(user.id);
  }

  Future<void> _addProfile(BuildContext context, AppDatabase db) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau profil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex. Camille'),
          onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ProfileRepository(db: db).create(name: name);
  }
}

class _ProfileTile extends StatelessWidget {
  final Profile profile;
  final SyncService sync;
  const _ProfileTile({required this.profile, required this.sync});

  @override
  Widget build(BuildContext context) {
    final isActive = profile.id == sync.identity.id;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isActive ? Theme.of(context).colorScheme.primary : null,
        child: Text(
          profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
          style: isActive
              ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
              : null,
        ),
      ),
      title: Text(profile.name),
      subtitle: Text(isActive ? 'Actif sur cet appareil' : 'Accès complet'),
      trailing: isActive
          ? const Chip(label: Text('Actif'))
          : TextButton(
              onPressed: () => sync.switchActiveProfile(profile),
              child: const Text('Activer'),
            ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UniversesScreen(
            ownerId: profile.id,
            ownerName: profile.name,
            isMine: isActive,
          ),
        ),
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
