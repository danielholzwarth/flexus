// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_lift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BestLiftAdapter extends TypeAdapter<BestLift> {
  @override
  final int typeId = 5;

  @override
  BestLift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BestLift(
      id: fields[0] as int,
      userID: fields[1] as int,
      setID: fields[2] as int,
      positionID: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BestLift obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userID)
      ..writeByte(2)
      ..write(obj.setID)
      ..writeByte(3)
      ..write(obj.positionID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BestLiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
