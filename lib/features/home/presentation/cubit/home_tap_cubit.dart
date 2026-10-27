import 'package:flutter_bloc/flutter_bloc.dart';

/// التاب المختار بالـ Home: 0 محاضرات، 1 مقالات، 2 أدوات.
class HomeTabCubit extends Cubit<int> {
  HomeTabCubit() : super(0);

  void select(int index) {
    if (index != state) emit(index);
  }
}
