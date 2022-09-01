import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

enum LoginStatus {
  loggedOut,
  processing,
  loggedIn,
  wrongUserId,
  wrongPassword,
  wrongCaptcha,
  maxAttemptsError,
  sessionTimedOut,
  unknownResponse
}

enum ForgotUserIDSearchStatus {
  notSearching,
  searching,
  notFound,
  found,
  unknownResponse,
  sessionTimedOut,
  otpTriggerWait
}

enum ForgotUserIDValidateStatus {
  notProcessing,
  processing,
  invalidOTP,
  successful,
  unknownResponse,
  sessionTimedOut
}

class UserLoginState extends ChangeNotifier {
  late String _solvedCaptcha = "Test";
  String get solvedCaptcha => _solvedCaptcha;

  late String _userID = "";
  String get userID => _userID;

  late String _password = "";
  String get password => _password;

  Uint8List? _captchaImage;
  Uint8List? get captchaImage => _captchaImage;

  late LoginStatus _loginStatus = LoginStatus.loggedOut;
  LoginStatus get loginStatus => _loginStatus;

  late Duration _otpTriggerWait = Duration.zero;
  Duration get otpTriggerWait => _otpTriggerWait;

  late ForgotUserIDSearchStatus _forgotUserIDSearchStatus =
      ForgotUserIDSearchStatus.notSearching;
  ForgotUserIDSearchStatus get forgotUserIDSearchStatus =>
      _forgotUserIDSearchStatus;

  late ForgotUserIDValidateStatus _forgotUserIDValidateStatus =
      ForgotUserIDValidateStatus.notProcessing;
  ForgotUserIDValidateStatus get forgotUserIDValidateStatus =>
      _forgotUserIDValidateStatus;

  late String _erpIDOrRegNo = "";
  String get erpIDOrRegNo => _erpIDOrRegNo;

  late String _emailOTP = "";
  String get emailOTP => _emailOTP;

  void setCaptcha({required String captcha}) {
    _solvedCaptcha = captcha;
    notifyListeners();

    print(solvedCaptcha);

    print("setCaptcha called");
  }

  void setUserID({required String userID}) {
    _userID = userID;
    notifyListeners();
  }

  void setPassword({required String password}) {
    _password = password;
    notifyListeners();
  }

  void updateCaptchaImage({required Uint8List? bytes}) {
    _captchaImage = bytes;
    notifyListeners();
  }

  void updateLoginStatus({required LoginStatus loginStatus}) {
    _loginStatus = loginStatus;

    notifyListeners();
  }

  void setEmailOTP({required String emailOTP}) {
    _emailOTP = emailOTP;
    notifyListeners();
  }

  void setErpIDOrRegNo({required String erpIDOrRegNo}) {
    _erpIDOrRegNo = erpIDOrRegNo;
    notifyListeners();
  }

  void updateForgotUserIDSearchStatus(
      {required ForgotUserIDSearchStatus status}) {
    _forgotUserIDSearchStatus = status;

    notifyListeners();
  }

  void updateForgotUserIDValidateStatus(
      {required ForgotUserIDValidateStatus status}) {
    _forgotUserIDValidateStatus = status;

    notifyListeners();
  }

  void setOTPTriggerWait({required dom.Document forgotUserIDSearchDocument}) {
    DateTime? otpTriggerDateTime;

    dom.Element? tableBody = forgotUserIDSearchDocument
        .getElementById('validateOTP')
        ?.children[0]
        .children[1];

    otpTriggerDateTime = getDateTimeFromVTOPTextWithDateTime(
        text: tableBody?.children[1].innerHtml);
    if (otpTriggerDateTime != null) {
      Duration elapsedDuration = DateTime.now().difference(otpTriggerDateTime);
      _otpTriggerWait = const Duration(minutes: 10) - elapsedDuration;
      print("otpTriggerWait: $_otpTriggerWait");
    } else {
      _otpTriggerWait = Duration.zero;
    }

    notifyListeners();
  }

  void setUserIDFromForgotUserIDValidate(
      {required dom.Document forgotUserIDValidateDocument}) {
    String userID;

    dom.Element? tableBody = forgotUserIDValidateDocument
        .getElementById('forgotLoginID')
        ?.children[0]
        .children[0];

    userID = tableBody?.children[0].innerHtml ?? "User ID unavailable";

    _userID = userID;
    notifyListeners();
  }
}

DateTime? getDateTimeFromVTOPTextWithDateTime({required String? text}) {
  //Function works only for this type of string 'Last successful OTP triggered at 01/09/2022 02:28:43 AM'
  if (text != null) {
    String dateTime = text;

    dateTime = dateTime.replaceAll(RegExp("[a-zA-Z]"), "").replaceAll("/", "-");
    List<String> splitDateTime =
        dateTime.split(" ").map((e) => e.replaceAll(" ", "")).toList();
    splitDateTime.removeWhere((element) => element.isEmpty);
    String date = splitDateTime[0];
    String day = date.split("-")[0];
    String month = date.split("-")[1];
    String year = date.split("-")[2];
    String time = splitDateTime[1];
    if (text.contains("PM")) {
      int hour = ((int.parse(time.split(":")[0])) % 12) + 12;
      time = "$hour:${time.split(":")[1]}:${time.split(":")[2]}";
    }

    dateTime = "$year-$month-$day $time";

    DateTime? finalDateTime;
    try {
      finalDateTime = DateTime.parse(dateTime);
    } on Exception catch (exception) {
      log(exception.toString());
    } catch (error) {
      log(error.toString());
    }
    return finalDateTime;
  } else {
    return null;
  }
}
