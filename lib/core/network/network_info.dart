import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract network status checker.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onStatusChange;
}

/// Implementation using internet_connection_checker.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected {
    print('<<<<<<<<<<<[NetworkInfoImpl.isConnected]>>>>>>>>>>>>>');
    return connectionChecker.hasConnection;
  }

  @override
  Stream<bool> get onStatusChange {
    print('<<<<<<<<<<<[NetworkInfoImpl.onStatusChange]>>>>>>>>>>>>>');
    return connectionChecker.onStatusChange.map((status) => status == InternetConnectionStatus.connected);
  }
}
