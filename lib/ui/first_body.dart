import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RunHeadlessInAppWebView extends StatefulWidget {
  const RunHeadlessInAppWebView({
    Key? key,
    this.arguments,
    this.onConsoleMessage,
    this.onCurrentStatus,
  }) : super(key: key);

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
          ],
        ),
      ),
    );
  }
}

class RunHeadlessInAppWebViewArguments {
  String? currentStatus;

  RunHeadlessInAppWebViewArguments({
    required this.currentStatus,
  });
}
