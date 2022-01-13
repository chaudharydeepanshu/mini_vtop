import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

performSignOut(
    {required BuildContext context,
    required HeadlessInAppWebView? headlessWebView,
    required ValueChanged<String> onCurrentFullUrl}) async {
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
    });
  } else {
    const snackBar = SnackBar(
      content: Text(
          'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  // setState(() {
  //   currentStatus = null;
  // });
}
