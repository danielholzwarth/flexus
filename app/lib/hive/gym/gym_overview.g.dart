// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymOverviewAdapter extends TypeAdapter<GymOverview> {
  @override
  final int typeId = 8;

  @override
  GymOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymOverview(
      gym: fields[0] as Gym,
      userAccounts: (fields[1] as List).cast<UserAccount>(),
      totalFriends: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GymOverview obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gym)
      ..writeByte(1)
      ..write(obj.userAccounts)
      ..writeByte(2)
      ..write(obj.totalFriends);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
