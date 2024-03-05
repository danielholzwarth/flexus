// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymAdapter extends TypeAdapter<Gym> {
  @override
  final int typeId = 7;

  @override
  Gym read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gym(
      id: fields[0] as int,
      name: fields[1] as String,
      country: fields[2] as String,
      cityName: fields[3] as String,
      zipCode: fields[4] as String,
      streetName: fields[5] as String,
      houseNumber: fields[6] as String,
      latitude: fields[7] as double,
      longitude: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Gym obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.cityName)
      ..writeByte(4)
      ..write(obj.zipCode)
      ..writeByte(5)
      ..write(obj.streetName)
      ..writeByte(6)
      ..write(obj.houseNumber)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
