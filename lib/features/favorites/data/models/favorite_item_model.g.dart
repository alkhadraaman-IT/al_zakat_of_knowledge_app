// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteItemModelAdapter extends TypeAdapter<FavoriteItemModel> {
  @override
  final typeId = 10;

  @override
  FavoriteItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteItemModel(
      id: fields[0] as String,
      type: fields[1] as String,
      title: fields[2] as String,
      payload: (fields[3] as Map).cast<dynamic, dynamic>(),
      savedAtMs: (fields[4] as num).toInt(),
      userId: fields[5] == null ? '' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.savedAtMs)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
