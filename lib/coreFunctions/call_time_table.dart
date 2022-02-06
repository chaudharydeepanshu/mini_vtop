import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

callTimeTable(
    {required BuildContext context,
    required HeadlessInAppWebView? headlessWebView,
    required bool processingSomething,
    required ValueChanged<bool> onProcessingSomething,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onError}) async {
  onProcessingSomething.call(processingSomething);
  if (headlessWebView?.isRunning() ?? false) {
    if (!await InternetConnectionChecker().hasConnection) {
      debugPrint(
          "InternetConnectionChecker plugin detected no internet access during execution of callTimeTable()\nSo, now calling runHeadlessInAppWebView() to recheck connection and and update error on screen");
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
              "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for callTimeTable");
          runHeadlessInAppWebView(
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl(value);
            },
          );
        } else {
          await headlessWebView.webViewController.evaluateJavascript(source: '''
                               document.getElementById("ACD0034").click();
                                ''');
          debugPrint("called TimeTable");
        }
      } else {
        debugPrint(
            "value for await headlessWebView?.webViewController.evaluateJavascript(source: 'new XMLSerializer().serializeToString(document);') is null in callTimeTable()");
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
