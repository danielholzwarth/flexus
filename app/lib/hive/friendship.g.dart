// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendshipAdapter extends TypeAdapter<Friendship> {
  @override
  final int typeId = 4;

  @override
  Friendship read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friendship(
      requestorID: fields[0] as int,
      requestedID: fields[1] as int,
      isAccepted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Friendship obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.requestorID)
      ..writeByte(1)
      ..write(obj.requestedID)
      ..writeByte(2)
      ..write(obj.isAccepted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendshipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
