import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

showConsoleMessage(
    {required BuildContext context,
    required HeadlessInAppWebView? headlessWebView}) async {
  if (headlessWebView?.isRunning() ?? false) {
    await headlessWebView?.webViewController
        .evaluateJavascript(source: "console.log('Here is the message!');");
  } else {
    const snackBar = SnackBar(
      content: Text(
          'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
