// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentWorkoutAdapter extends TypeAdapter<CurrentWorkout> {
  @override
  final int typeId = 20;

  @override
  CurrentWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentWorkout(
      gym: fields[0] as Gym?,
      plan: fields[1] as Plan?,
      split: fields[2] as Split?,
      exercises: (fields[3] as List).cast<CurrentExercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrentWorkout obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gym)
      ..writeByte(1)
      ..write(obj.plan)
      ..writeByte(2)
      ..write(obj.split)
      ..writeByte(3)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
