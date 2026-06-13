import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:get/get.dart';

class ConnectionCheck {
  ConnectionCheck._();

  static final instance = ConnectionCheck._();
  RxString connection = ''.obs;
  Future<String> initConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity()
          .checkConnectivity());
      return checkConnectionStatus(connectivityResult);
    } on Exception catch (e) {
      return "None $e";
    }
  }

  String checkConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return AppConstants.networkConnected;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return AppConstants.networkConnected;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return AppConstants.networkConnected;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return AppConstants.networkVpn;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return AppConstants.networkNotConnected;
    }
    return AppConstants.networkNotConnected;
  }
}
