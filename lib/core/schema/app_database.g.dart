// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _profilePicturePathMeta =
      const VerificationMeta('profilePicturePath');
  @override
  late final GeneratedColumn<String> profilePicturePath =
      GeneratedColumn<String>(
        'profile_picture_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    name,
    email,
    profilePicturePath,
    phoneNumber,
    emergencyContact,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('profile_picture_path')) {
      context.handle(
        _profilePicturePathMeta,
        profilePicturePath.isAcceptableOrUnknown(
          data['profile_picture_path']!,
          _profilePicturePathMeta,
        ),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      profilePicturePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_picture_path'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String remoteId;
  final String name;
  final String email;
  final String? profilePicturePath;
  final String? phoneNumber;
  final String? emergencyContact;
  final DateTime createdAt;
  const User({
    required this.remoteId,
    required this.name,
    required this.email,
    this.profilePicturePath,
    this.phoneNumber,
    this.emergencyContact,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || profilePicturePath != null) {
      map['profile_picture_path'] = Variable<String>(profilePicturePath);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      remoteId: Value(remoteId),
      name: Value(name),
      email: Value(email),
      profilePicturePath: profilePicturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicturePath),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      profilePicturePath: serializer.fromJson<String?>(
        json['profilePicturePath'],
      ),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'profilePicturePath': serializer.toJson<String?>(profilePicturePath),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    String? remoteId,
    String? name,
    String? email,
    Value<String?> profilePicturePath = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> emergencyContact = const Value.absent(),
    DateTime? createdAt,
  }) => User(
    remoteId: remoteId ?? this.remoteId,
    name: name ?? this.name,
    email: email ?? this.email,
    profilePicturePath: profilePicturePath.present
        ? profilePicturePath.value
        : this.profilePicturePath,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    emergencyContact: emergencyContact.present
        ? emergencyContact.value
        : this.emergencyContact,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      profilePicturePath: data.profilePicturePath.present
          ? data.profilePicturePath.value
          : this.profilePicturePath,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePicturePath: $profilePicturePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    name,
    email,
    profilePicturePath,
    phoneNumber,
    emergencyContact,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.email == this.email &&
          other.profilePicturePath == this.profilePicturePath &&
          other.phoneNumber == this.phoneNumber &&
          other.emergencyContact == this.emergencyContact &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> remoteId;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> profilePicturePath;
  final Value<String?> phoneNumber;
  final Value<String?> emergencyContact;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePicturePath = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String remoteId,
    required String name,
    required String email,
    this.profilePicturePath = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       name = Value(name),
       email = Value(email);
  static Insertable<User> custom({
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? profilePicturePath,
    Expression<String>? phoneNumber,
    Expression<String>? emergencyContact,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profilePicturePath != null)
        'profile_picture_path': profilePicturePath,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? profilePicturePath,
    Value<String?>? phoneNumber,
    Value<String?>? emergencyContact,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (profilePicturePath.present) {
      map['profile_picture_path'] = Variable<String>(profilePicturePath.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePicturePath: $profilePicturePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userRemoteIdMeta = const VerificationMeta(
    'userRemoteId',
  );
  @override
  late final GeneratedColumn<String> userRemoteId = GeneratedColumn<String>(
    'user_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campRemoteIdMeta = const VerificationMeta(
    'campRemoteId',
  );
  @override
  late final GeneratedColumn<String> campRemoteId = GeneratedColumn<String>(
    'camp_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userRemoteId,
    campRemoteId,
    longitude,
    latitude,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_remote_id')) {
      context.handle(
        _userRemoteIdMeta,
        userRemoteId.isAcceptableOrUnknown(
          data['user_remote_id']!,
          _userRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userRemoteIdMeta);
    }
    if (data.containsKey('camp_remote_id')) {
      context.handle(
        _campRemoteIdMeta,
        campRemoteId.isAcceptableOrUnknown(
          data['camp_remote_id']!,
          _campRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_campRemoteIdMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userRemoteId};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      userRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remote_id'],
      )!,
      campRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_remote_id'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final String userRemoteId;
  final String campRemoteId;
  final double longitude;
  final double latitude;
  final DateTime? lastUpdated;
  const Location({
    required this.userRemoteId,
    required this.campRemoteId,
    required this.longitude,
    required this.latitude,
    this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_remote_id'] = Variable<String>(userRemoteId);
    map['camp_remote_id'] = Variable<String>(campRemoteId);
    map['longitude'] = Variable<double>(longitude);
    map['latitude'] = Variable<double>(latitude);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      userRemoteId: Value(userRemoteId),
      campRemoteId: Value(campRemoteId),
      longitude: Value(longitude),
      latitude: Value(latitude),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      userRemoteId: serializer.fromJson<String>(json['userRemoteId']),
      campRemoteId: serializer.fromJson<String>(json['campRemoteId']),
      longitude: serializer.fromJson<double>(json['longitude']),
      latitude: serializer.fromJson<double>(json['latitude']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userRemoteId': serializer.toJson<String>(userRemoteId),
      'campRemoteId': serializer.toJson<String>(campRemoteId),
      'longitude': serializer.toJson<double>(longitude),
      'latitude': serializer.toJson<double>(latitude),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  Location copyWith({
    String? userRemoteId,
    String? campRemoteId,
    double? longitude,
    double? latitude,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => Location(
    userRemoteId: userRemoteId ?? this.userRemoteId,
    campRemoteId: campRemoteId ?? this.campRemoteId,
    longitude: longitude ?? this.longitude,
    latitude: latitude ?? this.latitude,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      userRemoteId: data.userRemoteId.present
          ? data.userRemoteId.value
          : this.userRemoteId,
      campRemoteId: data.campRemoteId.present
          ? data.campRemoteId.value
          : this.campRemoteId,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('longitude: $longitude, ')
          ..write('latitude: $latitude, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userRemoteId, campRemoteId, longitude, latitude, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.userRemoteId == this.userRemoteId &&
          other.campRemoteId == this.campRemoteId &&
          other.longitude == this.longitude &&
          other.latitude == this.latitude &&
          other.lastUpdated == this.lastUpdated);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<String> userRemoteId;
  final Value<String> campRemoteId;
  final Value<double> longitude;
  final Value<double> latitude;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const LocationsCompanion({
    this.userRemoteId = const Value.absent(),
    this.campRemoteId = const Value.absent(),
    this.longitude = const Value.absent(),
    this.latitude = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String userRemoteId,
    required String campRemoteId,
    required double longitude,
    required double latitude,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userRemoteId = Value(userRemoteId),
       campRemoteId = Value(campRemoteId),
       longitude = Value(longitude),
       latitude = Value(latitude);
  static Insertable<Location> custom({
    Expression<String>? userRemoteId,
    Expression<String>? campRemoteId,
    Expression<double>? longitude,
    Expression<double>? latitude,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userRemoteId != null) 'user_remote_id': userRemoteId,
      if (campRemoteId != null) 'camp_remote_id': campRemoteId,
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'latitude': latitude,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? userRemoteId,
    Value<String>? campRemoteId,
    Value<double>? longitude,
    Value<double>? latitude,
    Value<DateTime?>? lastUpdated,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      campRemoteId: campRemoteId ?? this.campRemoteId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userRemoteId.present) {
      map['user_remote_id'] = Variable<String>(userRemoteId.value);
    }
    if (campRemoteId.present) {
      map['camp_remote_id'] = Variable<String>(campRemoteId.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('longitude: $longitude, ')
          ..write('latitude: $latitude, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campRemoteIdMeta = const VerificationMeta(
    'campRemoteId',
  );
  @override
  late final GeneratedColumn<String> campRemoteId = GeneratedColumn<String>(
    'camp_remote_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
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
    defaultValue: const Constant('USD'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    campRemoteId,
    name,
    dueDate,
    amount,
    currency,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('camp_remote_id')) {
      context.handle(
        _campRemoteIdMeta,
        campRemoteId.isAcceptableOrUnknown(
          data['camp_remote_id']!,
          _campRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_campRemoteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      campRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_remote_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String remoteId;
  final String campRemoteId;
  final String name;
  final DateTime? dueDate;
  final int amount;
  final String currency;
  final DateTime createdAt;
  const Payment({
    required this.remoteId,
    required this.campRemoteId,
    required this.name,
    this.dueDate,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['camp_remote_id'] = Variable<String>(campRemoteId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      remoteId: Value(remoteId),
      campRemoteId: Value(campRemoteId),
      name: Value(name),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      amount: Value(amount),
      currency: Value(currency),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      campRemoteId: serializer.fromJson<String>(json['campRemoteId']),
      name: serializer.fromJson<String>(json['name']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'campRemoteId': serializer.toJson<String>(campRemoteId),
      'name': serializer.toJson<String>(name),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    String? remoteId,
    String? campRemoteId,
    String? name,
    Value<DateTime?> dueDate = const Value.absent(),
    int? amount,
    String? currency,
    DateTime? createdAt,
  }) => Payment(
    remoteId: remoteId ?? this.remoteId,
    campRemoteId: campRemoteId ?? this.campRemoteId,
    name: name ?? this.name,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      campRemoteId: data.campRemoteId.present
          ? data.campRemoteId.value
          : this.campRemoteId,
      name: data.name.present ? data.name.value : this.name,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('remoteId: $remoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('name: $name, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    campRemoteId,
    name,
    dueDate,
    amount,
    currency,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.remoteId == this.remoteId &&
          other.campRemoteId == this.campRemoteId &&
          other.name == this.name &&
          other.dueDate == this.dueDate &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> remoteId;
  final Value<String> campRemoteId;
  final Value<String> name;
  final Value<DateTime?> dueDate;
  final Value<int> amount;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.remoteId = const Value.absent(),
    this.campRemoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String remoteId,
    required String campRemoteId,
    required String name,
    this.dueDate = const Value.absent(),
    required int amount,
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       campRemoteId = Value(campRemoteId),
       name = Value(name),
       amount = Value(amount);
  static Insertable<Payment> custom({
    Expression<String>? remoteId,
    Expression<String>? campRemoteId,
    Expression<String>? name,
    Expression<DateTime>? dueDate,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (campRemoteId != null) 'camp_remote_id': campRemoteId,
      if (name != null) 'name': name,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? campRemoteId,
    Value<String>? name,
    Value<DateTime?>? dueDate,
    Value<int>? amount,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      remoteId: remoteId ?? this.remoteId,
      campRemoteId: campRemoteId ?? this.campRemoteId,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (campRemoteId.present) {
      map['camp_remote_id'] = Variable<String>(campRemoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('name: $name, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPaymentsTable extends UserPayments
    with TableInfo<$UserPaymentsTable, UserPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userRemoteIdMeta = const VerificationMeta(
    'userRemoteId',
  );
  @override
  late final GeneratedColumn<String> userRemoteId = GeneratedColumn<String>(
    'user_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentRemoteIdMeta = const VerificationMeta(
    'paymentRemoteId',
  );
  @override
  late final GeneratedColumn<String> paymentRemoteId = GeneratedColumn<String>(
    'payment_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  @override
  List<GeneratedColumn> get $columns => [userRemoteId, paymentRemoteId, isPaid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_remote_id')) {
      context.handle(
        _userRemoteIdMeta,
        userRemoteId.isAcceptableOrUnknown(
          data['user_remote_id']!,
          _userRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userRemoteIdMeta);
    }
    if (data.containsKey('payment_remote_id')) {
      context.handle(
        _paymentRemoteIdMeta,
        paymentRemoteId.isAcceptableOrUnknown(
          data['payment_remote_id']!,
          _paymentRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentRemoteIdMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userRemoteId, paymentRemoteId};
  @override
  UserPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPayment(
      userRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remote_id'],
      )!,
      paymentRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_remote_id'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
    );
  }

  @override
  $UserPaymentsTable createAlias(String alias) {
    return $UserPaymentsTable(attachedDatabase, alias);
  }
}

class UserPayment extends DataClass implements Insertable<UserPayment> {
  final String userRemoteId;
  final String paymentRemoteId;
  final bool isPaid;
  const UserPayment({
    required this.userRemoteId,
    required this.paymentRemoteId,
    required this.isPaid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_remote_id'] = Variable<String>(userRemoteId);
    map['payment_remote_id'] = Variable<String>(paymentRemoteId);
    map['is_paid'] = Variable<bool>(isPaid);
    return map;
  }

  UserPaymentsCompanion toCompanion(bool nullToAbsent) {
    return UserPaymentsCompanion(
      userRemoteId: Value(userRemoteId),
      paymentRemoteId: Value(paymentRemoteId),
      isPaid: Value(isPaid),
    );
  }

  factory UserPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPayment(
      userRemoteId: serializer.fromJson<String>(json['userRemoteId']),
      paymentRemoteId: serializer.fromJson<String>(json['paymentRemoteId']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userRemoteId': serializer.toJson<String>(userRemoteId),
      'paymentRemoteId': serializer.toJson<String>(paymentRemoteId),
      'isPaid': serializer.toJson<bool>(isPaid),
    };
  }

  UserPayment copyWith({
    String? userRemoteId,
    String? paymentRemoteId,
    bool? isPaid,
  }) => UserPayment(
    userRemoteId: userRemoteId ?? this.userRemoteId,
    paymentRemoteId: paymentRemoteId ?? this.paymentRemoteId,
    isPaid: isPaid ?? this.isPaid,
  );
  UserPayment copyWithCompanion(UserPaymentsCompanion data) {
    return UserPayment(
      userRemoteId: data.userRemoteId.present
          ? data.userRemoteId.value
          : this.userRemoteId,
      paymentRemoteId: data.paymentRemoteId.present
          ? data.paymentRemoteId.value
          : this.paymentRemoteId,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPayment(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('paymentRemoteId: $paymentRemoteId, ')
          ..write('isPaid: $isPaid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userRemoteId, paymentRemoteId, isPaid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPayment &&
          other.userRemoteId == this.userRemoteId &&
          other.paymentRemoteId == this.paymentRemoteId &&
          other.isPaid == this.isPaid);
}

class UserPaymentsCompanion extends UpdateCompanion<UserPayment> {
  final Value<String> userRemoteId;
  final Value<String> paymentRemoteId;
  final Value<bool> isPaid;
  final Value<int> rowid;
  const UserPaymentsCompanion({
    this.userRemoteId = const Value.absent(),
    this.paymentRemoteId = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPaymentsCompanion.insert({
    required String userRemoteId,
    required String paymentRemoteId,
    this.isPaid = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userRemoteId = Value(userRemoteId),
       paymentRemoteId = Value(paymentRemoteId);
  static Insertable<UserPayment> custom({
    Expression<String>? userRemoteId,
    Expression<String>? paymentRemoteId,
    Expression<bool>? isPaid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userRemoteId != null) 'user_remote_id': userRemoteId,
      if (paymentRemoteId != null) 'payment_remote_id': paymentRemoteId,
      if (isPaid != null) 'is_paid': isPaid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPaymentsCompanion copyWith({
    Value<String>? userRemoteId,
    Value<String>? paymentRemoteId,
    Value<bool>? isPaid,
    Value<int>? rowid,
  }) {
    return UserPaymentsCompanion(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      paymentRemoteId: paymentRemoteId ?? this.paymentRemoteId,
      isPaid: isPaid ?? this.isPaid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userRemoteId.present) {
      map['user_remote_id'] = Variable<String>(userRemoteId.value);
    }
    if (paymentRemoteId.present) {
      map['payment_remote_id'] = Variable<String>(paymentRemoteId.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPaymentsCompanion(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('paymentRemoteId: $paymentRemoteId, ')
          ..write('isPaid: $isPaid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampsTable extends Camps with TableInfo<$CampsTable, Camp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minGroupSizeMeta = const VerificationMeta(
    'minGroupSize',
  );
  @override
  late final GeneratedColumn<int> minGroupSize = GeneratedColumn<int>(
    'min_group_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatRemoteIdMeta = const VerificationMeta(
    'chatRemoteId',
  );
  @override
  late final GeneratedColumn<String> chatRemoteId = GeneratedColumn<String>(
    'chat_remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffChatRemoteIdMeta = const VerificationMeta(
    'staffChatRemoteId',
  );
  @override
  late final GeneratedColumn<String> staffChatRemoteId =
      GeneratedColumn<String>(
        'staff_chat_remote_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _joinCodeMeta = const VerificationMeta(
    'joinCode',
  );
  @override
  late final GeneratedColumn<String> joinCode = GeneratedColumn<String>(
    'join_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _myRoleMeta = const VerificationMeta('myRole');
  @override
  late final GeneratedColumn<String> myRole = GeneratedColumn<String>(
    'my_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    name,
    startDate,
    endDate,
    minGroupSize,
    chatRemoteId,
    staffChatRemoteId,
    joinCode,
    myRole,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Camp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('min_group_size')) {
      context.handle(
        _minGroupSizeMeta,
        minGroupSize.isAcceptableOrUnknown(
          data['min_group_size']!,
          _minGroupSizeMeta,
        ),
      );
    }
    if (data.containsKey('chat_remote_id')) {
      context.handle(
        _chatRemoteIdMeta,
        chatRemoteId.isAcceptableOrUnknown(
          data['chat_remote_id']!,
          _chatRemoteIdMeta,
        ),
      );
    }
    if (data.containsKey('staff_chat_remote_id')) {
      context.handle(
        _staffChatRemoteIdMeta,
        staffChatRemoteId.isAcceptableOrUnknown(
          data['staff_chat_remote_id']!,
          _staffChatRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_staffChatRemoteIdMeta);
    }
    if (data.containsKey('join_code')) {
      context.handle(
        _joinCodeMeta,
        joinCode.isAcceptableOrUnknown(data['join_code']!, _joinCodeMeta),
      );
    }
    if (data.containsKey('my_role')) {
      context.handle(
        _myRoleMeta,
        myRole.isAcceptableOrUnknown(data['my_role']!, _myRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_myRoleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  Camp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Camp(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      minGroupSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_group_size'],
      ),
      chatRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_remote_id'],
      ),
      staffChatRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_chat_remote_id'],
      )!,
      joinCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}join_code'],
      ),
      myRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_role'],
      )!,
    );
  }

  @override
  $CampsTable createAlias(String alias) {
    return $CampsTable(attachedDatabase, alias);
  }
}

class Camp extends DataClass implements Insertable<Camp> {
  final String remoteId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minGroupSize;
  final String? chatRemoteId;
  final String staffChatRemoteId;
  final String? joinCode;
  final String myRole;
  const Camp({
    required this.remoteId,
    required this.name,
    this.startDate,
    this.endDate,
    this.minGroupSize,
    this.chatRemoteId,
    required this.staffChatRemoteId,
    this.joinCode,
    required this.myRole,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || minGroupSize != null) {
      map['min_group_size'] = Variable<int>(minGroupSize);
    }
    if (!nullToAbsent || chatRemoteId != null) {
      map['chat_remote_id'] = Variable<String>(chatRemoteId);
    }
    map['staff_chat_remote_id'] = Variable<String>(staffChatRemoteId);
    if (!nullToAbsent || joinCode != null) {
      map['join_code'] = Variable<String>(joinCode);
    }
    map['my_role'] = Variable<String>(myRole);
    return map;
  }

  CampsCompanion toCompanion(bool nullToAbsent) {
    return CampsCompanion(
      remoteId: Value(remoteId),
      name: Value(name),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      minGroupSize: minGroupSize == null && nullToAbsent
          ? const Value.absent()
          : Value(minGroupSize),
      chatRemoteId: chatRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(chatRemoteId),
      staffChatRemoteId: Value(staffChatRemoteId),
      joinCode: joinCode == null && nullToAbsent
          ? const Value.absent()
          : Value(joinCode),
      myRole: Value(myRole),
    );
  }

  factory Camp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Camp(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      minGroupSize: serializer.fromJson<int?>(json['minGroupSize']),
      chatRemoteId: serializer.fromJson<String?>(json['chatRemoteId']),
      staffChatRemoteId: serializer.fromJson<String>(json['staffChatRemoteId']),
      joinCode: serializer.fromJson<String?>(json['joinCode']),
      myRole: serializer.fromJson<String>(json['myRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'minGroupSize': serializer.toJson<int?>(minGroupSize),
      'chatRemoteId': serializer.toJson<String?>(chatRemoteId),
      'staffChatRemoteId': serializer.toJson<String>(staffChatRemoteId),
      'joinCode': serializer.toJson<String?>(joinCode),
      'myRole': serializer.toJson<String>(myRole),
    };
  }

  Camp copyWith({
    String? remoteId,
    String? name,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> minGroupSize = const Value.absent(),
    Value<String?> chatRemoteId = const Value.absent(),
    String? staffChatRemoteId,
    Value<String?> joinCode = const Value.absent(),
    String? myRole,
  }) => Camp(
    remoteId: remoteId ?? this.remoteId,
    name: name ?? this.name,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    minGroupSize: minGroupSize.present ? minGroupSize.value : this.minGroupSize,
    chatRemoteId: chatRemoteId.present ? chatRemoteId.value : this.chatRemoteId,
    staffChatRemoteId: staffChatRemoteId ?? this.staffChatRemoteId,
    joinCode: joinCode.present ? joinCode.value : this.joinCode,
    myRole: myRole ?? this.myRole,
  );
  Camp copyWithCompanion(CampsCompanion data) {
    return Camp(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      minGroupSize: data.minGroupSize.present
          ? data.minGroupSize.value
          : this.minGroupSize,
      chatRemoteId: data.chatRemoteId.present
          ? data.chatRemoteId.value
          : this.chatRemoteId,
      staffChatRemoteId: data.staffChatRemoteId.present
          ? data.staffChatRemoteId.value
          : this.staffChatRemoteId,
      joinCode: data.joinCode.present ? data.joinCode.value : this.joinCode,
      myRole: data.myRole.present ? data.myRole.value : this.myRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Camp(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('minGroupSize: $minGroupSize, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('staffChatRemoteId: $staffChatRemoteId, ')
          ..write('joinCode: $joinCode, ')
          ..write('myRole: $myRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    name,
    startDate,
    endDate,
    minGroupSize,
    chatRemoteId,
    staffChatRemoteId,
    joinCode,
    myRole,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Camp &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.minGroupSize == this.minGroupSize &&
          other.chatRemoteId == this.chatRemoteId &&
          other.staffChatRemoteId == this.staffChatRemoteId &&
          other.joinCode == this.joinCode &&
          other.myRole == this.myRole);
}

class CampsCompanion extends UpdateCompanion<Camp> {
  final Value<String> remoteId;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> minGroupSize;
  final Value<String?> chatRemoteId;
  final Value<String> staffChatRemoteId;
  final Value<String?> joinCode;
  final Value<String> myRole;
  final Value<int> rowid;
  const CampsCompanion({
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.minGroupSize = const Value.absent(),
    this.chatRemoteId = const Value.absent(),
    this.staffChatRemoteId = const Value.absent(),
    this.joinCode = const Value.absent(),
    this.myRole = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampsCompanion.insert({
    required String remoteId,
    required String name,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.minGroupSize = const Value.absent(),
    this.chatRemoteId = const Value.absent(),
    required String staffChatRemoteId,
    this.joinCode = const Value.absent(),
    required String myRole,
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       name = Value(name),
       staffChatRemoteId = Value(staffChatRemoteId),
       myRole = Value(myRole);
  static Insertable<Camp> custom({
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? minGroupSize,
    Expression<String>? chatRemoteId,
    Expression<String>? staffChatRemoteId,
    Expression<String>? joinCode,
    Expression<String>? myRole,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (minGroupSize != null) 'min_group_size': minGroupSize,
      if (chatRemoteId != null) 'chat_remote_id': chatRemoteId,
      if (staffChatRemoteId != null) 'staff_chat_remote_id': staffChatRemoteId,
      if (joinCode != null) 'join_code': joinCode,
      if (myRole != null) 'my_role': myRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? name,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? minGroupSize,
    Value<String?>? chatRemoteId,
    Value<String>? staffChatRemoteId,
    Value<String?>? joinCode,
    Value<String>? myRole,
    Value<int>? rowid,
  }) {
    return CampsCompanion(
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minGroupSize: minGroupSize ?? this.minGroupSize,
      chatRemoteId: chatRemoteId ?? this.chatRemoteId,
      staffChatRemoteId: staffChatRemoteId ?? this.staffChatRemoteId,
      joinCode: joinCode ?? this.joinCode,
      myRole: myRole ?? this.myRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (minGroupSize.present) {
      map['min_group_size'] = Variable<int>(minGroupSize.value);
    }
    if (chatRemoteId.present) {
      map['chat_remote_id'] = Variable<String>(chatRemoteId.value);
    }
    if (staffChatRemoteId.present) {
      map['staff_chat_remote_id'] = Variable<String>(staffChatRemoteId.value);
    }
    if (joinCode.present) {
      map['join_code'] = Variable<String>(joinCode.value);
    }
    if (myRole.present) {
      map['my_role'] = Variable<String>(myRole.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('minGroupSize: $minGroupSize, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('staffChatRemoteId: $staffChatRemoteId, ')
          ..write('joinCode: $joinCode, ')
          ..write('myRole: $myRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _campRemoteIdMeta = const VerificationMeta(
    'campRemoteId',
  );
  @override
  late final GeneratedColumn<String> campRemoteId = GeneratedColumn<String>(
    'camp_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
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
  static const VerificationMeta _joinCodeMeta = const VerificationMeta(
    'joinCode',
  );
  @override
  late final GeneratedColumn<String> joinCode = GeneratedColumn<String>(
    'join_code',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    name,
    color,
    lastSeenAt,
    lastMessageAt,
    campRemoteId,
    typeId,
    type,
    joinCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
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
    if (data.containsKey('camp_remote_id')) {
      context.handle(
        _campRemoteIdMeta,
        campRemoteId.isAcceptableOrUnknown(
          data['camp_remote_id']!,
          _campRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_campRemoteIdMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
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
    if (data.containsKey('join_code')) {
      context.handle(
        _joinCodeMeta,
        joinCode.isAcceptableOrUnknown(data['join_code']!, _joinCodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      campRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_remote_id'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      joinCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}join_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final String remoteId;
  final String name;
  final String? color;
  final DateTime? lastSeenAt;
  final DateTime? lastMessageAt;
  final String campRemoteId;

  /// 'Real Room Id', 'Real Group Id', 'Archived Chat Has no typeId', 'Camp Id'
  final String? typeId;
  final String type;
  final String? joinCode;
  final DateTime? createdAt;
  const Chat({
    required this.remoteId,
    required this.name,
    this.color,
    this.lastSeenAt,
    this.lastMessageAt,
    required this.campRemoteId,
    this.typeId,
    required this.type,
    this.joinCode,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['camp_remote_id'] = Variable<String>(campRemoteId);
    if (!nullToAbsent || typeId != null) {
      map['type_id'] = Variable<String>(typeId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || joinCode != null) {
      map['join_code'] = Variable<String>(joinCode);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      remoteId: Value(remoteId),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      campRemoteId: Value(campRemoteId),
      typeId: typeId == null && nullToAbsent
          ? const Value.absent()
          : Value(typeId),
      type: Value(type),
      joinCode: joinCode == null && nullToAbsent
          ? const Value.absent()
          : Value(joinCode),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Chat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      campRemoteId: serializer.fromJson<String>(json['campRemoteId']),
      typeId: serializer.fromJson<String?>(json['typeId']),
      type: serializer.fromJson<String>(json['type']),
      joinCode: serializer.fromJson<String?>(json['joinCode']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'campRemoteId': serializer.toJson<String>(campRemoteId),
      'typeId': serializer.toJson<String?>(typeId),
      'type': serializer.toJson<String>(type),
      'joinCode': serializer.toJson<String?>(joinCode),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Chat copyWith({
    String? remoteId,
    String? name,
    Value<String?> color = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    String? campRemoteId,
    Value<String?> typeId = const Value.absent(),
    String? type,
    Value<String?> joinCode = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Chat(
    remoteId: remoteId ?? this.remoteId,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    campRemoteId: campRemoteId ?? this.campRemoteId,
    typeId: typeId.present ? typeId.value : this.typeId,
    type: type ?? this.type,
    joinCode: joinCode.present ? joinCode.value : this.joinCode,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      campRemoteId: data.campRemoteId.present
          ? data.campRemoteId.value
          : this.campRemoteId,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      type: data.type.present ? data.type.value : this.type,
      joinCode: data.joinCode.present ? data.joinCode.value : this.joinCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('typeId: $typeId, ')
          ..write('type: $type, ')
          ..write('joinCode: $joinCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    name,
    color,
    lastSeenAt,
    lastMessageAt,
    campRemoteId,
    typeId,
    type,
    joinCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.color == this.color &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastMessageAt == this.lastMessageAt &&
          other.campRemoteId == this.campRemoteId &&
          other.typeId == this.typeId &&
          other.type == this.type &&
          other.joinCode == this.joinCode &&
          other.createdAt == this.createdAt);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<String> remoteId;
  final Value<String> name;
  final Value<String?> color;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> lastMessageAt;
  final Value<String> campRemoteId;
  final Value<String?> typeId;
  final Value<String> type;
  final Value<String?> joinCode;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const ChatsCompanion({
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.campRemoteId = const Value.absent(),
    this.typeId = const Value.absent(),
    this.type = const Value.absent(),
    this.joinCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String remoteId,
    required String name,
    this.color = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    required String campRemoteId,
    this.typeId = const Value.absent(),
    required String type,
    this.joinCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       name = Value(name),
       campRemoteId = Value(campRemoteId),
       type = Value(type);
  static Insertable<Chat> custom({
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? lastMessageAt,
    Expression<String>? campRemoteId,
    Expression<String>? typeId,
    Expression<String>? type,
    Expression<String>? joinCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (campRemoteId != null) 'camp_remote_id': campRemoteId,
      if (typeId != null) 'type_id': typeId,
      if (type != null) 'type': type,
      if (joinCode != null) 'join_code': joinCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? name,
    Value<String?>? color,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? lastMessageAt,
    Value<String>? campRemoteId,
    Value<String?>? typeId,
    Value<String>? type,
    Value<String?>? joinCode,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      color: color ?? this.color,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      campRemoteId: campRemoteId ?? this.campRemoteId,
      typeId: typeId ?? this.typeId,
      type: type ?? this.type,
      joinCode: joinCode ?? this.joinCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (campRemoteId.present) {
      map['camp_remote_id'] = Variable<String>(campRemoteId.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (joinCode.present) {
      map['join_code'] = Variable<String>(joinCode.value);
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
    return (StringBuffer('ChatsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('typeId: $typeId, ')
          ..write('type: $type, ')
          ..write('joinCode: $joinCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberToCampTable extends MemberToCamp
    with TableInfo<$MemberToCampTable, MemberToCampData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberToCampTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userRemoteIdMeta = const VerificationMeta(
    'userRemoteId',
  );
  @override
  late final GeneratedColumn<String> userRemoteId = GeneratedColumn<String>(
    'user_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campRemoteIdMeta = const VerificationMeta(
    'campRemoteId',
  );
  @override
  late final GeneratedColumn<String> campRemoteId = GeneratedColumn<String>(
    'camp_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userRemoteId,
    campRemoteId,
    role,
    groupId,
    roomId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_to_camp';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberToCampData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_remote_id')) {
      context.handle(
        _userRemoteIdMeta,
        userRemoteId.isAcceptableOrUnknown(
          data['user_remote_id']!,
          _userRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userRemoteIdMeta);
    }
    if (data.containsKey('camp_remote_id')) {
      context.handle(
        _campRemoteIdMeta,
        campRemoteId.isAcceptableOrUnknown(
          data['camp_remote_id']!,
          _campRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_campRemoteIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userRemoteId, campRemoteId};
  @override
  MemberToCampData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberToCampData(
      userRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remote_id'],
      )!,
      campRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_remote_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
    );
  }

  @override
  $MemberToCampTable createAlias(String alias) {
    return $MemberToCampTable(attachedDatabase, alias);
  }
}

class MemberToCampData extends DataClass
    implements Insertable<MemberToCampData> {
  final String userRemoteId;
  final String campRemoteId;
  final String role;
  final String? groupId;
  final String? roomId;
  const MemberToCampData({
    required this.userRemoteId,
    required this.campRemoteId,
    required this.role,
    this.groupId,
    this.roomId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_remote_id'] = Variable<String>(userRemoteId);
    map['camp_remote_id'] = Variable<String>(campRemoteId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    return map;
  }

  MemberToCampCompanion toCompanion(bool nullToAbsent) {
    return MemberToCampCompanion(
      userRemoteId: Value(userRemoteId),
      campRemoteId: Value(campRemoteId),
      role: Value(role),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
    );
  }

  factory MemberToCampData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberToCampData(
      userRemoteId: serializer.fromJson<String>(json['userRemoteId']),
      campRemoteId: serializer.fromJson<String>(json['campRemoteId']),
      role: serializer.fromJson<String>(json['role']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      roomId: serializer.fromJson<String?>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userRemoteId': serializer.toJson<String>(userRemoteId),
      'campRemoteId': serializer.toJson<String>(campRemoteId),
      'role': serializer.toJson<String>(role),
      'groupId': serializer.toJson<String?>(groupId),
      'roomId': serializer.toJson<String?>(roomId),
    };
  }

  MemberToCampData copyWith({
    String? userRemoteId,
    String? campRemoteId,
    String? role,
    Value<String?> groupId = const Value.absent(),
    Value<String?> roomId = const Value.absent(),
  }) => MemberToCampData(
    userRemoteId: userRemoteId ?? this.userRemoteId,
    campRemoteId: campRemoteId ?? this.campRemoteId,
    role: role ?? this.role,
    groupId: groupId.present ? groupId.value : this.groupId,
    roomId: roomId.present ? roomId.value : this.roomId,
  );
  MemberToCampData copyWithCompanion(MemberToCampCompanion data) {
    return MemberToCampData(
      userRemoteId: data.userRemoteId.present
          ? data.userRemoteId.value
          : this.userRemoteId,
      campRemoteId: data.campRemoteId.present
          ? data.campRemoteId.value
          : this.campRemoteId,
      role: data.role.present ? data.role.value : this.role,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberToCampData(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('role: $role, ')
          ..write('groupId: $groupId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userRemoteId, campRemoteId, role, groupId, roomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberToCampData &&
          other.userRemoteId == this.userRemoteId &&
          other.campRemoteId == this.campRemoteId &&
          other.role == this.role &&
          other.groupId == this.groupId &&
          other.roomId == this.roomId);
}

class MemberToCampCompanion extends UpdateCompanion<MemberToCampData> {
  final Value<String> userRemoteId;
  final Value<String> campRemoteId;
  final Value<String> role;
  final Value<String?> groupId;
  final Value<String?> roomId;
  final Value<int> rowid;
  const MemberToCampCompanion({
    this.userRemoteId = const Value.absent(),
    this.campRemoteId = const Value.absent(),
    this.role = const Value.absent(),
    this.groupId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberToCampCompanion.insert({
    required String userRemoteId,
    required String campRemoteId,
    required String role,
    this.groupId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userRemoteId = Value(userRemoteId),
       campRemoteId = Value(campRemoteId),
       role = Value(role);
  static Insertable<MemberToCampData> custom({
    Expression<String>? userRemoteId,
    Expression<String>? campRemoteId,
    Expression<String>? role,
    Expression<String>? groupId,
    Expression<String>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userRemoteId != null) 'user_remote_id': userRemoteId,
      if (campRemoteId != null) 'camp_remote_id': campRemoteId,
      if (role != null) 'role': role,
      if (groupId != null) 'group_id': groupId,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberToCampCompanion copyWith({
    Value<String>? userRemoteId,
    Value<String>? campRemoteId,
    Value<String>? role,
    Value<String?>? groupId,
    Value<String?>? roomId,
    Value<int>? rowid,
  }) {
    return MemberToCampCompanion(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      campRemoteId: campRemoteId ?? this.campRemoteId,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userRemoteId.present) {
      map['user_remote_id'] = Variable<String>(userRemoteId.value);
    }
    if (campRemoteId.present) {
      map['camp_remote_id'] = Variable<String>(campRemoteId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberToCampCompanion(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('campRemoteId: $campRemoteId, ')
          ..write('role: $role, ')
          ..write('groupId: $groupId, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberToChatTable extends MemberToChat
    with TableInfo<$MemberToChatTable, MemberToChatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberToChatTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userRemoteIdMeta = const VerificationMeta(
    'userRemoteId',
  );
  @override
  late final GeneratedColumn<String> userRemoteId = GeneratedColumn<String>(
    'user_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatRemoteIdMeta = const VerificationMeta(
    'chatRemoteId',
  );
  @override
  late final GeneratedColumn<String> chatRemoteId = GeneratedColumn<String>(
    'chat_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastViewedMeta = const VerificationMeta(
    'lastViewed',
  );
  @override
  late final GeneratedColumn<DateTime> lastViewed = GeneratedColumn<DateTime>(
    'last_viewed',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userRemoteId,
    chatRemoteId,
    lastViewed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_to_chat';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberToChatData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_remote_id')) {
      context.handle(
        _userRemoteIdMeta,
        userRemoteId.isAcceptableOrUnknown(
          data['user_remote_id']!,
          _userRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userRemoteIdMeta);
    }
    if (data.containsKey('chat_remote_id')) {
      context.handle(
        _chatRemoteIdMeta,
        chatRemoteId.isAcceptableOrUnknown(
          data['chat_remote_id']!,
          _chatRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatRemoteIdMeta);
    }
    if (data.containsKey('last_viewed')) {
      context.handle(
        _lastViewedMeta,
        lastViewed.isAcceptableOrUnknown(data['last_viewed']!, _lastViewedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userRemoteId, chatRemoteId};
  @override
  MemberToChatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberToChatData(
      userRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remote_id'],
      )!,
      chatRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_remote_id'],
      )!,
      lastViewed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_viewed'],
      ),
    );
  }

  @override
  $MemberToChatTable createAlias(String alias) {
    return $MemberToChatTable(attachedDatabase, alias);
  }
}

class MemberToChatData extends DataClass
    implements Insertable<MemberToChatData> {
  final String userRemoteId;
  final String chatRemoteId;
  final DateTime? lastViewed;
  const MemberToChatData({
    required this.userRemoteId,
    required this.chatRemoteId,
    this.lastViewed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_remote_id'] = Variable<String>(userRemoteId);
    map['chat_remote_id'] = Variable<String>(chatRemoteId);
    if (!nullToAbsent || lastViewed != null) {
      map['last_viewed'] = Variable<DateTime>(lastViewed);
    }
    return map;
  }

  MemberToChatCompanion toCompanion(bool nullToAbsent) {
    return MemberToChatCompanion(
      userRemoteId: Value(userRemoteId),
      chatRemoteId: Value(chatRemoteId),
      lastViewed: lastViewed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewed),
    );
  }

  factory MemberToChatData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberToChatData(
      userRemoteId: serializer.fromJson<String>(json['userRemoteId']),
      chatRemoteId: serializer.fromJson<String>(json['chatRemoteId']),
      lastViewed: serializer.fromJson<DateTime?>(json['lastViewed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userRemoteId': serializer.toJson<String>(userRemoteId),
      'chatRemoteId': serializer.toJson<String>(chatRemoteId),
      'lastViewed': serializer.toJson<DateTime?>(lastViewed),
    };
  }

  MemberToChatData copyWith({
    String? userRemoteId,
    String? chatRemoteId,
    Value<DateTime?> lastViewed = const Value.absent(),
  }) => MemberToChatData(
    userRemoteId: userRemoteId ?? this.userRemoteId,
    chatRemoteId: chatRemoteId ?? this.chatRemoteId,
    lastViewed: lastViewed.present ? lastViewed.value : this.lastViewed,
  );
  MemberToChatData copyWithCompanion(MemberToChatCompanion data) {
    return MemberToChatData(
      userRemoteId: data.userRemoteId.present
          ? data.userRemoteId.value
          : this.userRemoteId,
      chatRemoteId: data.chatRemoteId.present
          ? data.chatRemoteId.value
          : this.chatRemoteId,
      lastViewed: data.lastViewed.present
          ? data.lastViewed.value
          : this.lastViewed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberToChatData(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('lastViewed: $lastViewed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userRemoteId, chatRemoteId, lastViewed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberToChatData &&
          other.userRemoteId == this.userRemoteId &&
          other.chatRemoteId == this.chatRemoteId &&
          other.lastViewed == this.lastViewed);
}

class MemberToChatCompanion extends UpdateCompanion<MemberToChatData> {
  final Value<String> userRemoteId;
  final Value<String> chatRemoteId;
  final Value<DateTime?> lastViewed;
  final Value<int> rowid;
  const MemberToChatCompanion({
    this.userRemoteId = const Value.absent(),
    this.chatRemoteId = const Value.absent(),
    this.lastViewed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberToChatCompanion.insert({
    required String userRemoteId,
    required String chatRemoteId,
    this.lastViewed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userRemoteId = Value(userRemoteId),
       chatRemoteId = Value(chatRemoteId);
  static Insertable<MemberToChatData> custom({
    Expression<String>? userRemoteId,
    Expression<String>? chatRemoteId,
    Expression<DateTime>? lastViewed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userRemoteId != null) 'user_remote_id': userRemoteId,
      if (chatRemoteId != null) 'chat_remote_id': chatRemoteId,
      if (lastViewed != null) 'last_viewed': lastViewed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberToChatCompanion copyWith({
    Value<String>? userRemoteId,
    Value<String>? chatRemoteId,
    Value<DateTime?>? lastViewed,
    Value<int>? rowid,
  }) {
    return MemberToChatCompanion(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      chatRemoteId: chatRemoteId ?? this.chatRemoteId,
      lastViewed: lastViewed ?? this.lastViewed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userRemoteId.present) {
      map['user_remote_id'] = Variable<String>(userRemoteId.value);
    }
    if (chatRemoteId.present) {
      map['chat_remote_id'] = Variable<String>(chatRemoteId.value);
    }
    if (lastViewed.present) {
      map['last_viewed'] = Variable<DateTime>(lastViewed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberToChatCompanion(')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('lastViewed: $lastViewed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatRemoteIdMeta = const VerificationMeta(
    'chatRemoteId',
  );
  @override
  late final GeneratedColumn<String> chatRemoteId = GeneratedColumn<String>(
    'chat_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userRemoteIdMeta = const VerificationMeta(
    'userRemoteId',
  );
  @override
  late final GeneratedColumn<String> userRemoteId = GeneratedColumn<String>(
    'user_remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyJsonMeta = const VerificationMeta(
    'bodyJson',
  );
  @override
  late final GeneratedColumn<String> bodyJson = GeneratedColumn<String>(
    'body_json',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageStatus, int>
  messageStatus = GeneratedColumn<int>(
    'message_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(MessageStatus.sending.index),
  ).withConverter<MessageStatus>($MessagesTable.$convertermessageStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    chatRemoteId,
    userRemoteId,
    bodyJson,
    createdAt,
    isSynced,
    messageStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('chat_remote_id')) {
      context.handle(
        _chatRemoteIdMeta,
        chatRemoteId.isAcceptableOrUnknown(
          data['chat_remote_id']!,
          _chatRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatRemoteIdMeta);
    }
    if (data.containsKey('user_remote_id')) {
      context.handle(
        _userRemoteIdMeta,
        userRemoteId.isAcceptableOrUnknown(
          data['user_remote_id']!,
          _userRemoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userRemoteIdMeta);
    }
    if (data.containsKey('body_json')) {
      context.handle(
        _bodyJsonMeta,
        bodyJson.isAcceptableOrUnknown(data['body_json']!, _bodyJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      chatRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_remote_id'],
      )!,
      userRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remote_id'],
      )!,
      bodyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      messageStatus: $MessagesTable.$convertermessageStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}message_status'],
        )!,
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageStatus, int, int> $convertermessageStatus =
      const EnumIndexConverter<MessageStatus>(MessageStatus.values);
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String? remoteId;
  final String chatRemoteId;
  final String userRemoteId;
  final String bodyJson;
  final DateTime? createdAt;
  final bool isSynced;
  final MessageStatus messageStatus;
  const Message({
    required this.id,
    this.remoteId,
    required this.chatRemoteId,
    required this.userRemoteId,
    required this.bodyJson,
    this.createdAt,
    required this.isSynced,
    required this.messageStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['chat_remote_id'] = Variable<String>(chatRemoteId);
    map['user_remote_id'] = Variable<String>(userRemoteId);
    map['body_json'] = Variable<String>(bodyJson);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    {
      map['message_status'] = Variable<int>(
        $MessagesTable.$convertermessageStatus.toSql(messageStatus),
      );
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      chatRemoteId: Value(chatRemoteId),
      userRemoteId: Value(userRemoteId),
      bodyJson: Value(bodyJson),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      messageStatus: Value(messageStatus),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      chatRemoteId: serializer.fromJson<String>(json['chatRemoteId']),
      userRemoteId: serializer.fromJson<String>(json['userRemoteId']),
      bodyJson: serializer.fromJson<String>(json['bodyJson']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      messageStatus: $MessagesTable.$convertermessageStatus.fromJson(
        serializer.fromJson<int>(json['messageStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'chatRemoteId': serializer.toJson<String>(chatRemoteId),
      'userRemoteId': serializer.toJson<String>(userRemoteId),
      'bodyJson': serializer.toJson<String>(bodyJson),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'messageStatus': serializer.toJson<int>(
        $MessagesTable.$convertermessageStatus.toJson(messageStatus),
      ),
    };
  }

  Message copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? chatRemoteId,
    String? userRemoteId,
    String? bodyJson,
    Value<DateTime?> createdAt = const Value.absent(),
    bool? isSynced,
    MessageStatus? messageStatus,
  }) => Message(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    chatRemoteId: chatRemoteId ?? this.chatRemoteId,
    userRemoteId: userRemoteId ?? this.userRemoteId,
    bodyJson: bodyJson ?? this.bodyJson,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    isSynced: isSynced ?? this.isSynced,
    messageStatus: messageStatus ?? this.messageStatus,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      chatRemoteId: data.chatRemoteId.present
          ? data.chatRemoteId.value
          : this.chatRemoteId,
      userRemoteId: data.userRemoteId.present
          ? data.userRemoteId.value
          : this.userRemoteId,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      messageStatus: data.messageStatus.present
          ? data.messageStatus.value
          : this.messageStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('messageStatus: $messageStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    chatRemoteId,
    userRemoteId,
    bodyJson,
    createdAt,
    isSynced,
    messageStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.chatRemoteId == this.chatRemoteId &&
          other.userRemoteId == this.userRemoteId &&
          other.bodyJson == this.bodyJson &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.messageStatus == this.messageStatus);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> chatRemoteId;
  final Value<String> userRemoteId;
  final Value<String> bodyJson;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<MessageStatus> messageStatus;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.chatRemoteId = const Value.absent(),
    this.userRemoteId = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.messageStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String chatRemoteId,
    required String userRemoteId,
    required String bodyJson,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.messageStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatRemoteId = Value(chatRemoteId),
       userRemoteId = Value(userRemoteId),
       bodyJson = Value(bodyJson);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? chatRemoteId,
    Expression<String>? userRemoteId,
    Expression<String>? bodyJson,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<int>? messageStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (chatRemoteId != null) 'chat_remote_id': chatRemoteId,
      if (userRemoteId != null) 'user_remote_id': userRemoteId,
      if (bodyJson != null) 'body_json': bodyJson,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (messageStatus != null) 'message_status': messageStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? chatRemoteId,
    Value<String>? userRemoteId,
    Value<String>? bodyJson,
    Value<DateTime?>? createdAt,
    Value<bool>? isSynced,
    Value<MessageStatus>? messageStatus,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      chatRemoteId: chatRemoteId ?? this.chatRemoteId,
      userRemoteId: userRemoteId ?? this.userRemoteId,
      bodyJson: bodyJson ?? this.bodyJson,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      messageStatus: messageStatus ?? this.messageStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (chatRemoteId.present) {
      map['chat_remote_id'] = Variable<String>(chatRemoteId.value);
    }
    if (userRemoteId.present) {
      map['user_remote_id'] = Variable<String>(userRemoteId.value);
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(bodyJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (messageStatus.present) {
      map['message_status'] = Variable<int>(
        $MessagesTable.$convertermessageStatus.toSql(messageStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('chatRemoteId: $chatRemoteId, ')
          ..write('userRemoteId: $userRemoteId, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('messageStatus: $messageStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $UserPaymentsTable userPayments = $UserPaymentsTable(this);
  late final $CampsTable camps = $CampsTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MemberToCampTable memberToCamp = $MemberToCampTable(this);
  late final $MemberToChatTable memberToChat = $MemberToChatTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final CampDao campDao = CampDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    locations,
    payments,
    userPayments,
    camps,
    chats,
    memberToCamp,
    memberToChat,
    messages,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String remoteId,
      required String name,
      required String email,
      Value<String?> profilePicturePath,
      Value<String?> phoneNumber,
      Value<String?> emergencyContact,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> remoteId,
      Value<String> name,
      Value<String> email,
      Value<String?> profilePicturePath,
      Value<String?> phoneNumber,
      Value<String?> emergencyContact,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePicturePath => $composableBuilder(
    column: $table.profilePicturePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePicturePath => $composableBuilder(
    column: $table.profilePicturePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get profilePicturePath => $composableBuilder(
    column: $table.profilePicturePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> profilePicturePath = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                remoteId: remoteId,
                name: name,
                email: email,
                profilePicturePath: profilePicturePath,
                phoneNumber: phoneNumber,
                emergencyContact: emergencyContact,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String name,
                required String email,
                Value<String?> profilePicturePath = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                remoteId: remoteId,
                name: name,
                email: email,
                profilePicturePath: profilePicturePath,
                phoneNumber: phoneNumber,
                emergencyContact: emergencyContact,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String userRemoteId,
      required String campRemoteId,
      required double longitude,
      required double latitude,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> userRemoteId,
      Value<String> campRemoteId,
      Value<double> longitude,
      Value<double> latitude,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
          Location,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userRemoteId = const Value.absent(),
                Value<String> campRemoteId = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                userRemoteId: userRemoteId,
                campRemoteId: campRemoteId,
                longitude: longitude,
                latitude: latitude,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userRemoteId,
                required String campRemoteId,
                required double longitude,
                required double latitude,
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                userRemoteId: userRemoteId,
                campRemoteId: campRemoteId,
                longitude: longitude,
                latitude: latitude,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
      Location,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String remoteId,
      required String campRemoteId,
      required String name,
      Value<DateTime?> dueDate,
      required int amount,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> remoteId,
      Value<String> campRemoteId,
      Value<String> name,
      Value<DateTime?> dueDate,
      Value<int> amount,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> campRemoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                remoteId: remoteId,
                campRemoteId: campRemoteId,
                name: name,
                dueDate: dueDate,
                amount: amount,
                currency: currency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String campRemoteId,
                required String name,
                Value<DateTime?> dueDate = const Value.absent(),
                required int amount,
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                remoteId: remoteId,
                campRemoteId: campRemoteId,
                name: name,
                dueDate: dueDate,
                amount: amount,
                currency: currency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$UserPaymentsTableCreateCompanionBuilder =
    UserPaymentsCompanion Function({
      required String userRemoteId,
      required String paymentRemoteId,
      Value<bool> isPaid,
      Value<int> rowid,
    });
typedef $$UserPaymentsTableUpdateCompanionBuilder =
    UserPaymentsCompanion Function({
      Value<String> userRemoteId,
      Value<String> paymentRemoteId,
      Value<bool> isPaid,
      Value<int> rowid,
    });

class $$UserPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPaymentsTable> {
  $$UserPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentRemoteId => $composableBuilder(
    column: $table.paymentRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPaymentsTable> {
  $$UserPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentRemoteId => $composableBuilder(
    column: $table.paymentRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPaymentsTable> {
  $$UserPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentRemoteId => $composableBuilder(
    column: $table.paymentRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);
}

class $$UserPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPaymentsTable,
          UserPayment,
          $$UserPaymentsTableFilterComposer,
          $$UserPaymentsTableOrderingComposer,
          $$UserPaymentsTableAnnotationComposer,
          $$UserPaymentsTableCreateCompanionBuilder,
          $$UserPaymentsTableUpdateCompanionBuilder,
          (
            UserPayment,
            BaseReferences<_$AppDatabase, $UserPaymentsTable, UserPayment>,
          ),
          UserPayment,
          PrefetchHooks Function()
        > {
  $$UserPaymentsTableTableManager(_$AppDatabase db, $UserPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userRemoteId = const Value.absent(),
                Value<String> paymentRemoteId = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPaymentsCompanion(
                userRemoteId: userRemoteId,
                paymentRemoteId: paymentRemoteId,
                isPaid: isPaid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userRemoteId,
                required String paymentRemoteId,
                Value<bool> isPaid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPaymentsCompanion.insert(
                userRemoteId: userRemoteId,
                paymentRemoteId: paymentRemoteId,
                isPaid: isPaid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPaymentsTable,
      UserPayment,
      $$UserPaymentsTableFilterComposer,
      $$UserPaymentsTableOrderingComposer,
      $$UserPaymentsTableAnnotationComposer,
      $$UserPaymentsTableCreateCompanionBuilder,
      $$UserPaymentsTableUpdateCompanionBuilder,
      (
        UserPayment,
        BaseReferences<_$AppDatabase, $UserPaymentsTable, UserPayment>,
      ),
      UserPayment,
      PrefetchHooks Function()
    >;
typedef $$CampsTableCreateCompanionBuilder =
    CampsCompanion Function({
      required String remoteId,
      required String name,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> minGroupSize,
      Value<String?> chatRemoteId,
      required String staffChatRemoteId,
      Value<String?> joinCode,
      required String myRole,
      Value<int> rowid,
    });
typedef $$CampsTableUpdateCompanionBuilder =
    CampsCompanion Function({
      Value<String> remoteId,
      Value<String> name,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> minGroupSize,
      Value<String?> chatRemoteId,
      Value<String> staffChatRemoteId,
      Value<String?> joinCode,
      Value<String> myRole,
      Value<int> rowid,
    });

class $$CampsTableFilterComposer extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minGroupSize => $composableBuilder(
    column: $table.minGroupSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffChatRemoteId => $composableBuilder(
    column: $table.staffChatRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinCode => $composableBuilder(
    column: $table.joinCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myRole => $composableBuilder(
    column: $table.myRole,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minGroupSize => $composableBuilder(
    column: $table.minGroupSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffChatRemoteId => $composableBuilder(
    column: $table.staffChatRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinCode => $composableBuilder(
    column: $table.joinCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myRole => $composableBuilder(
    column: $table.myRole,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get minGroupSize => $composableBuilder(
    column: $table.minGroupSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get staffChatRemoteId => $composableBuilder(
    column: $table.staffChatRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get joinCode =>
      $composableBuilder(column: $table.joinCode, builder: (column) => column);

  GeneratedColumn<String> get myRole =>
      $composableBuilder(column: $table.myRole, builder: (column) => column);
}

class $$CampsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampsTable,
          Camp,
          $$CampsTableFilterComposer,
          $$CampsTableOrderingComposer,
          $$CampsTableAnnotationComposer,
          $$CampsTableCreateCompanionBuilder,
          $$CampsTableUpdateCompanionBuilder,
          (Camp, BaseReferences<_$AppDatabase, $CampsTable, Camp>),
          Camp,
          PrefetchHooks Function()
        > {
  $$CampsTableTableManager(_$AppDatabase db, $CampsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> minGroupSize = const Value.absent(),
                Value<String?> chatRemoteId = const Value.absent(),
                Value<String> staffChatRemoteId = const Value.absent(),
                Value<String?> joinCode = const Value.absent(),
                Value<String> myRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion(
                remoteId: remoteId,
                name: name,
                startDate: startDate,
                endDate: endDate,
                minGroupSize: minGroupSize,
                chatRemoteId: chatRemoteId,
                staffChatRemoteId: staffChatRemoteId,
                joinCode: joinCode,
                myRole: myRole,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String name,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> minGroupSize = const Value.absent(),
                Value<String?> chatRemoteId = const Value.absent(),
                required String staffChatRemoteId,
                Value<String?> joinCode = const Value.absent(),
                required String myRole,
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion.insert(
                remoteId: remoteId,
                name: name,
                startDate: startDate,
                endDate: endDate,
                minGroupSize: minGroupSize,
                chatRemoteId: chatRemoteId,
                staffChatRemoteId: staffChatRemoteId,
                joinCode: joinCode,
                myRole: myRole,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampsTable,
      Camp,
      $$CampsTableFilterComposer,
      $$CampsTableOrderingComposer,
      $$CampsTableAnnotationComposer,
      $$CampsTableCreateCompanionBuilder,
      $$CampsTableUpdateCompanionBuilder,
      (Camp, BaseReferences<_$AppDatabase, $CampsTable, Camp>),
      Camp,
      PrefetchHooks Function()
    >;
typedef $$ChatsTableCreateCompanionBuilder =
    ChatsCompanion Function({
      required String remoteId,
      required String name,
      Value<String?> color,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastMessageAt,
      required String campRemoteId,
      Value<String?> typeId,
      required String type,
      Value<String?> joinCode,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$ChatsTableUpdateCompanionBuilder =
    ChatsCompanion Function({
      Value<String> remoteId,
      Value<String> name,
      Value<String?> color,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastMessageAt,
      Value<String> campRemoteId,
      Value<String?> typeId,
      Value<String> type,
      Value<String?> joinCode,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinCode => $composableBuilder(
    column: $table.joinCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinCode => $composableBuilder(
    column: $table.joinCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeId =>
      $composableBuilder(column: $table.typeId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get joinCode =>
      $composableBuilder(column: $table.joinCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatsTable,
          Chat,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
          Chat,
          PrefetchHooks Function()
        > {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<String> campRemoteId = const Value.absent(),
                Value<String?> typeId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> joinCode = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                remoteId: remoteId,
                name: name,
                color: color,
                lastSeenAt: lastSeenAt,
                lastMessageAt: lastMessageAt,
                campRemoteId: campRemoteId,
                typeId: typeId,
                type: type,
                joinCode: joinCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String name,
                Value<String?> color = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                required String campRemoteId,
                Value<String?> typeId = const Value.absent(),
                required String type,
                Value<String?> joinCode = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                remoteId: remoteId,
                name: name,
                color: color,
                lastSeenAt: lastSeenAt,
                lastMessageAt: lastMessageAt,
                campRemoteId: campRemoteId,
                typeId: typeId,
                type: type,
                joinCode: joinCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatsTable,
      Chat,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
      Chat,
      PrefetchHooks Function()
    >;
typedef $$MemberToCampTableCreateCompanionBuilder =
    MemberToCampCompanion Function({
      required String userRemoteId,
      required String campRemoteId,
      required String role,
      Value<String?> groupId,
      Value<String?> roomId,
      Value<int> rowid,
    });
typedef $$MemberToCampTableUpdateCompanionBuilder =
    MemberToCampCompanion Function({
      Value<String> userRemoteId,
      Value<String> campRemoteId,
      Value<String> role,
      Value<String?> groupId,
      Value<String?> roomId,
      Value<int> rowid,
    });

class $$MemberToCampTableFilterComposer
    extends Composer<_$AppDatabase, $MemberToCampTable> {
  $$MemberToCampTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberToCampTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberToCampTable> {
  $$MemberToCampTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberToCampTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberToCampTable> {
  $$MemberToCampTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campRemoteId => $composableBuilder(
    column: $table.campRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);
}

class $$MemberToCampTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberToCampTable,
          MemberToCampData,
          $$MemberToCampTableFilterComposer,
          $$MemberToCampTableOrderingComposer,
          $$MemberToCampTableAnnotationComposer,
          $$MemberToCampTableCreateCompanionBuilder,
          $$MemberToCampTableUpdateCompanionBuilder,
          (
            MemberToCampData,
            BaseReferences<_$AppDatabase, $MemberToCampTable, MemberToCampData>,
          ),
          MemberToCampData,
          PrefetchHooks Function()
        > {
  $$MemberToCampTableTableManager(_$AppDatabase db, $MemberToCampTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberToCampTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberToCampTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberToCampTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userRemoteId = const Value.absent(),
                Value<String> campRemoteId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberToCampCompanion(
                userRemoteId: userRemoteId,
                campRemoteId: campRemoteId,
                role: role,
                groupId: groupId,
                roomId: roomId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userRemoteId,
                required String campRemoteId,
                required String role,
                Value<String?> groupId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberToCampCompanion.insert(
                userRemoteId: userRemoteId,
                campRemoteId: campRemoteId,
                role: role,
                groupId: groupId,
                roomId: roomId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemberToCampTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberToCampTable,
      MemberToCampData,
      $$MemberToCampTableFilterComposer,
      $$MemberToCampTableOrderingComposer,
      $$MemberToCampTableAnnotationComposer,
      $$MemberToCampTableCreateCompanionBuilder,
      $$MemberToCampTableUpdateCompanionBuilder,
      (
        MemberToCampData,
        BaseReferences<_$AppDatabase, $MemberToCampTable, MemberToCampData>,
      ),
      MemberToCampData,
      PrefetchHooks Function()
    >;
typedef $$MemberToChatTableCreateCompanionBuilder =
    MemberToChatCompanion Function({
      required String userRemoteId,
      required String chatRemoteId,
      Value<DateTime?> lastViewed,
      Value<int> rowid,
    });
typedef $$MemberToChatTableUpdateCompanionBuilder =
    MemberToChatCompanion Function({
      Value<String> userRemoteId,
      Value<String> chatRemoteId,
      Value<DateTime?> lastViewed,
      Value<int> rowid,
    });

class $$MemberToChatTableFilterComposer
    extends Composer<_$AppDatabase, $MemberToChatTable> {
  $$MemberToChatTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastViewed => $composableBuilder(
    column: $table.lastViewed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberToChatTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberToChatTable> {
  $$MemberToChatTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastViewed => $composableBuilder(
    column: $table.lastViewed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberToChatTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberToChatTable> {
  $$MemberToChatTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastViewed => $composableBuilder(
    column: $table.lastViewed,
    builder: (column) => column,
  );
}

class $$MemberToChatTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberToChatTable,
          MemberToChatData,
          $$MemberToChatTableFilterComposer,
          $$MemberToChatTableOrderingComposer,
          $$MemberToChatTableAnnotationComposer,
          $$MemberToChatTableCreateCompanionBuilder,
          $$MemberToChatTableUpdateCompanionBuilder,
          (
            MemberToChatData,
            BaseReferences<_$AppDatabase, $MemberToChatTable, MemberToChatData>,
          ),
          MemberToChatData,
          PrefetchHooks Function()
        > {
  $$MemberToChatTableTableManager(_$AppDatabase db, $MemberToChatTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberToChatTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberToChatTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberToChatTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userRemoteId = const Value.absent(),
                Value<String> chatRemoteId = const Value.absent(),
                Value<DateTime?> lastViewed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberToChatCompanion(
                userRemoteId: userRemoteId,
                chatRemoteId: chatRemoteId,
                lastViewed: lastViewed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userRemoteId,
                required String chatRemoteId,
                Value<DateTime?> lastViewed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberToChatCompanion.insert(
                userRemoteId: userRemoteId,
                chatRemoteId: chatRemoteId,
                lastViewed: lastViewed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemberToChatTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberToChatTable,
      MemberToChatData,
      $$MemberToChatTableFilterComposer,
      $$MemberToChatTableOrderingComposer,
      $$MemberToChatTableAnnotationComposer,
      $$MemberToChatTableCreateCompanionBuilder,
      $$MemberToChatTableUpdateCompanionBuilder,
      (
        MemberToChatData,
        BaseReferences<_$AppDatabase, $MemberToChatTable, MemberToChatData>,
      ),
      MemberToChatData,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      required String chatRemoteId,
      required String userRemoteId,
      required String bodyJson,
      Value<DateTime?> createdAt,
      Value<bool> isSynced,
      Value<MessageStatus> messageStatus,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> chatRemoteId,
      Value<String> userRemoteId,
      Value<String> bodyJson,
      Value<DateTime?> createdAt,
      Value<bool> isSynced,
      Value<MessageStatus> messageStatus,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyJson => $composableBuilder(
    column: $table.bodyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageStatus, MessageStatus, int>
  get messageStatus => $composableBuilder(
    column: $table.messageStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyJson => $composableBuilder(
    column: $table.bodyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageStatus => $composableBuilder(
    column: $table.messageStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get chatRemoteId => $composableBuilder(
    column: $table.chatRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userRemoteId => $composableBuilder(
    column: $table.userRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageStatus, int> get messageStatus =>
      $composableBuilder(
        column: $table.messageStatus,
        builder: (column) => column,
      );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> chatRemoteId = const Value.absent(),
                Value<String> userRemoteId = const Value.absent(),
                Value<String> bodyJson = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<MessageStatus> messageStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                remoteId: remoteId,
                chatRemoteId: chatRemoteId,
                userRemoteId: userRemoteId,
                bodyJson: bodyJson,
                createdAt: createdAt,
                isSynced: isSynced,
                messageStatus: messageStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String chatRemoteId,
                required String userRemoteId,
                required String bodyJson,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<MessageStatus> messageStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                remoteId: remoteId,
                chatRemoteId: chatRemoteId,
                userRemoteId: userRemoteId,
                bodyJson: bodyJson,
                createdAt: createdAt,
                isSynced: isSynced,
                messageStatus: messageStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$UserPaymentsTableTableManager get userPayments =>
      $$UserPaymentsTableTableManager(_db, _db.userPayments);
  $$CampsTableTableManager get camps =>
      $$CampsTableTableManager(_db, _db.camps);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MemberToCampTableTableManager get memberToCamp =>
      $$MemberToCampTableTableManager(_db, _db.memberToCamp);
  $$MemberToChatTableTableManager get memberToChat =>
      $$MemberToChatTableTableManager(_db, _db.memberToChat);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
