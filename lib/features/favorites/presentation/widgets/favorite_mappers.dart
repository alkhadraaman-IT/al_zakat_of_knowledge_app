// presentation/mappers/favorite_mappers.dart
import '../../../articles/data/models/article_model.dart';
import '../../../articles/domain/entities/article_entity.dart';
import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../study_tools/data/models/study_tool_model.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';
import '../../domain/entities/favorite_item_entity.dart';

extension SessionFavorite on SessionEntity {
  FavoriteEntity toFavorite() => FavoriteEntity(
        id: id,
        type: FavoriteType.lecture,
        title: title,
        payload: SessionModel.fromEntity(this).toMap(),
        savedAt: DateTime.now(),
      );
}

extension ArticleFavorite on ArticleEntity {
  FavoriteEntity toFavorite() => FavoriteEntity(
        id: id,
        type: FavoriteType.article,
        title: title,
        payload: ArticleModel.fromEntity(this).toMap(),
        savedAt: DateTime.now(),
      );
}

extension StudyToolFavorite on StudyToolEntity {
  FavoriteEntity toFavorite() => FavoriteEntity(
        id: id,
        type: FavoriteType.tool,
        title: title,
        payload: StudyToolModel.fromEntity(this).toMap(),
        savedAt: DateTime.now(),
      );
}
