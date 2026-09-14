import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/item_repository.dart';
import '../sync/sync_service.dart';
import 'conflict_resolution_screen.dart';
import 'item_edit_screen.dart';
import 'peers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();
    final repo = ItemRepository(db: db, identity: sync.identity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma collection'),
        actions: [
          if (sync.lastConflicts.isNotEmpty)
            IconButton(
              tooltip: '${sync.lastConflicts.length} conflit(s) à résoudre',
              icon: Badge(
                label: Text('${sync.lastConflicts.length}'),
                child: const Icon(Icons.warning_amber_rounded),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ConflictResolutionScreen()),
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
      body: StreamBuilder<List<Item>>(
        stream: db.watchActiveItems(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Aucun objet pour l'instant.\nAppuyez sur + pour en ajouter un.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: item.category.isEmpty
                    ? null
                    : Text(item.category),
                trailing: Text('×${item.quantity}'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemEditScreen(existing: item),
                  ),
                ),
                onLongPress: () => _confirmDelete(context, repo, item),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ItemEditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ItemRepository repo, Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet objet ?'),
        content: Text(item.name),
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
      await repo.deleteItem(item);
    }
  }
}
