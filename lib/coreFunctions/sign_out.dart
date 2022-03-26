import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mini_vtop/coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

void performSignOut(
    {required BuildContext context,
    required HeadlessInAppWebView? headlessWebView,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onError}) async {
  if (headlessWebView?.isRunning() ?? false) {
    if (!await InternetConnectionChecker().hasConnection) {
      debugPrint(
          "InternetConnectionChecker plugin detected no internet access during execution of performSignOut()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
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
          debugPrint(
              "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for performSignOut");
          runHeadlessInAppWebView(
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl(value);
            },
          );
        } else {
          await headlessWebView.webViewController.evaluateJavascript(source: '''
                               ajaxCall('processLogout',null,'page_outline');
                                ''');
          debugPrint("called signOut");
        }
      } else {
        debugPrint(
            "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in performSignOut()");
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
