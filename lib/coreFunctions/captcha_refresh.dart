import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:mini_vtop/coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

performCaptchaRefresh(
    {required BuildContext context,
    required HeadlessInAppWebView? headlessWebView,
    required bool refreshingCaptcha,
    required ValueChanged<bool> onRefreshingCaptcha,
    required ValueChanged<String> onCurrentFullUrl}) async {
  onRefreshingCaptcha.call(refreshingCaptcha);
  if (headlessWebView?.isRunning() ?? false) {
    await headlessWebView?.webViewController
        .evaluateJavascript(
            source: "new XMLSerializer().serializeToString(document);")
        .then((value) async {
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
            "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for performCaptchaRefresh");
        runHeadlessInAppWebView(
          headlessWebView: headlessWebView,
          onCurrentFullUrl: (String value) {
            onCurrentFullUrl(value);
          },
        );
      } else {
        await headlessWebView.webViewController.evaluateJavascript(source: '''
                               doRefreshCaptcha();
                                ''');
        debugPrint("called captchaRefresh");
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
