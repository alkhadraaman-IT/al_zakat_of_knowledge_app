import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../articles/presentation/bloc/article_cubit.dart';
import '../../../sessions/presentation/session_cubit/session_cubit.dart';
import '../../../study_tools/presentation/cubit/study_tool_cubit.dart';

/// Cubit الرئيسية. الـ State هو رقم التاب المختار:
/// 0 محاضرات، 1 مقالات، 2 أدوات.
///
/// عند إنشائه يطلب التحميل الأولي من الـ Cubits الثلاثة، فما بنحتاج
/// StatefulWidget ولا initState ولا setState بالـ HomeView.
class HomeCubit extends Cubit<int> {
  HomeCubit({
    required SessionCubit sessionCubit,
    required StudyToolCubit studyToolCubit,
    required ArticleCubit articleCubit,
  }) : super(0) {
    sessionCubit.getSessions();
    studyToolCubit.getStudyTools();
    articleCubit.getArticles();
  }

  void selectTab(int index) {
    if (index != state) emit(index);
  }
}
