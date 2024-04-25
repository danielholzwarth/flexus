// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutDetailsAdapter extends TypeAdapter<WorkoutDetails> {
  @override
  final int typeId = 17;

  @override
  WorkoutDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutDetails(
      workoutID: fields[0] as int,
      gym: fields[2] as Gym?,
      date: fields[1] as DateTime,
      duration: fields[3] as int,
      split: fields[4] as Split?,
      exercises: (fields[5] as List).cast<Exercise>(),
      sets: (fields[6] as List)
          .map((dynamic e) => (e as List).cast<WorkoutSet>())
          .toList(),
      pbSetIDs: (fields[7] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutDetails obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.workoutID)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.gym)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.split)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.sets)
      ..writeByte(7)
      ..write(obj.pbSetIDs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
