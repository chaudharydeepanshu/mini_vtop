import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:ntp/ntp.dart';
import '../browser/browser.dart';
import 'AppTheme/app_theme_data.dart';

class FullWebView extends StatefulWidget {
  const FullWebView({
    Key? key,
    this.onShowStudentProfileAllView,
    this.loggedUserStatus,
    required this.arguments,
    this.onTimeTable,
  }) : super(key: key);

  final String? loggedUserStatus;
  final ValueChanged<bool>? onShowStudentProfileAllView;
  final ValueChanged<bool>? onTimeTable;
  final FullWebViewArguments arguments;

  @override
  _FullWebViewState createState() => _FullWebViewState();
}

class _FullWebViewState extends State<FullWebView> {
  ScrollController controller = ScrollController();
  List<Map> studentPortalOptions = [];
  bool isDialogShowing = false;

  @override
  void initState() {
    startTimeout();
    super.initState();
  }

  final interval = const Duration(seconds: 1);

  int timerMaxSeconds = 0;

  int currentSeconds = 0;

  late Timer timer;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout() async {
    DateTime? sessionDateTime = widget.arguments.sessionDateTime;
    DateTime dateTimeNow = await NTP.now();
    int differenceInSeconds =
        dateTimeNow.difference(sessionDateTime!).inSeconds;

    int secondsRemainingInSession = 3600 - differenceInSeconds;

    timerMaxSeconds = secondsRemainingInSession;

    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  // final GlobalKey webViewKey = GlobalKey();
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FlutterBrowserApp(
      themeMode: widget.arguments.themeMode,
    );
  }
}

class FlutterBrowserApp extends StatefulWidget {
  const FlutterBrowserApp({Key? key, required this.themeMode})
      : super(key: key);

  final ThemeMode? themeMode;

  @override
  State<FlutterBrowserApp> createState() => _FlutterBrowserAppState();
}

class _FlutterBrowserAppState extends State<FlutterBrowserApp> {
  @override
  Widget build(BuildContext context) {
    late ThemeMode? themeMode = widget.themeMode;

    return MaterialApp(
        title: 'Original VTOP Browser',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeClass.lightTheme,
        darkTheme: ThemeClass.darkTheme,
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        // ),
        initialRoute: '/',
        routes: {
          '/': (context) => const Browser(),
        });
  }
}

class FullWebViewArguments {
  dom.Document? studentPortalDocument;
  dom.Document? studentProfileAllViewDocument;
  String? studentName;
  HeadlessInAppWebView? headlessWebView;
  DateTime? sessionDateTime;
  bool processingSomething;
  ThemeMode? themeMode;
  ValueChanged<ThemeMode>? onThemeMode;

  FullWebViewArguments({
    required this.studentPortalDocument,
    required this.studentProfileAllViewDocument,
    required this.studentName,
    required this.headlessWebView,
    required this.sessionDateTime,
    required this.processingSomething,
    required this.themeMode,
    required this.onThemeMode,
  });
}
