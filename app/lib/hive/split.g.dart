// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitAdapter extends TypeAdapter<Split> {
  @override
  final int typeId = 15;

  @override
  Split read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Split(
      id: fields[0] as int,
      planID: fields[1] as int,
      name: fields[2] as String,
      orderInPlan: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Split obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planID)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.orderInPlan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
