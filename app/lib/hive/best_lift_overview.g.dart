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
      repetitions: fields[1] as int?,
      weight: fields[2] as double?,
      duration: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BestLiftOverview obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.repetitions)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BestLiftOverviewAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
