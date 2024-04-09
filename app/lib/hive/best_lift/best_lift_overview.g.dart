// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_lift_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BestLiftOverviewAdapter extends TypeAdapter<BestLiftOverview> {
  @override
  final int typeId = 6;

  @override
  BestLiftOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BestLiftOverview(
      exerciseName: fields[0] as String,
      measurement: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BestLiftOverview obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.measurement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BestLiftOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
