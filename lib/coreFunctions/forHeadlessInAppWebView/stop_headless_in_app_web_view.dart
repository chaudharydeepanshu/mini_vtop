import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

stopHeadlessInAppWebView(
    {required HeadlessInAppWebView? headlessWebView,
    required ValueChanged<String> onCurrentFullUrl}) {
  headlessWebView?.dispose();
  onCurrentFullUrl.call("");
}
