import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../models/field_schema.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';

class CollectionEditorScreen extends StatefulWidget {
  final Universe universe;
  final Collection? existing;

  const CollectionEditorScreen({super.key, required this.universe, this.existing});

  @override
  State<CollectionEditorScreen> createState() => _CollectionEditorScreenState();
}

class _CollectionEditorScreenState extends State<CollectionEditorScreen> {
  late final TextEditingController _nameController;
  late List<String> _categories;
  late List<String> _states;
  late List<FieldDefinition> _customFields;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final schema = existing != null
        ? CollectionSchema.decode(existing.schemaJson)
        : CollectionSchema.empty();
    _nameController = TextEditingController(text: existing?.name ?? '');
    _categories = List.of(schema.categories);
    _states = List.of(schema.states);
    _customFields = List.of(schema.customFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la collection' : 'Nouvelle collection'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom de la collection'),
          ),
          const SizedBox(height: 20),
          _ChipEditorSection(
            label: 'Catégories',
            values: _categories,
            onChanged: (v) => setState(() => _categories = v),
          ),
          const SizedBox(height: 20),
          _ChipEditorSection(
            label: 'États',
            values: _states,
            onChanged: (v) => setState(() => _states = v),
          ),
          const SizedBox(height: 20),
          Text('Champs personnalisés', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final field in _customFields)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Icon(_iconFor(field.type))),
                title: Text(field.label),
                subtitle: Text(field.type.label),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _customFields.remove(field)),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un champ'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(FieldType type) => switch (type) {
        FieldType.text => Icons.short_text,
        FieldType.longText => Icons.notes,
        FieldType.integer => Icons.numbers,
        FieldType.decimal => Icons.pin,
        FieldType.boolean => Icons.check_box_outlined,
        FieldType.date => Icons.calendar_today_outlined,
        FieldType.singleChoice => Icons.list_alt,
        FieldType.photo => Icons.photo_camera_outlined,
        FieldType.url => Icons.link,
      };

  Future<void> _addField() async {
    final field = await showDialog<FieldDefinition>(
      context: context,
      builder: (context) => const _AddFieldDialog(),
    );
    if (field != null) setState(() => _customFields.add(field));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final db = context.read<AppDatabase>();
    final sync = context.read<SyncService>();
    final repo = CollectionRepository(db: db, identity: sync.identity);
    final schema = CollectionSchema(
      categories: _categories,
      states: _states,
      customFields: _customFields,
    );
    final existing = widget.existing;
    if (existing == null) {
      await repo.create(universe: widget.universe, name: name, schema: schema);
    } else {
      await repo.update(existing, name: name, schema: schema);
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _ChipEditorSection extends StatelessWidget {
  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _ChipEditorSection({required this.label, required this.values, required this.onChanged});

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter — $label'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty && !values.contains(value)) {
      onChanged([...values, value]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              Chip(
                label: Text(value),
                onDeleted: () => onChanged(values.where((v) => v != value).toList()),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              onPressed: () => _add(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddFieldDialog extends StatefulWidget {
  const _AddFieldDialog();

  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final _labelController = TextEditingController();
  FieldType _type = FieldType.text;
  List<String> _options = [];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau champ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _labelController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Libellé'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FieldType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final type in FieldType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (v) => setState(() => _type = v ?? FieldType.text),
          ),
          if (_type == FieldType.singleChoice) ...[
            const SizedBox(height: 12),
            _ChipEditorSection(
              label: 'Options',
              values: _options,
              onChanged: (v) => setState(() => _options = v),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) return;
            final key = label
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                .replaceAll(RegExp(r'^_+|_+$'), '');
            Navigator.of(context).pop(FieldDefinition(
              key: key.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : key,
              label: label,
              type: _type,
              options: _options,
            ));
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
