import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../models/field_schema.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';
import 'item_edit_screen.dart';

class ItemsScreen extends StatefulWidget {
  final Collection collection;
  final bool isMine;

  const ItemsScreen({super.key, required this.collection, required this.isMine});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  bool _grid = true;
  String _query = '';
  String? _categoryFilter;
  String? _stateFilter;
  bool? _ownedFilter;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final sync = context.watch<SyncService>();
    final repo = ItemRepository(db: db, identity: sync.identity);
    final schema = CollectionSchema.decode(widget.collection.schemaJson);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: [
          IconButton(
            icon: Icon(_grid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher…',
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Tous')),
                      ButtonSegment(value: true, label: Text('Possédés')),
                      ButtonSegment(value: false, label: Text('Souhaités')),
                    ],
                    selected: {_ownedFilter},
                    onSelectionChanged: (selection) =>
                        setState(() => _ownedFilter = selection.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (schema.categories.isNotEmpty || schema.states.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  for (final category in schema.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _categoryFilter == category,
                        onSelected: (selected) =>
                            setState(() => _categoryFilter = selected ? category : null),
                      ),
                    ),
                  for (final state in schema.states)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(state),
                        selected: _stateFilter == state,
                        onSelected: (selected) =>
                            setState(() => _stateFilter = selected ? state : null),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: db.watchItemsOf(widget.collection.id),
              builder: (context, snapshot) {
                var items = snapshot.data ?? const [];
                items = items.where((item) {
                  if (_query.isNotEmpty && !item.name.toLowerCase().contains(_query)) {
                    return false;
                  }
                  if (_categoryFilter != null && item.category != _categoryFilter) return false;
                  if (_stateFilter != null && item.state != _stateFilter) return false;
                  if (_ownedFilter != null && item.owned != _ownedFilter) return false;
                  return true;
                }).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.isMine
                            ? "Aucun objet pour l'instant.\nAppuyez sur + pour en ajouter un."
                            : 'Aucun objet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _ItemGridCard(
                          item: items[index],
                          onTap: () => _open(context, items[index]),
                          onLongPress: widget.isMine
                              ? () => _confirmDelete(context, repo, items[index])
                              : null,
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: _ItemThumb(item: item),
                            title: Text(item.name),
                            subtitle: Text([
                              if (item.category.isNotEmpty) item.category,
                              '×${item.quantity}',
                            ].join(' · ')),
                            trailing: item.owned
                                ? null
                                : Chip(
                                    avatar: const Icon(Icons.star_border, size: 16),
                                    label: const Text('Souhaité'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                            onTap: () => _open(context, item),
                            onLongPress: widget.isMine ? () => _confirmDelete(context, repo, item) : null,
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isMine
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemEditScreen(collection: widget.collection, schema: schema),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _open(BuildContext context, Item item) {
    final schema = CollectionSchema.decode(widget.collection.schemaJson);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemEditScreen(
          collection: widget.collection,
          schema: schema,
          existing: item,
          readOnly: !widget.isMine,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ItemRepository repo, Item item) async {
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
    if (confirmed == true) await repo.delete(item);
  }
}

class _ItemThumb extends StatelessWidget {
  final Item item;
  const _ItemThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.photoBase64 != null) {
      return CircleAvatar(backgroundImage: MemoryImage(base64Decode(item.photoBase64!)));
    }
    return const CircleAvatar(child: Icon(Icons.inventory_2_outlined));
  }
}

class _ItemGridCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _ItemGridCard({required this.item, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wanted = !item.owned;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: wanted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.tertiary, width: 1.5, style: BorderStyle.solid),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    width: double.infinity,
                    color: scheme.secondaryContainer,
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: wanted ? 0.55 : 1,
                      child: item.photoBase64 != null
                          ? Image.memory(base64Decode(item.photoBase64!), fit: BoxFit.cover, width: double.infinity)
                          : Icon(Icons.inventory_2_outlined, color: scheme.secondary, size: 28),
                    ),
                  ),
                  if (wanted)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Chip(
                        avatar: Icon(Icons.star_border, size: 16, color: scheme.onTertiaryContainer),
                        label: const Text('Souhaité'),
                        labelStyle: TextStyle(color: scheme.onTertiaryContainer),
                        backgroundColor: scheme.tertiaryContainer,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(item.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                [if (item.category.isNotEmpty) item.category, '×${item.quantity}'].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
