import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

performSignIn(
    {required String uname,
    required String passwd,
    required String captchaCheck,
    required bool processingSomething,
    required bool refreshingCaptcha,
    required ValueChanged<bool> onRefreshingCaptcha,
    required ValueChanged<bool> onProcessingSomething,
    required BuildContext context,
    required HeadlessInAppWebView? headlessWebView,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onError}) async {
  onRefreshingCaptcha.call(refreshingCaptcha);
  onProcessingSomething.call(processingSomething);
  if (headlessWebView?.isRunning() ?? false) {
    if (!await InternetConnectionChecker().hasConnection) {
      debugPrint(
          "InternetConnectionChecker plugin detected no internet access during execution of performSignIn()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
      onError.call("net::ERR_INTERNET_DISCONNECTED");
    }

    await headlessWebView?.webViewController
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
          // runHeadlessInAppWebView(
          //     headlessWebView: headlessWebView,
          //     onCurrentFullUrl: (String value) {
          //       onCurrentFullUrl.call(value);
          //     });
          debugPrint(
              "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for performSignIn");
          runHeadlessInAppWebView(
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl(value);
            },
          );
        } else {
          await headlessWebView.webViewController.evaluateJavascript(source: '''
        document.getElementById('uname').value = '$uname';
        document.getElementById('passwd').value = '$passwd';
        document.getElementById('captchaCheck').value = '$captchaCheck';
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
    const snackBar = SnackBar(
      content: Text(
          'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
