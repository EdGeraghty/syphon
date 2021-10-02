import 'dart:convert';

import 'package:sembast/sembast.dart';
import 'package:syphon/global/print.dart';
import 'package:syphon/storage/constants.dart';
import 'package:syphon/storage/moor/database.dart';
import 'package:syphon/store/rooms/room/model.dart';

///
/// Room Queries
///
extension RoomQueries on StorageDatabase {
  Future<void> insertRooms(List<Room> rooms) {
    return batch(
      (batch) => batch.insertAllOnConflictUpdate(this.rooms, rooms),
    );
  }

  Future<Room> selectRoom(String roomId) {
    return (select(rooms)
          ..where((tbl) => tbl.id.equals(roomId))
          ..limit(1))
        .getSingle();
  }

  Future<List<Room>> selectRooms(List<String> ids, {int offset = 0, int limit = 25}) {
    return (select(rooms)
          ..where((tbl) => tbl.id.isIn(ids))
          ..limit(25, offset: offset))
        .get();
  }

  // Future<List<Room>> searchRooms(String text, {int offset = 0, int limit = 25}) {
  //   return (select(rooms)
  //         ..where((tbl) => tbl.topic.like('%$text%'))
  //         ..limit(25, offset: offset))
  //       .get();
  // }
}

Future saveRooms(
  Map<String, Room> rooms, {
  Database? cache,
  Database? storage,
}) async {
  final store = StoreRef<String?, String>(StorageKeys.ROOMS);

  return storage!.transaction((txn) async {
    for (final Room? room in rooms.values) {
      final record = store.record(room?.id);
      await record.put(txn, jsonEncode(room));
    }
  });
}

Future saveRoom(
  Room room, {
  Database? cache,
  Database? storage,
}) async {
  final store = StoreRef<String?, String>(StorageKeys.ROOMS);

  return storage!.transaction((txn) async {
    final record = store.record(room.id);
    await record.put(txn, jsonEncode(room));
  });
}

Future deleteRooms(
  Map<String, Room?> rooms, {
  Database? cache,
  Database? storage,
}) async {
  final store = StoreRef<String?, String>(StorageKeys.ROOMS);

  return storage!.transaction((txn) async {
    for (final Room? room in rooms.values) {
      final record = store.record(room?.id);
      await record.delete(txn);
    }
  });
}

Future<Map<String, Room>> loadRooms({
  Database? cache,
  required Database storage,
  int offset = 0,
  int limit = 10,
}) async {
  final Map<String, Room> rooms = {};

  try {
    final store = StoreRef<String, String>(StorageKeys.ROOMS);
    final count = await store.count(storage);

    final finder = Finder(
      limit: limit,
      offset: offset,
    );

    final roomsPaginated = await store.find(
      storage,
      finder: finder,
    );

    if (roomsPaginated.isEmpty) {
      return rooms;
    }

    for (RecordSnapshot<String, String> record in roomsPaginated) {
      rooms[record.key] = Room.fromJson(json.decode(record.value));
    }

    if (offset < count) {
      rooms.addAll(await (loadRooms(
        offset: offset + limit,
        storage: storage,
      ) as Future<Map<String, Room>>));
    }

    printInfo('[rooms] loaded ${rooms.length.toString()}');
  } catch (error) {
    printError(error.toString(), title: 'loadRooms');
  }
  return rooms;
}
