import 'package:drift/drift.dart';

import '../db/database.dart';
import 'entities.dart';

/// Wire representation of an [Item]. The 7 default fields are real
/// properties (see docs/spec-universes-collections.md §3); everything the
/// owning collection's schema adds on top travels as [customValuesJson].
class ItemPayload implements SyncEntity {
  @override
  final String id;
  final String collectionId;
  @override
  final String ownerId;

  final String name;
  final String category;
  final int quantity;
  final double? estimatedValue;
  final String state;
  final String notes;
  final bool owned;
  final String photosJson;
  final String customValuesJson;

  @override
  final String versionId;
  @override
  final String? parentVersionId;
  @override
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;

  const ItemPayload({
    required this.id,
    required this.collectionId,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.quantity,
    this.estimatedValue,
    required this.state,
    required this.notes,
    required this.owned,
    required this.photosJson,
    required this.customValuesJson,
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
  });

  factory ItemPayload.fromRow(Item row) => ItemPayload(
        id: row.id,
        collectionId: row.collectionId,
        ownerId: row.ownerId,
        name: row.name,
        category: row.category,
        quantity: row.quantity,
        estimatedValue: row.estimatedValue,
        state: row.state,
        notes: row.notes,
        owned: row.owned,
        photosJson: row.photosJson,
        customValuesJson: row.customValuesJson,
        versionId: row.versionId,
        parentVersionId: row.parentVersionId,
        parentVersionId2: row.parentVersionId2,
        updatedByDevice: row.updatedByDevice,
        updatedAt: row.updatedAt,
        deleted: row.deleted,
      );

  factory ItemPayload.fromJson(Map<String, dynamic> json) => ItemPayload(
        id: json['id'] as String,
        collectionId: json['collectionId'] as String,
        ownerId: json['ownerId'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        estimatedValue: (json['estimatedValue'] as num?)?.toDouble(),
        state: json['state'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        owned: json['owned'] as bool? ?? true,
        photosJson: json['photosJson'] as String? ?? '[]',
        customValuesJson: json['customValuesJson'] as String? ?? '{}',
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

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'collectionId': collectionId,
        'ownerId': ownerId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'estimatedValue': estimatedValue,
        'state': state,
        'notes': notes,
        'owned': owned,
        'photosJson': photosJson,
        'customValuesJson': customValuesJson,
        'versionId': versionId,
        'parentVersionId': parentVersionId,
        'parentVersionId2': parentVersionId2,
        'updatedByDevice': updatedByDevice,
        'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
        'deleted': deleted,
      };

  ItemsCompanion toCompanion() => ItemsCompanion.insert(
        id: id,
        collectionId: collectionId,
        ownerId: ownerId,
        name: name,
        category: Value(category),
        quantity: Value(quantity),
        estimatedValue: Value(estimatedValue),
        state: Value(state),
        notes: Value(notes),
        owned: Value(owned),
        photosJson: Value(photosJson),
        customValuesJson: Value(customValuesJson),
        versionId: versionId,
        parentVersionId: Value(parentVersionId),
        parentVersionId2: Value(parentVersionId2),
        updatedByDevice: updatedByDevice,
        updatedAt: updatedAt,
        deleted: Value(deleted),
      );
}
