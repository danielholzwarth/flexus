// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAccountOverviewAdapter extends TypeAdapter<UserAccountOverview> {
  @override
  final int typeId = 4;

  @override
  UserAccountOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccountOverview(
      userAccount: fields[0] as UserAccount,
      gender: fields[1] as String?,
      bestLiftOverview: (fields[2] as List?)?.cast<BestLiftOverview>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserAccountOverview obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userAccount)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.bestLiftOverview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserAccountOverviewAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
