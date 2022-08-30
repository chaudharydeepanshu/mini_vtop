import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/webview_state.dart';

enum VTOPPageStatus { notProcessing, processing, loaded, error }

class VTOPActions extends ChangeNotifier {
  VTOPActions(this.read);

  final Reader read;

  VTOPPageStatus _studentProfilePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentProfilePageStatus => _studentProfilePageStatus;

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

    String registrationNumber =
        readUserLoginStateProviderValue.registrationNumber;
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
                               document.getElementById("STA002").click();
                                ''');
            debugPrint("called StudentProfileAllView");

            _studentProfilePageStatus = VTOPPageStatus.processing;
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
    notifyListeners();
  }

  void callStudentGradeHistory({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

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
}
