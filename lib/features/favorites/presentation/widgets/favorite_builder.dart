import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_item_entity.dart';
import '../cubit/favorites_cubit.dart';

/// يربط أي كرت بالمفضلة من مكان واحد.
/// - يقرأ حالة القلب من [FavoritesCubit] (يعيد البناء فقط عند تغيّر حالة هذا العنصر).
/// - يعطي الكرت دالة [onToggle] للإضافة/الحذف.
///
/// بدل ما كل شاشة تحتفظ بـ Set<String> وتعمل setState.
class FavoriteBuilder extends StatelessWidget {
  final FavoriteType type;
  final String id;

  /// تُستدعى فقط عند الضغط (مثل session.toFavorite).
  final FavoriteEntity Function() toFavorite;

  final Widget Function(
    BuildContext context,
    bool isFavorite,
    VoidCallback onToggle,
  ) builder;

  const FavoriteBuilder({
    super.key,
    required this.type,
    required this.id,
    required this.toFavorite,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.isFavorite(type, id),
    );
    return builder(
      context,
      isFavorite,
      () => context.read<FavoritesCubit>().toggle(toFavorite()),
    );
  }
}
