import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static final ConnectivityUtils _instance = ConnectivityUtils._internal();
  factory ConnectivityUtils() => _instance;
  ConnectivityUtils._internal();

  final _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}
