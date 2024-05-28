// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingWorkoutAdapter extends TypeAdapter<PendingWorkout> {
  @override
  final int typeId = 25;

  @override
  PendingWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingWorkout(
      id: fields[0] as int,
      workoutID: fields[1] as int,
      planID: fields[2] as int?,
      splitID: fields[3] as int?,
      gymID: fields[4] as int?,
      exercisesJSON: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, PendingWorkout obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutID)
      ..writeByte(2)
      ..write(obj.planID)
      ..writeByte(3)
      ..write(obj.splitID)
      ..writeByte(4)
      ..write(obj.gymID)
      ..writeByte(5)
      ..write(obj.exercisesJSON);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
