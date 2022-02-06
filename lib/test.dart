import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    debugPrint("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    debugPrint("Started $url");
  }

  @override
  Future onLoadStop(url) async {
    debugPrint("Stopped $url");
  }

  @override
  void onLoadError(url, code, message) {
    debugPrint("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    debugPrint("Progress: $progress");
  }

  @override
  void onExit() {
    debugPrint("Browser closed!");
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final MyInAppBrowser browser = MyInAppBrowser();

  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: true),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InAppBrowser Example'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              widget.browser.openUrlRequest(
                  urlRequest: URLRequest(
                      url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
                  options: options);
            },
            child: const Text("Open InAppBrowser")),
      ),
    );
  }
}
