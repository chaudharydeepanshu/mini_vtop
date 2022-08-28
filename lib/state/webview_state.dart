import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HeadlessWebView extends ChangeNotifier {
  HeadlessInAppWebView? headlessWebView;
  String _url = "";
  String get url => _url;

  @override
  void dispose() {
    headlessWebView?.dispose();
    super.dispose();
  }

  init() async {
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse("https://www.google.com")),
      onWebViewCreated: (controller) {
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print('Console Message: ${consoleMessage.message}');
      },
      onLoadStart: (controller, url) async {
        print('onLoadStart $url');
        _url = url?.toString() ?? '';
      },
      onLoadStop: (controller, url) async {
        print('onLoadStop $url');
        _url = url?.toString() ?? '';
      },
    );

    await headlessWebView?.dispose();
    await headlessWebView?.run();

    print("lol");
  }
}
