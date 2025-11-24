// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 3;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      preview: fields[3] as String,
      timestamp: fields[4] as DateTime,
      isRead: fields[5] as bool,
      type: fields[6] as String,
      linkedContentId: fields[7] as String?,
      thumbnailUrl: fields[8] as String?,
      data: (fields[9] as Map?)?.cast<String, dynamic>(),
      isSyncedToBackend: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.preview)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.linkedContentId)
      ..writeByte(8)
      ..write(obj.thumbnailUrl)
      ..writeByte(9)
      ..write(obj.data)
      ..writeByte(10)
      ..write(obj.isSyncedToBackend);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
