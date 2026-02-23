import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ==================== TABLES ====================

class CachedUsers extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get totpEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get preferredLanguage =>
      text().withDefault(const Constant('en'))();
  TextColumn get timezone => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedSpaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // SpaceType enum value
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get inviteCode => text().nullable()();
  IntColumn get maxMembers => integer().withDefault(const Constant(3))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedSpaceMemberships extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(CachedSpaces, #id)();
  TextColumn get userId => text().references(CachedUsers, #id)();
  TextColumn get role => text()(); // MemberRole enum
  TextColumn get accessLevel => text()(); // AccessLevel enum
  TextColumn get status => text()(); // MembershipStatus enum
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedActivities extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // ActivityCategory enum
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get trailerUrl => text().nullable()();
  TextColumn get privacy => text()(); // ActivityPrivacy enum
  TextColumn get status => text()(); // ActivityStatus enum
  TextColumn get mode => text()(); // ActivityMode enum
  TextColumn get metadata => text().nullable()(); // JSON string
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get completedNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedActivityVotes extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text().references(CachedActivities, #id)();
  TextColumn get userId => text()();
  IntColumn get score => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedCalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get title => text()();
  TextColumn get location => text().nullable()();
  TextColumn get eventType => text()(); // EventType enum
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get sourceModule => text().nullable()();
  TextColumn get sourceEntityId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedTasks extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()(); // TaskStatus enum
  TextColumn get priority => text()(); // TaskPriority enum
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get parentTaskId => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedReminders extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get message => text()();
  DateTimeColumn get triggerAt => dateTime()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get linkedModule => text().nullable()();
  TextColumn get linkedEntityId => text().nullable()();
  BoolColumn get isSent => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedGroceryLists extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get name => text()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedGroceryItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(CachedGroceryLists, #id)();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text().nullable()(); // GroceryCategory enum
  TextColumn get note => text().nullable()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  TextColumn get checkedBy => text().nullable()();
  DateTimeColumn get checkedAt => dateTime().nullable()();
  IntColumn get priceCents => integer().nullable()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedNotifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get spaceId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get sourceModule => text().nullable()();
  TextColumn get sourceEntityId => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedConversations extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get type => text()(); // ConversationType enum
  TextColumn get title => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId =>
      text().references(CachedConversations, #id)();
  TextColumn get senderId => text()();
  TextColumn get content =>
      text()(); // For standard tier; encrypted blob for private capsule
  TextColumn get contentType => text()(); // MessageContentType enum
  TextColumn get replyToMessageId => text().nullable()();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedFinanceEntries extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get type => text()(); // income, expense
  TextColumn get category => text().nullable()();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get description => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedCharters extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get content => text()();
  IntColumn get versionNumber => integer().withDefault(const Constant(1))();
  TextColumn get editedBy => text()();
  BoolColumn get isAcknowledged =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedPolls extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get question => text()();
  TextColumn get options => text()(); // JSON array
  TextColumn get votes => text().nullable()(); // JSON map
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedCards extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get type => text()(); // debit, credit, loyalty
  TextColumn get holderName => text()();
  TextColumn get lastFourDigits => text().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get expiryDate => text().nullable()();
  TextColumn get storeName => text().nullable()();
  TextColumn get loyaltyNumber => text().nullable()();
  TextColumn get encryptedData => text().nullable()(); // encrypted details
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedFiles extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get uploadedBy => text()();
  TextColumn get filename => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get mimeType => text()();
  TextColumn get folderId => text().nullable()();
  TextColumn get url => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedMemories extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get createdBy => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get photoUrls => text().nullable()(); // JSON array
  BoolColumn get isMilestone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get memoryDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sync queue for offline operations
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType =>
      text()(); // 'activity', 'task', 'calendar_event', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON string of the entity data
  TextColumn get spaceId => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
}

// App preferences stored locally
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    CachedUsers,
    CachedSpaces,
    CachedSpaceMemberships,
    CachedActivities,
    CachedActivityVotes,
    CachedCalendarEvents,
    CachedTasks,
    CachedReminders,
    CachedGroceryLists,
    CachedGroceryItems,
    CachedNotifications,
    CachedConversations,
    CachedMessages,
    CachedFinanceEntries,
    CachedCharters,
    CachedPolls,
    CachedCards,
    CachedFiles,
    CachedMemories,
    SyncQueue,
    AppPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(cachedFinanceEntries);
        await m.createTable(cachedCharters);
        await m.createTable(cachedPolls);
        await m.createTable(cachedCards);
        await m.createTable(cachedFiles);
        await m.createTable(cachedMemories);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'studio_pair.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
