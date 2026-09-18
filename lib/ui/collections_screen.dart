import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';
import 'collection_editor_screen.dart';
import 'items_screen.dart';

class CollectionsScreen extends StatelessWidget {
  final Universe universe;
  final bool isMine;

  const CollectionsScreen({super.key, required this.universe, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();
    final repo = CollectionRepository(db: db, identity: sync.identity);

    return Scaffold(
      appBar: AppBar(title: Text(universe.name)),
      body: StreamBuilder<List<Collection>>(
        stream: db.watchCollectionsOf(universe.id),
        builder: (context, snapshot) {
          final collections = snapshot.data ?? const [];
          if (collections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isMine
                      ? "Aucune collection pour l'instant.\nAppuyez sur + pour en créer une."
                      : "Aucune collection dans cet univers.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: collections.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.style_outlined)),
                title: Text(collection.name),
                subtitle: StreamBuilder<int>(
                  stream: db.watchItemCountOf(collection.id),
                  builder: (context, countSnapshot) =>
                      Text('${countSnapshot.data ?? '…'} objets'),
                ),
                trailing: isMine
                    ? PopupMenuButton<_CollectionAction>(
                        onSelected: (action) => switch (action) {
                          _CollectionAction.edit => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CollectionEditorScreen(
                                  universe: universe,
                                  existing: collection,
                                ),
                              ),
                            ),
                          _CollectionAction.delete => _confirmDelete(context, repo, collection),
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _CollectionAction.edit,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Modifier'),
                            ),
                          ),
                          PopupMenuItem(
                            value: _CollectionAction.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Supprimer'),
                            ),
                          ),
                        ],
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemsScreen(collection: collection, isMine: isMine),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isMine
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CollectionEditorScreen(universe: universe),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, CollectionRepository repo, Collection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette collection ?'),
        content: Text('${collection.name} et tous ses objets seront supprimés sur cet appareil.'),
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
      await repo.delete(collection);
    }
  }
}

enum _CollectionAction { edit, delete }
