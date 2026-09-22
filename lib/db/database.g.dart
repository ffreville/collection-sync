// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $KnownUsersTable extends KnownUsers
    with TableInfo<$KnownUsersTable, KnownUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnownUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'known_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnownUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnownUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnownUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $KnownUsersTable createAlias(String alias) {
    return $KnownUsersTable(attachedDatabase, alias);
  }
}

class KnownUser extends DataClass implements Insertable<KnownUser> {
  final String id;
  final String name;
  final DateTime lastSyncedAt;
  const KnownUser({
    required this.id,
    required this.name,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  KnownUsersCompanion toCompanion(bool nullToAbsent) {
    return KnownUsersCompanion(
      id: Value(id),
      name: Value(name),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory KnownUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnownUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  KnownUser copyWith({String? id, String? name, DateTime? lastSyncedAt}) =>
      KnownUser(
        id: id ?? this.id,
        name: name ?? this.name,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
  KnownUser copyWithCompanion(KnownUsersCompanion data) {
    return KnownUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class KnownUsersCompanion extends UpdateCompanion<KnownUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const KnownUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnownUsersCompanion.insert({
    required String id,
    required String name,
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<KnownUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnownUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return KnownUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String name;
  final DateTime createdAt;
  const Profile({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith({String? id, String? name, DateTime? createdAt}) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UniversesTable extends Universes
    with TableInfo<$UniversesTable, Universe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentVersionIdMeta = const VerificationMeta(
    'parentVersionId',
  );
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
    'parent_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentVersionId2Meta = const VerificationMeta(
    'parentVersionId2',
  );
  @override
  late final GeneratedColumn<String> parentVersionId2 = GeneratedColumn<String>(
    'parent_version_id2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    ownerId,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Universe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
        _parentVersionIdMeta,
        parentVersionId.isAcceptableOrUnknown(
          data['parent_version_id']!,
          _parentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_version_id2')) {
      context.handle(
        _parentVersionId2Meta,
        parentVersionId2.isAcceptableOrUnknown(
          data['parent_version_id2']!,
          _parentVersionId2Meta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedByDeviceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Universe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Universe(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      parentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id'],
      ),
      parentVersionId2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id2'],
      ),
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $UniversesTable createAlias(String alias) {
    return $UniversesTable(attachedDatabase, alias);
  }
}

class Universe extends DataClass implements Insertable<Universe> {
  final String versionId;
  final String? parentVersionId;
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;
  final String id;
  final String ownerId;
  final String name;
  const Universe({
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
    required this.id,
    required this.ownerId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(versionId);
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    if (!nullToAbsent || parentVersionId2 != null) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2);
    }
    map['updated_by_device'] = Variable<String>(updatedByDevice);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    return map;
  }

  UniversesCompanion toCompanion(bool nullToAbsent) {
    return UniversesCompanion(
      versionId: Value(versionId),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      parentVersionId2: parentVersionId2 == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId2),
      updatedByDevice: Value(updatedByDevice),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
    );
  }

  factory Universe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Universe(
      versionId: serializer.fromJson<String>(json['versionId']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      parentVersionId2: serializer.fromJson<String?>(json['parentVersionId2']),
      updatedByDevice: serializer.fromJson<String>(json['updatedByDevice']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<String>(versionId),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'parentVersionId2': serializer.toJson<String?>(parentVersionId2),
      'updatedByDevice': serializer.toJson<String>(updatedByDevice),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
    };
  }

  Universe copyWith({
    String? versionId,
    Value<String?> parentVersionId = const Value.absent(),
    Value<String?> parentVersionId2 = const Value.absent(),
    String? updatedByDevice,
    DateTime? updatedAt,
    bool? deleted,
    String? id,
    String? ownerId,
    String? name,
  }) => Universe(
    versionId: versionId ?? this.versionId,
    parentVersionId: parentVersionId.present
        ? parentVersionId.value
        : this.parentVersionId,
    parentVersionId2: parentVersionId2.present
        ? parentVersionId2.value
        : this.parentVersionId2,
    updatedByDevice: updatedByDevice ?? this.updatedByDevice,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
  );
  Universe copyWithCompanion(UniversesCompanion data) {
    return Universe(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      parentVersionId2: data.parentVersionId2.present
          ? data.parentVersionId2.value
          : this.parentVersionId2,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Universe(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    ownerId,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Universe &&
          other.versionId == this.versionId &&
          other.parentVersionId == this.parentVersionId &&
          other.parentVersionId2 == this.parentVersionId2 &&
          other.updatedByDevice == this.updatedByDevice &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name);
}

class UniversesCompanion extends UpdateCompanion<Universe> {
  final Value<String> versionId;
  final Value<String?> parentVersionId;
  final Value<String?> parentVersionId2;
  final Value<String> updatedByDevice;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<int> rowid;
  const UniversesCompanion({
    this.versionId = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UniversesCompanion.insert({
    required String versionId,
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    required String updatedByDevice,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String id,
    required String ownerId,
    required String name,
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       updatedByDevice = Value(updatedByDevice),
       updatedAt = Value(updatedAt),
       id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name);
  static Insertable<Universe> custom({
    Expression<String>? versionId,
    Expression<String>? parentVersionId,
    Expression<String>? parentVersionId2,
    Expression<String>? updatedByDevice,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (parentVersionId2 != null) 'parent_version_id2': parentVersionId2,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UniversesCompanion copyWith({
    Value<String>? versionId,
    Value<String?>? parentVersionId,
    Value<String?>? parentVersionId2,
    Value<String>? updatedByDevice,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return UniversesCompanion(
      versionId: versionId ?? this.versionId,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      parentVersionId2: parentVersionId2 ?? this.parentVersionId2,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (parentVersionId2.present) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UniversesCompanion(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentVersionIdMeta = const VerificationMeta(
    'parentVersionId',
  );
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
    'parent_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentVersionId2Meta = const VerificationMeta(
    'parentVersionId2',
  );
  @override
  late final GeneratedColumn<String> parentVersionId2 = GeneratedColumn<String>(
    'parent_version_id2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universeIdMeta = const VerificationMeta(
    'universeId',
  );
  @override
  late final GeneratedColumn<String> universeId = GeneratedColumn<String>(
    'universe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaJsonMeta = const VerificationMeta(
    'schemaJson',
  );
  @override
  late final GeneratedColumn<String> schemaJson = GeneratedColumn<String>(
    'schema_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    universeId,
    ownerId,
    name,
    schemaJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
        _parentVersionIdMeta,
        parentVersionId.isAcceptableOrUnknown(
          data['parent_version_id']!,
          _parentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_version_id2')) {
      context.handle(
        _parentVersionId2Meta,
        parentVersionId2.isAcceptableOrUnknown(
          data['parent_version_id2']!,
          _parentVersionId2Meta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedByDeviceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('universe_id')) {
      context.handle(
        _universeIdMeta,
        universeId.isAcceptableOrUnknown(data['universe_id']!, _universeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_universeIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('schema_json')) {
      context.handle(
        _schemaJsonMeta,
        schemaJson.isAcceptableOrUnknown(data['schema_json']!, _schemaJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_schemaJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      parentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id'],
      ),
      parentVersionId2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id2'],
      ),
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      universeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}universe_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      schemaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_json'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String versionId;
  final String? parentVersionId;
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;
  final String id;
  final String universeId;
  final String ownerId;
  final String name;
  final String schemaJson;
  const Collection({
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
    required this.id,
    required this.universeId,
    required this.ownerId,
    required this.name,
    required this.schemaJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(versionId);
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    if (!nullToAbsent || parentVersionId2 != null) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2);
    }
    map['updated_by_device'] = Variable<String>(updatedByDevice);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['universe_id'] = Variable<String>(universeId);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['schema_json'] = Variable<String>(schemaJson);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      versionId: Value(versionId),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      parentVersionId2: parentVersionId2 == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId2),
      updatedByDevice: Value(updatedByDevice),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      id: Value(id),
      universeId: Value(universeId),
      ownerId: Value(ownerId),
      name: Value(name),
      schemaJson: Value(schemaJson),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      versionId: serializer.fromJson<String>(json['versionId']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      parentVersionId2: serializer.fromJson<String?>(json['parentVersionId2']),
      updatedByDevice: serializer.fromJson<String>(json['updatedByDevice']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      universeId: serializer.fromJson<String>(json['universeId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      schemaJson: serializer.fromJson<String>(json['schemaJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<String>(versionId),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'parentVersionId2': serializer.toJson<String?>(parentVersionId2),
      'updatedByDevice': serializer.toJson<String>(updatedByDevice),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'universeId': serializer.toJson<String>(universeId),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'schemaJson': serializer.toJson<String>(schemaJson),
    };
  }

  Collection copyWith({
    String? versionId,
    Value<String?> parentVersionId = const Value.absent(),
    Value<String?> parentVersionId2 = const Value.absent(),
    String? updatedByDevice,
    DateTime? updatedAt,
    bool? deleted,
    String? id,
    String? universeId,
    String? ownerId,
    String? name,
    String? schemaJson,
  }) => Collection(
    versionId: versionId ?? this.versionId,
    parentVersionId: parentVersionId.present
        ? parentVersionId.value
        : this.parentVersionId,
    parentVersionId2: parentVersionId2.present
        ? parentVersionId2.value
        : this.parentVersionId2,
    updatedByDevice: updatedByDevice ?? this.updatedByDevice,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    universeId: universeId ?? this.universeId,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    schemaJson: schemaJson ?? this.schemaJson,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      parentVersionId2: data.parentVersionId2.present
          ? data.parentVersionId2.value
          : this.parentVersionId2,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      universeId: data.universeId.present
          ? data.universeId.value
          : this.universeId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      schemaJson: data.schemaJson.present
          ? data.schemaJson.value
          : this.schemaJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('universeId: $universeId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('schemaJson: $schemaJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    universeId,
    ownerId,
    name,
    schemaJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.versionId == this.versionId &&
          other.parentVersionId == this.parentVersionId &&
          other.parentVersionId2 == this.parentVersionId2 &&
          other.updatedByDevice == this.updatedByDevice &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.universeId == this.universeId &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.schemaJson == this.schemaJson);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> versionId;
  final Value<String?> parentVersionId;
  final Value<String?> parentVersionId2;
  final Value<String> updatedByDevice;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> universeId;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> schemaJson;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.versionId = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.universeId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.schemaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String versionId,
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    required String updatedByDevice,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String id,
    required String universeId,
    required String ownerId,
    required String name,
    required String schemaJson,
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       updatedByDevice = Value(updatedByDevice),
       updatedAt = Value(updatedAt),
       id = Value(id),
       universeId = Value(universeId),
       ownerId = Value(ownerId),
       name = Value(name),
       schemaJson = Value(schemaJson);
  static Insertable<Collection> custom({
    Expression<String>? versionId,
    Expression<String>? parentVersionId,
    Expression<String>? parentVersionId2,
    Expression<String>? updatedByDevice,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? universeId,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? schemaJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (parentVersionId2 != null) 'parent_version_id2': parentVersionId2,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (universeId != null) 'universe_id': universeId,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (schemaJson != null) 'schema_json': schemaJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? versionId,
    Value<String?>? parentVersionId,
    Value<String?>? parentVersionId2,
    Value<String>? updatedByDevice,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? universeId,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String>? schemaJson,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      versionId: versionId ?? this.versionId,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      parentVersionId2: parentVersionId2 ?? this.parentVersionId2,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      universeId: universeId ?? this.universeId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      schemaJson: schemaJson ?? this.schemaJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (parentVersionId2.present) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (universeId.present) {
      map['universe_id'] = Variable<String>(universeId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (schemaJson.present) {
      map['schema_json'] = Variable<String>(schemaJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('universeId: $universeId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('schemaJson: $schemaJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentVersionIdMeta = const VerificationMeta(
    'parentVersionId',
  );
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
    'parent_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentVersionId2Meta = const VerificationMeta(
    'parentVersionId2',
  );
  @override
  late final GeneratedColumn<String> parentVersionId2 = GeneratedColumn<String>(
    'parent_version_id2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _estimatedValueMeta = const VerificationMeta(
    'estimatedValue',
  );
  @override
  late final GeneratedColumn<double> estimatedValue = GeneratedColumn<double>(
    'estimated_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ownedMeta = const VerificationMeta('owned');
  @override
  late final GeneratedColumn<bool> owned = GeneratedColumn<bool>(
    'owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("owned" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _photosJsonMeta = const VerificationMeta(
    'photosJson',
  );
  @override
  late final GeneratedColumn<String> photosJson = GeneratedColumn<String>(
    'photos_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _customValuesJsonMeta = const VerificationMeta(
    'customValuesJson',
  );
  @override
  late final GeneratedColumn<String> customValuesJson = GeneratedColumn<String>(
    'custom_values_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    collectionId,
    ownerId,
    name,
    category,
    quantity,
    estimatedValue,
    state,
    notes,
    owned,
    photosJson,
    customValuesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
        _parentVersionIdMeta,
        parentVersionId.isAcceptableOrUnknown(
          data['parent_version_id']!,
          _parentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_version_id2')) {
      context.handle(
        _parentVersionId2Meta,
        parentVersionId2.isAcceptableOrUnknown(
          data['parent_version_id2']!,
          _parentVersionId2Meta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedByDeviceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('estimated_value')) {
      context.handle(
        _estimatedValueMeta,
        estimatedValue.isAcceptableOrUnknown(
          data['estimated_value']!,
          _estimatedValueMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('owned')) {
      context.handle(
        _ownedMeta,
        owned.isAcceptableOrUnknown(data['owned']!, _ownedMeta),
      );
    }
    if (data.containsKey('photos_json')) {
      context.handle(
        _photosJsonMeta,
        photosJson.isAcceptableOrUnknown(data['photos_json']!, _photosJsonMeta),
      );
    }
    if (data.containsKey('custom_values_json')) {
      context.handle(
        _customValuesJsonMeta,
        customValuesJson.isAcceptableOrUnknown(
          data['custom_values_json']!,
          _customValuesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      parentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id'],
      ),
      parentVersionId2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id2'],
      ),
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      estimatedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_value'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      owned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}owned'],
      )!,
      photosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photos_json'],
      )!,
      customValuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_values_json'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String versionId;
  final String? parentVersionId;
  final String? parentVersionId2;
  final String updatedByDevice;
  final DateTime updatedAt;
  final bool deleted;
  final String id;
  final String collectionId;
  final String ownerId;
  final String name;
  final String category;
  final int quantity;
  final double? estimatedValue;
  final String state;
  final String notes;

  /// Whether you have this item, or just want it — an ordinary want-list
  /// entry rather than something you actually own. Kept as a real column
  /// (not a custom field) so every collection gets this distinction for free.
  final bool owned;

  /// JSON array of base64-encoded photos — an item can carry a small gallery
  /// rather than a single cover photo. The first entry is used as the cover
  /// thumbnail wherever only one image fits (grid/list views).
  final String photosJson;
  final String customValuesJson;
  const Item({
    required this.versionId,
    this.parentVersionId,
    this.parentVersionId2,
    required this.updatedByDevice,
    required this.updatedAt,
    required this.deleted,
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(versionId);
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    if (!nullToAbsent || parentVersionId2 != null) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2);
    }
    map['updated_by_device'] = Variable<String>(updatedByDevice);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || estimatedValue != null) {
      map['estimated_value'] = Variable<double>(estimatedValue);
    }
    map['state'] = Variable<String>(state);
    map['notes'] = Variable<String>(notes);
    map['owned'] = Variable<bool>(owned);
    map['photos_json'] = Variable<String>(photosJson);
    map['custom_values_json'] = Variable<String>(customValuesJson);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      versionId: Value(versionId),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      parentVersionId2: parentVersionId2 == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId2),
      updatedByDevice: Value(updatedByDevice),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      ownerId: Value(ownerId),
      name: Value(name),
      category: Value(category),
      quantity: Value(quantity),
      estimatedValue: estimatedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedValue),
      state: Value(state),
      notes: Value(notes),
      owned: Value(owned),
      photosJson: Value(photosJson),
      customValuesJson: Value(customValuesJson),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      versionId: serializer.fromJson<String>(json['versionId']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      parentVersionId2: serializer.fromJson<String?>(json['parentVersionId2']),
      updatedByDevice: serializer.fromJson<String>(json['updatedByDevice']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      quantity: serializer.fromJson<int>(json['quantity']),
      estimatedValue: serializer.fromJson<double?>(json['estimatedValue']),
      state: serializer.fromJson<String>(json['state']),
      notes: serializer.fromJson<String>(json['notes']),
      owned: serializer.fromJson<bool>(json['owned']),
      photosJson: serializer.fromJson<String>(json['photosJson']),
      customValuesJson: serializer.fromJson<String>(json['customValuesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<String>(versionId),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'parentVersionId2': serializer.toJson<String?>(parentVersionId2),
      'updatedByDevice': serializer.toJson<String>(updatedByDevice),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'quantity': serializer.toJson<int>(quantity),
      'estimatedValue': serializer.toJson<double?>(estimatedValue),
      'state': serializer.toJson<String>(state),
      'notes': serializer.toJson<String>(notes),
      'owned': serializer.toJson<bool>(owned),
      'photosJson': serializer.toJson<String>(photosJson),
      'customValuesJson': serializer.toJson<String>(customValuesJson),
    };
  }

  Item copyWith({
    String? versionId,
    Value<String?> parentVersionId = const Value.absent(),
    Value<String?> parentVersionId2 = const Value.absent(),
    String? updatedByDevice,
    DateTime? updatedAt,
    bool? deleted,
    String? id,
    String? collectionId,
    String? ownerId,
    String? name,
    String? category,
    int? quantity,
    Value<double?> estimatedValue = const Value.absent(),
    String? state,
    String? notes,
    bool? owned,
    String? photosJson,
    String? customValuesJson,
  }) => Item(
    versionId: versionId ?? this.versionId,
    parentVersionId: parentVersionId.present
        ? parentVersionId.value
        : this.parentVersionId,
    parentVersionId2: parentVersionId2.present
        ? parentVersionId2.value
        : this.parentVersionId2,
    updatedByDevice: updatedByDevice ?? this.updatedByDevice,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    estimatedValue: estimatedValue.present
        ? estimatedValue.value
        : this.estimatedValue,
    state: state ?? this.state,
    notes: notes ?? this.notes,
    owned: owned ?? this.owned,
    photosJson: photosJson ?? this.photosJson,
    customValuesJson: customValuesJson ?? this.customValuesJson,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      parentVersionId2: data.parentVersionId2.present
          ? data.parentVersionId2.value
          : this.parentVersionId2,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      estimatedValue: data.estimatedValue.present
          ? data.estimatedValue.value
          : this.estimatedValue,
      state: data.state.present ? data.state.value : this.state,
      notes: data.notes.present ? data.notes.value : this.notes,
      owned: data.owned.present ? data.owned.value : this.owned,
      photosJson: data.photosJson.present
          ? data.photosJson.value
          : this.photosJson,
      customValuesJson: data.customValuesJson.present
          ? data.customValuesJson.value
          : this.customValuesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('state: $state, ')
          ..write('notes: $notes, ')
          ..write('owned: $owned, ')
          ..write('photosJson: $photosJson, ')
          ..write('customValuesJson: $customValuesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    versionId,
    parentVersionId,
    parentVersionId2,
    updatedByDevice,
    updatedAt,
    deleted,
    id,
    collectionId,
    ownerId,
    name,
    category,
    quantity,
    estimatedValue,
    state,
    notes,
    owned,
    photosJson,
    customValuesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.versionId == this.versionId &&
          other.parentVersionId == this.parentVersionId &&
          other.parentVersionId2 == this.parentVersionId2 &&
          other.updatedByDevice == this.updatedByDevice &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.estimatedValue == this.estimatedValue &&
          other.state == this.state &&
          other.notes == this.notes &&
          other.owned == this.owned &&
          other.photosJson == this.photosJson &&
          other.customValuesJson == this.customValuesJson);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> versionId;
  final Value<String?> parentVersionId;
  final Value<String?> parentVersionId2;
  final Value<String> updatedByDevice;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> category;
  final Value<int> quantity;
  final Value<double?> estimatedValue;
  final Value<String> state;
  final Value<String> notes;
  final Value<bool> owned;
  final Value<String> photosJson;
  final Value<String> customValuesJson;
  final Value<int> rowid;
  const ItemsCompanion({
    this.versionId = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.estimatedValue = const Value.absent(),
    this.state = const Value.absent(),
    this.notes = const Value.absent(),
    this.owned = const Value.absent(),
    this.photosJson = const Value.absent(),
    this.customValuesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String versionId,
    this.parentVersionId = const Value.absent(),
    this.parentVersionId2 = const Value.absent(),
    required String updatedByDevice,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String id,
    required String collectionId,
    required String ownerId,
    required String name,
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.estimatedValue = const Value.absent(),
    this.state = const Value.absent(),
    this.notes = const Value.absent(),
    this.owned = const Value.absent(),
    this.photosJson = const Value.absent(),
    this.customValuesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       updatedByDevice = Value(updatedByDevice),
       updatedAt = Value(updatedAt),
       id = Value(id),
       collectionId = Value(collectionId),
       ownerId = Value(ownerId),
       name = Value(name);
  static Insertable<Item> custom({
    Expression<String>? versionId,
    Expression<String>? parentVersionId,
    Expression<String>? parentVersionId2,
    Expression<String>? updatedByDevice,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? quantity,
    Expression<double>? estimatedValue,
    Expression<String>? state,
    Expression<String>? notes,
    Expression<bool>? owned,
    Expression<String>? photosJson,
    Expression<String>? customValuesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (parentVersionId2 != null) 'parent_version_id2': parentVersionId2,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (estimatedValue != null) 'estimated_value': estimatedValue,
      if (state != null) 'state': state,
      if (notes != null) 'notes': notes,
      if (owned != null) 'owned': owned,
      if (photosJson != null) 'photos_json': photosJson,
      if (customValuesJson != null) 'custom_values_json': customValuesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? versionId,
    Value<String?>? parentVersionId,
    Value<String?>? parentVersionId2,
    Value<String>? updatedByDevice,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String>? category,
    Value<int>? quantity,
    Value<double?>? estimatedValue,
    Value<String>? state,
    Value<String>? notes,
    Value<bool>? owned,
    Value<String>? photosJson,
    Value<String>? customValuesJson,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      versionId: versionId ?? this.versionId,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      parentVersionId2: parentVersionId2 ?? this.parentVersionId2,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      state: state ?? this.state,
      notes: notes ?? this.notes,
      owned: owned ?? this.owned,
      photosJson: photosJson ?? this.photosJson,
      customValuesJson: customValuesJson ?? this.customValuesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (parentVersionId2.present) {
      map['parent_version_id2'] = Variable<String>(parentVersionId2.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (estimatedValue.present) {
      map['estimated_value'] = Variable<double>(estimatedValue.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (owned.present) {
      map['owned'] = Variable<bool>(owned.value);
    }
    if (photosJson.present) {
      map['photos_json'] = Variable<String>(photosJson.value);
    }
    if (customValuesJson.present) {
      map['custom_values_json'] = Variable<String>(customValuesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('versionId: $versionId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('parentVersionId2: $parentVersionId2, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('estimatedValue: $estimatedValue, ')
          ..write('state: $state, ')
          ..write('notes: $notes, ')
          ..write('owned: $owned, ')
          ..write('photosJson: $photosJson, ')
          ..write('customValuesJson: $customValuesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs with TableInfo<$SyncLogsTable, SyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerNameMeta = const VerificationMeta(
    'peerName',
  );
  @override
  late final GeneratedColumn<String> peerName = GeneratedColumn<String>(
    'peer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedCountMeta = const VerificationMeta(
    'appliedCount',
  );
  @override
  late final GeneratedColumn<int> appliedCount = GeneratedColumn<int>(
    'applied_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pendingCountMeta = const VerificationMeta(
    'pendingCount',
  );
  @override
  late final GeneratedColumn<int> pendingCount = GeneratedColumn<int>(
    'pending_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conflictCountMeta = const VerificationMeta(
    'conflictCount',
  );
  @override
  late final GeneratedColumn<int> conflictCount = GeneratedColumn<int>(
    'conflict_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    peerName,
    startedAt,
    direction,
    appliedCount,
    pendingCount,
    conflictCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('peer_name')) {
      context.handle(
        _peerNameMeta,
        peerName.isAcceptableOrUnknown(data['peer_name']!, _peerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_peerNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('applied_count')) {
      context.handle(
        _appliedCountMeta,
        appliedCount.isAcceptableOrUnknown(
          data['applied_count']!,
          _appliedCountMeta,
        ),
      );
    }
    if (data.containsKey('pending_count')) {
      context.handle(
        _pendingCountMeta,
        pendingCount.isAcceptableOrUnknown(
          data['pending_count']!,
          _pendingCountMeta,
        ),
      );
    }
    if (data.containsKey('conflict_count')) {
      context.handle(
        _conflictCountMeta,
        conflictCount.isAcceptableOrUnknown(
          data['conflict_count']!,
          _conflictCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      peerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      appliedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_count'],
      )!,
      pendingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_count'],
      )!,
      conflictCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conflict_count'],
      )!,
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLog extends DataClass implements Insertable<SyncLog> {
  final String id;
  final String peerName;
  final DateTime startedAt;

  /// 'incoming' (a peer connected to you — everything it sent was applied
  /// automatically) or 'outgoing' (you initiated — some changes may only
  /// have been proposed, see [pendingCount]).
  final String direction;
  final int appliedCount;
  final int pendingCount;
  final int conflictCount;
  const SyncLog({
    required this.id,
    required this.peerName,
    required this.startedAt,
    required this.direction,
    required this.appliedCount,
    required this.pendingCount,
    required this.conflictCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['peer_name'] = Variable<String>(peerName);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['direction'] = Variable<String>(direction);
    map['applied_count'] = Variable<int>(appliedCount);
    map['pending_count'] = Variable<int>(pendingCount);
    map['conflict_count'] = Variable<int>(conflictCount);
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      peerName: Value(peerName),
      startedAt: Value(startedAt),
      direction: Value(direction),
      appliedCount: Value(appliedCount),
      pendingCount: Value(pendingCount),
      conflictCount: Value(conflictCount),
    );
  }

  factory SyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLog(
      id: serializer.fromJson<String>(json['id']),
      peerName: serializer.fromJson<String>(json['peerName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      direction: serializer.fromJson<String>(json['direction']),
      appliedCount: serializer.fromJson<int>(json['appliedCount']),
      pendingCount: serializer.fromJson<int>(json['pendingCount']),
      conflictCount: serializer.fromJson<int>(json['conflictCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'peerName': serializer.toJson<String>(peerName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'direction': serializer.toJson<String>(direction),
      'appliedCount': serializer.toJson<int>(appliedCount),
      'pendingCount': serializer.toJson<int>(pendingCount),
      'conflictCount': serializer.toJson<int>(conflictCount),
    };
  }

  SyncLog copyWith({
    String? id,
    String? peerName,
    DateTime? startedAt,
    String? direction,
    int? appliedCount,
    int? pendingCount,
    int? conflictCount,
  }) => SyncLog(
    id: id ?? this.id,
    peerName: peerName ?? this.peerName,
    startedAt: startedAt ?? this.startedAt,
    direction: direction ?? this.direction,
    appliedCount: appliedCount ?? this.appliedCount,
    pendingCount: pendingCount ?? this.pendingCount,
    conflictCount: conflictCount ?? this.conflictCount,
  );
  SyncLog copyWithCompanion(SyncLogsCompanion data) {
    return SyncLog(
      id: data.id.present ? data.id.value : this.id,
      peerName: data.peerName.present ? data.peerName.value : this.peerName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      direction: data.direction.present ? data.direction.value : this.direction,
      appliedCount: data.appliedCount.present
          ? data.appliedCount.value
          : this.appliedCount,
      pendingCount: data.pendingCount.present
          ? data.pendingCount.value
          : this.pendingCount,
      conflictCount: data.conflictCount.present
          ? data.conflictCount.value
          : this.conflictCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLog(')
          ..write('id: $id, ')
          ..write('peerName: $peerName, ')
          ..write('startedAt: $startedAt, ')
          ..write('direction: $direction, ')
          ..write('appliedCount: $appliedCount, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('conflictCount: $conflictCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    peerName,
    startedAt,
    direction,
    appliedCount,
    pendingCount,
    conflictCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLog &&
          other.id == this.id &&
          other.peerName == this.peerName &&
          other.startedAt == this.startedAt &&
          other.direction == this.direction &&
          other.appliedCount == this.appliedCount &&
          other.pendingCount == this.pendingCount &&
          other.conflictCount == this.conflictCount);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLog> {
  final Value<String> id;
  final Value<String> peerName;
  final Value<DateTime> startedAt;
  final Value<String> direction;
  final Value<int> appliedCount;
  final Value<int> pendingCount;
  final Value<int> conflictCount;
  final Value<int> rowid;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.peerName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.direction = const Value.absent(),
    this.appliedCount = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    required String id,
    required String peerName,
    required DateTime startedAt,
    required String direction,
    this.appliedCount = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       peerName = Value(peerName),
       startedAt = Value(startedAt),
       direction = Value(direction);
  static Insertable<SyncLog> custom({
    Expression<String>? id,
    Expression<String>? peerName,
    Expression<DateTime>? startedAt,
    Expression<String>? direction,
    Expression<int>? appliedCount,
    Expression<int>? pendingCount,
    Expression<int>? conflictCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (peerName != null) 'peer_name': peerName,
      if (startedAt != null) 'started_at': startedAt,
      if (direction != null) 'direction': direction,
      if (appliedCount != null) 'applied_count': appliedCount,
      if (pendingCount != null) 'pending_count': pendingCount,
      if (conflictCount != null) 'conflict_count': conflictCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? peerName,
    Value<DateTime>? startedAt,
    Value<String>? direction,
    Value<int>? appliedCount,
    Value<int>? pendingCount,
    Value<int>? conflictCount,
    Value<int>? rowid,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      peerName: peerName ?? this.peerName,
      startedAt: startedAt ?? this.startedAt,
      direction: direction ?? this.direction,
      appliedCount: appliedCount ?? this.appliedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      conflictCount: conflictCount ?? this.conflictCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (peerName.present) {
      map['peer_name'] = Variable<String>(peerName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (appliedCount.present) {
      map['applied_count'] = Variable<int>(appliedCount.value);
    }
    if (pendingCount.present) {
      map['pending_count'] = Variable<int>(pendingCount.value);
    }
    if (conflictCount.present) {
      map['conflict_count'] = Variable<int>(conflictCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('peerName: $peerName, ')
          ..write('startedAt: $startedAt, ')
          ..write('direction: $direction, ')
          ..write('appliedCount: $appliedCount, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('conflictCount: $conflictCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KnownUsersTable knownUsers = $KnownUsersTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $UniversesTable universes = $UniversesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    knownUsers,
    profiles,
    universes,
    collections,
    items,
    syncLogs,
  ];
}

typedef $$KnownUsersTableCreateCompanionBuilder = KnownUsersCompanion Function({
  required String id,
  required String name,
  required DateTime lastSyncedAt,
  Value<int> rowid,
});
typedef $$KnownUsersTableUpdateCompanionBuilder = KnownUsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> lastSyncedAt,
  Value<int> rowid,
});

class $$KnownUsersTableFilterComposer
    extends Composer<_$AppDatabase, $KnownUsersTable> {
  $$KnownUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KnownUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $KnownUsersTable> {
  $$KnownUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KnownUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $KnownUsersTable> {
  $$KnownUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$KnownUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KnownUsersTable,
          KnownUser,
          $$KnownUsersTableFilterComposer,
          $$KnownUsersTableOrderingComposer,
          $$KnownUsersTableAnnotationComposer,
          $$KnownUsersTableCreateCompanionBuilder,
          $$KnownUsersTableUpdateCompanionBuilder,
          (
            KnownUser,
            BaseReferences<_$AppDatabase, $KnownUsersTable, KnownUser>,
          ),
          KnownUser,
          PrefetchHooks Function()
        > {
  $$KnownUsersTableTableManager(_$AppDatabase db, $KnownUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnownUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KnownUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KnownUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnownUsersCompanion(
                id: id,
                name: name,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => KnownUsersCompanion.insert(
                id: id,
                name: name,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KnownUsersTable, KnownUser>(table),
                  BaseReferences<_$AppDatabase, $KnownUsersTable, KnownUser>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KnownUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KnownUsersTable,
      KnownUser,
      $$KnownUsersTableFilterComposer,
      $$KnownUsersTableOrderingComposer,
      $$KnownUsersTableAnnotationComposer,
      $$KnownUsersTableCreateCompanionBuilder,
      $$KnownUsersTableUpdateCompanionBuilder,
      (KnownUser, BaseReferences<_$AppDatabase, $KnownUsersTable, KnownUser>),
      KnownUser,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$UniversesTableCreateCompanionBuilder = UniversesCompanion Function({
  required String versionId,
  Value<String?> parentVersionId,
  Value<String?> parentVersionId2,
  required String updatedByDevice,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String id,
  required String ownerId,
  required String name,
  Value<int> rowid,
});
typedef $$UniversesTableUpdateCompanionBuilder = UniversesCompanion Function({
  Value<String> versionId,
  Value<String?> parentVersionId,
  Value<String?> parentVersionId2,
  Value<String> updatedByDevice,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> id,
  Value<String> ownerId,
  Value<String> name,
  Value<int> rowid,
});

class $$UniversesTableFilterComposer
    extends Composer<_$AppDatabase, $UniversesTable> {
  $$UniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $UniversesTable> {
  $$UniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UniversesTable> {
  $$UniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$UniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UniversesTable,
          Universe,
          $$UniversesTableFilterComposer,
          $$UniversesTableOrderingComposer,
          $$UniversesTableAnnotationComposer,
          $$UniversesTableCreateCompanionBuilder,
          $$UniversesTableUpdateCompanionBuilder,
          (Universe, BaseReferences<_$AppDatabase, $UniversesTable, Universe>),
          Universe,
          PrefetchHooks Function()
        > {
  $$UniversesTableTableManager(_$AppDatabase db, $UniversesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UniversesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> versionId = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                Value<String> updatedByDevice = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UniversesCompanion(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                ownerId: ownerId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String versionId,
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                required String updatedByDevice,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String ownerId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => UniversesCompanion.insert(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                ownerId: ownerId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UniversesTable, Universe>(table),
                  BaseReferences<_$AppDatabase, $UniversesTable, Universe>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UniversesTable,
      Universe,
      $$UniversesTableFilterComposer,
      $$UniversesTableOrderingComposer,
      $$UniversesTableAnnotationComposer,
      $$UniversesTableCreateCompanionBuilder,
      $$UniversesTableUpdateCompanionBuilder,
      (Universe, BaseReferences<_$AppDatabase, $UniversesTable, Universe>),
      Universe,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String versionId,
      Value<String?> parentVersionId,
      Value<String?> parentVersionId2,
      required String updatedByDevice,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String id,
      required String universeId,
      required String ownerId,
      required String name,
      required String schemaJson,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> versionId,
      Value<String?> parentVersionId,
      Value<String?> parentVersionId2,
      Value<String> updatedByDevice,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> id,
      Value<String> universeId,
      Value<String> ownerId,
      Value<String> name,
      Value<String> schemaJson,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get schemaJson => $composableBuilder(
    column: $table.schemaJson,
    builder: (column) => column,
  );
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> versionId = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                Value<String> updatedByDevice = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> universeId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> schemaJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                universeId: universeId,
                ownerId: ownerId,
                name: name,
                schemaJson: schemaJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String versionId,
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                required String updatedByDevice,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String universeId,
                required String ownerId,
                required String name,
                required String schemaJson,
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                universeId: universeId,
                ownerId: ownerId,
                name: name,
                schemaJson: schemaJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, Collection>(table),
                  BaseReferences<_$AppDatabase, $CollectionsTable, Collection>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String versionId,
  Value<String?> parentVersionId,
  Value<String?> parentVersionId2,
  required String updatedByDevice,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String id,
  required String collectionId,
  required String ownerId,
  required String name,
  Value<String> category,
  Value<int> quantity,
  Value<double?> estimatedValue,
  Value<String> state,
  Value<String> notes,
  Value<bool> owned,
  Value<String> photosJson,
  Value<String> customValuesJson,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> versionId,
  Value<String?> parentVersionId,
  Value<String?> parentVersionId2,
  Value<String> updatedByDevice,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> id,
  Value<String> collectionId,
  Value<String> ownerId,
  Value<String> name,
  Value<String> category,
  Value<int> quantity,
  Value<double?> estimatedValue,
  Value<String> state,
  Value<String> notes,
  Value<bool> owned,
  Value<String> photosJson,
  Value<String> customValuesJson,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedValue => $composableBuilder(
    column: $table.estimatedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photosJson => $composableBuilder(
    column: $table.photosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customValuesJson => $composableBuilder(
    column: $table.customValuesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedValue => $composableBuilder(
    column: $table.estimatedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photosJson => $composableBuilder(
    column: $table.photosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customValuesJson => $composableBuilder(
    column: $table.customValuesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentVersionId2 => $composableBuilder(
    column: $table.parentVersionId2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get estimatedValue => $composableBuilder(
    column: $table.estimatedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get owned =>
      $composableBuilder(column: $table.owned, builder: (column) => column);

  GeneratedColumn<String> get photosJson => $composableBuilder(
    column: $table.photosJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customValuesJson => $composableBuilder(
    column: $table.customValuesJson,
    builder: (column) => column,
  );
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> versionId = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                Value<String> updatedByDevice = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double?> estimatedValue = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> owned = const Value.absent(),
                Value<String> photosJson = const Value.absent(),
                Value<String> customValuesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                ownerId: ownerId,
                name: name,
                category: category,
                quantity: quantity,
                estimatedValue: estimatedValue,
                state: state,
                notes: notes,
                owned: owned,
                photosJson: photosJson,
                customValuesJson: customValuesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String versionId,
                Value<String?> parentVersionId = const Value.absent(),
                Value<String?> parentVersionId2 = const Value.absent(),
                required String updatedByDevice,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String collectionId,
                required String ownerId,
                required String name,
                Value<String> category = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double?> estimatedValue = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> owned = const Value.absent(),
                Value<String> photosJson = const Value.absent(),
                Value<String> customValuesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                versionId: versionId,
                parentVersionId: parentVersionId,
                parentVersionId2: parentVersionId2,
                updatedByDevice: updatedByDevice,
                updatedAt: updatedAt,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                ownerId: ownerId,
                name: name,
                category: category,
                quantity: quantity,
                estimatedValue: estimatedValue,
                state: state,
                notes: notes,
                owned: owned,
                photosJson: photosJson,
                customValuesJson: customValuesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  BaseReferences<_$AppDatabase, $ItemsTable, Item>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$SyncLogsTableCreateCompanionBuilder = SyncLogsCompanion Function({
  required String id,
  required String peerName,
  required DateTime startedAt,
  required String direction,
  Value<int> appliedCount,
  Value<int> pendingCount,
  Value<int> conflictCount,
  Value<int> rowid,
});
typedef $$SyncLogsTableUpdateCompanionBuilder = SyncLogsCompanion Function({
  Value<String> id,
  Value<String> peerName,
  Value<DateTime> startedAt,
  Value<String> direction,
  Value<int> appliedCount,
  Value<int> pendingCount,
  Value<int> conflictCount,
  Value<int> rowid,
});

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedCount => $composableBuilder(
    column: $table.appliedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedCount => $composableBuilder(
    column: $table.appliedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get peerName =>
      $composableBuilder(column: $table.peerName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get appliedCount => $composableBuilder(
    column: $table.appliedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => column,
  );
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          SyncLog,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
          SyncLog,
          PrefetchHooks Function()
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> peerName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> appliedCount = const Value.absent(),
                Value<int> pendingCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                peerName: peerName,
                startedAt: startedAt,
                direction: direction,
                appliedCount: appliedCount,
                pendingCount: pendingCount,
                conflictCount: conflictCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String peerName,
                required DateTime startedAt,
                required String direction,
                Value<int> appliedCount = const Value.absent(),
                Value<int> pendingCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                peerName: peerName,
                startedAt: startedAt,
                direction: direction,
                appliedCount: appliedCount,
                pendingCount: pendingCount,
                conflictCount: conflictCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncLogsTable, SyncLog>(table),
                  BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      SyncLog,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
      SyncLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KnownUsersTableTableManager get knownUsers =>
      $$KnownUsersTableTableManager(_db, _db.knownUsers);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$UniversesTableTableManager get universes =>
      $$UniversesTableTableManager(_db, _db.universes);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
}
