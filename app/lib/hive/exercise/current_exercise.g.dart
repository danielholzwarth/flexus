// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentExerciseAdapter extends TypeAdapter<CurrentExercise> {
  @override
  final int typeId = 21;

  @override
  CurrentExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentExercise(
      exercise: fields[0] as Exercise,
      goal: fields[1] as String,
      measurements: (fields[2] as List).cast<Measurement>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrentExercise obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.goal)
      ..writeByte(2)
      ..write(obj.measurements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
