import 'package:drift/drift.dart';

import '../db/database.dart';

/// Wire representation of an [Item], exchanged between devices during sync.
/// Kept separate from the drift row class so the network protocol doesn't
/// change shape every time the local DB schema does.
class ItemPayload {
  final String id;
  final String name;
  final String category;
  final String notes;
  final int quantity;
  final String versionId;
  final String? parentVersionId;
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;

  const ItemPayload({
    required this.id,
    required this.name,
    required this.category,
    required this.notes,
    required this.quantity,
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
  });

  factory ItemPayload.fromRow(Item row) => ItemPayload(
        id: row.id,
        name: row.name,
        category: row.category,
        notes: row.notes,
        quantity: row.quantity,
        versionId: row.versionId,
        parentVersionId: row.parentVersionId,
        parentVersionId2: row.parentVersionId2,
        updatedByDevice: row.updatedByDevice,
        updatedAt: row.updatedAt,
        deleted: row.deleted,
      );

  factory ItemPayload.fromJson(Map<String, dynamic> json) => ItemPayload(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        versionId: json['versionId'] as String,
        parentVersionId: json['parentVersionId'] as String?,
        parentVersionId2: json['parentVersionId2'] as String?,
        updatedByDevice: json['updatedByDevice'] as String,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          json['updatedAt'] as int,
          isUtc: true,
        ),
        deleted: json['deleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'notes': notes,
        'quantity': quantity,
        'versionId': versionId,
        'parentVersionId': parentVersionId,
        'parentVersionId2': parentVersionId2,
        'updatedByDevice': updatedByDevice,
        'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
        'deleted': deleted,
      };

  ItemsCompanion toCompanion() => ItemsCompanion.insert(
        id: id,
        name: name,
        category: Value(category),
        notes: Value(notes),
        quantity: Value(quantity),
        versionId: versionId,
        parentVersionId: Value(parentVersionId),
        parentVersionId2: Value(parentVersionId2),
        updatedByDevice: updatedByDevice,
        updatedAt: updatedAt,
        deleted: Value(deleted),
      );

  /// Whether this version was created directly from [ancestor] — i.e. it is
  /// safe to replace [ancestor] with this version without asking the user
  /// anything (a "fast-forward").
  bool isDirectSuccessorOf(ItemPayload ancestor) =>
      parentVersionId == ancestor.versionId ||
      parentVersionId2 == ancestor.versionId;
}
