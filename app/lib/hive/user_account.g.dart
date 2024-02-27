// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAccountAdapter extends TypeAdapter<UserAccount> {
  @override
  final int typeId = 0;

  @override
  UserAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccount(
      id: fields[0] as int,
      username: fields[1] as String,
      name: fields[2] as String,
      createdAt: fields[3] as DateTime,
      level: fields[4] as int,
      profilePicture: fields[5] as Uint8List?,
      bodyweight: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccount obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.profilePicture)
      ..writeByte(6)
      ..write(obj.bodyweight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
