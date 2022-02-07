import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';
import '../browser/browser.dart';
import 'AppTheme/app_theme_data.dart';

class FullWebView extends StatefulWidget {
  const FullWebView({
    Key? key,
    required this.onShowStudentProfileAllView,
    required this.loggedUserStatus,
    required this.arguments,
    required this.onTimeTable,
    required this.onPerformSignOut,
  }) : super(key: key);

  final String? loggedUserStatus;
  final ValueChanged<bool>? onShowStudentProfileAllView;
  final ValueChanged<bool>? onTimeTable;
  final FullWebViewArguments arguments;
  final ValueChanged<bool>? onPerformSignOut;

  @override
  _FullWebViewState createState() => _FullWebViewState();
}

class _FullWebViewState extends State<FullWebView> {
  ScrollController controller = ScrollController();
  List<Map> studentPortalOptions = [];
  bool isDialogShowing = false;

  requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  @override
  void initState() {
    requestPermissions();
    startTimeout();
    super.initState();
  }

  final interval = const Duration(seconds: 1);

  int timerMaxSeconds = 0;

  int currentSeconds = 0;

  Timer? timer;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout() async {
    DateTime? sessionDateTime = widget.arguments.sessionDateTime;
    DateTime dateTimeNow = await NTP.now();
    // gives difference between current time and the saved session time
    int differenceInSeconds =
        dateTimeNow.difference(sessionDateTime!).inSeconds;

    // removing that much seconds from 1hour of seconds
    int secondsRemainingInSession = 3480 - differenceInSeconds;

    // the no. of seconds the timer should run
    timerMaxSeconds = secondsRemainingInSession;

    // interval is 1 second
    var duration = interval;

    // timer provides timer.tick which just keep running at interval of 1 seconds
    // so the ticker will keep increasing and doesn't get affected by any of our variables
    // but once it gets bigger then timerMaxSeconds variable we close the timer and sign out the user
    // now you might be confused that the timer would just reset on closing app then it will not sign out when it should so
    // so to fight that case we are reassigning timerMaxSeconds variable with the amounts of seconds remaining from that time
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        // print(timer.tick.toString() + " , " + timerMaxSeconds.toString());
        //gets the timer.tick value for removing that much seconds from timerMaxSeconds for displaying timer on screen/ui
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds || timerMaxSeconds <= 0) {
          widget.onPerformSignOut?.call(true);
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  // final GlobalKey webViewKey = GlobalKey();
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    screenBasedPixelWidth = widget.arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.arguments.screenBasedPixelHeight;
    return widget.arguments.studentName == null ||
            (timerText == "00: 00" || timerText.isEmpty)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please Wait ...",
                    style: GoogleFonts.lato(
                      // color: Colors.white,
                      // textStyle: Theme.of(context).textTheme.headline1,
                      fontSize: screenBasedPixelWidth * 17,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ],
          )
        : FlutterBrowserApp(
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
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  FullWebViewArguments({
    required this.studentPortalDocument,
    required this.studentProfileAllViewDocument,
    required this.studentName,
    required this.headlessWebView,
    required this.sessionDateTime,
    required this.processingSomething,
    required this.themeMode,
    required this.onThemeMode,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
