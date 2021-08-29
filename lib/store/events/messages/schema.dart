import 'package:moor/moor.dart';
import 'package:syphon/store/events/messages/model.dart';

///
/// Messages Model (Table)
///
/// Meant to store messages in _cold storage_
/// using Moor and SQLite + SQLCipher
///
@UseRowClass(Message)
class Messages extends Table {
  // TextColumn get id => text().clientDefault(() => _uuid.v4())();

  // event base data
  TextColumn get id => text().customConstraint('UNIQUE')();
  TextColumn get roomId => text().nullable()(); // TODO: index on roomId
  TextColumn get userId => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get sender => text().nullable()();
  TextColumn get stateKey => text().nullable()();

  // Message drafting
  BoolColumn get pending => boolean()();
  BoolColumn get syncing => boolean()();
  BoolColumn get failed => boolean()();

  // Message editing
  BoolColumn get edited => boolean()();
  BoolColumn get replacement => boolean()();

  // Message timestamps
  IntColumn get timestamp => integer()();
  IntColumn get received => integer()();

  // Message Only
  TextColumn get body => text().nullable()();
  TextColumn get msgtype => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get filename => text().nullable()();
  TextColumn get formattedBody => text().nullable()();

  // Encrypted Messages only
  TextColumn get typeDecrypted => text().nullable()(); // inner type of decrypted event
  TextColumn get ciphertext => text().nullable()();
  TextColumn get algorithm => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get senderKey => text().nullable()(); // Curve25519 device key which initiated the session
  TextColumn get deviceId => text().nullable()();
  TextColumn get relatedEventId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}