import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RunHeadlessInAppWebView extends StatefulWidget {
  const RunHeadlessInAppWebView({
    Key? key,
    this.arguments,
    // this.onCaptchaImage,
    // this.onHeadlessWebView,
    this.onConsoleMessage,
    this.onCurrentStatus,
  }) : super(key: key);

  // final ValueChanged<Image>? onCaptchaImage;
  // final ValueChanged<HeadlessInAppWebView>? onHeadlessWebView;
  final ValueChanged<String>? onCurrentStatus;
  final ValueChanged<bool>? onConsoleMessage;
  final RunHeadlessInAppWebViewArguments? arguments;

  @override
  _RunHeadlessInAppWebViewState createState() =>
      _RunHeadlessInAppWebViewState();
}

class _RunHeadlessInAppWebViewState extends State<RunHeadlessInAppWebView> {
  HeadlessInAppWebView? headlessWebView;
  late String? currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.arguments?.currentStatus;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  currentStatus = "runHeadlessInAppWebView";
                  widget.onCurrentStatus?.call("runHeadlessInAppWebView");
                },
                child: const Text("Run HeadlessInAppWebView"),
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    widget.onConsoleMessage?.call(true);
                  },
                  child: const Text("Send console.log message")),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  currentStatus = "stopHeadlessInAppWebView";
                  widget.onCurrentStatus?.call("stopHeadlessInAppWebView");
                },
                child: const Text("Dispose HeadlessInAppWebView"),
              ),
            ),
            // TextField(
            //   controller: _controller,
            //   onSubmitted: (String value) async {
            //     await showDialog<void>(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return AlertDialog(
            //           title: const Text('Thanks!'),
            //           content: Text(
            //               'You typed "$value", which has length ${value.characters.length}.'),
            //           actions: <Widget>[
            //             TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               child: const Text('OK'),
            //             ),
            //           ],
            //         );
            //       },
            //     );
            //   },
            // ),
            // TextField(
            //   controller: _controller2,
            //   onSubmitted: (String value) async {
            //     await showDialog<void>(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return AlertDialog(
            //           title: const Text('Thanks!'),
            //           content: Text(
            //               'You typed "$value", which has length ${value.characters.length}.'),
            //           actions: <Widget>[
            //             TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               child: const Text('OK'),
            //             ),
            //           ],
            //         );
            //       },
            //     );
            //   },
            // ),
            // TextField(
            //   controller: _controller3,
            //   onSubmitted: (String value) async {
            //     await showDialog<void>(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return AlertDialog(
            //           title: const Text('Thanks!'),
            //           content: Text(
            //               'You typed "$value", which has length ${value.characters.length}.'),
            //           actions: <Widget>[
            //             TextButton(
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               child: const Text('OK'),
            //             ),
            //           ],
            //         );
            //       },
            //     );
            //   },
            // ),
            // Center(
            //   child: Container(
            //     padding: const EdgeInsets.all(20.0),
            //     child: image,
            //     // Html(
            //     //   data: serializedDocument,
            //     // ),
            //     // Text("Document: $serializedDocument"),
            //   ),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     if (headlessWebView?.isRunning() ?? false) {
            //       var response = await headlessWebView?.webViewController
            //           .evaluateJavascript(
            //               source:
            //                   "new XMLSerializer().serializeToString(document);");
            //       printWrapped(response);
            //       var fillDetailsAndSubmit = await headlessWebView
            //           ?.webViewController
            //           .evaluateJavascript(source: '''
            //                     document.getElementById('uname').value = '${_controller?.value.text}';
            //                     document.getElementById('passwd').value = '${_controller2?.value.text}';
            //                     document.getElementById('captchaCheck').value = '${_controller3?.value.text}';
            //                     document.getElementById('captcha').click();
            //                     ''');
            //       // var fillPassword = await headlessWebView?.webViewController
            //       //     .evaluateJavascript(
            //       //         source:
            //       //             "");
            //       // var fillCaptcha = await headlessWebView?.webViewController
            //       //     .evaluateJavascript(
            //       //         source:
            //       //             "");
            //       // await headlessWebView?.webViewController
            //       //     .evaluateJavascript(source: '''
            //       //     document.getElementById('uname').value = ${_controller.value.text};
            //       //     document.getElementById('passwd').value = ${_controller2.value.text};
            //       //     document.getElementById('captchaCheck').value = ${_controller3.value.text};
            //       //     ''');
            //     } else {
            //       const snackBar = SnackBar(
            //         content: Text(
            //             'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
            //         duration: Duration(milliseconds: 1500),
            //       );
            //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //     }
            //   },
            //   child: const Text('SignIn'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     if (headlessWebView?.isRunning() ?? false) {
            //       var response = await headlessWebView?.webViewController
            //           .evaluateJavascript(
            //               source:
            //                   "new XMLSerializer().serializeToString(document);");
            //       printWrapped(response);
            //       var fillDetailsAndSubmit = await headlessWebView
            //           ?.webViewController
            //           .evaluateJavascript(source: '''
            //                    ajaxCall('processLogout',null,'page_outline');
            //                     ''');
            //       // var fillPassword = await headlessWebView?.webViewController
            //       //     .evaluateJavascript(
            //       //         source:
            //       //             "");
            //       // var fillCaptcha = await headlessWebView?.webViewController
            //       //     .evaluateJavascript(
            //       //         source:
            //       //             "");
            //       // await headlessWebView?.webViewController
            //       //     .evaluateJavascript(source: '''
            //       //     document.getElementById('uname').value = ${_controller.value.text};
            //       //     document.getElementById('passwd').value = ${_controller2.value.text};
            //       //     document.getElementById('captchaCheck').value = ${_controller3.value.text};
            //       //     ''');
            //     } else {
            //       const snackBar = SnackBar(
            //         content: Text(
            //             'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
            //         duration: Duration(milliseconds: 1500),
            //       );
            //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //     }
            //   },
            //   child: const Text('Logout'),
            // ),
          ],
        ),
      ),
    );
  }
}

class RunHeadlessInAppWebViewArguments {
  // HeadlessInAppWebView? headlessWebView;
  String? currentStatus;

  RunHeadlessInAppWebViewArguments({
    // required this.headlessWebView,
    required this.currentStatus,
  });
}
