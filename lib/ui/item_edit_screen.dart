import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';
import '../models/field_schema.dart';
import '../sync/repositories.dart';
import '../sync/sync_service.dart';

class ItemEditScreen extends StatefulWidget {
  final Collection collection;
  final CollectionSchema schema;
  final Item? existing;
  final bool readOnly;

  const ItemEditScreen({
    super.key,
    required this.collection,
    required this.schema,
    this.existing,
    this.readOnly = false,
  });

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _valueController;
  late final TextEditingController _notesController;
  String? _category;
  String? _state;
  String? _photoBase64;
  bool _owned = true;

  late Map<String, dynamic> _customValues;
  final Map<String, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _quantityController = TextEditingController(text: '${existing?.quantity ?? 1}');
    _valueController = TextEditingController(text: existing?.estimatedValue?.toString() ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _category = existing != null && existing.category.isNotEmpty ? existing.category : null;
    _state = existing != null && existing.state.isNotEmpty ? existing.state : null;
    _photoBase64 = existing?.photoBase64;
    _owned = existing?.owned ?? true;
    _customValues = existing != null
        ? Map<String, dynamic>.from(jsonDecode(existing.customValuesJson) as Map)
        : {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key) {
    return _customControllers.putIfAbsent(
      key,
      () => TextEditingController(text: _customValues[key]?.toString() ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? widget.existing!.name : (isEditing ? "Modifier l'objet" : 'Nouvel objet')),
        actions: [
          if (!widget.readOnly && isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: _delete,
            ),
          if (!widget.readOnly) TextButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
      body: AbsorbPointer(
        absorbing: widget.readOnly,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PhotoPicker(
              base64: _photoBase64,
              onPick: widget.readOnly ? null : _pickPhoto,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Possédé'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Souhaité'),
                  icon: Icon(Icons.star_border),
                ),
              ],
              selected: {_owned},
              onSelectionChanged: widget.readOnly
                  ? null
                  : (selection) => setState(() => _owned = selection.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                    items: [
                      for (final category in widget.schema.categories)
                        DropdownMenuItem(value: category, child: Text(category)),
                    ],
                    onChanged: widget.readOnly ? null : (v) => setState(() => _category = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _state,
                    decoration: const InputDecoration(labelText: 'État'),
                    items: [
                      for (final state in widget.schema.states)
                        DropdownMenuItem(value: state, child: Text(state)),
                    ],
                    onChanged: widget.readOnly ? null : (v) => setState(() => _state = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(labelText: 'Valeur estimée'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
            ),
            if (widget.schema.customFields.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text('Détails', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              for (final field in widget.schema.customFields) ...[
                _buildCustomField(field),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField(FieldDefinition field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.url:
        return TextField(
          controller: _controllerFor(field.key),
          decoration: InputDecoration(labelText: field.label),
          keyboardType: field.type == FieldType.url ? TextInputType.url : TextInputType.text,
        );
      case FieldType.longText:
        return TextField(
          controller: _controllerFor(field.key),
          decoration: InputDecoration(labelText: field.label),
          maxLines: 3,
        );
      case FieldType.integer:
        return TextField(
          controller: _controllerFor(field.key),
          decoration: InputDecoration(labelText: field.label),
          keyboardType: TextInputType.number,
        );
      case FieldType.decimal:
        return TextField(
          controller: _controllerFor(field.key),
          decoration: InputDecoration(labelText: field.label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        );
      case FieldType.boolean:
        final value = _customValues[field.key] == true;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          value: value,
          onChanged: widget.readOnly ? null : (v) => setState(() => _customValues[field.key] = v),
        );
      case FieldType.date:
        final iso = _customValues[field.key] as String?;
        final date = iso != null ? DateTime.tryParse(iso) : null;
        return InkWell(
          onTap: widget.readOnly ? null : () => _pickDate(field.key, date),
          child: InputDecorator(
            decoration: InputDecoration(labelText: field.label),
            child: Text(date != null ? _formatDate(date) : '—'),
          ),
        );
      case FieldType.singleChoice:
        return DropdownButtonFormField<String>(
          initialValue: _customValues[field.key] as String?,
          decoration: InputDecoration(labelText: field.label),
          items: [
            for (final option in field.options) DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: widget.readOnly ? null : (v) => setState(() => _customValues[field.key] = v),
        );
      case FieldType.photo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _PhotoPicker(
              base64: _customValues[field.key] as String?,
              onPick: widget.readOnly
                  ? null
                  : () async {
                      final b64 = await _pickImageBase64();
                      if (b64 != null) setState(() => _customValues[field.key] = b64);
                    },
              compact: true,
            ),
          ],
        );
      case FieldType.file:
        final value = _customValues[field.key] as Map<String, dynamic>?;
        final fileName = value?['name'] as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: widget.readOnly ? null : () => _pickFile(field.key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName ?? 'Aucun fichier',
                        overflow: TextOverflow.ellipsis,
                        style: fileName == null
                            ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
                            : null,
                      ),
                    ),
                    if (fileName != null && !widget.readOnly)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _customValues[field.key] = null),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Future<void> _pickDate(String key, DateTime? initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _customValues[key] = picked.toIso8601String());
    }
  }

  /// Files are embedded as base64 in the sync payload, same mechanism as
  /// photo — practical on a fast local Wi-Fi, but note this means a large
  /// file bloats that sync message; there's no chunked transfer yet (see
  /// docs/spec-universes-collections.md §5).
  Future<void> _pickFile(String key) async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _customValues[key] = {'name': picked.name, 'base64': base64Encode(bytes)};
    });
  }

  Future<String?> _pickImageBase64() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 82,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _pickPhoto() async {
    final b64 = await _pickImageBase64();
    if (b64 != null) setState(() => _photoBase64 = b64);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final db = context.read<AppDatabase>();
    final sync = context.read<SyncService>();
    final repo = ItemRepository(db: db, identity: sync.identity);

    for (final field in widget.schema.customFields) {
      switch (field.type) {
        case FieldType.text:
        case FieldType.longText:
        case FieldType.url:
          _customValues[field.key] = _controllerFor(field.key).text.trim();
        case FieldType.integer:
          _customValues[field.key] = int.tryParse(_controllerFor(field.key).text.trim());
        case FieldType.decimal:
          _customValues[field.key] = double.tryParse(_controllerFor(field.key).text.trim());
        case FieldType.boolean:
        case FieldType.date:
        case FieldType.singleChoice:
        case FieldType.photo:
        case FieldType.file:
          break; // already kept up to date in _customValues directly
      }
    }

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final estimatedValue = double.tryParse(_valueController.text.trim().replaceAll(',', '.'));

    final existing = widget.existing;
    if (existing == null) {
      await repo.create(
        collection: widget.collection,
        name: name,
        category: _category ?? '',
        photoBase64: _photoBase64,
        quantity: quantity,
        estimatedValue: estimatedValue,
        state: _state ?? '',
        notes: _notesController.text.trim(),
        owned: _owned,
        customValues: _customValues,
      );
    } else {
      await repo.update(
        existing,
        name: name,
        category: _category ?? '',
        photoBase64: _photoBase64,
        quantity: quantity,
        estimatedValue: estimatedValue,
        state: _state ?? '',
        notes: _notesController.text.trim(),
        owned: _owned,
        customValues: _customValues,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet objet ?'),
        content: Text(existing.name),
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
    if (confirmed != true || !mounted) return;
    final db = context.read<AppDatabase>();
    final sync = context.read<SyncService>();
    await ItemRepository(db: db, identity: sync.identity).delete(existing);
    if (mounted) Navigator.of(context).pop();
  }
}

class _PhotoPicker extends StatelessWidget {
  final String? base64;
  final VoidCallback? onPick;
  final bool compact;

  const _PhotoPicker({required this.base64, required this.onPick, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: compact ? 100 : 180,
        width: compact ? 100 : double.infinity,
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          image: base64 != null
              ? DecorationImage(image: MemoryImage(base64Decode(base64!)), fit: BoxFit.cover)
              : null,
        ),
        alignment: Alignment.center,
        child: base64 == null
            ? Icon(Icons.add_a_photo_outlined, color: scheme.secondary)
            : (onPick != null
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                : null),
      ),
    );
  }
}
