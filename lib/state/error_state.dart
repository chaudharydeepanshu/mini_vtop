import 'dart:developer';

import 'package:flutter/material.dart';

enum ErrorStatus {
  // For no errors. If no error continue with other things.
  noError,

  // net::ERR_CONNECTION_CLOSED
  connectionClosedError,

  // net::ERR_NAME_NOT_RESOLVED
  internetOrDnsError,

  // net::ERR_CLEARTEXT_NOT_PERMITTED HTTP traffic is not permitted
  httpTrafficError,

  // For no internet error.
  noInternetError,

  // For unknown errors.
  unknownError,

  // For any main VTOP related errors.
  vtopError,

  // If WebView provides null document before action request.
  nullDocBeforeAction,

  // For any VTOP Page related errors. Like unknown responses.
  vtopUnknownResponsesError,

  // For VTOP SSL related errors.
  sslError,
}

class ErrorStatusState extends ChangeNotifier {
  late ErrorStatus _errorStatus;
  ErrorStatus get errorStatus => _errorStatus;

  init() {
    _errorStatus = ErrorStatus.noError;
    notifyListeners();
  }

  update({required ErrorStatus status}) {
    _errorStatus = status;
    log("Error Status: $errorStatus");
    notifyListeners();
  }
}
