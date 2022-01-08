import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

runHeadlessInAppWebView(
    {required HeadlessInAppWebView? headlessWebView,
    required ValueChanged<String> onCurrentFullUrl}) async {
  await headlessWebView?.dispose().whenComplete(() async {
    onCurrentFullUrl.call("");
    await headlessWebView.run();
  });
}
