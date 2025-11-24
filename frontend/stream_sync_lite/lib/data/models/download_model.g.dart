// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadModelAdapter extends TypeAdapter<DownloadModel> {
  @override
  final int typeId = 4;

  @override
  DownloadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadModel(
      id: fields[0] as String,
      videoId: fields[1] as String,
      videoTitle: fields[2] as String,
      videoUrl: fields[3] as String,
      thumbnailUrl: fields[4] as String,
      localPath: fields[5] as String,
      status: fields[6] as String,
      progress: fields[7] as double,
      totalBytes: fields[8] as int,
      downloadedBytes: fields[9] as int,
      createdAt: fields[10] as DateTime,
      completedAt: fields[11] as DateTime?,
      errorMessage: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoId)
      ..writeByte(2)
      ..write(obj.videoTitle)
      ..writeByte(3)
      ..write(obj.videoUrl)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.localPath)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.totalBytes)
      ..writeByte(9)
      ..write(obj.downloadedBytes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.completedAt)
      ..writeByte(12)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
