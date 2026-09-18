import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';
import 'collections_screen.dart';

class UniversesScreen extends StatelessWidget {
  final String ownerId;
  final String ownerName;
  final bool isMine;

  const UniversesScreen({
    super.key,
    required this.ownerId,
    required this.ownerName,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();
    final repo = UniverseRepository(db: db, identity: sync.identity);

    return Scaffold(
      appBar: AppBar(
        title: Text(isMine ? 'Vos univers' : 'Univers de $ownerName'),
      ),
      body: StreamBuilder<List<Universe>>(
        stream: db.watchUniversesOf(ownerId),
        builder: (context, snapshot) {
          final universes = snapshot.data ?? const [];
          if (universes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isMine
                      ? "Aucun univers pour l'instant.\nAppuyez sur + pour en créer un."
                      : "$ownerName n'a encore aucun univers.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: universes.length,
            itemBuilder: (context, index) {
              final universe = universes[index];
              return _UniverseTile(
                universe: universe,
                isMine: isMine,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CollectionsScreen(universe: universe, isMine: isMine),
                  ),
                ),
                onRename: isMine ? () => _renameUniverse(context, repo, universe) : null,
                onDelete: isMine ? () => _confirmDelete(context, repo, universe) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: isMine
          ? FloatingActionButton(
              onPressed: () => _createUniverse(context, repo),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _createUniverse(BuildContext context, UniverseRepository repo) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel univers'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex. Marvel'),
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
    if (name != null && name.isNotEmpty) {
      await repo.create(name: name);
    }
  }

  Future<void> _renameUniverse(
      BuildContext context, UniverseRepository repo, Universe universe) async {
    final controller = TextEditingController(text: universe.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Renommer l'univers"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && name != universe.name) {
      await repo.rename(universe, name);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, UniverseRepository repo, Universe universe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet univers ?'),
        content: Text(
          '${universe.name} et toutes ses collections seront supprimés sur cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.delete(universe);
    }
  }
}

enum _UniverseAction { rename, delete }

class _UniverseTile extends StatelessWidget {
  final Universe universe;
  final bool isMine;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const _UniverseTile({
    required this.universe,
    required this.isMine,
    required this.onTap,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: scheme.primaryContainer,
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.auto_awesome_mosaic_outlined, color: scheme.primary, size: 32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Text(
                    universe.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (onRename != null || onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.85),
                shape: const CircleBorder(),
                child: PopupMenuButton<_UniverseAction>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (action) => switch (action) {
                    _UniverseAction.rename => onRename?.call(),
                    _UniverseAction.delete => onDelete?.call(),
                  },
                  itemBuilder: (context) => [
                    if (onRename != null)
                      const PopupMenuItem(
                        value: _UniverseAction.rename,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Renommer'),
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: _UniverseAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Supprimer'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
