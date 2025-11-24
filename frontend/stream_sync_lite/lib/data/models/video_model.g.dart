// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 1;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      channelName: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      videoUrl: fields[4] as String,
      duration: fields[5] as String,
      publishedDate: fields[6] as DateTime,
      description: fields[7] as String?,
      viewCount: fields[8] as int,
      likeCount: fields[9] as int,
      isFavorite: fields[10] as bool,
      lastPlayedPosition: fields[11] as int,
      isCached: fields[12] as bool,
      cachedVideoPath: fields[13] as String?,
      chapters: (fields[14] as List?)?.cast<VideoChapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.channelName)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.publishedDate)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.viewCount)
      ..writeByte(9)
      ..write(obj.likeCount)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.lastPlayedPosition)
      ..writeByte(12)
      ..write(obj.isCached)
      ..writeByte(13)
      ..write(obj.cachedVideoPath)
      ..writeByte(14)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoChapterAdapter extends TypeAdapter<VideoChapter> {
  @override
  final int typeId = 2;

  @override
  VideoChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoChapter(
      title: fields[0] as String,
      startTime: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VideoChapter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
