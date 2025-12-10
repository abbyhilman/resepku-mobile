import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();

  factory ConnectivityHelper() => _instance;

  ConnectivityHelper._internal();

  Future<bool> hasConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      // connectivity_plus 5.0.2 returns ConnectivityResult (single value)
      return result != ConnectivityResult.none;
    } catch (e) {
      // Default to connected if check fails
      return true;
    }
  }
}
