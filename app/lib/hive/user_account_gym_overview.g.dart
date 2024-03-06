// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_gym_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAccountGymOverviewAdapter
    extends TypeAdapter<UserAccountGymOverview> {
  @override
  final int typeId = 9;

  @override
  UserAccountGymOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccountGymOverview(
      id: fields[0] as int,
      username: fields[1] as String,
      name: fields[2] as String,
      profilePicture: fields[3] as Uint8List?,
      workoutStartTime: fields[4] as DateTime,
      averageWorkoutDuration: fields[5] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccountGymOverview obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.profilePicture)
      ..writeByte(4)
      ..write(obj.workoutStartTime)
      ..writeByte(5)
      ..write(obj.averageWorkoutDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccountGymOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
