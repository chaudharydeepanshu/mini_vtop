import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:minivtop/db/flutter_secure_storage/secure_storage_repository.dart';

enum LoginResponseStatus {
  loggedOut,
  processing,
  loggedIn,
  wrongUserId,
  wrongPassword,
  wrongCaptcha,
  maxAttemptsError,
  // unknownResponse
}

enum ForgotUserIDSearchResponseStatus {
  notSearching,
  searching,
  notFound,
  found,
  // unknownResponse,
  otpTriggerWait
}

enum ForgotUserIDValidateResponseStatus {
  notProcessing,
  processing,
  invalidOTP,
  successful,
  notAuthorized
  // unknownResponse
}

class UserLoginState extends ChangeNotifier {
  bool _shouldSaveCredentials = true;
  bool get shouldSaveCredentials => _shouldSaveCredentials;

  late bool _isCredentialsFound = false;
  bool get isCredentialsFound => _isCredentialsFound;

  late String _autoCaptcha = "";
  String get autoCaptcha => _autoCaptcha;

  late String _captcha = "";
  String get captcha => _captcha;

  late String _userID = "";
  String get userID => _userID;

  late String _password = "";
  String get password => _password;

  Uint8List? _captchaImage;
  Uint8List? get captchaImage => _captchaImage;

  late LoginResponseStatus _loginResponseStatus = LoginResponseStatus.loggedOut;
  LoginResponseStatus get loginResponseStatus => _loginResponseStatus;

  late Duration _otpTriggerWait = Duration.zero;
  Duration get otpTriggerWait => _otpTriggerWait;

  late ForgotUserIDSearchResponseStatus _forgotUserIDSearchStatus =
      ForgotUserIDSearchResponseStatus.notSearching;
  ForgotUserIDSearchResponseStatus get forgotUserIDSearchStatus =>
      _forgotUserIDSearchStatus;

  late ForgotUserIDValidateResponseStatus _forgotUserIDValidateStatus =
      ForgotUserIDValidateResponseStatus.notProcessing;
  ForgotUserIDValidateResponseStatus get forgotUserIDValidateStatus =>
      _forgotUserIDValidateStatus;

  late String _erpIDOrRegNo = "";
  String get erpIDOrRegNo => _erpIDOrRegNo;

  late String _emailOTP = "";
  String get emailOTP => _emailOTP;

  init() async {
    _userID = await SecureStorageRepository().getVTOPCredentialsUserID();
    _password =
        await SecureStorageRepository().getVTOPCredentialsUserPassword();

    if (_userID != "" && _password != "") {
      _isCredentialsFound = true;
    }
  }

  void updateIsCredentialsFoundStatus({required bool status}) {
    _isCredentialsFound = status;
    notifyListeners();
  }

  void updateShouldSaveCredentialsStatus({required bool status}) {
    _shouldSaveCredentials = status;
    notifyListeners();
  }

  void setAutoCaptcha({required String autoCaptcha}) {
    _autoCaptcha = autoCaptcha;
    _captcha = autoCaptcha;
    notifyListeners();
  }

  void setCaptcha({required String captcha}) {
    _captcha = captcha;
    notifyListeners();
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

  void updateLoginStatus({required LoginResponseStatus loginStatus}) {
    _loginResponseStatus = loginStatus;

    notifyListeners();
  }

  void addCredentialsToDB() {
    if (shouldSaveCredentials) {
      SecureStorageRepository()
          .updateVTOPCredentials(userID: userID, userPassword: password);
      updateIsCredentialsFoundStatus(status: true);
    }
    notifyListeners();
  }

  void updateResponseStatus({required LoginResponseStatus loginStatus}) {
    _loginResponseStatus = loginStatus;

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
      {required ForgotUserIDSearchResponseStatus status}) {
    _forgotUserIDSearchStatus = status;

    notifyListeners();
  }

  void updateForgotUserIDValidateStatus(
      {required ForgotUserIDValidateResponseStatus status}) {
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
      log("otpTriggerWait: $_otpTriggerWait");
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
