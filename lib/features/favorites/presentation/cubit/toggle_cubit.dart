import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit عام لأي حالة true/false محلية بكرت أو widget
/// (توسيع نص، إظهار/إخفاء...) بدل StatefulWidget + setState.
///
/// الاستخدام:
///   BlocProvider(create: (_) => ToggleCubit(), child: ...)
///   BlocBuilder<ToggleCubit, bool>(builder: (context, on) => ...)
///   context.read<ToggleCubit>().toggle();
class ToggleCubit extends Cubit<bool> {
  ToggleCubit([super.initial = false]);

  void toggle() => emit(!state);
}
