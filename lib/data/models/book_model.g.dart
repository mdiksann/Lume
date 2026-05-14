// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookModelAdapter extends TypeAdapter<BookModel> {
  @override
  final typeId = 0;

  @override
  BookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookModel(
      id: fields[0] as String,
      title: fields[1] as String,
      authors: (fields[2] as List).cast<String>(),
      description: fields[3] as String?,
      genres: fields[4] == null ? const [] : (fields[4] as List).cast<String>(),
      coverUrl: fields[5] as String?,
      publishedDate: fields[6] as String?,
      statusIndex: (fields[7] as num).toInt(),
      dateAdded: fields[8] as DateTime,
      rating: (fields[9] as num?)?.toDouble(),
      pageCount: (fields[10] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, BookModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authors)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.coverUrl)
      ..writeByte(6)
      ..write(obj.publishedDate)
      ..writeByte(7)
      ..write(obj.statusIndex)
      ..writeByte(8)
      ..write(obj.dateAdded)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.pageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
