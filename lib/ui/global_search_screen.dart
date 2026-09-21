import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../models/field_schema.dart';
import '../sync/sync_service.dart';
import '../utils/format.dart';
import 'item_edit_screen.dart';

/// Search across every universe/collection you can see — yours and whatever
/// peers have synced to you — instead of only within one collection.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Rechercher un objet…',
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        ),
      ),
      body: _query.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Recherchez un objet par son nom, dans tous vos univers et '
                  'collections (y compris ceux synchronisés).',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<List<ItemSearchResult>>(
              stream: db.watchAllItems(),
              builder: (context, snapshot) {
                final results = (snapshot.data ?? const [])
                    .where((r) => r.item.name.toLowerCase().contains(_query))
                    .toList();
                if (results.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucun objet ne correspond.'),
                    ),
                  );
                }
                return StreamBuilder<List<Profile>>(
                  stream: db.watchProfiles(),
                  builder: (context, profilesSnapshot) {
                    return StreamBuilder<List<KnownUser>>(
                      stream: db.watchKnownUsers(),
                      builder: (context, knownSnapshot) {
                        final ownerNames = <String, String>{
                          for (final p in profilesSnapshot.data ?? const <Profile>[]) p.id: p.name,
                          for (final u in knownSnapshot.data ?? const <KnownUser>[]) u.id: u.name,
                        };
                        return ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = results[index];
                            final isMine = result.item.ownerId == sync.identity.id;
                            final ownerName = ownerNames[result.item.ownerId] ?? '?';
                            return ListTile(
                              leading: _ResultThumb(item: result.item),
                              title: Text(result.item.name),
                              subtitle: Text(
                                '${result.universeName} / ${result.collection.name} · '
                                '${isMine ? 'vous' : ownerName}'
                                '${result.item.estimatedValue != null ? ' · ${formatCurrency(result.item.estimatedValue!)}' : ''}',
                              ),
                              trailing: result.item.owned
                                  ? null
                                  : const Icon(Icons.star_border),
                              onTap: () {
                                final schema = CollectionSchema.decode(result.collection.schemaJson);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ItemEditScreen(
                                      collection: result.collection,
                                      schema: schema,
                                      existing: result.item,
                                      readOnly: !isMine,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ResultThumb extends StatelessWidget {
  final Item item;
  const _ResultThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.photos.isNotEmpty) {
      return CircleAvatar(backgroundImage: MemoryImage(base64Decode(item.photos.first)));
    }
    return const CircleAvatar(child: Icon(Icons.inventory_2_outlined));
  }
}
