import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ErrorStatus {
  // For no errors. If no error continue with other things.
  noError,

  // net::ERR_CONNECTION_CLOSED Unexpectedly closed the connection.
  connectionClosedError,

  // net::ERR_NAME_NOT_RESOLVED This website doesn't exist
  nameNotResolvedError,

  // net::ERR_CONNECTION_RESET The connection was reset.
  connectionResetError,

  // net::ERR_ADDRESS_UNREACHABLE is entered address in not reachable
  addressUnreachableError,

  // net::ERR_CLEARTEXT_NOT_PERMITTED HTTP traffic is not permitted
  httpTrafficError,

  // net::ERR_INTERNET_DISCONNECTED For no internet error.
  noInternetError,

  // For unknown errors.
  unknownError,

  // For any main VTOP related errors.
  vtopError,

  // If WebView provides null document before action request.
  nullDocBeforeAction,

  // If webpage is not available.
  webpageNotAvailable,

  // For any VTOP Page related errors. Like unknown responses.
  vtopUnknownResponsesError,

  // For VTOP SSL related errors.
  sslError,

  // For html parsing related errors.
  docParsingError,
}

class ErrorStatusState extends ChangeNotifier {
  ErrorStatusState(this.ref);

  final Ref ref;

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

  onLoadErrorHandler({
    required Uri? url,
    required int? code,
    required String message,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
        "onLoadError -> url: $url, errorCode:$code, message:$message", null,
        reason: 'a non-fatal error');

    if (message == "net::ERR_CONNECTION_CLOSED") {
      update(status: ErrorStatus.connectionClosedError);
    } else if (message == "net::ERR_NAME_NOT_RESOLVED") {
      update(status: ErrorStatus.nameNotResolvedError);
    } else if (message == "net::ERR_CONNECTION_RESET") {
      update(status: ErrorStatus.connectionResetError);
    } else if (message == "net::ERR_ADDRESS_UNREACHABLE") {
      update(status: ErrorStatus.addressUnreachableError);
    } else if (message == "net::ERR_INTERNET_DISCONNECTED") {
      update(status: ErrorStatus.noInternetError);
    } else {
      update(status: ErrorStatus.unknownError);
    }

    notifyListeners();
  }
}
