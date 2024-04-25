// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSetAdapter extends TypeAdapter<WorkoutSet> {
  @override
  final int typeId = 19;

  @override
  WorkoutSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSet(
      id: fields[0] as int,
      workoutID: fields[1] as int,
      exerciseID: fields[2] as int,
      orderNumber: fields[3] as int,
      repetitions: fields[4] as int,
      workload: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutID)
      ..writeByte(2)
      ..write(obj.exerciseID)
      ..writeByte(3)
      ..write(obj.orderNumber)
      ..writeByte(4)
      ..write(obj.repetitions)
      ..writeByte(5)
      ..write(obj.workload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
