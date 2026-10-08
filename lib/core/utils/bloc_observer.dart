import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom BLoC observer for debugging state transitions.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    // ignore: avoid_print
    print('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // ignore: avoid_print
    print('BLoC Event: ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('BLoC Change: ${bloc.runtimeType} -> $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    // ignore: avoid_print
    print('BLoC Error: ${bloc.runtimeType} -> $error');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    // ignore: avoid_print
    print('BLoC Closed: ${bloc.runtimeType}');
  }
}
