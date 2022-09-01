import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/webview_state.dart';

enum VTOPPageStatus {
  notProcessing,
  processing,
  loaded,
  sessionTimeout,
  unknownResponse
}

class VTOPActions extends ChangeNotifier {
  VTOPActions(this.read);

  final Reader read;

  VTOPPageStatus _studentProfilePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentProfilePageStatus => _studentProfilePageStatus;

  VTOPPageStatus _studentGradeHistoryPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentGradeHistoryPageStatus =>
      _studentGradeHistoryPageStatus;

  VTOPPageStatus _forgotUserIDPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get forgotUserIDPageStatus => _forgotUserIDPageStatus;

  VTOPPageStatus _forgotUserIDSearchPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get forgotUserIDSearchPageStatus =>
      _forgotUserIDSearchPageStatus;

  VTOPPageStatus _forgotUserIDValidatePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get forgotUserIDValidatePageStatus =>
      _forgotUserIDValidatePageStatus;

  late final HeadlessWebView readHeadlessWebViewProviderValue =
      read(headlessWebViewProvider);

  late final UserLoginState readUserLoginStateProviderValue =
      read(userLoginStateProvider);

  init() {
    readHeadlessWebViewProviderValue.resetControlVars();
  }

  void updateStudentProfilePageStatus({required VTOPPageStatus status}) {
    _studentProfilePageStatus = status;
    notifyListeners();
  }

  void updateStudentGradeHistoryPageStatus({required VTOPPageStatus status}) {
    _studentGradeHistoryPageStatus = status;
    notifyListeners();
  }

  void updateForgotUserIDPageStatus({required VTOPPageStatus status}) {
    _forgotUserIDPageStatus = status;
    notifyListeners();
  }

  void updateForgotUserIDSearchPageStatus({required VTOPPageStatus status}) {
    _forgotUserIDSearchPageStatus = status;
    notifyListeners();
  }

  void updateForgotUserIDValidatePageStatus({required VTOPPageStatus status}) {
    _forgotUserIDValidatePageStatus = status;
    notifyListeners();
  }

  void performCaptchaRefresh({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;
    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of performCaptchaRefresh()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            print(
                "You are logged out due to inactivity for more than 15 minutes");
            print(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for performCaptchaRefresh");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
                               doRefreshCaptcha();
                                ''');
            print("called captchaRefresh");
          }
        } else {
          print(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in performCaptchaRefresh()");
        }
      });
    } else {
// print('HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!');
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void performSignIn({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    String registrationNumber = readUserLoginStateProviderValue.userID;
    String password = readUserLoginStateProviderValue.password;
    String solvedCaptcha = readUserLoginStateProviderValue.solvedCaptcha;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of performSignIn()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            debugPrint(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for performSignIn");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
        document.getElementById('uname').value = '$registrationNumber';
        document.getElementById('passwd').value = '$password';
        document.getElementById('captchaCheck').value = '$solvedCaptcha';
        document.getElementById('captcha').click();
                                ''');
            debugPrint("called signIn");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in performSignIn()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void callStudentProfileAllView({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _studentProfilePageStatus = VTOPPageStatus.processing;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of callStudentProfileAllView()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes")
              // || value.contains("You have been successfully logged out")
              ) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            debugPrint(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for callStudentProfileAllView");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
                               document.getElementById("STA002").click();
                                ''');
            debugPrint("called StudentProfileAllView");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callStudentProfileAllView()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void callStudentGradeHistory({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _studentGradeHistoryPageStatus = VTOPPageStatus.processing;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of callStudentProfileAllView()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            debugPrint(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for callStudentProfileAllView");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
                               document.getElementById("EXM0023").click();
                                ''');
            debugPrint("called Academics");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callStudentProfileAllView()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void callForgotUserID({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _forgotUserIDPageStatus = VTOPPageStatus.processing;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of callStudentProfileAllView()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            _forgotUserIDPageStatus = VTOPPageStatus.sessionTimeout;
            notifyListeners();
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
                               forgotUserID();
                                ''');

            debugPrint("called ForgotUserID");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callStudentProfileAllView()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void callForgotUserIDSearch({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    String erpIDOrRegNo = readUserLoginStateProviderValue.erpIDOrRegNo;

    _forgotUserIDSearchPageStatus = VTOPPageStatus.processing;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of callStudentProfileAllView()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            debugPrint(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for callStudentProfileAllView");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
            document.getElementById("userId").value = '$erpIDOrRegNo';
         document.getElementById("btnSubmit").click();
                                ''');

            debugPrint("called ForgotUserIDSearch");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callStudentProfileAllView()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void callForgotUserIDValidate({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    String emailOTP = readUserLoginStateProviderValue.emailOTP;

    _forgotUserIDSearchPageStatus = VTOPPageStatus.processing;

    if (headlessWebView.isRunning()) {
      // if (!await InternetConnectionChecker().hasConnection) {
      //   debugPrint(
      //       "InternetConnectionChecker plugin detected no internet access during execution of callStudentProfileAllView()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      //   onError.call("net::ERR_INTERNET_DISCONNECTED");
      // }

      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) async {
        if (value != null) {
          // printWrapped(value);
          if (value.contains(
                  "You are logged out due to inactivity for more than 15 minutes") ||
              value.contains("You have been successfully logged out")) {
            debugPrint(
                "You are logged out due to inactivity for more than 15 minutes");
            debugPrint(
                "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for callStudentProfileAllView");
            // runHeadlessInAppWebView(
            //   headlessWebView: headlessWebView,
            //   onCurrentFullUrl: (String value) {
            //     onCurrentFullUrl(value);
            //   },
            // );
          } else {
            await headlessWebView.webViewController
                .evaluateJavascript(source: '''
            document.getElementById("otp").value = '$emailOTP';
         document.getElementById("btnValidate").click();
                                ''');

            debugPrint("called ForgotUserIDValidate");
          }
        } else {
          debugPrint(
              "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callStudentProfileAllView()");
        }
      });
    } else {
      // const snackBar = SnackBar(
      //   content: Text(
      //       'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      //   duration: Duration(milliseconds: 1500),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
