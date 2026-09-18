import 'package:drift/drift.dart';

import '../db/database.dart';
import 'entities.dart';

class CollectionPayload implements SyncEntity {
  @override
  final String id;
  final String universeId;
  @override
  final String ownerId;
  final String name;

  /// Raw JSON — see lib/models/field_schema.dart for the decoded shape.
  final String schemaJson;

  @override
  final String versionId;
  @override
  final String? parentVersionId;
  @override
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;

  const CollectionPayload({
    required this.id,
    required this.universeId,
    required this.ownerId,
    required this.name,
    required this.schemaJson,
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
  });

  factory CollectionPayload.fromRow(Collection row) => CollectionPayload(
        id: row.id,
        universeId: row.universeId,
        ownerId: row.ownerId,
        name: row.name,
        schemaJson: row.schemaJson,
        versionId: row.versionId,
        parentVersionId: row.parentVersionId,
        parentVersionId2: row.parentVersionId2,
        updatedByDevice: row.updatedByDevice,
        updatedAt: row.updatedAt,
        deleted: row.deleted,
      );

  factory CollectionPayload.fromJson(Map<String, dynamic> json) => CollectionPayload(
        id: json['id'] as String,
        universeId: json['universeId'] as String,
        ownerId: json['ownerId'] as String,
        name: json['name'] as String,
        schemaJson: json['schemaJson'] as String,
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
        'universeId': universeId,
        'ownerId': ownerId,
        'name': name,
        'schemaJson': schemaJson,
        'versionId': versionId,
        'parentVersionId': parentVersionId,
        'parentVersionId2': parentVersionId2,
        'updatedByDevice': updatedByDevice,
        'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
        'deleted': deleted,
      };

  CollectionsCompanion toCompanion() => CollectionsCompanion.insert(
        id: id,
        universeId: universeId,
        ownerId: ownerId,
        name: name,
        schemaJson: schemaJson,
        versionId: versionId,
        parentVersionId: Value(parentVersionId),
        parentVersionId2: Value(parentVersionId2),
        updatedByDevice: updatedByDevice,
        updatedAt: updatedAt,
        deleted: Value(deleted),
      );
}
