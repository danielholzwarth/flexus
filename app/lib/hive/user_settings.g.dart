// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 1;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      id: fields[0] as int,
      userAccountID: fields[1] as int,
      fontSize: fields[2] as double,
      isDarkMode: fields[3] as bool,
      languageID: fields[4] as int,
      isUnlisted: fields[5] as bool,
      isPullFromEveryone: fields[6] as bool,
      pullUserListID: fields[7] as int?,
      isNotifyEveryone: fields[8] as bool,
      notifyUserListID: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userAccountID)
      ..writeByte(2)
      ..write(obj.fontSize)
      ..writeByte(3)
      ..write(obj.isDarkMode)
      ..writeByte(4)
      ..write(obj.languageID)
      ..writeByte(5)
      ..write(obj.isUnlisted)
      ..writeByte(6)
      ..write(obj.isPullFromEveryone)
      ..writeByte(7)
      ..write(obj.pullUserListID)
      ..writeByte(8)
      ..write(obj.isNotifyEveryone)
      ..writeByte(9)
      ..write(obj.notifyUserListID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
