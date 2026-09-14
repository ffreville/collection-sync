import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../sync/item_repository.dart';
import '../sync/sync_service.dart';

class ItemEditScreen extends StatefulWidget {
  final Item? existing;

  const ItemEditScreen({super.key, this.existing});

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _categoryController =
        TextEditingController(text: existing?.category ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _quantityController =
        TextEditingController(text: '${existing?.quantity ?? 1}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier l'objet" : 'Nouvel objet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n < 0) ? 'Nombre invalide' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final sync = context.read<SyncService>();
    final repo = ItemRepository(db: db, identity: sync.identity);

    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final notes = _notesController.text.trim();
    final quantity = int.parse(_quantityController.text);

    final existing = widget.existing;
    if (existing == null) {
      await repo.createItem(
        name: name,
        category: category,
        notes: notes,
        quantity: quantity,
      );
    } else {
      await repo.updateItem(
        existing,
        name: name,
        category: category,
        notes: notes,
        quantity: quantity,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
