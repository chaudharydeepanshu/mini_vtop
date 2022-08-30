import 'package:flutter/material.dart';

enum ConnectionStatus { connecting, connected, error }

class ConnectionStatusState extends ChangeNotifier {
  late ConnectionStatus _connectionStatus;
  ConnectionStatus get connectionStatus => _connectionStatus;

  init() {
    _connectionStatus = ConnectionStatus.connecting;
    print("_connectionStatus: $_connectionStatus");
    notifyListeners();
  }

  update({required ConnectionStatus newStatus}) {
    _connectionStatus = newStatus;
    print("_connectionStatus: $_connectionStatus");
    notifyListeners();
  }
}
