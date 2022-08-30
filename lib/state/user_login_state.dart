import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserLoginState extends ChangeNotifier {
  late String _solvedCaptcha = "Test";
  String get solvedCaptcha => _solvedCaptcha;

  late String _registrationNumber = "";
  String get registrationNumber => _registrationNumber;

  late String _password = "";
  String get password => _password;

  Uint8List? _captchaImage;
  Uint8List? get captchaImage => _captchaImage;

  late bool _userLoggedIn = false;
  bool get userLoggedIn => _userLoggedIn;

  late bool _processingLogin = false;
  bool get processingLogin => _processingLogin;

  void setCaptcha({required String captcha}) {
    _solvedCaptcha = captcha;
    notifyListeners();

    print(solvedCaptcha);

    print("setCaptcha called");
  }

  void setRegistrationNumber({required String registrationNumber}) {
    _registrationNumber = registrationNumber;
    notifyListeners();
  }

  void setPassword({required String password}) {
    _password = password;
    notifyListeners();
  }

  void updateCaptchaImage({required Uint8List bytes}) {
    _captchaImage = bytes;
    notifyListeners();
  }

  void updateLoginStatus({required bool loginStatus}) {
    _userLoggedIn = loginStatus;

    notifyListeners();
  }

  void updateLoginProgress({required bool loginProgress}) {
    _processingLogin = loginProgress;
    notifyListeners();
  }
}
