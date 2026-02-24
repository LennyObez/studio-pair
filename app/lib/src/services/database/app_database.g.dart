// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedUsersTable extends CachedUsers
    with TableInfo<$CachedUsersTable, CachedUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totpEnabledMeta = const VerificationMeta(
    'totpEnabled',
  );
  @override
  late final GeneratedColumn<bool> totpEnabled = GeneratedColumn<bool>(
    'totp_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("totp_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preferredLanguageMeta = const VerificationMeta(
    'preferredLanguage',
  );
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>(
        'preferred_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('en'),
      );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    avatarUrl,
    totpEnabled,
    preferredLanguage,
    timezone,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('totp_enabled')) {
      context.handle(
        _totpEnabledMeta,
        totpEnabled.isAcceptableOrUnknown(
          data['totp_enabled']!,
          _totpEnabledMeta,
        ),
      );
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
        _preferredLanguageMeta,
        preferredLanguage.isAcceptableOrUnknown(
          data['preferred_language']!,
          _preferredLanguageMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      totpEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}totp_enabled'],
      )!,
      preferredLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_language'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedUsersTable createAlias(String alias) {
    return $CachedUsersTable(attachedDatabase, alias);
  }
}

class CachedUser extends DataClass implements Insertable<CachedUser> {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool totpEnabled;
  final String preferredLanguage;
  final String? timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.totpEnabled,
    required this.preferredLanguage,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['totp_enabled'] = Variable<bool>(totpEnabled);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedUsersCompanion toCompanion(bool nullToAbsent) {
    return CachedUsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      totpEnabled: Value(totpEnabled),
      preferredLanguage: Value(preferredLanguage),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUser(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      totpEnabled: serializer.fromJson<bool>(json['totpEnabled']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'totpEnabled': serializer.toJson<bool>(totpEnabled),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'timezone': serializer.toJson<String?>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedUser copyWith({
    String? id,
    String? email,
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    bool? totpEnabled,
    String? preferredLanguage,
    Value<String?> timezone = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedUser(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    totpEnabled: totpEnabled ?? this.totpEnabled,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    timezone: timezone.present ? timezone.value : this.timezone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedUser copyWithCompanion(CachedUsersCompanion data) {
    return CachedUser(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      totpEnabled: data.totpEnabled.present
          ? data.totpEnabled.value
          : this.totpEnabled,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUser(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('totpEnabled: $totpEnabled, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    displayName,
    avatarUrl,
    totpEnabled,
    preferredLanguage,
    timezone,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUser &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.totpEnabled == this.totpEnabled &&
          other.preferredLanguage == this.preferredLanguage &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedUsersCompanion extends UpdateCompanion<CachedUser> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<bool> totpEnabled;
  final Value<String> preferredLanguage;
  final Value<String?> timezone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedUsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.totpEnabled = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUsersCompanion.insert({
    required String id,
    required String email,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.totpEnabled = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.timezone = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedUser> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<bool>? totpEnabled,
    Expression<String>? preferredLanguage,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (totpEnabled != null) 'totp_enabled': totpEnabled,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<bool>? totpEnabled,
    Value<String>? preferredLanguage,
    Value<String?>? timezone,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedUsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totpEnabled: totpEnabled ?? this.totpEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (totpEnabled.present) {
      map['totp_enabled'] = Variable<bool>(totpEnabled.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('totpEnabled: $totpEnabled, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSpacesTable extends CachedSpaces
    with TableInfo<$CachedSpacesTable, CachedSpace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSpacesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteCodeMeta = const VerificationMeta(
    'inviteCode',
  );
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
    'invite_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxMembersMeta = const VerificationMeta(
    'maxMembers',
  );
  @override
  late final GeneratedColumn<int> maxMembers = GeneratedColumn<int>(
    'max_members',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    avatarUrl,
    inviteCode,
    maxMembers,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSpace> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('invite_code')) {
      context.handle(
        _inviteCodeMeta,
        inviteCode.isAcceptableOrUnknown(data['invite_code']!, _inviteCodeMeta),
      );
    }
    if (data.containsKey('max_members')) {
      context.handle(
        _maxMembersMeta,
        maxMembers.isAcceptableOrUnknown(data['max_members']!, _maxMembersMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSpace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSpace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      inviteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_code'],
      ),
      maxMembers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_members'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedSpacesTable createAlias(String alias) {
    return $CachedSpacesTable(attachedDatabase, alias);
  }
}

class CachedSpace extends DataClass implements Insertable<CachedSpace> {
  final String id;
  final String name;
  final String type;
  final String? avatarUrl;
  final String? inviteCode;
  final int maxMembers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedSpace({
    required this.id,
    required this.name,
    required this.type,
    this.avatarUrl,
    this.inviteCode,
    required this.maxMembers,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || inviteCode != null) {
      map['invite_code'] = Variable<String>(inviteCode);
    }
    map['max_members'] = Variable<int>(maxMembers);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedSpacesCompanion toCompanion(bool nullToAbsent) {
    return CachedSpacesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      inviteCode: inviteCode == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteCode),
      maxMembers: Value(maxMembers),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedSpace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSpace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      inviteCode: serializer.fromJson<String?>(json['inviteCode']),
      maxMembers: serializer.fromJson<int>(json['maxMembers']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'inviteCode': serializer.toJson<String?>(inviteCode),
      'maxMembers': serializer.toJson<int>(maxMembers),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedSpace copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> inviteCode = const Value.absent(),
    int? maxMembers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedSpace(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    inviteCode: inviteCode.present ? inviteCode.value : this.inviteCode,
    maxMembers: maxMembers ?? this.maxMembers,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedSpace copyWithCompanion(CachedSpacesCompanion data) {
    return CachedSpace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      inviteCode: data.inviteCode.present
          ? data.inviteCode.value
          : this.inviteCode,
      maxMembers: data.maxMembers.present
          ? data.maxMembers.value
          : this.maxMembers,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSpace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    avatarUrl,
    inviteCode,
    maxMembers,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSpace &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.avatarUrl == this.avatarUrl &&
          other.inviteCode == this.inviteCode &&
          other.maxMembers == this.maxMembers &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedSpacesCompanion extends UpdateCompanion<CachedSpace> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> avatarUrl;
  final Value<String?> inviteCode;
  final Value<int> maxMembers;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedSpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.maxMembers = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSpacesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.avatarUrl = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.maxMembers = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedSpace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? avatarUrl,
    Expression<String>? inviteCode,
    Expression<int>? maxMembers,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (maxMembers != null) 'max_members': maxMembers,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? avatarUrl,
    Value<String?>? inviteCode,
    Value<int>? maxMembers,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedSpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      inviteCode: inviteCode ?? this.inviteCode,
      maxMembers: maxMembers ?? this.maxMembers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (maxMembers.present) {
      map['max_members'] = Variable<int>(maxMembers.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSpaceMembershipsTable extends CachedSpaceMemberships
    with TableInfo<$CachedSpaceMembershipsTable, CachedSpaceMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSpaceMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_spaces (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_users (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessLevelMeta = const VerificationMeta(
    'accessLevel',
  );
  @override
  late final GeneratedColumn<String> accessLevel = GeneratedColumn<String>(
    'access_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    userId,
    role,
    accessLevel,
    status,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_space_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSpaceMembership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('access_level')) {
      context.handle(
        _accessLevelMeta,
        accessLevel.isAcceptableOrUnknown(
          data['access_level']!,
          _accessLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessLevelMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSpaceMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSpaceMembership(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      accessLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_level'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedSpaceMembershipsTable createAlias(String alias) {
    return $CachedSpaceMembershipsTable(attachedDatabase, alias);
  }
}

class CachedSpaceMembership extends DataClass
    implements Insertable<CachedSpaceMembership> {
  final String id;
  final String spaceId;
  final String userId;
  final String role;
  final String accessLevel;
  final String status;
  final DateTime syncedAt;
  const CachedSpaceMembership({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.accessLevel,
    required this.status,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['access_level'] = Variable<String>(accessLevel);
    map['status'] = Variable<String>(status);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedSpaceMembershipsCompanion toCompanion(bool nullToAbsent) {
    return CachedSpaceMembershipsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      userId: Value(userId),
      role: Value(role),
      accessLevel: Value(accessLevel),
      status: Value(status),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedSpaceMembership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSpaceMembership(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      accessLevel: serializer.fromJson<String>(json['accessLevel']),
      status: serializer.fromJson<String>(json['status']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'accessLevel': serializer.toJson<String>(accessLevel),
      'status': serializer.toJson<String>(status),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedSpaceMembership copyWith({
    String? id,
    String? spaceId,
    String? userId,
    String? role,
    String? accessLevel,
    String? status,
    DateTime? syncedAt,
  }) => CachedSpaceMembership(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    accessLevel: accessLevel ?? this.accessLevel,
    status: status ?? this.status,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedSpaceMembership copyWithCompanion(
    CachedSpaceMembershipsCompanion data,
  ) {
    return CachedSpaceMembership(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      accessLevel: data.accessLevel.present
          ? data.accessLevel.value
          : this.accessLevel,
      status: data.status.present ? data.status.value : this.status,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSpaceMembership(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('accessLevel: $accessLevel, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, spaceId, userId, role, accessLevel, status, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSpaceMembership &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.accessLevel == this.accessLevel &&
          other.status == this.status &&
          other.syncedAt == this.syncedAt);
}

class CachedSpaceMembershipsCompanion
    extends UpdateCompanion<CachedSpaceMembership> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String> accessLevel;
  final Value<String> status;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedSpaceMembershipsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.accessLevel = const Value.absent(),
    this.status = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSpaceMembershipsCompanion.insert({
    required String id,
    required String spaceId,
    required String userId,
    required String role,
    required String accessLevel,
    required String status,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       userId = Value(userId),
       role = Value(role),
       accessLevel = Value(accessLevel),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<CachedSpaceMembership> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? accessLevel,
    Expression<String>? status,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (accessLevel != null) 'access_level': accessLevel,
      if (status != null) 'status': status,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSpaceMembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? userId,
    Value<String>? role,
    Value<String>? accessLevel,
    Value<String>? status,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedSpaceMembershipsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      accessLevel: accessLevel ?? this.accessLevel,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (accessLevel.present) {
      map['access_level'] = Variable<String>(accessLevel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSpaceMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('accessLevel: $accessLevel, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedActivitiesTable extends CachedActivities
    with TableInfo<$CachedActivitiesTable, CachedActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trailerUrlMeta = const VerificationMeta(
    'trailerUrl',
  );
  @override
  late final GeneratedColumn<String> trailerUrl = GeneratedColumn<String>(
    'trailer_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _privacyMeta = const VerificationMeta(
    'privacy',
  );
  @override
  late final GeneratedColumn<String> privacy = GeneratedColumn<String>(
    'privacy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedNotesMeta = const VerificationMeta(
    'completedNotes',
  );
  @override
  late final GeneratedColumn<String> completedNotes = GeneratedColumn<String>(
    'completed_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    title,
    description,
    category,
    thumbnailUrl,
    trailerUrl,
    privacy,
    status,
    mode,
    metadata,
    completedAt,
    completedNotes,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('trailer_url')) {
      context.handle(
        _trailerUrlMeta,
        trailerUrl.isAcceptableOrUnknown(data['trailer_url']!, _trailerUrlMeta),
      );
    }
    if (data.containsKey('privacy')) {
      context.handle(
        _privacyMeta,
        privacy.isAcceptableOrUnknown(data['privacy']!, _privacyMeta),
      );
    } else if (isInserting) {
      context.missing(_privacyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_notes')) {
      context.handle(
        _completedNotesMeta,
        completedNotes.isAcceptableOrUnknown(
          data['completed_notes']!,
          _completedNotesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedActivity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      trailerUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trailer_url'],
      ),
      privacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      completedNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedActivitiesTable createAlias(String alias) {
    return $CachedActivitiesTable(attachedDatabase, alias);
  }
}

class CachedActivity extends DataClass implements Insertable<CachedActivity> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String title;
  final String? description;
  final String category;
  final String? thumbnailUrl;
  final String? trailerUrl;
  final String privacy;
  final String status;
  final String mode;
  final String? metadata;
  final DateTime? completedAt;
  final String? completedNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedActivity({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.category,
    this.thumbnailUrl,
    this.trailerUrl,
    required this.privacy,
    required this.status,
    required this.mode,
    this.metadata,
    this.completedAt,
    this.completedNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || trailerUrl != null) {
      map['trailer_url'] = Variable<String>(trailerUrl);
    }
    map['privacy'] = Variable<String>(privacy);
    map['status'] = Variable<String>(status);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || completedNotes != null) {
      map['completed_notes'] = Variable<String>(completedNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedActivitiesCompanion toCompanion(bool nullToAbsent) {
    return CachedActivitiesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      trailerUrl: trailerUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(trailerUrl),
      privacy: Value(privacy),
      status: Value(status),
      mode: Value(mode),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedNotes: completedNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(completedNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedActivity(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      trailerUrl: serializer.fromJson<String?>(json['trailerUrl']),
      privacy: serializer.fromJson<String>(json['privacy']),
      status: serializer.fromJson<String>(json['status']),
      mode: serializer.fromJson<String>(json['mode']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completedNotes: serializer.fromJson<String?>(json['completedNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'trailerUrl': serializer.toJson<String?>(trailerUrl),
      'privacy': serializer.toJson<String>(privacy),
      'status': serializer.toJson<String>(status),
      'mode': serializer.toJson<String>(mode),
      'metadata': serializer.toJson<String?>(metadata),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completedNotes': serializer.toJson<String?>(completedNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedActivity copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? title,
    Value<String?> description = const Value.absent(),
    String? category,
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> trailerUrl = const Value.absent(),
    String? privacy,
    String? status,
    String? mode,
    Value<String?> metadata = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> completedNotes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedActivity(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category ?? this.category,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    trailerUrl: trailerUrl.present ? trailerUrl.value : this.trailerUrl,
    privacy: privacy ?? this.privacy,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    metadata: metadata.present ? metadata.value : this.metadata,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedNotes: completedNotes.present
        ? completedNotes.value
        : this.completedNotes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedActivity copyWithCompanion(CachedActivitiesCompanion data) {
    return CachedActivity(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      trailerUrl: data.trailerUrl.present
          ? data.trailerUrl.value
          : this.trailerUrl,
      privacy: data.privacy.present ? data.privacy.value : this.privacy,
      status: data.status.present ? data.status.value : this.status,
      mode: data.mode.present ? data.mode.value : this.mode,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completedNotes: data.completedNotes.present
          ? data.completedNotes.value
          : this.completedNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivity(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('trailerUrl: $trailerUrl, ')
          ..write('privacy: $privacy, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('metadata: $metadata, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedNotes: $completedNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    title,
    description,
    category,
    thumbnailUrl,
    trailerUrl,
    privacy,
    status,
    mode,
    metadata,
    completedAt,
    completedNotes,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedActivity &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.trailerUrl == this.trailerUrl &&
          other.privacy == this.privacy &&
          other.status == this.status &&
          other.mode == this.mode &&
          other.metadata == this.metadata &&
          other.completedAt == this.completedAt &&
          other.completedNotes == this.completedNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedActivitiesCompanion extends UpdateCompanion<CachedActivity> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> category;
  final Value<String?> thumbnailUrl;
  final Value<String?> trailerUrl;
  final Value<String> privacy;
  final Value<String> status;
  final Value<String> mode;
  final Value<String?> metadata;
  final Value<DateTime?> completedAt;
  final Value<String?> completedNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedActivitiesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.trailerUrl = const Value.absent(),
    this.privacy = const Value.absent(),
    this.status = const Value.absent(),
    this.mode = const Value.absent(),
    this.metadata = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedActivitiesCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    this.description = const Value.absent(),
    required String category,
    this.thumbnailUrl = const Value.absent(),
    this.trailerUrl = const Value.absent(),
    required String privacy,
    required String status,
    required String mode,
    this.metadata = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedNotes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       title = Value(title),
       category = Value(category),
       privacy = Value(privacy),
       status = Value(status),
       mode = Value(mode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedActivity> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? thumbnailUrl,
    Expression<String>? trailerUrl,
    Expression<String>? privacy,
    Expression<String>? status,
    Expression<String>? mode,
    Expression<String>? metadata,
    Expression<DateTime>? completedAt,
    Expression<String>? completedNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (trailerUrl != null) 'trailer_url': trailerUrl,
      if (privacy != null) 'privacy': privacy,
      if (status != null) 'status': status,
      if (mode != null) 'mode': mode,
      if (metadata != null) 'metadata': metadata,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedNotes != null) 'completed_notes': completedNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? category,
    Value<String?>? thumbnailUrl,
    Value<String?>? trailerUrl,
    Value<String>? privacy,
    Value<String>? status,
    Value<String>? mode,
    Value<String?>? metadata,
    Value<DateTime?>? completedAt,
    Value<String?>? completedNotes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedActivitiesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      metadata: metadata ?? this.metadata,
      completedAt: completedAt ?? this.completedAt,
      completedNotes: completedNotes ?? this.completedNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (trailerUrl.present) {
      map['trailer_url'] = Variable<String>(trailerUrl.value);
    }
    if (privacy.present) {
      map['privacy'] = Variable<String>(privacy.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completedNotes.present) {
      map['completed_notes'] = Variable<String>(completedNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('trailerUrl: $trailerUrl, ')
          ..write('privacy: $privacy, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('metadata: $metadata, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedNotes: $completedNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedActivityVotesTable extends CachedActivityVotes
    with TableInfo<$CachedActivityVotesTable, CachedActivityVote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedActivityVotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_activities (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    userId,
    score,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_activity_votes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedActivityVote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedActivityVote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedActivityVote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedActivityVotesTable createAlias(String alias) {
    return $CachedActivityVotesTable(attachedDatabase, alias);
  }
}

class CachedActivityVote extends DataClass
    implements Insertable<CachedActivityVote> {
  final String id;
  final String activityId;
  final String userId;
  final int score;
  final DateTime createdAt;
  final DateTime syncedAt;
  const CachedActivityVote({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.score,
    required this.createdAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['user_id'] = Variable<String>(userId);
    map['score'] = Variable<int>(score);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedActivityVotesCompanion toCompanion(bool nullToAbsent) {
    return CachedActivityVotesCompanion(
      id: Value(id),
      activityId: Value(activityId),
      userId: Value(userId),
      score: Value(score),
      createdAt: Value(createdAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedActivityVote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedActivityVote(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      userId: serializer.fromJson<String>(json['userId']),
      score: serializer.fromJson<int>(json['score']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'userId': serializer.toJson<String>(userId),
      'score': serializer.toJson<int>(score),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedActivityVote copyWith({
    String? id,
    String? activityId,
    String? userId,
    int? score,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) => CachedActivityVote(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    userId: userId ?? this.userId,
    score: score ?? this.score,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedActivityVote copyWithCompanion(CachedActivityVotesCompanion data) {
    return CachedActivityVote(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      userId: data.userId.present ? data.userId.value : this.userId,
      score: data.score.present ? data.score.value : this.score,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivityVote(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('userId: $userId, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, activityId, userId, score, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedActivityVote &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.userId == this.userId &&
          other.score == this.score &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class CachedActivityVotesCompanion extends UpdateCompanion<CachedActivityVote> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> userId;
  final Value<int> score;
  final Value<DateTime> createdAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedActivityVotesCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.userId = const Value.absent(),
    this.score = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedActivityVotesCompanion.insert({
    required String id,
    required String activityId,
    required String userId,
    required int score,
    required DateTime createdAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       userId = Value(userId),
       score = Value(score),
       createdAt = Value(createdAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedActivityVote> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? userId,
    Expression<int>? score,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (userId != null) 'user_id': userId,
      if (score != null) 'score': score,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedActivityVotesCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? userId,
    Value<int>? score,
    Value<DateTime>? createdAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedActivityVotesCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivityVotesCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('userId: $userId, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCalendarEventsTable extends CachedCalendarEvents
    with TableInfo<$CachedCalendarEventsTable, CachedCalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceModuleMeta = const VerificationMeta(
    'sourceModule',
  );
  @override
  late final GeneratedColumn<String> sourceModule = GeneratedColumn<String>(
    'source_module',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEntityIdMeta = const VerificationMeta(
    'sourceEntityId',
  );
  @override
  late final GeneratedColumn<String> sourceEntityId = GeneratedColumn<String>(
    'source_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    title,
    location,
    eventType,
    allDay,
    startAt,
    endAt,
    recurrenceRule,
    sourceModule,
    sourceEntityId,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('source_module')) {
      context.handle(
        _sourceModuleMeta,
        sourceModule.isAcceptableOrUnknown(
          data['source_module']!,
          _sourceModuleMeta,
        ),
      );
    }
    if (data.containsKey('source_entity_id')) {
      context.handle(
        _sourceEntityIdMeta,
        sourceEntityId.isAcceptableOrUnknown(
          data['source_entity_id']!,
          _sourceEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      sourceModule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_module'],
      ),
      sourceEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entity_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedCalendarEventsTable createAlias(String alias) {
    return $CachedCalendarEventsTable(attachedDatabase, alias);
  }
}

class CachedCalendarEvent extends DataClass
    implements Insertable<CachedCalendarEvent> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String title;
  final String? location;
  final String eventType;
  final bool allDay;
  final DateTime startAt;
  final DateTime endAt;
  final String? recurrenceRule;
  final String? sourceModule;
  final String? sourceEntityId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedCalendarEvent({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.location,
    required this.eventType,
    required this.allDay,
    required this.startAt,
    required this.endAt,
    this.recurrenceRule,
    this.sourceModule,
    this.sourceEntityId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['event_type'] = Variable<String>(eventType);
    map['all_day'] = Variable<bool>(allDay);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || sourceModule != null) {
      map['source_module'] = Variable<String>(sourceModule);
    }
    if (!nullToAbsent || sourceEntityId != null) {
      map['source_entity_id'] = Variable<String>(sourceEntityId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedCalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedCalendarEventsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      title: Value(title),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      eventType: Value(eventType),
      allDay: Value(allDay),
      startAt: Value(startAt),
      endAt: Value(endAt),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      sourceModule: sourceModule == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceModule),
      sourceEntityId: sourceEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntityId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedCalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      location: serializer.fromJson<String?>(json['location']),
      eventType: serializer.fromJson<String>(json['eventType']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      sourceModule: serializer.fromJson<String?>(json['sourceModule']),
      sourceEntityId: serializer.fromJson<String?>(json['sourceEntityId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'title': serializer.toJson<String>(title),
      'location': serializer.toJson<String?>(location),
      'eventType': serializer.toJson<String>(eventType),
      'allDay': serializer.toJson<bool>(allDay),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'sourceModule': serializer.toJson<String?>(sourceModule),
      'sourceEntityId': serializer.toJson<String?>(sourceEntityId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedCalendarEvent copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? title,
    Value<String?> location = const Value.absent(),
    String? eventType,
    bool? allDay,
    DateTime? startAt,
    DateTime? endAt,
    Value<String?> recurrenceRule = const Value.absent(),
    Value<String?> sourceModule = const Value.absent(),
    Value<String?> sourceEntityId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedCalendarEvent(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    title: title ?? this.title,
    location: location.present ? location.value : this.location,
    eventType: eventType ?? this.eventType,
    allDay: allDay ?? this.allDay,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    sourceModule: sourceModule.present ? sourceModule.value : this.sourceModule,
    sourceEntityId: sourceEntityId.present
        ? sourceEntityId.value
        : this.sourceEntityId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedCalendarEvent copyWithCompanion(CachedCalendarEventsCompanion data) {
    return CachedCalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      location: data.location.present ? data.location.value : this.location,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      sourceModule: data.sourceModule.present
          ? data.sourceModule.value
          : this.sourceModule,
      sourceEntityId: data.sourceEntityId.present
          ? data.sourceEntityId.value
          : this.sourceEntityId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCalendarEvent(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('eventType: $eventType, ')
          ..write('allDay: $allDay, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('sourceModule: $sourceModule, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    title,
    location,
    eventType,
    allDay,
    startAt,
    endAt,
    recurrenceRule,
    sourceModule,
    sourceEntityId,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCalendarEvent &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.location == this.location &&
          other.eventType == this.eventType &&
          other.allDay == this.allDay &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.recurrenceRule == this.recurrenceRule &&
          other.sourceModule == this.sourceModule &&
          other.sourceEntityId == this.sourceEntityId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedCalendarEventsCompanion
    extends UpdateCompanion<CachedCalendarEvent> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> title;
  final Value<String?> location;
  final Value<String> eventType;
  final Value<bool> allDay;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<String?> recurrenceRule;
  final Value<String?> sourceModule;
  final Value<String?> sourceEntityId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedCalendarEventsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.location = const Value.absent(),
    this.eventType = const Value.absent(),
    this.allDay = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.sourceModule = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCalendarEventsCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    this.location = const Value.absent(),
    required String eventType,
    this.allDay = const Value.absent(),
    required DateTime startAt,
    required DateTime endAt,
    this.recurrenceRule = const Value.absent(),
    this.sourceModule = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       title = Value(title),
       eventType = Value(eventType),
       startAt = Value(startAt),
       endAt = Value(endAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedCalendarEvent> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? location,
    Expression<String>? eventType,
    Expression<bool>? allDay,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? recurrenceRule,
    Expression<String>? sourceModule,
    Expression<String>? sourceEntityId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (location != null) 'location': location,
      if (eventType != null) 'event_type': eventType,
      if (allDay != null) 'all_day': allDay,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (sourceModule != null) 'source_module': sourceModule,
      if (sourceEntityId != null) 'source_entity_id': sourceEntityId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCalendarEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? title,
    Value<String?>? location,
    Value<String>? eventType,
    Value<bool>? allDay,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<String?>? recurrenceRule,
    Value<String?>? sourceModule,
    Value<String?>? sourceEntityId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedCalendarEventsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      allDay: allDay ?? this.allDay,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      sourceModule: sourceModule ?? this.sourceModule,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (sourceModule.present) {
      map['source_module'] = Variable<String>(sourceModule.value);
    }
    if (sourceEntityId.present) {
      map['source_entity_id'] = Variable<String>(sourceEntityId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('eventType: $eventType, ')
          ..write('allDay: $allDay, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('sourceModule: $sourceModule, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTasksTable extends CachedTasks
    with TableInfo<$CachedTasksTable, CachedTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentTaskIdMeta = const VerificationMeta(
    'parentTaskId',
  );
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
    'parent_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    title,
    description,
    status,
    priority,
    dueDate,
    parentTaskId,
    isRecurring,
    recurrenceRule,
    completedAt,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
        _parentTaskIdMeta,
        parentTaskId.isAcceptableOrUnknown(
          data['parent_task_id']!,
          _parentTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      parentTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_task_id'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedTasksTable createAlias(String alias) {
    return $CachedTasksTable(attachedDatabase, alias);
  }
}

class CachedTask extends DataClass implements Insertable<CachedTask> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String? parentTaskId;
  final bool isRecurring;
  final String? recurrenceRule;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedTask({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.parentTaskId,
    required this.isRecurring,
    this.recurrenceRule,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<String>(parentTaskId);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedTasksCompanion toCompanion(bool nullToAbsent) {
    return CachedTasksCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      priority: Value(priority),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
      isRecurring: Value(isRecurring),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTask(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      parentTaskId: serializer.fromJson<String?>(json['parentTaskId']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'parentTaskId': serializer.toJson<String?>(parentTaskId),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedTask copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? title,
    Value<String?> description = const Value.absent(),
    String? status,
    String? priority,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> parentTaskId = const Value.absent(),
    bool? isRecurring,
    Value<String?> recurrenceRule = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedTask(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    parentTaskId: parentTaskId.present ? parentTaskId.value : this.parentTaskId,
    isRecurring: isRecurring ?? this.isRecurring,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedTask copyWithCompanion(CachedTasksCompanion data) {
    return CachedTask(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTask(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    title,
    description,
    status,
    priority,
    dueDate,
    parentTaskId,
    isRecurring,
    recurrenceRule,
    completedAt,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTask &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.dueDate == this.dueDate &&
          other.parentTaskId == this.parentTaskId &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceRule == this.recurrenceRule &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedTasksCompanion extends UpdateCompanion<CachedTask> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<String> priority;
  final Value<DateTime?> dueDate;
  final Value<String?> parentTaskId;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceRule;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedTasksCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTasksCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    this.description = const Value.absent(),
    required String status,
    required String priority,
    this.dueDate = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       title = Value(title),
       status = Value(status),
       priority = Value(priority),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedTask> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<DateTime>? dueDate,
    Expression<String>? parentTaskId,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceRule,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? status,
    Value<String>? priority,
    Value<DateTime?>? dueDate,
    Value<String?>? parentTaskId,
    Value<bool>? isRecurring,
    Value<String?>? recurrenceRule,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedTasksCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTasksCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRemindersTable extends CachedReminders
    with TableInfo<$CachedRemindersTable, CachedReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerAtMeta = const VerificationMeta(
    'triggerAt',
  );
  @override
  late final GeneratedColumn<DateTime> triggerAt = GeneratedColumn<DateTime>(
    'trigger_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedModuleMeta = const VerificationMeta(
    'linkedModule',
  );
  @override
  late final GeneratedColumn<String> linkedModule = GeneratedColumn<String>(
    'linked_module',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedEntityIdMeta = const VerificationMeta(
    'linkedEntityId',
  );
  @override
  late final GeneratedColumn<String> linkedEntityId = GeneratedColumn<String>(
    'linked_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSentMeta = const VerificationMeta('isSent');
  @override
  late final GeneratedColumn<bool> isSent = GeneratedColumn<bool>(
    'is_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    message,
    triggerAt,
    recurrenceRule,
    linkedModule,
    linkedEntityId,
    isSent,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('trigger_at')) {
      context.handle(
        _triggerAtMeta,
        triggerAt.isAcceptableOrUnknown(data['trigger_at']!, _triggerAtMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerAtMeta);
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('linked_module')) {
      context.handle(
        _linkedModuleMeta,
        linkedModule.isAcceptableOrUnknown(
          data['linked_module']!,
          _linkedModuleMeta,
        ),
      );
    }
    if (data.containsKey('linked_entity_id')) {
      context.handle(
        _linkedEntityIdMeta,
        linkedEntityId.isAcceptableOrUnknown(
          data['linked_entity_id']!,
          _linkedEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('is_sent')) {
      context.handle(
        _isSentMeta,
        isSent.isAcceptableOrUnknown(data['is_sent']!, _isSentMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      triggerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trigger_at'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      linkedModule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_module'],
      ),
      linkedEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_entity_id'],
      ),
      isSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sent'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedRemindersTable createAlias(String alias) {
    return $CachedRemindersTable(attachedDatabase, alias);
  }
}

class CachedReminder extends DataClass implements Insertable<CachedReminder> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String message;
  final DateTime triggerAt;
  final String? recurrenceRule;
  final String? linkedModule;
  final String? linkedEntityId;
  final bool isSent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedReminder({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.message,
    required this.triggerAt,
    this.recurrenceRule,
    this.linkedModule,
    this.linkedEntityId,
    required this.isSent,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['message'] = Variable<String>(message);
    map['trigger_at'] = Variable<DateTime>(triggerAt);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || linkedModule != null) {
      map['linked_module'] = Variable<String>(linkedModule);
    }
    if (!nullToAbsent || linkedEntityId != null) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId);
    }
    map['is_sent'] = Variable<bool>(isSent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedRemindersCompanion toCompanion(bool nullToAbsent) {
    return CachedRemindersCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      message: Value(message),
      triggerAt: Value(triggerAt),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      linkedModule: linkedModule == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedModule),
      linkedEntityId: linkedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedEntityId),
      isSent: Value(isSent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedReminder(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      message: serializer.fromJson<String>(json['message']),
      triggerAt: serializer.fromJson<DateTime>(json['triggerAt']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      linkedModule: serializer.fromJson<String?>(json['linkedModule']),
      linkedEntityId: serializer.fromJson<String?>(json['linkedEntityId']),
      isSent: serializer.fromJson<bool>(json['isSent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'message': serializer.toJson<String>(message),
      'triggerAt': serializer.toJson<DateTime>(triggerAt),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'linkedModule': serializer.toJson<String?>(linkedModule),
      'linkedEntityId': serializer.toJson<String?>(linkedEntityId),
      'isSent': serializer.toJson<bool>(isSent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedReminder copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? message,
    DateTime? triggerAt,
    Value<String?> recurrenceRule = const Value.absent(),
    Value<String?> linkedModule = const Value.absent(),
    Value<String?> linkedEntityId = const Value.absent(),
    bool? isSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedReminder(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    message: message ?? this.message,
    triggerAt: triggerAt ?? this.triggerAt,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    linkedModule: linkedModule.present ? linkedModule.value : this.linkedModule,
    linkedEntityId: linkedEntityId.present
        ? linkedEntityId.value
        : this.linkedEntityId,
    isSent: isSent ?? this.isSent,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedReminder copyWithCompanion(CachedRemindersCompanion data) {
    return CachedReminder(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      message: data.message.present ? data.message.value : this.message,
      triggerAt: data.triggerAt.present ? data.triggerAt.value : this.triggerAt,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      linkedModule: data.linkedModule.present
          ? data.linkedModule.value
          : this.linkedModule,
      linkedEntityId: data.linkedEntityId.present
          ? data.linkedEntityId.value
          : this.linkedEntityId,
      isSent: data.isSent.present ? data.isSent.value : this.isSent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedReminder(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('message: $message, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('linkedModule: $linkedModule, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('isSent: $isSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    message,
    triggerAt,
    recurrenceRule,
    linkedModule,
    linkedEntityId,
    isSent,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedReminder &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.message == this.message &&
          other.triggerAt == this.triggerAt &&
          other.recurrenceRule == this.recurrenceRule &&
          other.linkedModule == this.linkedModule &&
          other.linkedEntityId == this.linkedEntityId &&
          other.isSent == this.isSent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedRemindersCompanion extends UpdateCompanion<CachedReminder> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> message;
  final Value<DateTime> triggerAt;
  final Value<String?> recurrenceRule;
  final Value<String?> linkedModule;
  final Value<String?> linkedEntityId;
  final Value<bool> isSent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedRemindersCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.message = const Value.absent(),
    this.triggerAt = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.linkedModule = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.isSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRemindersCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String message,
    required DateTime triggerAt,
    this.recurrenceRule = const Value.absent(),
    this.linkedModule = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.isSent = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       message = Value(message),
       triggerAt = Value(triggerAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedReminder> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? message,
    Expression<DateTime>? triggerAt,
    Expression<String>? recurrenceRule,
    Expression<String>? linkedModule,
    Expression<String>? linkedEntityId,
    Expression<bool>? isSent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (message != null) 'message': message,
      if (triggerAt != null) 'trigger_at': triggerAt,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (linkedModule != null) 'linked_module': linkedModule,
      if (linkedEntityId != null) 'linked_entity_id': linkedEntityId,
      if (isSent != null) 'is_sent': isSent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? message,
    Value<DateTime>? triggerAt,
    Value<String?>? recurrenceRule,
    Value<String?>? linkedModule,
    Value<String?>? linkedEntityId,
    Value<bool>? isSent,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedRemindersCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      message: message ?? this.message,
      triggerAt: triggerAt ?? this.triggerAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      linkedModule: linkedModule ?? this.linkedModule,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (triggerAt.present) {
      map['trigger_at'] = Variable<DateTime>(triggerAt.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (linkedModule.present) {
      map['linked_module'] = Variable<String>(linkedModule.value);
    }
    if (linkedEntityId.present) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId.value);
    }
    if (isSent.present) {
      map['is_sent'] = Variable<bool>(isSent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRemindersCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('message: $message, ')
          ..write('triggerAt: $triggerAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('linkedModule: $linkedModule, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('isSent: $isSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedGroceryListsTable extends CachedGroceryLists
    with TableInfo<$CachedGroceryListsTable, CachedGroceryList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedGroceryListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
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
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    name,
    createdBy,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_grocery_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedGroceryList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedGroceryList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedGroceryList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedGroceryListsTable createAlias(String alias) {
    return $CachedGroceryListsTable(attachedDatabase, alias);
  }
}

class CachedGroceryList extends DataClass
    implements Insertable<CachedGroceryList> {
  final String id;
  final String spaceId;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedGroceryList({
    required this.id,
    required this.spaceId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['name'] = Variable<String>(name);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedGroceryListsCompanion toCompanion(bool nullToAbsent) {
    return CachedGroceryListsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      name: Value(name),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedGroceryList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedGroceryList(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      name: serializer.fromJson<String>(json['name']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'name': serializer.toJson<String>(name),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedGroceryList copyWith({
    String? id,
    String? spaceId,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedGroceryList(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    name: name ?? this.name,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedGroceryList copyWithCompanion(CachedGroceryListsCompanion data) {
    return CachedGroceryList(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      name: data.name.present ? data.name.value : this.name,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroceryList(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, spaceId, name, createdBy, createdAt, updatedAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedGroceryList &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.name == this.name &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedGroceryListsCompanion extends UpdateCompanion<CachedGroceryList> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> name;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedGroceryListsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedGroceryListsCompanion.insert({
    required String id,
    required String spaceId,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       name = Value(name),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedGroceryList> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? name,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (name != null) 'name': name,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedGroceryListsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? name,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedGroceryListsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroceryListsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedGroceryItemsTable extends CachedGroceryItems
    with TableInfo<$CachedGroceryItemsTable, CachedGroceryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedGroceryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_grocery_lists (id)',
    ),
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checkedByMeta = const VerificationMeta(
    'checkedBy',
  );
  @override
  late final GeneratedColumn<String> checkedBy = GeneratedColumn<String>(
    'checked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    name,
    quantity,
    unit,
    category,
    note,
    isChecked,
    checkedBy,
    checkedAt,
    priceCents,
    displayOrder,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_grocery_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedGroceryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    if (data.containsKey('checked_by')) {
      context.handle(
        _checkedByMeta,
        checkedBy.isAcceptableOrUnknown(data['checked_by']!, _checkedByMeta),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedGroceryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedGroceryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
      checkedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checked_by'],
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      ),
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedGroceryItemsTable createAlias(String alias) {
    return $CachedGroceryItemsTable(attachedDatabase, alias);
  }
}

class CachedGroceryItem extends DataClass
    implements Insertable<CachedGroceryItem> {
  final String id;
  final String listId;
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;
  final String? note;
  final bool isChecked;
  final String? checkedBy;
  final DateTime? checkedAt;
  final int? priceCents;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedGroceryItem({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    this.note,
    required this.isChecked,
    this.checkedBy,
    this.checkedAt,
    this.priceCents,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_checked'] = Variable<bool>(isChecked);
    if (!nullToAbsent || checkedBy != null) {
      map['checked_by'] = Variable<String>(checkedBy);
    }
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    if (!nullToAbsent || priceCents != null) {
      map['price_cents'] = Variable<int>(priceCents);
    }
    map['display_order'] = Variable<int>(displayOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedGroceryItemsCompanion toCompanion(bool nullToAbsent) {
    return CachedGroceryItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isChecked: Value(isChecked),
      checkedBy: checkedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedBy),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
      priceCents: priceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(priceCents),
      displayOrder: Value(displayOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedGroceryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedGroceryItem(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      checkedBy: serializer.fromJson<String?>(json['checkedBy']),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
      priceCents: serializer.fromJson<int?>(json['priceCents']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'category': serializer.toJson<String?>(category),
      'note': serializer.toJson<String?>(note),
      'isChecked': serializer.toJson<bool>(isChecked),
      'checkedBy': serializer.toJson<String?>(checkedBy),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
      'priceCents': serializer.toJson<int?>(priceCents),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedGroceryItem copyWith({
    String? id,
    String? listId,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isChecked,
    Value<String?> checkedBy = const Value.absent(),
    Value<DateTime?> checkedAt = const Value.absent(),
    Value<int?> priceCents = const Value.absent(),
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedGroceryItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    category: category.present ? category.value : this.category,
    note: note.present ? note.value : this.note,
    isChecked: isChecked ?? this.isChecked,
    checkedBy: checkedBy.present ? checkedBy.value : this.checkedBy,
    checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
    priceCents: priceCents.present ? priceCents.value : this.priceCents,
    displayOrder: displayOrder ?? this.displayOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedGroceryItem copyWithCompanion(CachedGroceryItemsCompanion data) {
    return CachedGroceryItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      checkedBy: data.checkedBy.present ? data.checkedBy.value : this.checkedBy,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroceryItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedBy: $checkedBy, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('priceCents: $priceCents, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    name,
    quantity,
    unit,
    category,
    note,
    isChecked,
    checkedBy,
    checkedAt,
    priceCents,
    displayOrder,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedGroceryItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.note == this.note &&
          other.isChecked == this.isChecked &&
          other.checkedBy == this.checkedBy &&
          other.checkedAt == this.checkedAt &&
          other.priceCents == this.priceCents &&
          other.displayOrder == this.displayOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedGroceryItemsCompanion extends UpdateCompanion<CachedGroceryItem> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<String?> category;
  final Value<String?> note;
  final Value<bool> isChecked;
  final Value<String?> checkedBy;
  final Value<DateTime?> checkedAt;
  final Value<int?> priceCents;
  final Value<int> displayOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedGroceryItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedBy = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedGroceryItemsCompanion.insert({
    required String id,
    required String listId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedBy = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.displayOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedGroceryItem> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<String>? note,
    Expression<bool>? isChecked,
    Expression<String>? checkedBy,
    Expression<DateTime>? checkedAt,
    Expression<int>? priceCents,
    Expression<int>? displayOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (isChecked != null) 'is_checked': isChecked,
      if (checkedBy != null) 'checked_by': checkedBy,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (priceCents != null) 'price_cents': priceCents,
      if (displayOrder != null) 'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedGroceryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? name,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<String?>? category,
    Value<String?>? note,
    Value<bool>? isChecked,
    Value<String?>? checkedBy,
    Value<DateTime?>? checkedAt,
    Value<int?>? priceCents,
    Value<int>? displayOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedGroceryItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      note: note ?? this.note,
      isChecked: isChecked ?? this.isChecked,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
      priceCents: priceCents ?? this.priceCents,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (checkedBy.present) {
      map['checked_by'] = Variable<String>(checkedBy.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroceryItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedBy: $checkedBy, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('priceCents: $priceCents, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedNotificationsTable extends CachedNotifications
    with TableInfo<$CachedNotificationsTable, CachedNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceModuleMeta = const VerificationMeta(
    'sourceModule',
  );
  @override
  late final GeneratedColumn<String> sourceModule = GeneratedColumn<String>(
    'source_module',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEntityIdMeta = const VerificationMeta(
    'sourceEntityId',
  );
  @override
  late final GeneratedColumn<String> sourceEntityId = GeneratedColumn<String>(
    'source_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    spaceId,
    type,
    title,
    body,
    sourceModule,
    sourceEntityId,
    isRead,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('source_module')) {
      context.handle(
        _sourceModuleMeta,
        sourceModule.isAcceptableOrUnknown(
          data['source_module']!,
          _sourceModuleMeta,
        ),
      );
    }
    if (data.containsKey('source_entity_id')) {
      context.handle(
        _sourceEntityIdMeta,
        sourceEntityId.isAcceptableOrUnknown(
          data['source_entity_id']!,
          _sourceEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      sourceModule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_module'],
      ),
      sourceEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entity_id'],
      ),
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedNotificationsTable createAlias(String alias) {
    return $CachedNotificationsTable(attachedDatabase, alias);
  }
}

class CachedNotification extends DataClass
    implements Insertable<CachedNotification> {
  final String id;
  final String userId;
  final String? spaceId;
  final String type;
  final String title;
  final String body;
  final String? sourceModule;
  final String? sourceEntityId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime syncedAt;
  const CachedNotification({
    required this.id,
    required this.userId,
    this.spaceId,
    required this.type,
    required this.title,
    required this.body,
    this.sourceModule,
    this.sourceEntityId,
    required this.isRead,
    required this.createdAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || sourceModule != null) {
      map['source_module'] = Variable<String>(sourceModule);
    }
    if (!nullToAbsent || sourceEntityId != null) {
      map['source_entity_id'] = Variable<String>(sourceEntityId);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedNotificationsCompanion toCompanion(bool nullToAbsent) {
    return CachedNotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      sourceModule: sourceModule == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceModule),
      sourceEntityId: sourceEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntityId),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedNotification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      sourceModule: serializer.fromJson<String?>(json['sourceModule']),
      sourceEntityId: serializer.fromJson<String?>(json['sourceEntityId']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'spaceId': serializer.toJson<String?>(spaceId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'sourceModule': serializer.toJson<String?>(sourceModule),
      'sourceEntityId': serializer.toJson<String?>(sourceEntityId),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedNotification copyWith({
    String? id,
    String? userId,
    Value<String?> spaceId = const Value.absent(),
    String? type,
    String? title,
    String? body,
    Value<String?> sourceModule = const Value.absent(),
    Value<String?> sourceEntityId = const Value.absent(),
    bool? isRead,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) => CachedNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    spaceId: spaceId.present ? spaceId.value : this.spaceId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    sourceModule: sourceModule.present ? sourceModule.value : this.sourceModule,
    sourceEntityId: sourceEntityId.present
        ? sourceEntityId.value
        : this.sourceEntityId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedNotification copyWithCompanion(CachedNotificationsCompanion data) {
    return CachedNotification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      sourceModule: data.sourceModule.present
          ? data.sourceModule.value
          : this.sourceModule,
      sourceEntityId: data.sourceEntityId.present
          ? data.sourceEntityId.value
          : this.sourceEntityId,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('sourceModule: $sourceModule, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    spaceId,
    type,
    title,
    body,
    sourceModule,
    sourceEntityId,
    isRead,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedNotification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.spaceId == this.spaceId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.sourceModule == this.sourceModule &&
          other.sourceEntityId == this.sourceEntityId &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class CachedNotificationsCompanion extends UpdateCompanion<CachedNotification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> spaceId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> sourceModule;
  final Value<String?> sourceEntityId;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedNotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.sourceModule = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedNotificationsCompanion.insert({
    required String id,
    required String userId,
    this.spaceId = const Value.absent(),
    required String type,
    required String title,
    required String body,
    this.sourceModule = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime createdAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedNotification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? spaceId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? sourceModule,
    Expression<String>? sourceEntityId,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (spaceId != null) 'space_id': spaceId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (sourceModule != null) 'source_module': sourceModule,
      if (sourceEntityId != null) 'source_entity_id': sourceEntityId,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedNotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? spaceId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? sourceModule,
    Value<String?>? sourceEntityId,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedNotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      spaceId: spaceId ?? this.spaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      sourceModule: sourceModule ?? this.sourceModule,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (sourceModule.present) {
      map['source_module'] = Variable<String>(sourceModule.value);
    }
    if (sourceEntityId.present) {
      map['source_entity_id'] = Variable<String>(sourceEntityId.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('sourceModule: $sourceModule, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedConversationsTable extends CachedConversations
    with TableInfo<$CachedConversationsTable, CachedConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    type,
    title,
    createdBy,
    lastMessagePreview,
    lastMessageAt,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedConversationsTable createAlias(String alias) {
    return $CachedConversationsTable(attachedDatabase, alias);
  }
}

class CachedConversation extends DataClass
    implements Insertable<CachedConversation> {
  final String id;
  final String spaceId;
  final String type;
  final String? title;
  final String createdBy;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedConversation({
    required this.id,
    required this.spaceId,
    required this.type,
    this.title,
    required this.createdBy,
    this.lastMessagePreview,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedConversationsCompanion toCompanion(bool nullToAbsent) {
    return CachedConversationsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdBy: Value(createdBy),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedConversation(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'createdBy': serializer.toJson<String>(createdBy),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedConversation copyWith({
    String? id,
    String? spaceId,
    String? type,
    Value<String?> title = const Value.absent(),
    String? createdBy,
    Value<String?> lastMessagePreview = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedConversation(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    createdBy: createdBy ?? this.createdBy,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedConversation copyWithCompanion(CachedConversationsCompanion data) {
    return CachedConversation(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedConversation(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('createdBy: $createdBy, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    type,
    title,
    createdBy,
    lastMessagePreview,
    lastMessageAt,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedConversation &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.type == this.type &&
          other.title == this.title &&
          other.createdBy == this.createdBy &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedConversationsCompanion extends UpdateCompanion<CachedConversation> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> type;
  final Value<String?> title;
  final Value<String> createdBy;
  final Value<String?> lastMessagePreview;
  final Value<DateTime?> lastMessageAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedConversationsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedConversationsCompanion.insert({
    required String id,
    required String spaceId,
    required String type,
    this.title = const Value.absent(),
    required String createdBy,
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       type = Value(type),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedConversation> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? createdBy,
    Expression<String>? lastMessagePreview,
    Expression<DateTime>? lastMessageAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (createdBy != null) 'created_by': createdBy,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? type,
    Value<String?>? title,
    Value<String>? createdBy,
    Value<String?>? lastMessagePreview,
    Value<DateTime?>? lastMessageAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedConversationsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedConversationsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('createdBy: $createdBy, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMessagesTable extends CachedMessages
    with TableInfo<$CachedMessagesTable, CachedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_conversations (id)',
    ),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyToMessageIdMeta = const VerificationMeta(
    'replyToMessageId',
  );
  @override
  late final GeneratedColumn<String> replyToMessageId = GeneratedColumn<String>(
    'reply_to_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEditedMeta = const VerificationMeta(
    'isEdited',
  );
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
    'is_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    senderId,
    content,
    contentType,
    replyToMessageId,
    isEdited,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('reply_to_message_id')) {
      context.handle(
        _replyToMessageIdMeta,
        replyToMessageId.isAcceptableOrUnknown(
          data['reply_to_message_id']!,
          _replyToMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('is_edited')) {
      context.handle(
        _isEditedMeta,
        isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      replyToMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_message_id'],
      ),
      isEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_edited'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedMessagesTable createAlias(String alias) {
    return $CachedMessagesTable(attachedDatabase, alias);
  }
}

class CachedMessage extends DataClass implements Insertable<CachedMessage> {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String contentType;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.contentType,
    this.replyToMessageId,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['content'] = Variable<String>(content);
    map['content_type'] = Variable<String>(contentType);
    if (!nullToAbsent || replyToMessageId != null) {
      map['reply_to_message_id'] = Variable<String>(replyToMessageId);
    }
    map['is_edited'] = Variable<bool>(isEdited);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedMessagesCompanion toCompanion(bool nullToAbsent) {
    return CachedMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      content: Value(content),
      contentType: Value(contentType),
      replyToMessageId: replyToMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToMessageId),
      isEdited: Value(isEdited),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMessage(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      contentType: serializer.fromJson<String>(json['contentType']),
      replyToMessageId: serializer.fromJson<String?>(json['replyToMessageId']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String>(content),
      'contentType': serializer.toJson<String>(contentType),
      'replyToMessageId': serializer.toJson<String?>(replyToMessageId),
      'isEdited': serializer.toJson<bool>(isEdited),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? contentType,
    Value<String?> replyToMessageId = const Value.absent(),
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    contentType: contentType ?? this.contentType,
    replyToMessageId: replyToMessageId.present
        ? replyToMessageId.value
        : this.replyToMessageId,
    isEdited: isEdited ?? this.isEdited,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedMessage copyWithCompanion(CachedMessagesCompanion data) {
    return CachedMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      replyToMessageId: data.replyToMessageId.present
          ? data.replyToMessageId.value
          : this.replyToMessageId,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('isEdited: $isEdited, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    senderId,
    content,
    contentType,
    replyToMessageId,
    isEdited,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.contentType == this.contentType &&
          other.replyToMessageId == this.replyToMessageId &&
          other.isEdited == this.isEdited &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedMessagesCompanion extends UpdateCompanion<CachedMessage> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String> content;
  final Value<String> contentType;
  final Value<String?> replyToMessageId;
  final Value<bool> isEdited;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.contentType = const Value.absent(),
    this.replyToMessageId = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    required String contentType,
    this.replyToMessageId = const Value.absent(),
    this.isEdited = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       senderId = Value(senderId),
       content = Value(content),
       contentType = Value(contentType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedMessage> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? contentType,
    Expression<String>? replyToMessageId,
    Expression<bool>? isEdited,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (contentType != null) 'content_type': contentType,
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      if (isEdited != null) 'is_edited': isEdited,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? senderId,
    Value<String>? content,
    Value<String>? contentType,
    Value<String?>? replyToMessageId,
    Value<bool>? isEdited,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (replyToMessageId.present) {
      map['reply_to_message_id'] = Variable<String>(replyToMessageId.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('isEdited: $isEdited, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedFinanceEntriesTable extends CachedFinanceEntries
    with TableInfo<$CachedFinanceEntriesTable, CachedFinanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFinanceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    type,
    category,
    amountCents,
    currency,
    description,
    isRecurring,
    recurrenceRule,
    date,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_finance_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFinanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFinanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFinanceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedFinanceEntriesTable createAlias(String alias) {
    return $CachedFinanceEntriesTable(attachedDatabase, alias);
  }
}

class CachedFinanceEntry extends DataClass
    implements Insertable<CachedFinanceEntry> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String type;
  final String? category;
  final int amountCents;
  final String currency;
  final String? description;
  final bool isRecurring;
  final String? recurrenceRule;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedFinanceEntry({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.type,
    this.category,
    required this.amountCents,
    required this.currency,
    this.description,
    required this.isRecurring,
    this.recurrenceRule,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['amount_cents'] = Variable<int>(amountCents);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedFinanceEntriesCompanion toCompanion(bool nullToAbsent) {
    return CachedFinanceEntriesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      type: Value(type),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      amountCents: Value(amountCents),
      currency: Value(currency),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isRecurring: Value(isRecurring),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedFinanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFinanceEntry(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String?>(json['category']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<String>(json['currency']),
      description: serializer.fromJson<String?>(json['description']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String?>(category),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<String>(currency),
      'description': serializer.toJson<String?>(description),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedFinanceEntry copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? type,
    Value<String?> category = const Value.absent(),
    int? amountCents,
    String? currency,
    Value<String?> description = const Value.absent(),
    bool? isRecurring,
    Value<String?> recurrenceRule = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedFinanceEntry(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    type: type ?? this.type,
    category: category.present ? category.value : this.category,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    description: description.present ? description.value : this.description,
    isRecurring: isRecurring ?? this.isRecurring,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedFinanceEntry copyWithCompanion(CachedFinanceEntriesCompanion data) {
    return CachedFinanceEntry(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      description: data.description.present
          ? data.description.value
          : this.description,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFinanceEntry(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    type,
    category,
    amountCents,
    currency,
    description,
    isRecurring,
    recurrenceRule,
    date,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFinanceEntry &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.type == this.type &&
          other.category == this.category &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.description == this.description &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceRule == this.recurrenceRule &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedFinanceEntriesCompanion
    extends UpdateCompanion<CachedFinanceEntry> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> type;
  final Value<String?> category;
  final Value<int> amountCents;
  final Value<String> currency;
  final Value<String?> description;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceRule;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedFinanceEntriesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFinanceEntriesCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String type,
    this.category = const Value.absent(),
    required int amountCents,
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       type = Value(type),
       amountCents = Value(amountCents),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedFinanceEntry> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<String>? description,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceRule,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (description != null) 'description': description,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFinanceEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? type,
    Value<String?>? category,
    Value<int>? amountCents,
    Value<String>? currency,
    Value<String?>? description,
    Value<bool>? isRecurring,
    Value<String?>? recurrenceRule,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedFinanceEntriesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFinanceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedChartersTable extends CachedCharters
    with TableInfo<$CachedChartersTable, CachedCharter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChartersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAcknowledgedMeta = const VerificationMeta(
    'isAcknowledged',
  );
  @override
  late final GeneratedColumn<bool> isAcknowledged = GeneratedColumn<bool>(
    'is_acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_acknowledged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    content,
    versionNumber,
    editedBy,
    isAcknowledged,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_charters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCharter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    } else if (isInserting) {
      context.missing(_editedByMeta);
    }
    if (data.containsKey('is_acknowledged')) {
      context.handle(
        _isAcknowledgedMeta,
        isAcknowledged.isAcceptableOrUnknown(
          data['is_acknowledged']!,
          _isAcknowledgedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCharter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCharter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      isAcknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_acknowledged'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedChartersTable createAlias(String alias) {
    return $CachedChartersTable(attachedDatabase, alias);
  }
}

class CachedCharter extends DataClass implements Insertable<CachedCharter> {
  final String id;
  final String spaceId;
  final String content;
  final int versionNumber;
  final String editedBy;
  final bool isAcknowledged;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedCharter({
    required this.id,
    required this.spaceId,
    required this.content,
    required this.versionNumber,
    required this.editedBy,
    required this.isAcknowledged,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['content'] = Variable<String>(content);
    map['version_number'] = Variable<int>(versionNumber);
    map['edited_by'] = Variable<String>(editedBy);
    map['is_acknowledged'] = Variable<bool>(isAcknowledged);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedChartersCompanion toCompanion(bool nullToAbsent) {
    return CachedChartersCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      content: Value(content),
      versionNumber: Value(versionNumber),
      editedBy: Value(editedBy),
      isAcknowledged: Value(isAcknowledged),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedCharter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCharter(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      content: serializer.fromJson<String>(json['content']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      isAcknowledged: serializer.fromJson<bool>(json['isAcknowledged']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'content': serializer.toJson<String>(content),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'editedBy': serializer.toJson<String>(editedBy),
      'isAcknowledged': serializer.toJson<bool>(isAcknowledged),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedCharter copyWith({
    String? id,
    String? spaceId,
    String? content,
    int? versionNumber,
    String? editedBy,
    bool? isAcknowledged,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedCharter(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    content: content ?? this.content,
    versionNumber: versionNumber ?? this.versionNumber,
    editedBy: editedBy ?? this.editedBy,
    isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedCharter copyWithCompanion(CachedChartersCompanion data) {
    return CachedCharter(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      content: data.content.present ? data.content.value : this.content,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      isAcknowledged: data.isAcknowledged.present
          ? data.isAcknowledged.value
          : this.isAcknowledged,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCharter(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('content: $content, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('editedBy: $editedBy, ')
          ..write('isAcknowledged: $isAcknowledged, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    content,
    versionNumber,
    editedBy,
    isAcknowledged,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCharter &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.content == this.content &&
          other.versionNumber == this.versionNumber &&
          other.editedBy == this.editedBy &&
          other.isAcknowledged == this.isAcknowledged &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedChartersCompanion extends UpdateCompanion<CachedCharter> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> content;
  final Value<int> versionNumber;
  final Value<String> editedBy;
  final Value<bool> isAcknowledged;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedChartersCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.content = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.isAcknowledged = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChartersCompanion.insert({
    required String id,
    required String spaceId,
    required String content,
    this.versionNumber = const Value.absent(),
    required String editedBy,
    this.isAcknowledged = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       content = Value(content),
       editedBy = Value(editedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedCharter> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? content,
    Expression<int>? versionNumber,
    Expression<String>? editedBy,
    Expression<bool>? isAcknowledged,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (content != null) 'content': content,
      if (versionNumber != null) 'version_number': versionNumber,
      if (editedBy != null) 'edited_by': editedBy,
      if (isAcknowledged != null) 'is_acknowledged': isAcknowledged,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChartersCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? content,
    Value<int>? versionNumber,
    Value<String>? editedBy,
    Value<bool>? isAcknowledged,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedChartersCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      content: content ?? this.content,
      versionNumber: versionNumber ?? this.versionNumber,
      editedBy: editedBy ?? this.editedBy,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (isAcknowledged.present) {
      map['is_acknowledged'] = Variable<bool>(isAcknowledged.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChartersCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('content: $content, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('editedBy: $editedBy, ')
          ..write('isAcknowledged: $isAcknowledged, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPollsTable extends CachedPolls
    with TableInfo<$CachedPollsTable, CachedPoll> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPollsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _votesMeta = const VerificationMeta('votes');
  @override
  late final GeneratedColumn<String> votes = GeneratedColumn<String>(
    'votes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    question,
    options,
    votes,
    isActive,
    expiresAt,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_polls';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPoll> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    } else if (isInserting) {
      context.missing(_optionsMeta);
    }
    if (data.containsKey('votes')) {
      context.handle(
        _votesMeta,
        votes.isAcceptableOrUnknown(data['votes']!, _votesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPoll map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPoll(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      )!,
      votes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}votes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedPollsTable createAlias(String alias) {
    return $CachedPollsTable(attachedDatabase, alias);
  }
}

class CachedPoll extends DataClass implements Insertable<CachedPoll> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String question;
  final String options;
  final String? votes;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedPoll({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.question,
    required this.options,
    this.votes,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['question'] = Variable<String>(question);
    map['options'] = Variable<String>(options);
    if (!nullToAbsent || votes != null) {
      map['votes'] = Variable<String>(votes);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedPollsCompanion toCompanion(bool nullToAbsent) {
    return CachedPollsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      question: Value(question),
      options: Value(options),
      votes: votes == null && nullToAbsent
          ? const Value.absent()
          : Value(votes),
      isActive: Value(isActive),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedPoll.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPoll(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      question: serializer.fromJson<String>(json['question']),
      options: serializer.fromJson<String>(json['options']),
      votes: serializer.fromJson<String?>(json['votes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'question': serializer.toJson<String>(question),
      'options': serializer.toJson<String>(options),
      'votes': serializer.toJson<String?>(votes),
      'isActive': serializer.toJson<bool>(isActive),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedPoll copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? question,
    String? options,
    Value<String?> votes = const Value.absent(),
    bool? isActive,
    Value<DateTime?> expiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedPoll(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    question: question ?? this.question,
    options: options ?? this.options,
    votes: votes.present ? votes.value : this.votes,
    isActive: isActive ?? this.isActive,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedPoll copyWithCompanion(CachedPollsCompanion data) {
    return CachedPoll(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      question: data.question.present ? data.question.value : this.question,
      options: data.options.present ? data.options.value : this.options,
      votes: data.votes.present ? data.votes.value : this.votes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPoll(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('question: $question, ')
          ..write('options: $options, ')
          ..write('votes: $votes, ')
          ..write('isActive: $isActive, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    question,
    options,
    votes,
    isActive,
    expiresAt,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPoll &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.question == this.question &&
          other.options == this.options &&
          other.votes == this.votes &&
          other.isActive == this.isActive &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedPollsCompanion extends UpdateCompanion<CachedPoll> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> question;
  final Value<String> options;
  final Value<String?> votes;
  final Value<bool> isActive;
  final Value<DateTime?> expiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedPollsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.question = const Value.absent(),
    this.options = const Value.absent(),
    this.votes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPollsCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String question,
    required String options,
    this.votes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.expiresAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       question = Value(question),
       options = Value(options),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedPoll> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? question,
    Expression<String>? options,
    Expression<String>? votes,
    Expression<bool>? isActive,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (question != null) 'question': question,
      if (options != null) 'options': options,
      if (votes != null) 'votes': votes,
      if (isActive != null) 'is_active': isActive,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPollsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? question,
    Value<String>? options,
    Value<String?>? votes,
    Value<bool>? isActive,
    Value<DateTime?>? expiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedPollsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      question: question ?? this.question,
      options: options ?? this.options,
      votes: votes ?? this.votes,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (votes.present) {
      map['votes'] = Variable<String>(votes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPollsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('question: $question, ')
          ..write('options: $options, ')
          ..write('votes: $votes, ')
          ..write('isActive: $isActive, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCardsTable extends CachedCards
    with TableInfo<$CachedCardsTable, CachedCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holderNameMeta = const VerificationMeta(
    'holderName',
  );
  @override
  late final GeneratedColumn<String> holderName = GeneratedColumn<String>(
    'holder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFourDigitsMeta = const VerificationMeta(
    'lastFourDigits',
  );
  @override
  late final GeneratedColumn<String> lastFourDigits = GeneratedColumn<String>(
    'last_four_digits',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<String> expiryDate = GeneratedColumn<String>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeNameMeta = const VerificationMeta(
    'storeName',
  );
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
    'store_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyaltyNumberMeta = const VerificationMeta(
    'loyaltyNumber',
  );
  @override
  late final GeneratedColumn<String> loyaltyNumber = GeneratedColumn<String>(
    'loyalty_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedDataMeta = const VerificationMeta(
    'encryptedData',
  );
  @override
  late final GeneratedColumn<String> encryptedData = GeneratedColumn<String>(
    'encrypted_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    type,
    holderName,
    lastFourDigits,
    provider,
    expiryDate,
    storeName,
    loyaltyNumber,
    encryptedData,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('holder_name')) {
      context.handle(
        _holderNameMeta,
        holderName.isAcceptableOrUnknown(data['holder_name']!, _holderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_holderNameMeta);
    }
    if (data.containsKey('last_four_digits')) {
      context.handle(
        _lastFourDigitsMeta,
        lastFourDigits.isAcceptableOrUnknown(
          data['last_four_digits']!,
          _lastFourDigitsMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('store_name')) {
      context.handle(
        _storeNameMeta,
        storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta),
      );
    }
    if (data.containsKey('loyalty_number')) {
      context.handle(
        _loyaltyNumberMeta,
        loyaltyNumber.isAcceptableOrUnknown(
          data['loyalty_number']!,
          _loyaltyNumberMeta,
        ),
      );
    }
    if (data.containsKey('encrypted_data')) {
      context.handle(
        _encryptedDataMeta,
        encryptedData.isAcceptableOrUnknown(
          data['encrypted_data']!,
          _encryptedDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      holderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder_name'],
      )!,
      lastFourDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_four_digits'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_date'],
      ),
      storeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_name'],
      ),
      loyaltyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty_number'],
      ),
      encryptedData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedCardsTable createAlias(String alias) {
    return $CachedCardsTable(attachedDatabase, alias);
  }
}

class CachedCard extends DataClass implements Insertable<CachedCard> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String type;
  final String holderName;
  final String? lastFourDigits;
  final String? provider;
  final String? expiryDate;
  final String? storeName;
  final String? loyaltyNumber;
  final String? encryptedData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedCard({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.type,
    required this.holderName,
    this.lastFourDigits,
    this.provider,
    this.expiryDate,
    this.storeName,
    this.loyaltyNumber,
    this.encryptedData,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['type'] = Variable<String>(type);
    map['holder_name'] = Variable<String>(holderName);
    if (!nullToAbsent || lastFourDigits != null) {
      map['last_four_digits'] = Variable<String>(lastFourDigits);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<String>(expiryDate);
    }
    if (!nullToAbsent || storeName != null) {
      map['store_name'] = Variable<String>(storeName);
    }
    if (!nullToAbsent || loyaltyNumber != null) {
      map['loyalty_number'] = Variable<String>(loyaltyNumber);
    }
    if (!nullToAbsent || encryptedData != null) {
      map['encrypted_data'] = Variable<String>(encryptedData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedCardsCompanion toCompanion(bool nullToAbsent) {
    return CachedCardsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      type: Value(type),
      holderName: Value(holderName),
      lastFourDigits: lastFourDigits == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFourDigits),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      storeName: storeName == null && nullToAbsent
          ? const Value.absent()
          : Value(storeName),
      loyaltyNumber: loyaltyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(loyaltyNumber),
      encryptedData: encryptedData == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCard(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      type: serializer.fromJson<String>(json['type']),
      holderName: serializer.fromJson<String>(json['holderName']),
      lastFourDigits: serializer.fromJson<String?>(json['lastFourDigits']),
      provider: serializer.fromJson<String?>(json['provider']),
      expiryDate: serializer.fromJson<String?>(json['expiryDate']),
      storeName: serializer.fromJson<String?>(json['storeName']),
      loyaltyNumber: serializer.fromJson<String?>(json['loyaltyNumber']),
      encryptedData: serializer.fromJson<String?>(json['encryptedData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'type': serializer.toJson<String>(type),
      'holderName': serializer.toJson<String>(holderName),
      'lastFourDigits': serializer.toJson<String?>(lastFourDigits),
      'provider': serializer.toJson<String?>(provider),
      'expiryDate': serializer.toJson<String?>(expiryDate),
      'storeName': serializer.toJson<String?>(storeName),
      'loyaltyNumber': serializer.toJson<String?>(loyaltyNumber),
      'encryptedData': serializer.toJson<String?>(encryptedData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedCard copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? type,
    String? holderName,
    Value<String?> lastFourDigits = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> expiryDate = const Value.absent(),
    Value<String?> storeName = const Value.absent(),
    Value<String?> loyaltyNumber = const Value.absent(),
    Value<String?> encryptedData = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedCard(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    type: type ?? this.type,
    holderName: holderName ?? this.holderName,
    lastFourDigits: lastFourDigits.present
        ? lastFourDigits.value
        : this.lastFourDigits,
    provider: provider.present ? provider.value : this.provider,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    storeName: storeName.present ? storeName.value : this.storeName,
    loyaltyNumber: loyaltyNumber.present
        ? loyaltyNumber.value
        : this.loyaltyNumber,
    encryptedData: encryptedData.present
        ? encryptedData.value
        : this.encryptedData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedCard copyWithCompanion(CachedCardsCompanion data) {
    return CachedCard(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      type: data.type.present ? data.type.value : this.type,
      holderName: data.holderName.present
          ? data.holderName.value
          : this.holderName,
      lastFourDigits: data.lastFourDigits.present
          ? data.lastFourDigits.value
          : this.lastFourDigits,
      provider: data.provider.present ? data.provider.value : this.provider,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      loyaltyNumber: data.loyaltyNumber.present
          ? data.loyaltyNumber.value
          : this.loyaltyNumber,
      encryptedData: data.encryptedData.present
          ? data.encryptedData.value
          : this.encryptedData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCard(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('type: $type, ')
          ..write('holderName: $holderName, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('provider: $provider, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('storeName: $storeName, ')
          ..write('loyaltyNumber: $loyaltyNumber, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    type,
    holderName,
    lastFourDigits,
    provider,
    expiryDate,
    storeName,
    loyaltyNumber,
    encryptedData,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCard &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.type == this.type &&
          other.holderName == this.holderName &&
          other.lastFourDigits == this.lastFourDigits &&
          other.provider == this.provider &&
          other.expiryDate == this.expiryDate &&
          other.storeName == this.storeName &&
          other.loyaltyNumber == this.loyaltyNumber &&
          other.encryptedData == this.encryptedData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedCardsCompanion extends UpdateCompanion<CachedCard> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> type;
  final Value<String> holderName;
  final Value<String?> lastFourDigits;
  final Value<String?> provider;
  final Value<String?> expiryDate;
  final Value<String?> storeName;
  final Value<String?> loyaltyNumber;
  final Value<String?> encryptedData;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedCardsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.type = const Value.absent(),
    this.holderName = const Value.absent(),
    this.lastFourDigits = const Value.absent(),
    this.provider = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.storeName = const Value.absent(),
    this.loyaltyNumber = const Value.absent(),
    this.encryptedData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCardsCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String type,
    required String holderName,
    this.lastFourDigits = const Value.absent(),
    this.provider = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.storeName = const Value.absent(),
    this.loyaltyNumber = const Value.absent(),
    this.encryptedData = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       type = Value(type),
       holderName = Value(holderName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedCard> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? type,
    Expression<String>? holderName,
    Expression<String>? lastFourDigits,
    Expression<String>? provider,
    Expression<String>? expiryDate,
    Expression<String>? storeName,
    Expression<String>? loyaltyNumber,
    Expression<String>? encryptedData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (type != null) 'type': type,
      if (holderName != null) 'holder_name': holderName,
      if (lastFourDigits != null) 'last_four_digits': lastFourDigits,
      if (provider != null) 'provider': provider,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (storeName != null) 'store_name': storeName,
      if (loyaltyNumber != null) 'loyalty_number': loyaltyNumber,
      if (encryptedData != null) 'encrypted_data': encryptedData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? type,
    Value<String>? holderName,
    Value<String?>? lastFourDigits,
    Value<String?>? provider,
    Value<String?>? expiryDate,
    Value<String?>? storeName,
    Value<String?>? loyaltyNumber,
    Value<String?>? encryptedData,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedCardsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      holderName: holderName ?? this.holderName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      provider: provider ?? this.provider,
      expiryDate: expiryDate ?? this.expiryDate,
      storeName: storeName ?? this.storeName,
      loyaltyNumber: loyaltyNumber ?? this.loyaltyNumber,
      encryptedData: encryptedData ?? this.encryptedData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (holderName.present) {
      map['holder_name'] = Variable<String>(holderName.value);
    }
    if (lastFourDigits.present) {
      map['last_four_digits'] = Variable<String>(lastFourDigits.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(expiryDate.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (loyaltyNumber.present) {
      map['loyalty_number'] = Variable<String>(loyaltyNumber.value);
    }
    if (encryptedData.present) {
      map['encrypted_data'] = Variable<String>(encryptedData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCardsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('type: $type, ')
          ..write('holderName: $holderName, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('provider: $provider, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('storeName: $storeName, ')
          ..write('loyaltyNumber: $loyaltyNumber, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedFilesTable extends CachedFiles
    with TableInfo<$CachedFilesTable, CachedFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedByMeta = const VerificationMeta(
    'uploadedBy',
  );
  @override
  late final GeneratedColumn<String> uploadedBy = GeneratedColumn<String>(
    'uploaded_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    uploadedBy,
    filename,
    sizeBytes,
    mimeType,
    folderId,
    url,
    thumbnailUrl,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('uploaded_by')) {
      context.handle(
        _uploadedByMeta,
        uploadedBy.isAcceptableOrUnknown(data['uploaded_by']!, _uploadedByMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadedByMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      uploadedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploaded_by'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedFilesTable createAlias(String alias) {
    return $CachedFilesTable(attachedDatabase, alias);
  }
}

class CachedFile extends DataClass implements Insertable<CachedFile> {
  final String id;
  final String spaceId;
  final String uploadedBy;
  final String filename;
  final int sizeBytes;
  final String mimeType;
  final String? folderId;
  final String url;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedFile({
    required this.id,
    required this.spaceId,
    required this.uploadedBy,
    required this.filename,
    required this.sizeBytes,
    required this.mimeType,
    this.folderId,
    required this.url,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['uploaded_by'] = Variable<String>(uploadedBy);
    map['filename'] = Variable<String>(filename);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedFilesCompanion toCompanion(bool nullToAbsent) {
    return CachedFilesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      uploadedBy: Value(uploadedBy),
      filename: Value(filename),
      sizeBytes: Value(sizeBytes),
      mimeType: Value(mimeType),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      url: Value(url),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFile(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      uploadedBy: serializer.fromJson<String>(json['uploadedBy']),
      filename: serializer.fromJson<String>(json['filename']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      url: serializer.fromJson<String>(json['url']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'uploadedBy': serializer.toJson<String>(uploadedBy),
      'filename': serializer.toJson<String>(filename),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'mimeType': serializer.toJson<String>(mimeType),
      'folderId': serializer.toJson<String?>(folderId),
      'url': serializer.toJson<String>(url),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedFile copyWith({
    String? id,
    String? spaceId,
    String? uploadedBy,
    String? filename,
    int? sizeBytes,
    String? mimeType,
    Value<String?> folderId = const Value.absent(),
    String? url,
    Value<String?> thumbnailUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedFile(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    uploadedBy: uploadedBy ?? this.uploadedBy,
    filename: filename ?? this.filename,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    mimeType: mimeType ?? this.mimeType,
    folderId: folderId.present ? folderId.value : this.folderId,
    url: url ?? this.url,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedFile copyWithCompanion(CachedFilesCompanion data) {
    return CachedFile(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      uploadedBy: data.uploadedBy.present
          ? data.uploadedBy.value
          : this.uploadedBy,
      filename: data.filename.present ? data.filename.value : this.filename,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      url: data.url.present ? data.url.value : this.url,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFile(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('uploadedBy: $uploadedBy, ')
          ..write('filename: $filename, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('folderId: $folderId, ')
          ..write('url: $url, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    uploadedBy,
    filename,
    sizeBytes,
    mimeType,
    folderId,
    url,
    thumbnailUrl,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFile &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.uploadedBy == this.uploadedBy &&
          other.filename == this.filename &&
          other.sizeBytes == this.sizeBytes &&
          other.mimeType == this.mimeType &&
          other.folderId == this.folderId &&
          other.url == this.url &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedFilesCompanion extends UpdateCompanion<CachedFile> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> uploadedBy;
  final Value<String> filename;
  final Value<int> sizeBytes;
  final Value<String> mimeType;
  final Value<String?> folderId;
  final Value<String> url;
  final Value<String?> thumbnailUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedFilesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.uploadedBy = const Value.absent(),
    this.filename = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.folderId = const Value.absent(),
    this.url = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFilesCompanion.insert({
    required String id,
    required String spaceId,
    required String uploadedBy,
    required String filename,
    required int sizeBytes,
    required String mimeType,
    this.folderId = const Value.absent(),
    required String url,
    this.thumbnailUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       uploadedBy = Value(uploadedBy),
       filename = Value(filename),
       sizeBytes = Value(sizeBytes),
       mimeType = Value(mimeType),
       url = Value(url),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedFile> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? uploadedBy,
    Expression<String>? filename,
    Expression<int>? sizeBytes,
    Expression<String>? mimeType,
    Expression<String>? folderId,
    Expression<String>? url,
    Expression<String>? thumbnailUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (uploadedBy != null) 'uploaded_by': uploadedBy,
      if (filename != null) 'filename': filename,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (folderId != null) 'folder_id': folderId,
      if (url != null) 'url': url,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? uploadedBy,
    Value<String>? filename,
    Value<int>? sizeBytes,
    Value<String>? mimeType,
    Value<String?>? folderId,
    Value<String>? url,
    Value<String?>? thumbnailUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedFilesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      filename: filename ?? this.filename,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      folderId: folderId ?? this.folderId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (uploadedBy.present) {
      map['uploaded_by'] = Variable<String>(uploadedBy.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFilesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('uploadedBy: $uploadedBy, ')
          ..write('filename: $filename, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('folderId: $folderId, ')
          ..write('url: $url, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMemoriesTable extends CachedMemories
    with TableInfo<$CachedMemoriesTable, CachedMemory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlsMeta = const VerificationMeta(
    'photoUrls',
  );
  @override
  late final GeneratedColumn<String> photoUrls = GeneratedColumn<String>(
    'photo_urls',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMilestoneMeta = const VerificationMeta(
    'isMilestone',
  );
  @override
  late final GeneratedColumn<bool> isMilestone = GeneratedColumn<bool>(
    'is_milestone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_milestone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memoryDateMeta = const VerificationMeta(
    'memoryDate',
  );
  @override
  late final GeneratedColumn<DateTime> memoryDate = GeneratedColumn<DateTime>(
    'memory_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    createdBy,
    title,
    description,
    photoUrls,
    isMilestone,
    memoryDate,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMemory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('photo_urls')) {
      context.handle(
        _photoUrlsMeta,
        photoUrls.isAcceptableOrUnknown(data['photo_urls']!, _photoUrlsMeta),
      );
    }
    if (data.containsKey('is_milestone')) {
      context.handle(
        _isMilestoneMeta,
        isMilestone.isAcceptableOrUnknown(
          data['is_milestone']!,
          _isMilestoneMeta,
        ),
      );
    }
    if (data.containsKey('memory_date')) {
      context.handle(
        _memoryDateMeta,
        memoryDate.isAcceptableOrUnknown(data['memory_date']!, _memoryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMemory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMemory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      photoUrls: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_urls'],
      ),
      isMilestone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_milestone'],
      )!,
      memoryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}memory_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedMemoriesTable createAlias(String alias) {
    return $CachedMemoriesTable(attachedDatabase, alias);
  }
}

class CachedMemory extends DataClass implements Insertable<CachedMemory> {
  final String id;
  final String spaceId;
  final String createdBy;
  final String title;
  final String? description;
  final String? photoUrls;
  final bool isMilestone;
  final DateTime memoryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedMemory({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.description,
    this.photoUrls,
    required this.isMilestone,
    required this.memoryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_by'] = Variable<String>(createdBy);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || photoUrls != null) {
      map['photo_urls'] = Variable<String>(photoUrls);
    }
    map['is_milestone'] = Variable<bool>(isMilestone);
    map['memory_date'] = Variable<DateTime>(memoryDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedMemoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedMemoriesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdBy: Value(createdBy),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      photoUrls: photoUrls == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrls),
      isMilestone: Value(isMilestone),
      memoryDate: Value(memoryDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedMemory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMemory(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      photoUrls: serializer.fromJson<String?>(json['photoUrls']),
      isMilestone: serializer.fromJson<bool>(json['isMilestone']),
      memoryDate: serializer.fromJson<DateTime>(json['memoryDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdBy': serializer.toJson<String>(createdBy),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'photoUrls': serializer.toJson<String?>(photoUrls),
      'isMilestone': serializer.toJson<bool>(isMilestone),
      'memoryDate': serializer.toJson<DateTime>(memoryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedMemory copyWith({
    String? id,
    String? spaceId,
    String? createdBy,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> photoUrls = const Value.absent(),
    bool? isMilestone,
    DateTime? memoryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedMemory(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    createdBy: createdBy ?? this.createdBy,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    photoUrls: photoUrls.present ? photoUrls.value : this.photoUrls,
    isMilestone: isMilestone ?? this.isMilestone,
    memoryDate: memoryDate ?? this.memoryDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedMemory copyWithCompanion(CachedMemoriesCompanion data) {
    return CachedMemory(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      photoUrls: data.photoUrls.present ? data.photoUrls.value : this.photoUrls,
      isMilestone: data.isMilestone.present
          ? data.isMilestone.value
          : this.isMilestone,
      memoryDate: data.memoryDate.present
          ? data.memoryDate.value
          : this.memoryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMemory(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('photoUrls: $photoUrls, ')
          ..write('isMilestone: $isMilestone, ')
          ..write('memoryDate: $memoryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    createdBy,
    title,
    description,
    photoUrls,
    isMilestone,
    memoryDate,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMemory &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.description == this.description &&
          other.photoUrls == this.photoUrls &&
          other.isMilestone == this.isMilestone &&
          other.memoryDate == this.memoryDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedMemoriesCompanion extends UpdateCompanion<CachedMemory> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> createdBy;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> photoUrls;
  final Value<bool> isMilestone;
  final Value<DateTime> memoryDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedMemoriesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.photoUrls = const Value.absent(),
    this.isMilestone = const Value.absent(),
    this.memoryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMemoriesCompanion.insert({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    this.description = const Value.absent(),
    this.photoUrls = const Value.absent(),
    this.isMilestone = const Value.absent(),
    required DateTime memoryDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       createdBy = Value(createdBy),
       title = Value(title),
       memoryDate = Value(memoryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedMemory> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? photoUrls,
    Expression<bool>? isMilestone,
    Expression<DateTime>? memoryDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (photoUrls != null) 'photo_urls': photoUrls,
      if (isMilestone != null) 'is_milestone': isMilestone,
      if (memoryDate != null) 'memory_date': memoryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMemoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? createdBy,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? photoUrls,
    Value<bool>? isMilestone,
    Value<DateTime>? memoryDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedMemoriesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      isMilestone: isMilestone ?? this.isMilestone,
      memoryDate: memoryDate ?? this.memoryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (photoUrls.present) {
      map['photo_urls'] = Variable<String>(photoUrls.value);
    }
    if (isMilestone.present) {
      map['is_milestone'] = Variable<bool>(isMilestone.value);
    }
    if (memoryDate.present) {
      map['memory_date'] = Variable<DateTime>(memoryDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMemoriesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('photoUrls: $photoUrls, ')
          ..write('isMilestone: $isMilestone, ')
          ..write('memoryDate: $memoryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    spaceId,
    retryCount,
    createdAt,
    lastAttemptAt,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final String spaceId;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.spaceId,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['space_id'] = Variable<String>(spaceId);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      spaceId: Value(spaceId),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'spaceId': serializer.toJson<String>(spaceId),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    String? spaceId,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    spaceId: spaceId ?? this.spaceId,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('spaceId: $spaceId, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    spaceId,
    retryCount,
    createdAt,
    lastAttemptAt,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.spaceId == this.spaceId &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> spaceId;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> errorMessage;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required String spaceId,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       spaceId = Value(spaceId),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? spaceId,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (spaceId != null) 'space_id': spaceId,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? spaceId,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? errorMessage,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      spaceId: spaceId ?? this.spaceId,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('spaceId: $spaceId, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String key;
  final String value;
  const AppPreference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppPreference copyWith({String? key, String? value}) =>
      AppPreference(key: key ?? this.key, value: value ?? this.value);
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedUsersTable cachedUsers = $CachedUsersTable(this);
  late final $CachedSpacesTable cachedSpaces = $CachedSpacesTable(this);
  late final $CachedSpaceMembershipsTable cachedSpaceMemberships =
      $CachedSpaceMembershipsTable(this);
  late final $CachedActivitiesTable cachedActivities = $CachedActivitiesTable(
    this,
  );
  late final $CachedActivityVotesTable cachedActivityVotes =
      $CachedActivityVotesTable(this);
  late final $CachedCalendarEventsTable cachedCalendarEvents =
      $CachedCalendarEventsTable(this);
  late final $CachedTasksTable cachedTasks = $CachedTasksTable(this);
  late final $CachedRemindersTable cachedReminders = $CachedRemindersTable(
    this,
  );
  late final $CachedGroceryListsTable cachedGroceryLists =
      $CachedGroceryListsTable(this);
  late final $CachedGroceryItemsTable cachedGroceryItems =
      $CachedGroceryItemsTable(this);
  late final $CachedNotificationsTable cachedNotifications =
      $CachedNotificationsTable(this);
  late final $CachedConversationsTable cachedConversations =
      $CachedConversationsTable(this);
  late final $CachedMessagesTable cachedMessages = $CachedMessagesTable(this);
  late final $CachedFinanceEntriesTable cachedFinanceEntries =
      $CachedFinanceEntriesTable(this);
  late final $CachedChartersTable cachedCharters = $CachedChartersTable(this);
  late final $CachedPollsTable cachedPolls = $CachedPollsTable(this);
  late final $CachedCardsTable cachedCards = $CachedCardsTable(this);
  late final $CachedFilesTable cachedFiles = $CachedFilesTable(this);
  late final $CachedMemoriesTable cachedMemories = $CachedMemoriesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedUsers,
    cachedSpaces,
    cachedSpaceMemberships,
    cachedActivities,
    cachedActivityVotes,
    cachedCalendarEvents,
    cachedTasks,
    cachedReminders,
    cachedGroceryLists,
    cachedGroceryItems,
    cachedNotifications,
    cachedConversations,
    cachedMessages,
    cachedFinanceEntries,
    cachedCharters,
    cachedPolls,
    cachedCards,
    cachedFiles,
    cachedMemories,
    syncQueue,
    appPreferences,
  ];
}

typedef $$CachedUsersTableCreateCompanionBuilder =
    CachedUsersCompanion Function({
      required String id,
      required String email,
      required String displayName,
      Value<String?> avatarUrl,
      Value<bool> totpEnabled,
      Value<String> preferredLanguage,
      Value<String?> timezone,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedUsersTableUpdateCompanionBuilder =
    CachedUsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> displayName,
      Value<String?> avatarUrl,
      Value<bool> totpEnabled,
      Value<String> preferredLanguage,
      Value<String?> timezone,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUsersTable,
          CachedUser,
          $$CachedUsersTableFilterComposer,
          $$CachedUsersTableOrderingComposer,
          $$CachedUsersTableCreateCompanionBuilder,
          $$CachedUsersTableUpdateCompanionBuilder
        > {
  $$CachedUsersTableTableManager(_$AppDatabase db, $CachedUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedUsersTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedUsersTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<bool> totpEnabled = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                totpEnabled: totpEnabled,
                preferredLanguage: preferredLanguage,
                timezone: timezone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String displayName,
                Value<String?> avatarUrl = const Value.absent(),
                Value<bool> totpEnabled = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedUsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                totpEnabled: totpEnabled,
                preferredLanguage: preferredLanguage,
                timezone: timezone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedUsersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get email => $state.composableBuilder(
    column: $state.table.email,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get displayName => $state.composableBuilder(
    column: $state.table.displayName,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
    column: $state.table.avatarUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get totpEnabled => $state.composableBuilder(
    column: $state.table.totpEnabled,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get preferredLanguage => $state.composableBuilder(
    column: $state.table.preferredLanguage,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get timezone => $state.composableBuilder(
    column: $state.table.timezone,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter cachedSpaceMembershipsRefs(
    ComposableFilter Function($$CachedSpaceMembershipsTableFilterComposer f) f,
  ) {
    final $$CachedSpaceMembershipsTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $state.db.cachedSpaceMemberships,
          getReferencedColumn: (t) => t.userId,
          builder: (joinBuilder, parentComposers) =>
              $$CachedSpaceMembershipsTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedSpaceMemberships,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return f(composer);
  }
}

class $$CachedUsersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get email => $state.composableBuilder(
    column: $state.table.email,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get displayName => $state.composableBuilder(
    column: $state.table.displayName,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
    column: $state.table.avatarUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get totpEnabled => $state.composableBuilder(
    column: $state.table.totpEnabled,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get preferredLanguage => $state.composableBuilder(
    column: $state.table.preferredLanguage,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get timezone => $state.composableBuilder(
    column: $state.table.timezone,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedSpacesTableCreateCompanionBuilder =
    CachedSpacesCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> avatarUrl,
      Value<String?> inviteCode,
      Value<int> maxMembers,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedSpacesTableUpdateCompanionBuilder =
    CachedSpacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> avatarUrl,
      Value<String?> inviteCode,
      Value<int> maxMembers,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedSpacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSpacesTable,
          CachedSpace,
          $$CachedSpacesTableFilterComposer,
          $$CachedSpacesTableOrderingComposer,
          $$CachedSpacesTableCreateCompanionBuilder,
          $$CachedSpacesTableUpdateCompanionBuilder
        > {
  $$CachedSpacesTableTableManager(_$AppDatabase db, $CachedSpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedSpacesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedSpacesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> inviteCode = const Value.absent(),
                Value<int> maxMembers = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSpacesCompanion(
                id: id,
                name: name,
                type: type,
                avatarUrl: avatarUrl,
                inviteCode: inviteCode,
                maxMembers: maxMembers,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> inviteCode = const Value.absent(),
                Value<int> maxMembers = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSpacesCompanion.insert(
                id: id,
                name: name,
                type: type,
                avatarUrl: avatarUrl,
                inviteCode: inviteCode,
                maxMembers: maxMembers,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedSpacesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedSpacesTable> {
  $$CachedSpacesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
    column: $state.table.avatarUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get inviteCode => $state.composableBuilder(
    column: $state.table.inviteCode,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get maxMembers => $state.composableBuilder(
    column: $state.table.maxMembers,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter cachedSpaceMembershipsRefs(
    ComposableFilter Function($$CachedSpaceMembershipsTableFilterComposer f) f,
  ) {
    final $$CachedSpaceMembershipsTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $state.db.cachedSpaceMemberships,
          getReferencedColumn: (t) => t.spaceId,
          builder: (joinBuilder, parentComposers) =>
              $$CachedSpaceMembershipsTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedSpaceMemberships,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return f(composer);
  }
}

class $$CachedSpacesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedSpacesTable> {
  $$CachedSpacesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
    column: $state.table.avatarUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get inviteCode => $state.composableBuilder(
    column: $state.table.inviteCode,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get maxMembers => $state.composableBuilder(
    column: $state.table.maxMembers,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedSpaceMembershipsTableCreateCompanionBuilder =
    CachedSpaceMembershipsCompanion Function({
      required String id,
      required String spaceId,
      required String userId,
      required String role,
      required String accessLevel,
      required String status,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedSpaceMembershipsTableUpdateCompanionBuilder =
    CachedSpaceMembershipsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> userId,
      Value<String> role,
      Value<String> accessLevel,
      Value<String> status,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedSpaceMembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSpaceMembershipsTable,
          CachedSpaceMembership,
          $$CachedSpaceMembershipsTableFilterComposer,
          $$CachedSpaceMembershipsTableOrderingComposer,
          $$CachedSpaceMembershipsTableCreateCompanionBuilder,
          $$CachedSpaceMembershipsTableUpdateCompanionBuilder
        > {
  $$CachedSpaceMembershipsTableTableManager(
    _$AppDatabase db,
    $CachedSpaceMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedSpaceMembershipsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedSpaceMembershipsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> accessLevel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSpaceMembershipsCompanion(
                id: id,
                spaceId: spaceId,
                userId: userId,
                role: role,
                accessLevel: accessLevel,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String userId,
                required String role,
                required String accessLevel,
                required String status,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSpaceMembershipsCompanion.insert(
                id: id,
                spaceId: spaceId,
                userId: userId,
                role: role,
                accessLevel: accessLevel,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedSpaceMembershipsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedSpaceMembershipsTable> {
  $$CachedSpaceMembershipsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get role => $state.composableBuilder(
    column: $state.table.role,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get accessLevel => $state.composableBuilder(
    column: $state.table.accessLevel,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  $$CachedSpacesTableFilterComposer get spaceId {
    final $$CachedSpacesTableFilterComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $state.db.cachedSpaces,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, parentComposers) =>
          $$CachedSpacesTableFilterComposer(
            ComposerState(
              $state.db,
              $state.db.cachedSpaces,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return composer;
  }

  $$CachedUsersTableFilterComposer get userId {
    final $$CachedUsersTableFilterComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $state.db.cachedUsers,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, parentComposers) =>
          $$CachedUsersTableFilterComposer(
            ComposerState(
              $state.db,
              $state.db.cachedUsers,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return composer;
  }
}

class $$CachedSpaceMembershipsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedSpaceMembershipsTable> {
  $$CachedSpaceMembershipsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get role => $state.composableBuilder(
    column: $state.table.role,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get accessLevel => $state.composableBuilder(
    column: $state.table.accessLevel,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  $$CachedSpacesTableOrderingComposer get spaceId {
    final $$CachedSpacesTableOrderingComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $state.db.cachedSpaces,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, parentComposers) =>
          $$CachedSpacesTableOrderingComposer(
            ComposerState(
              $state.db,
              $state.db.cachedSpaces,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return composer;
  }

  $$CachedUsersTableOrderingComposer get userId {
    final $$CachedUsersTableOrderingComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $state.db.cachedUsers,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, parentComposers) =>
          $$CachedUsersTableOrderingComposer(
            ComposerState(
              $state.db,
              $state.db.cachedUsers,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return composer;
  }
}

typedef $$CachedActivitiesTableCreateCompanionBuilder =
    CachedActivitiesCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String title,
      Value<String?> description,
      required String category,
      Value<String?> thumbnailUrl,
      Value<String?> trailerUrl,
      required String privacy,
      required String status,
      required String mode,
      Value<String?> metadata,
      Value<DateTime?> completedAt,
      Value<String?> completedNotes,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedActivitiesTableUpdateCompanionBuilder =
    CachedActivitiesCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> title,
      Value<String?> description,
      Value<String> category,
      Value<String?> thumbnailUrl,
      Value<String?> trailerUrl,
      Value<String> privacy,
      Value<String> status,
      Value<String> mode,
      Value<String?> metadata,
      Value<DateTime?> completedAt,
      Value<String?> completedNotes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedActivitiesTable,
          CachedActivity,
          $$CachedActivitiesTableFilterComposer,
          $$CachedActivitiesTableOrderingComposer,
          $$CachedActivitiesTableCreateCompanionBuilder,
          $$CachedActivitiesTableUpdateCompanionBuilder
        > {
  $$CachedActivitiesTableTableManager(
    _$AppDatabase db,
    $CachedActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedActivitiesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedActivitiesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> trailerUrl = const Value.absent(),
                Value<String> privacy = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> completedNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedActivitiesCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                category: category,
                thumbnailUrl: thumbnailUrl,
                trailerUrl: trailerUrl,
                privacy: privacy,
                status: status,
                mode: mode,
                metadata: metadata,
                completedAt: completedAt,
                completedNotes: completedNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String title,
                Value<String?> description = const Value.absent(),
                required String category,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> trailerUrl = const Value.absent(),
                required String privacy,
                required String status,
                required String mode,
                Value<String?> metadata = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> completedNotes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedActivitiesCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                category: category,
                thumbnailUrl: thumbnailUrl,
                trailerUrl: trailerUrl,
                privacy: privacy,
                status: status,
                mode: mode,
                metadata: metadata,
                completedAt: completedAt,
                completedNotes: completedNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedActivitiesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedActivitiesTable> {
  $$CachedActivitiesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get thumbnailUrl => $state.composableBuilder(
    column: $state.table.thumbnailUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get trailerUrl => $state.composableBuilder(
    column: $state.table.trailerUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get privacy => $state.composableBuilder(
    column: $state.table.privacy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get mode => $state.composableBuilder(
    column: $state.table.mode,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get metadata => $state.composableBuilder(
    column: $state.table.metadata,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
    column: $state.table.completedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get completedNotes => $state.composableBuilder(
    column: $state.table.completedNotes,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter cachedActivityVotesRefs(
    ComposableFilter Function($$CachedActivityVotesTableFilterComposer f) f,
  ) {
    final $$CachedActivityVotesTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $state.db.cachedActivityVotes,
          getReferencedColumn: (t) => t.activityId,
          builder: (joinBuilder, parentComposers) =>
              $$CachedActivityVotesTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedActivityVotes,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return f(composer);
  }
}

class $$CachedActivitiesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedActivitiesTable> {
  $$CachedActivitiesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get thumbnailUrl => $state.composableBuilder(
    column: $state.table.thumbnailUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get trailerUrl => $state.composableBuilder(
    column: $state.table.trailerUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get privacy => $state.composableBuilder(
    column: $state.table.privacy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get mode => $state.composableBuilder(
    column: $state.table.mode,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get metadata => $state.composableBuilder(
    column: $state.table.metadata,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
    column: $state.table.completedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get completedNotes => $state.composableBuilder(
    column: $state.table.completedNotes,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedActivityVotesTableCreateCompanionBuilder =
    CachedActivityVotesCompanion Function({
      required String id,
      required String activityId,
      required String userId,
      required int score,
      required DateTime createdAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedActivityVotesTableUpdateCompanionBuilder =
    CachedActivityVotesCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> userId,
      Value<int> score,
      Value<DateTime> createdAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedActivityVotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedActivityVotesTable,
          CachedActivityVote,
          $$CachedActivityVotesTableFilterComposer,
          $$CachedActivityVotesTableOrderingComposer,
          $$CachedActivityVotesTableCreateCompanionBuilder,
          $$CachedActivityVotesTableUpdateCompanionBuilder
        > {
  $$CachedActivityVotesTableTableManager(
    _$AppDatabase db,
    $CachedActivityVotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedActivityVotesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedActivityVotesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedActivityVotesCompanion(
                id: id,
                activityId: activityId,
                userId: userId,
                score: score,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String userId,
                required int score,
                required DateTime createdAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedActivityVotesCompanion.insert(
                id: id,
                activityId: activityId,
                userId: userId,
                score: score,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedActivityVotesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedActivityVotesTable> {
  $$CachedActivityVotesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get score => $state.composableBuilder(
    column: $state.table.score,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  $$CachedActivitiesTableFilterComposer get activityId {
    final $$CachedActivitiesTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $state.db.cachedActivities,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedActivitiesTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedActivities,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

class $$CachedActivityVotesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedActivityVotesTable> {
  $$CachedActivityVotesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get score => $state.composableBuilder(
    column: $state.table.score,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  $$CachedActivitiesTableOrderingComposer get activityId {
    final $$CachedActivitiesTableOrderingComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $state.db.cachedActivities,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedActivitiesTableOrderingComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedActivities,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

typedef $$CachedCalendarEventsTableCreateCompanionBuilder =
    CachedCalendarEventsCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String title,
      Value<String?> location,
      required String eventType,
      Value<bool> allDay,
      required DateTime startAt,
      required DateTime endAt,
      Value<String?> recurrenceRule,
      Value<String?> sourceModule,
      Value<String?> sourceEntityId,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedCalendarEventsTableUpdateCompanionBuilder =
    CachedCalendarEventsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> title,
      Value<String?> location,
      Value<String> eventType,
      Value<bool> allDay,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<String?> recurrenceRule,
      Value<String?> sourceModule,
      Value<String?> sourceEntityId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedCalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCalendarEventsTable,
          CachedCalendarEvent,
          $$CachedCalendarEventsTableFilterComposer,
          $$CachedCalendarEventsTableOrderingComposer,
          $$CachedCalendarEventsTableCreateCompanionBuilder,
          $$CachedCalendarEventsTableUpdateCompanionBuilder
        > {
  $$CachedCalendarEventsTableTableManager(
    _$AppDatabase db,
    $CachedCalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedCalendarEventsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedCalendarEventsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> sourceModule = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCalendarEventsCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                location: location,
                eventType: eventType,
                allDay: allDay,
                startAt: startAt,
                endAt: endAt,
                recurrenceRule: recurrenceRule,
                sourceModule: sourceModule,
                sourceEntityId: sourceEntityId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String title,
                Value<String?> location = const Value.absent(),
                required String eventType,
                Value<bool> allDay = const Value.absent(),
                required DateTime startAt,
                required DateTime endAt,
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> sourceModule = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCalendarEventsCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                location: location,
                eventType: eventType,
                allDay: allDay,
                startAt: startAt,
                endAt: endAt,
                recurrenceRule: recurrenceRule,
                sourceModule: sourceModule,
                sourceEntityId: sourceEntityId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedCalendarEventsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedCalendarEventsTable> {
  $$CachedCalendarEventsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get location => $state.composableBuilder(
    column: $state.table.location,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get eventType => $state.composableBuilder(
    column: $state.table.eventType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get allDay => $state.composableBuilder(
    column: $state.table.allDay,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get startAt => $state.composableBuilder(
    column: $state.table.startAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get endAt => $state.composableBuilder(
    column: $state.table.endAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceModule => $state.composableBuilder(
    column: $state.table.sourceModule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceEntityId => $state.composableBuilder(
    column: $state.table.sourceEntityId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedCalendarEventsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedCalendarEventsTable> {
  $$CachedCalendarEventsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get location => $state.composableBuilder(
    column: $state.table.location,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get eventType => $state.composableBuilder(
    column: $state.table.eventType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get allDay => $state.composableBuilder(
    column: $state.table.allDay,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get startAt => $state.composableBuilder(
    column: $state.table.startAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get endAt => $state.composableBuilder(
    column: $state.table.endAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceModule => $state.composableBuilder(
    column: $state.table.sourceModule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceEntityId => $state.composableBuilder(
    column: $state.table.sourceEntityId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedTasksTableCreateCompanionBuilder =
    CachedTasksCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String title,
      Value<String?> description,
      required String status,
      required String priority,
      Value<DateTime?> dueDate,
      Value<String?> parentTaskId,
      Value<bool> isRecurring,
      Value<String?> recurrenceRule,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedTasksTableUpdateCompanionBuilder =
    CachedTasksCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> title,
      Value<String?> description,
      Value<String> status,
      Value<String> priority,
      Value<DateTime?> dueDate,
      Value<String?> parentTaskId,
      Value<bool> isRecurring,
      Value<String?> recurrenceRule,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedTasksTable,
          CachedTask,
          $$CachedTasksTableFilterComposer,
          $$CachedTasksTableOrderingComposer,
          $$CachedTasksTableCreateCompanionBuilder,
          $$CachedTasksTableUpdateCompanionBuilder
        > {
  $$CachedTasksTableTableManager(_$AppDatabase db, $CachedTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedTasksTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedTasksTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> parentTaskId = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                parentTaskId: parentTaskId,
                isRecurring: isRecurring,
                recurrenceRule: recurrenceRule,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String title,
                Value<String?> description = const Value.absent(),
                required String status,
                required String priority,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> parentTaskId = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                parentTaskId: parentTaskId,
                isRecurring: isRecurring,
                recurrenceRule: recurrenceRule,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedTasksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedTasksTable> {
  $$CachedTasksTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get priority => $state.composableBuilder(
    column: $state.table.priority,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get dueDate => $state.composableBuilder(
    column: $state.table.dueDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get parentTaskId => $state.composableBuilder(
    column: $state.table.parentTaskId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isRecurring => $state.composableBuilder(
    column: $state.table.isRecurring,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
    column: $state.table.completedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedTasksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedTasksTable> {
  $$CachedTasksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get status => $state.composableBuilder(
    column: $state.table.status,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get priority => $state.composableBuilder(
    column: $state.table.priority,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get dueDate => $state.composableBuilder(
    column: $state.table.dueDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get parentTaskId => $state.composableBuilder(
    column: $state.table.parentTaskId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isRecurring => $state.composableBuilder(
    column: $state.table.isRecurring,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
    column: $state.table.completedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedRemindersTableCreateCompanionBuilder =
    CachedRemindersCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String message,
      required DateTime triggerAt,
      Value<String?> recurrenceRule,
      Value<String?> linkedModule,
      Value<String?> linkedEntityId,
      Value<bool> isSent,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedRemindersTableUpdateCompanionBuilder =
    CachedRemindersCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> message,
      Value<DateTime> triggerAt,
      Value<String?> recurrenceRule,
      Value<String?> linkedModule,
      Value<String?> linkedEntityId,
      Value<bool> isSent,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRemindersTable,
          CachedReminder,
          $$CachedRemindersTableFilterComposer,
          $$CachedRemindersTableOrderingComposer,
          $$CachedRemindersTableCreateCompanionBuilder,
          $$CachedRemindersTableUpdateCompanionBuilder
        > {
  $$CachedRemindersTableTableManager(
    _$AppDatabase db,
    $CachedRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedRemindersTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedRemindersTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> triggerAt = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> linkedModule = const Value.absent(),
                Value<String?> linkedEntityId = const Value.absent(),
                Value<bool> isSent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRemindersCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                message: message,
                triggerAt: triggerAt,
                recurrenceRule: recurrenceRule,
                linkedModule: linkedModule,
                linkedEntityId: linkedEntityId,
                isSent: isSent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String message,
                required DateTime triggerAt,
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> linkedModule = const Value.absent(),
                Value<String?> linkedEntityId = const Value.absent(),
                Value<bool> isSent = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedRemindersCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                message: message,
                triggerAt: triggerAt,
                recurrenceRule: recurrenceRule,
                linkedModule: linkedModule,
                linkedEntityId: linkedEntityId,
                isSent: isSent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedRemindersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedRemindersTable> {
  $$CachedRemindersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get message => $state.composableBuilder(
    column: $state.table.message,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get triggerAt => $state.composableBuilder(
    column: $state.table.triggerAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get linkedModule => $state.composableBuilder(
    column: $state.table.linkedModule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get linkedEntityId => $state.composableBuilder(
    column: $state.table.linkedEntityId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isSent => $state.composableBuilder(
    column: $state.table.isSent,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedRemindersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedRemindersTable> {
  $$CachedRemindersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get message => $state.composableBuilder(
    column: $state.table.message,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get triggerAt => $state.composableBuilder(
    column: $state.table.triggerAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get linkedModule => $state.composableBuilder(
    column: $state.table.linkedModule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get linkedEntityId => $state.composableBuilder(
    column: $state.table.linkedEntityId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isSent => $state.composableBuilder(
    column: $state.table.isSent,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedGroceryListsTableCreateCompanionBuilder =
    CachedGroceryListsCompanion Function({
      required String id,
      required String spaceId,
      required String name,
      required String createdBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedGroceryListsTableUpdateCompanionBuilder =
    CachedGroceryListsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> name,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedGroceryListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedGroceryListsTable,
          CachedGroceryList,
          $$CachedGroceryListsTableFilterComposer,
          $$CachedGroceryListsTableOrderingComposer,
          $$CachedGroceryListsTableCreateCompanionBuilder,
          $$CachedGroceryListsTableUpdateCompanionBuilder
        > {
  $$CachedGroceryListsTableTableManager(
    _$AppDatabase db,
    $CachedGroceryListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedGroceryListsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedGroceryListsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedGroceryListsCompanion(
                id: id,
                spaceId: spaceId,
                name: name,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String name,
                required String createdBy,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedGroceryListsCompanion.insert(
                id: id,
                spaceId: spaceId,
                name: name,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedGroceryListsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedGroceryListsTable> {
  $$CachedGroceryListsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter cachedGroceryItemsRefs(
    ComposableFilter Function($$CachedGroceryItemsTableFilterComposer f) f,
  ) {
    final $$CachedGroceryItemsTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $state.db.cachedGroceryItems,
          getReferencedColumn: (t) => t.listId,
          builder: (joinBuilder, parentComposers) =>
              $$CachedGroceryItemsTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedGroceryItems,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return f(composer);
  }
}

class $$CachedGroceryListsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedGroceryListsTable> {
  $$CachedGroceryListsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedGroceryItemsTableCreateCompanionBuilder =
    CachedGroceryItemsCompanion Function({
      required String id,
      required String listId,
      required String name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      Value<String?> note,
      Value<bool> isChecked,
      Value<String?> checkedBy,
      Value<DateTime?> checkedAt,
      Value<int?> priceCents,
      Value<int> displayOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedGroceryItemsTableUpdateCompanionBuilder =
    CachedGroceryItemsCompanion Function({
      Value<String> id,
      Value<String> listId,
      Value<String> name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      Value<String?> note,
      Value<bool> isChecked,
      Value<String?> checkedBy,
      Value<DateTime?> checkedAt,
      Value<int?> priceCents,
      Value<int> displayOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedGroceryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedGroceryItemsTable,
          CachedGroceryItem,
          $$CachedGroceryItemsTableFilterComposer,
          $$CachedGroceryItemsTableOrderingComposer,
          $$CachedGroceryItemsTableCreateCompanionBuilder,
          $$CachedGroceryItemsTableUpdateCompanionBuilder
        > {
  $$CachedGroceryItemsTableTableManager(
    _$AppDatabase db,
    $CachedGroceryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedGroceryItemsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedGroceryItemsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<String?> checkedBy = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<int?> priceCents = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedGroceryItemsCompanion(
                id: id,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                note: note,
                isChecked: isChecked,
                checkedBy: checkedBy,
                checkedAt: checkedAt,
                priceCents: priceCents,
                displayOrder: displayOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<String?> checkedBy = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<int?> priceCents = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedGroceryItemsCompanion.insert(
                id: id,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                note: note,
                isChecked: isChecked,
                checkedBy: checkedBy,
                checkedAt: checkedAt,
                priceCents: priceCents,
                displayOrder: displayOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedGroceryItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedGroceryItemsTable> {
  $$CachedGroceryItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get quantity => $state.composableBuilder(
    column: $state.table.quantity,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get unit => $state.composableBuilder(
    column: $state.table.unit,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get note => $state.composableBuilder(
    column: $state.table.note,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isChecked => $state.composableBuilder(
    column: $state.table.isChecked,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get checkedBy => $state.composableBuilder(
    column: $state.table.checkedBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get checkedAt => $state.composableBuilder(
    column: $state.table.checkedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get priceCents => $state.composableBuilder(
    column: $state.table.priceCents,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get displayOrder => $state.composableBuilder(
    column: $state.table.displayOrder,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  $$CachedGroceryListsTableFilterComposer get listId {
    final $$CachedGroceryListsTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.listId,
          referencedTable: $state.db.cachedGroceryLists,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedGroceryListsTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedGroceryLists,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

class $$CachedGroceryItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedGroceryItemsTable> {
  $$CachedGroceryItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get quantity => $state.composableBuilder(
    column: $state.table.quantity,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get unit => $state.composableBuilder(
    column: $state.table.unit,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get note => $state.composableBuilder(
    column: $state.table.note,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isChecked => $state.composableBuilder(
    column: $state.table.isChecked,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get checkedBy => $state.composableBuilder(
    column: $state.table.checkedBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get checkedAt => $state.composableBuilder(
    column: $state.table.checkedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get priceCents => $state.composableBuilder(
    column: $state.table.priceCents,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get displayOrder => $state.composableBuilder(
    column: $state.table.displayOrder,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  $$CachedGroceryListsTableOrderingComposer get listId {
    final $$CachedGroceryListsTableOrderingComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.listId,
          referencedTable: $state.db.cachedGroceryLists,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedGroceryListsTableOrderingComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedGroceryLists,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

typedef $$CachedNotificationsTableCreateCompanionBuilder =
    CachedNotificationsCompanion Function({
      required String id,
      required String userId,
      Value<String?> spaceId,
      required String type,
      required String title,
      required String body,
      Value<String?> sourceModule,
      Value<String?> sourceEntityId,
      Value<bool> isRead,
      required DateTime createdAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedNotificationsTableUpdateCompanionBuilder =
    CachedNotificationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> spaceId,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String?> sourceModule,
      Value<String?> sourceEntityId,
      Value<bool> isRead,
      Value<DateTime> createdAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedNotificationsTable,
          CachedNotification,
          $$CachedNotificationsTableFilterComposer,
          $$CachedNotificationsTableOrderingComposer,
          $$CachedNotificationsTableCreateCompanionBuilder,
          $$CachedNotificationsTableUpdateCompanionBuilder
        > {
  $$CachedNotificationsTableTableManager(
    _$AppDatabase db,
    $CachedNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedNotificationsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedNotificationsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> sourceModule = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion(
                id: id,
                userId: userId,
                spaceId: spaceId,
                type: type,
                title: title,
                body: body,
                sourceModule: sourceModule,
                sourceEntityId: sourceEntityId,
                isRead: isRead,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> spaceId = const Value.absent(),
                required String type,
                required String title,
                required String body,
                Value<String?> sourceModule = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                required DateTime createdAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion.insert(
                id: id,
                userId: userId,
                spaceId: spaceId,
                type: type,
                title: title,
                body: body,
                sourceModule: sourceModule,
                sourceEntityId: sourceEntityId,
                isRead: isRead,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedNotificationsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get body => $state.composableBuilder(
    column: $state.table.body,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceModule => $state.composableBuilder(
    column: $state.table.sourceModule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceEntityId => $state.composableBuilder(
    column: $state.table.sourceEntityId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isRead => $state.composableBuilder(
    column: $state.table.isRead,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedNotificationsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get body => $state.composableBuilder(
    column: $state.table.body,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceModule => $state.composableBuilder(
    column: $state.table.sourceModule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceEntityId => $state.composableBuilder(
    column: $state.table.sourceEntityId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isRead => $state.composableBuilder(
    column: $state.table.isRead,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedConversationsTableCreateCompanionBuilder =
    CachedConversationsCompanion Function({
      required String id,
      required String spaceId,
      required String type,
      Value<String?> title,
      required String createdBy,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedConversationsTableUpdateCompanionBuilder =
    CachedConversationsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> type,
      Value<String?> title,
      Value<String> createdBy,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedConversationsTable,
          CachedConversation,
          $$CachedConversationsTableFilterComposer,
          $$CachedConversationsTableOrderingComposer,
          $$CachedConversationsTableCreateCompanionBuilder,
          $$CachedConversationsTableUpdateCompanionBuilder
        > {
  $$CachedConversationsTableTableManager(
    _$AppDatabase db,
    $CachedConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedConversationsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedConversationsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedConversationsCompanion(
                id: id,
                spaceId: spaceId,
                type: type,
                title: title,
                createdBy: createdBy,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String type,
                Value<String?> title = const Value.absent(),
                required String createdBy,
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedConversationsCompanion.insert(
                id: id,
                spaceId: spaceId,
                type: type,
                title: title,
                createdBy: createdBy,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedConversationsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedConversationsTable> {
  $$CachedConversationsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get lastMessagePreview => $state.composableBuilder(
    column: $state.table.lastMessagePreview,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get lastMessageAt => $state.composableBuilder(
    column: $state.table.lastMessageAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter cachedMessagesRefs(
    ComposableFilter Function($$CachedMessagesTableFilterComposer f) f,
  ) {
    final $$CachedMessagesTableFilterComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $state.db.cachedMessages,
      getReferencedColumn: (t) => t.conversationId,
      builder: (joinBuilder, parentComposers) =>
          $$CachedMessagesTableFilterComposer(
            ComposerState(
              $state.db,
              $state.db.cachedMessages,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return f(composer);
  }
}

class $$CachedConversationsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedConversationsTable> {
  $$CachedConversationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get lastMessagePreview => $state.composableBuilder(
    column: $state.table.lastMessagePreview,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $state.composableBuilder(
    column: $state.table.lastMessageAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedMessagesTableCreateCompanionBuilder =
    CachedMessagesCompanion Function({
      required String id,
      required String conversationId,
      required String senderId,
      required String content,
      required String contentType,
      Value<String?> replyToMessageId,
      Value<bool> isEdited,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedMessagesTableUpdateCompanionBuilder =
    CachedMessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> senderId,
      Value<String> content,
      Value<String> contentType,
      Value<String?> replyToMessageId,
      Value<bool> isEdited,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMessagesTable,
          CachedMessage,
          $$CachedMessagesTableFilterComposer,
          $$CachedMessagesTableOrderingComposer,
          $$CachedMessagesTableCreateCompanionBuilder,
          $$CachedMessagesTableUpdateCompanionBuilder
        > {
  $$CachedMessagesTableTableManager(
    _$AppDatabase db,
    $CachedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedMessagesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedMessagesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String?> replyToMessageId = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMessagesCompanion(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                contentType: contentType,
                replyToMessageId: replyToMessageId,
                isEdited: isEdited,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String senderId,
                required String content,
                required String contentType,
                Value<String?> replyToMessageId = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                contentType: contentType,
                replyToMessageId: replyToMessageId,
                isEdited: isEdited,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedMessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get senderId => $state.composableBuilder(
    column: $state.table.senderId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get content => $state.composableBuilder(
    column: $state.table.content,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get contentType => $state.composableBuilder(
    column: $state.table.contentType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get replyToMessageId => $state.composableBuilder(
    column: $state.table.replyToMessageId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isEdited => $state.composableBuilder(
    column: $state.table.isEdited,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  $$CachedConversationsTableFilterComposer get conversationId {
    final $$CachedConversationsTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationId,
          referencedTable: $state.db.cachedConversations,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedConversationsTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedConversations,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

class $$CachedMessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get senderId => $state.composableBuilder(
    column: $state.table.senderId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get content => $state.composableBuilder(
    column: $state.table.content,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get contentType => $state.composableBuilder(
    column: $state.table.contentType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get replyToMessageId => $state.composableBuilder(
    column: $state.table.replyToMessageId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isEdited => $state.composableBuilder(
    column: $state.table.isEdited,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  $$CachedConversationsTableOrderingComposer get conversationId {
    final $$CachedConversationsTableOrderingComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationId,
          referencedTable: $state.db.cachedConversations,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$CachedConversationsTableOrderingComposer(
                ComposerState(
                  $state.db,
                  $state.db.cachedConversations,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

typedef $$CachedFinanceEntriesTableCreateCompanionBuilder =
    CachedFinanceEntriesCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String type,
      Value<String?> category,
      required int amountCents,
      Value<String> currency,
      Value<String?> description,
      Value<bool> isRecurring,
      Value<String?> recurrenceRule,
      required DateTime date,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedFinanceEntriesTableUpdateCompanionBuilder =
    CachedFinanceEntriesCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> type,
      Value<String?> category,
      Value<int> amountCents,
      Value<String> currency,
      Value<String?> description,
      Value<bool> isRecurring,
      Value<String?> recurrenceRule,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedFinanceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFinanceEntriesTable,
          CachedFinanceEntry,
          $$CachedFinanceEntriesTableFilterComposer,
          $$CachedFinanceEntriesTableOrderingComposer,
          $$CachedFinanceEntriesTableCreateCompanionBuilder,
          $$CachedFinanceEntriesTableUpdateCompanionBuilder
        > {
  $$CachedFinanceEntriesTableTableManager(
    _$AppDatabase db,
    $CachedFinanceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedFinanceEntriesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedFinanceEntriesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFinanceEntriesCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                type: type,
                category: category,
                amountCents: amountCents,
                currency: currency,
                description: description,
                isRecurring: isRecurring,
                recurrenceRule: recurrenceRule,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String type,
                Value<String?> category = const Value.absent(),
                required int amountCents,
                Value<String> currency = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                required DateTime date,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedFinanceEntriesCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                type: type,
                category: category,
                amountCents: amountCents,
                currency: currency,
                description: description,
                isRecurring: isRecurring,
                recurrenceRule: recurrenceRule,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedFinanceEntriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedFinanceEntriesTable> {
  $$CachedFinanceEntriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get amountCents => $state.composableBuilder(
    column: $state.table.amountCents,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get currency => $state.composableBuilder(
    column: $state.table.currency,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isRecurring => $state.composableBuilder(
    column: $state.table.isRecurring,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get date => $state.composableBuilder(
    column: $state.table.date,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedFinanceEntriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedFinanceEntriesTable> {
  $$CachedFinanceEntriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get category => $state.composableBuilder(
    column: $state.table.category,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get amountCents => $state.composableBuilder(
    column: $state.table.amountCents,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get currency => $state.composableBuilder(
    column: $state.table.currency,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isRecurring => $state.composableBuilder(
    column: $state.table.isRecurring,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recurrenceRule => $state.composableBuilder(
    column: $state.table.recurrenceRule,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
    column: $state.table.date,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedChartersTableCreateCompanionBuilder =
    CachedChartersCompanion Function({
      required String id,
      required String spaceId,
      required String content,
      Value<int> versionNumber,
      required String editedBy,
      Value<bool> isAcknowledged,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedChartersTableUpdateCompanionBuilder =
    CachedChartersCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> content,
      Value<int> versionNumber,
      Value<String> editedBy,
      Value<bool> isAcknowledged,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedChartersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedChartersTable,
          CachedCharter,
          $$CachedChartersTableFilterComposer,
          $$CachedChartersTableOrderingComposer,
          $$CachedChartersTableCreateCompanionBuilder,
          $$CachedChartersTableUpdateCompanionBuilder
        > {
  $$CachedChartersTableTableManager(
    _$AppDatabase db,
    $CachedChartersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedChartersTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedChartersTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<bool> isAcknowledged = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChartersCompanion(
                id: id,
                spaceId: spaceId,
                content: content,
                versionNumber: versionNumber,
                editedBy: editedBy,
                isAcknowledged: isAcknowledged,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String content,
                Value<int> versionNumber = const Value.absent(),
                required String editedBy,
                Value<bool> isAcknowledged = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedChartersCompanion.insert(
                id: id,
                spaceId: spaceId,
                content: content,
                versionNumber: versionNumber,
                editedBy: editedBy,
                isAcknowledged: isAcknowledged,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedChartersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedChartersTable> {
  $$CachedChartersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get content => $state.composableBuilder(
    column: $state.table.content,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get versionNumber => $state.composableBuilder(
    column: $state.table.versionNumber,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get editedBy => $state.composableBuilder(
    column: $state.table.editedBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isAcknowledged => $state.composableBuilder(
    column: $state.table.isAcknowledged,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedChartersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedChartersTable> {
  $$CachedChartersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get content => $state.composableBuilder(
    column: $state.table.content,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get versionNumber => $state.composableBuilder(
    column: $state.table.versionNumber,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get editedBy => $state.composableBuilder(
    column: $state.table.editedBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isAcknowledged => $state.composableBuilder(
    column: $state.table.isAcknowledged,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedPollsTableCreateCompanionBuilder =
    CachedPollsCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String question,
      required String options,
      Value<String?> votes,
      Value<bool> isActive,
      Value<DateTime?> expiresAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedPollsTableUpdateCompanionBuilder =
    CachedPollsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> question,
      Value<String> options,
      Value<String?> votes,
      Value<bool> isActive,
      Value<DateTime?> expiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedPollsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPollsTable,
          CachedPoll,
          $$CachedPollsTableFilterComposer,
          $$CachedPollsTableOrderingComposer,
          $$CachedPollsTableCreateCompanionBuilder,
          $$CachedPollsTableUpdateCompanionBuilder
        > {
  $$CachedPollsTableTableManager(_$AppDatabase db, $CachedPollsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedPollsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedPollsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<String?> votes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPollsCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                question: question,
                options: options,
                votes: votes,
                isActive: isActive,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String question,
                required String options,
                Value<String?> votes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedPollsCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                question: question,
                options: options,
                votes: votes,
                isActive: isActive,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedPollsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedPollsTable> {
  $$CachedPollsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get question => $state.composableBuilder(
    column: $state.table.question,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get options => $state.composableBuilder(
    column: $state.table.options,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get votes => $state.composableBuilder(
    column: $state.table.votes,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isActive => $state.composableBuilder(
    column: $state.table.isActive,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get expiresAt => $state.composableBuilder(
    column: $state.table.expiresAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedPollsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedPollsTable> {
  $$CachedPollsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get question => $state.composableBuilder(
    column: $state.table.question,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get options => $state.composableBuilder(
    column: $state.table.options,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get votes => $state.composableBuilder(
    column: $state.table.votes,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
    column: $state.table.isActive,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get expiresAt => $state.composableBuilder(
    column: $state.table.expiresAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedCardsTableCreateCompanionBuilder =
    CachedCardsCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String type,
      required String holderName,
      Value<String?> lastFourDigits,
      Value<String?> provider,
      Value<String?> expiryDate,
      Value<String?> storeName,
      Value<String?> loyaltyNumber,
      Value<String?> encryptedData,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedCardsTableUpdateCompanionBuilder =
    CachedCardsCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> type,
      Value<String> holderName,
      Value<String?> lastFourDigits,
      Value<String?> provider,
      Value<String?> expiryDate,
      Value<String?> storeName,
      Value<String?> loyaltyNumber,
      Value<String?> encryptedData,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCardsTable,
          CachedCard,
          $$CachedCardsTableFilterComposer,
          $$CachedCardsTableOrderingComposer,
          $$CachedCardsTableCreateCompanionBuilder,
          $$CachedCardsTableUpdateCompanionBuilder
        > {
  $$CachedCardsTableTableManager(_$AppDatabase db, $CachedCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedCardsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedCardsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> holderName = const Value.absent(),
                Value<String?> lastFourDigits = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> expiryDate = const Value.absent(),
                Value<String?> storeName = const Value.absent(),
                Value<String?> loyaltyNumber = const Value.absent(),
                Value<String?> encryptedData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCardsCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                type: type,
                holderName: holderName,
                lastFourDigits: lastFourDigits,
                provider: provider,
                expiryDate: expiryDate,
                storeName: storeName,
                loyaltyNumber: loyaltyNumber,
                encryptedData: encryptedData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String type,
                required String holderName,
                Value<String?> lastFourDigits = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> expiryDate = const Value.absent(),
                Value<String?> storeName = const Value.absent(),
                Value<String?> loyaltyNumber = const Value.absent(),
                Value<String?> encryptedData = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCardsCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                type: type,
                holderName: holderName,
                lastFourDigits: lastFourDigits,
                provider: provider,
                expiryDate: expiryDate,
                storeName: storeName,
                loyaltyNumber: loyaltyNumber,
                encryptedData: encryptedData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedCardsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedCardsTable> {
  $$CachedCardsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get holderName => $state.composableBuilder(
    column: $state.table.holderName,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get lastFourDigits => $state.composableBuilder(
    column: $state.table.lastFourDigits,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get provider => $state.composableBuilder(
    column: $state.table.provider,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get expiryDate => $state.composableBuilder(
    column: $state.table.expiryDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get storeName => $state.composableBuilder(
    column: $state.table.storeName,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get loyaltyNumber => $state.composableBuilder(
    column: $state.table.loyaltyNumber,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get encryptedData => $state.composableBuilder(
    column: $state.table.encryptedData,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedCardsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedCardsTable> {
  $$CachedCardsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get type => $state.composableBuilder(
    column: $state.table.type,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get holderName => $state.composableBuilder(
    column: $state.table.holderName,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get lastFourDigits => $state.composableBuilder(
    column: $state.table.lastFourDigits,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get provider => $state.composableBuilder(
    column: $state.table.provider,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get expiryDate => $state.composableBuilder(
    column: $state.table.expiryDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get storeName => $state.composableBuilder(
    column: $state.table.storeName,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get loyaltyNumber => $state.composableBuilder(
    column: $state.table.loyaltyNumber,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get encryptedData => $state.composableBuilder(
    column: $state.table.encryptedData,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedFilesTableCreateCompanionBuilder =
    CachedFilesCompanion Function({
      required String id,
      required String spaceId,
      required String uploadedBy,
      required String filename,
      required int sizeBytes,
      required String mimeType,
      Value<String?> folderId,
      required String url,
      Value<String?> thumbnailUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedFilesTableUpdateCompanionBuilder =
    CachedFilesCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> uploadedBy,
      Value<String> filename,
      Value<int> sizeBytes,
      Value<String> mimeType,
      Value<String?> folderId,
      Value<String> url,
      Value<String?> thumbnailUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFilesTable,
          CachedFile,
          $$CachedFilesTableFilterComposer,
          $$CachedFilesTableOrderingComposer,
          $$CachedFilesTableCreateCompanionBuilder,
          $$CachedFilesTableUpdateCompanionBuilder
        > {
  $$CachedFilesTableTableManager(_$AppDatabase db, $CachedFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedFilesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedFilesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> uploadedBy = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFilesCompanion(
                id: id,
                spaceId: spaceId,
                uploadedBy: uploadedBy,
                filename: filename,
                sizeBytes: sizeBytes,
                mimeType: mimeType,
                folderId: folderId,
                url: url,
                thumbnailUrl: thumbnailUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String uploadedBy,
                required String filename,
                required int sizeBytes,
                required String mimeType,
                Value<String?> folderId = const Value.absent(),
                required String url,
                Value<String?> thumbnailUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedFilesCompanion.insert(
                id: id,
                spaceId: spaceId,
                uploadedBy: uploadedBy,
                filename: filename,
                sizeBytes: sizeBytes,
                mimeType: mimeType,
                folderId: folderId,
                url: url,
                thumbnailUrl: thumbnailUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedFilesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedFilesTable> {
  $$CachedFilesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get uploadedBy => $state.composableBuilder(
    column: $state.table.uploadedBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get filename => $state.composableBuilder(
    column: $state.table.filename,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get sizeBytes => $state.composableBuilder(
    column: $state.table.sizeBytes,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get mimeType => $state.composableBuilder(
    column: $state.table.mimeType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get folderId => $state.composableBuilder(
    column: $state.table.folderId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get url => $state.composableBuilder(
    column: $state.table.url,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get thumbnailUrl => $state.composableBuilder(
    column: $state.table.thumbnailUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedFilesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedFilesTable> {
  $$CachedFilesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get uploadedBy => $state.composableBuilder(
    column: $state.table.uploadedBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get filename => $state.composableBuilder(
    column: $state.table.filename,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get sizeBytes => $state.composableBuilder(
    column: $state.table.sizeBytes,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get mimeType => $state.composableBuilder(
    column: $state.table.mimeType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get folderId => $state.composableBuilder(
    column: $state.table.folderId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get url => $state.composableBuilder(
    column: $state.table.url,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get thumbnailUrl => $state.composableBuilder(
    column: $state.table.thumbnailUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CachedMemoriesTableCreateCompanionBuilder =
    CachedMemoriesCompanion Function({
      required String id,
      required String spaceId,
      required String createdBy,
      required String title,
      Value<String?> description,
      Value<String?> photoUrls,
      Value<bool> isMilestone,
      required DateTime memoryDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedMemoriesTableUpdateCompanionBuilder =
    CachedMemoriesCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String> createdBy,
      Value<String> title,
      Value<String?> description,
      Value<String?> photoUrls,
      Value<bool> isMilestone,
      Value<DateTime> memoryDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedMemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMemoriesTable,
          CachedMemory,
          $$CachedMemoriesTableFilterComposer,
          $$CachedMemoriesTableOrderingComposer,
          $$CachedMemoriesTableCreateCompanionBuilder,
          $$CachedMemoriesTableUpdateCompanionBuilder
        > {
  $$CachedMemoriesTableTableManager(
    _$AppDatabase db,
    $CachedMemoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CachedMemoriesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CachedMemoriesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> photoUrls = const Value.absent(),
                Value<bool> isMilestone = const Value.absent(),
                Value<DateTime> memoryDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMemoriesCompanion(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                photoUrls: photoUrls,
                isMilestone: isMilestone,
                memoryDate: memoryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String createdBy,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> photoUrls = const Value.absent(),
                Value<bool> isMilestone = const Value.absent(),
                required DateTime memoryDate,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMemoriesCompanion.insert(
                id: id,
                spaceId: spaceId,
                createdBy: createdBy,
                title: title,
                description: description,
                photoUrls: photoUrls,
                isMilestone: isMilestone,
                memoryDate: memoryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CachedMemoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CachedMemoriesTable> {
  $$CachedMemoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get photoUrls => $state.composableBuilder(
    column: $state.table.photoUrls,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isMilestone => $state.composableBuilder(
    column: $state.table.isMilestone,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get memoryDate => $state.composableBuilder(
    column: $state.table.memoryDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CachedMemoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CachedMemoriesTable> {
  $$CachedMemoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get createdBy => $state.composableBuilder(
    column: $state.table.createdBy,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get title => $state.composableBuilder(
    column: $state.table.title,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get photoUrls => $state.composableBuilder(
    column: $state.table.photoUrls,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isMilestone => $state.composableBuilder(
    column: $state.table.isMilestone,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get memoryDate => $state.composableBuilder(
    column: $state.table.memoryDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payload,
      required String spaceId,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> errorMessage,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<String> spaceId,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> errorMessage,
    });

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SyncQueueTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$SyncQueueTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                spaceId: spaceId,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                required String payload,
                required String spaceId,
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                spaceId: spaceId,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
              ),
        ),
      );
}

class $$SyncQueueTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get entityType => $state.composableBuilder(
    column: $state.table.entityType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get entityId => $state.composableBuilder(
    column: $state.table.entityId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get operation => $state.composableBuilder(
    column: $state.table.operation,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get payload => $state.composableBuilder(
    column: $state.table.payload,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get retryCount => $state.composableBuilder(
    column: $state.table.retryCount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $state.composableBuilder(
    column: $state.table.lastAttemptAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get errorMessage => $state.composableBuilder(
    column: $state.table.errorMessage,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$SyncQueueTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get entityType => $state.composableBuilder(
    column: $state.table.entityType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get entityId => $state.composableBuilder(
    column: $state.table.entityId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get operation => $state.composableBuilder(
    column: $state.table.operation,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get payload => $state.composableBuilder(
    column: $state.table.payload,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
    column: $state.table.spaceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get retryCount => $state.composableBuilder(
    column: $state.table.retryCount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $state.composableBuilder(
    column: $state.table.lastAttemptAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get errorMessage => $state.composableBuilder(
    column: $state.table.errorMessage,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AppPreferencesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$AppPreferencesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
        ),
      );
}

class $$AppPreferencesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
    column: $state.table.key,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get value => $state.composableBuilder(
    column: $state.table.value,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
    column: $state.table.key,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get value => $state.composableBuilder(
    column: $state.table.value,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedUsersTableTableManager get cachedUsers =>
      $$CachedUsersTableTableManager(_db, _db.cachedUsers);
  $$CachedSpacesTableTableManager get cachedSpaces =>
      $$CachedSpacesTableTableManager(_db, _db.cachedSpaces);
  $$CachedSpaceMembershipsTableTableManager get cachedSpaceMemberships =>
      $$CachedSpaceMembershipsTableTableManager(
        _db,
        _db.cachedSpaceMemberships,
      );
  $$CachedActivitiesTableTableManager get cachedActivities =>
      $$CachedActivitiesTableTableManager(_db, _db.cachedActivities);
  $$CachedActivityVotesTableTableManager get cachedActivityVotes =>
      $$CachedActivityVotesTableTableManager(_db, _db.cachedActivityVotes);
  $$CachedCalendarEventsTableTableManager get cachedCalendarEvents =>
      $$CachedCalendarEventsTableTableManager(_db, _db.cachedCalendarEvents);
  $$CachedTasksTableTableManager get cachedTasks =>
      $$CachedTasksTableTableManager(_db, _db.cachedTasks);
  $$CachedRemindersTableTableManager get cachedReminders =>
      $$CachedRemindersTableTableManager(_db, _db.cachedReminders);
  $$CachedGroceryListsTableTableManager get cachedGroceryLists =>
      $$CachedGroceryListsTableTableManager(_db, _db.cachedGroceryLists);
  $$CachedGroceryItemsTableTableManager get cachedGroceryItems =>
      $$CachedGroceryItemsTableTableManager(_db, _db.cachedGroceryItems);
  $$CachedNotificationsTableTableManager get cachedNotifications =>
      $$CachedNotificationsTableTableManager(_db, _db.cachedNotifications);
  $$CachedConversationsTableTableManager get cachedConversations =>
      $$CachedConversationsTableTableManager(_db, _db.cachedConversations);
  $$CachedMessagesTableTableManager get cachedMessages =>
      $$CachedMessagesTableTableManager(_db, _db.cachedMessages);
  $$CachedFinanceEntriesTableTableManager get cachedFinanceEntries =>
      $$CachedFinanceEntriesTableTableManager(_db, _db.cachedFinanceEntries);
  $$CachedChartersTableTableManager get cachedCharters =>
      $$CachedChartersTableTableManager(_db, _db.cachedCharters);
  $$CachedPollsTableTableManager get cachedPolls =>
      $$CachedPollsTableTableManager(_db, _db.cachedPolls);
  $$CachedCardsTableTableManager get cachedCards =>
      $$CachedCardsTableTableManager(_db, _db.cachedCards);
  $$CachedFilesTableTableManager get cachedFiles =>
      $$CachedFilesTableTableManager(_db, _db.cachedFiles);
  $$CachedMemoriesTableTableManager get cachedMemories =>
      $$CachedMemoriesTableTableManager(_db, _db.cachedMemories);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
