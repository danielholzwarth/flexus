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
      repetitions: fields[1] as int,
      workload: fields[2] as double,
      isRepetition: fields[3] as bool,
      position: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BestLiftOverview obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.repetitions)
      ..writeByte(2)
      ..write(obj.workload)
      ..writeByte(3)
      ..write(obj.isRepetition)
      ..writeByte(4)
      ..write(obj.position);
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
