import 'package:drift/drift.dart';

import '../db/database.dart';
import 'entities.dart';

class UniversePayload implements SyncEntity {
  @override
  final String id;
  @override
  final String ownerId;
  final String name;
  @override
  final String versionId;
  @override
  final String? parentVersionId;
  @override
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;

  const UniversePayload({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
  });

  factory UniversePayload.fromRow(Universe row) => UniversePayload(
        id: row.id,
        ownerId: row.ownerId,
        name: row.name,
        versionId: row.versionId,
        parentVersionId: row.parentVersionId,
        parentVersionId2: row.parentVersionId2,
        updatedByDevice: row.updatedByDevice,
        updatedAt: row.updatedAt,
        deleted: row.deleted,
      );

  factory UniversePayload.fromJson(Map<String, dynamic> json) => UniversePayload(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        name: json['name'] as String,
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
        'ownerId': ownerId,
        'name': name,
        'versionId': versionId,
        'parentVersionId': parentVersionId,
        'parentVersionId2': parentVersionId2,
        'updatedByDevice': updatedByDevice,
        'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
        'deleted': deleted,
      };

  UniversesCompanion toCompanion() => UniversesCompanion.insert(
        id: id,
        ownerId: ownerId,
        name: name,
        versionId: versionId,
        parentVersionId: Value(parentVersionId),
        parentVersionId2: Value(parentVersionId2),
        updatedByDevice: updatedByDevice,
        updatedAt: updatedAt,
        deleted: Value(deleted),
      );
}
