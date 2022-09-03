import 'dart:developer';

import 'package:flutter/material.dart';

enum ConnectionStatus {
  connecting,
  connected,
  // error
}

class ConnectionStatusState extends ChangeNotifier {
  late ConnectionStatus _connectionStatus;
  ConnectionStatus get connectionStatus => _connectionStatus;

  init() {
    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
  }

  update({required ConnectionStatus status}) {
    _connectionStatus = status;
    log("Connection Status: $connectionStatus");
    notifyListeners();
  }
}
