// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserListAdapter extends TypeAdapter<UserList> {
  @override
  final int typeId = 11;

  @override
  UserList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserList(
      id: fields[0] as int,
      listID: fields[1] as int,
      memberIDs: (fields[2] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listID)
      ..writeByte(2)
      ..write(obj.memberIDs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
