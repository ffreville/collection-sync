import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';
import '../utils/format.dart';

/// Everything the active profile wants but doesn't have yet, across every
/// universe/collection — with a one-tap "je l'ai reçu" and a share action
/// so the list can be sent to family for gift ideas.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();
    final repo = ItemRepository(db: db, identity: sync.identity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de souhaits'),
        actions: [
          StreamBuilder<List<ItemSearchResult>>(
            stream: db.watchWishlistOf(sync.identity.id),
            builder: (context, snapshot) {
              final results = snapshot.data ?? const [];
              return IconButton(
                tooltip: 'Partager',
                icon: const Icon(Icons.ios_share),
                onPressed: results.isEmpty ? null : () => _share(context, results),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ItemSearchResult>>(
        stream: db.watchWishlistOf(sync.identity.id),
        builder: (context, snapshot) {
          final results = snapshot.data ?? const [];
          if (results.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Aucun souhait pour l'instant.\nMarquez un objet comme "
                  '« Souhaité » depuis une collection pour le voir ici.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                leading: _Thumb(item: result.item),
                title: Text(result.item.name),
                subtitle: Text([
                  '${result.universeName} / ${result.collection.name}',
                  if (result.item.estimatedValue != null)
                    formatCurrency(result.item.estimatedValue!),
                ].join(' · ')),
                trailing: OutlinedButton.icon(
                  onPressed: () => repo.markOwned(result.item),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Reçu'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _share(BuildContext context, List<ItemSearchResult> results) async {
    final byGroup = <String, List<ItemSearchResult>>{};
    for (final result in results) {
      final key = '${result.universeName} / ${result.collection.name}';
      byGroup.putIfAbsent(key, () => []).add(result);
    }

    final buffer = StringBuffer('Ma liste de souhaits\n');
    for (final entry in byGroup.entries) {
      buffer.writeln('\n${entry.key}');
      for (final result in entry.value) {
        final value = result.item.estimatedValue != null
            ? ' (${formatCurrency(result.item.estimatedValue!)})'
            : '';
        buffer.writeln('- ${result.item.name}$value');
      }
    }

    await SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: 'Ma liste de souhaits'),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Item item;
  const _Thumb({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.photos.isNotEmpty) {
      return CircleAvatar(backgroundImage: MemoryImage(base64Decode(item.photos.first)));
    }
    return const CircleAvatar(child: Icon(Icons.star_border));
  }
}
