import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:ntp/ntp.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class StudentPortal extends StatefulWidget {
  const StudentPortal({
    Key? key,
    required this.onShowStudentProfileAllView,
    required this.loggedUserStatus,
    required this.arguments,
    required this.onTimeTable,
    required this.onPerformSignOut,
    required this.onProcessingSomething,
    required this.onClassAttendance,
  }) : super(key: key);

  final String? loggedUserStatus;
  final ValueChanged<bool>? onShowStudentProfileAllView;
  final ValueChanged<bool>? onTimeTable;
  final ValueChanged<bool>? onClassAttendance;
  final StudentPortalArguments arguments;
  final ValueChanged<bool>? onPerformSignOut;
  final ValueChanged<bool> onProcessingSomething;

  @override
  _StudentPortalState createState() => _StudentPortalState();
}

class _StudentPortalState extends State<StudentPortal> {
  ScrollController controller = ScrollController();
  List<Map> studentPortalOptions = [];
  bool isDialogShowing = false;
  late StudentPortalArguments arguments;

  @override
  void didUpdateWidget(StudentPortal oldWidget) {
    if (oldWidget.arguments != widget.arguments) {
      arguments = widget.arguments;
    }
    super.didUpdateWidget(oldWidget);
  }

  runRequestingDataDialogBox() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onProcessingSomething.call(
          true); //then set processing something true for the new loading dialog
      customAlertDialogBox(
        isDialogShowing: isDialogShowing,
        context: context,
        onIsDialogShowing: (bool value) {
          setState(() {
            isDialogShowing = value;
          });
        },
        dialogTitle: 'Requesting Data',
        dialogContent: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: widgetSizeProvider(
                  fixedSize: 36, sizeDecidingVariable: screenBasedPixelWidth),
              width: widgetSizeProvider(
                  fixedSize: 36, sizeDecidingVariable: screenBasedPixelWidth),
              child: CircularProgressIndicator(
                strokeWidth: widgetSizeProvider(
                    fixedSize: 4, sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
            Text(
              'Please wait...',
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.60)),
                  sizeDecidingVariable: screenBasedPixelWidth),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        barrierDismissible: true,
        screenBasedPixelHeight: screenBasedPixelHeight,
        screenBasedPixelWidth: screenBasedPixelWidth,
        onProcessingSomething: (bool value) {
          widget.onProcessingSomething.call(value);
        },
      ).then((_) => isDialogShowing = false);
    });
  }

  @override
  void initState() {
    arguments = widget.arguments;
    studentPortalOptions = [
      {
        "name": "Your Info",
        "icon": Icons.work,
        "internalOptionsMapList": [
          {
            "name": "Profile",
            "action": () {
              widget.onShowStudentProfileAllView?.call(true);
              Navigator.of(context).pop(); // pop the option selection dialog
              runRequestingDataDialogBox();
            },
          },
        ],
      },
      {
        "name": "Academics",
        "icon": Icons.school,
        "internalOptionsMapList": [
          {
            "name": "Time Table & Subjects Details",
            "action": () {
              widget.onTimeTable?.call(true);
              Navigator.of(context).pop(); // pop the option selection dialog
              runRequestingDataDialogBox();
            },
          },
          {
            "name": "Class Attendance",
            "action": () {
              widget.onClassAttendance?.call(true);
              Navigator.of(context).pop(); // pop the option selection dialog
              runRequestingDataDialogBox();
            },
          },
        ],
      },
    ];
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
    DateTime? sessionDateTime = arguments.sessionDateTime;
    DateTime dateTimeNow = await NTP.now();
    // gives difference between current time and the saved session time
    int differenceInSeconds = dateTimeNow
        .difference(sessionDateTime!)
        .inSeconds; //todo: this is getting null sometimes so fix it

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
        // debugPrint(timer.tick.toString() + " , " + timerMaxSeconds.toString());
        //gets the timer.tick value for removing that much seconds from timerMaxSeconds for displaying timer on screen/ui
        currentSeconds = timer.tick;
        // timerMaxSeconds = 10;
        if (timer.tick >= timerMaxSeconds || timerMaxSeconds <= 0) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            widget.onProcessingSomething.call(true);
            customAlertDialogBox(
              isDialogShowing: isDialogShowing,
              context: context,
              onIsDialogShowing: (bool value) {
                setState(() {
                  isDialogShowing = value;
                });
              },
              dialogTitle: 'You logged out',
              dialogContent: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: widgetSizeProvider(
                        fixedSize: 36,
                        sizeDecidingVariable: screenBasedPixelWidth),
                    width: widgetSizeProvider(
                        fixedSize: 36,
                        sizeDecidingVariable: screenBasedPixelWidth),
                    child: CircularProgressIndicator(
                      strokeWidth: widgetSizeProvider(
                          fixedSize: 4,
                          sizeDecidingVariable: screenBasedPixelWidth),
                    ),
                  ),
                  Text(
                    'So, re-requesting login page please wait...',
                    style: getDynamicTextStyle(
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.60)),
                        sizeDecidingVariable: screenBasedPixelWidth),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              barrierDismissible: false,
              screenBasedPixelHeight: screenBasedPixelHeight,
              screenBasedPixelWidth: screenBasedPixelWidth,
              onProcessingSomething: (bool value) {
                setState(() {
                  widget.onProcessingSomething.call(value);
                });
              },
            ).then((_) => isDialogShowing = false);
          });
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

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  String waitingText = "Please Wait ...";

  @override
  Widget build(BuildContext context) {
    //created to fix a bug which is resulting in users getting stuck on please wait
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          waitingText =
              "Taking too long?\nTry switching VTOP mode\nOR\nRestart the app.\nWe are working on a fix.";
        });
      }
      if (arguments.studentName == null ||
          (timerText == "00: 00" || timerText.isEmpty)) {
        debugPrint("arguments.studentName: ${arguments.studentName}");
        debugPrint("timerText: $timerText");
      }
    });

    screenBasedPixelWidth = arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = arguments.screenBasedPixelHeight;

    return (arguments.studentName == null ||
            (timerText == "00: 00" || timerText.isEmpty))
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: widgetSizeProvider(
                      fixedSize: 4,
                      sizeDecidingVariable: arguments.screenBasedPixelWidth),
                ),
                SizedBox(
                  height: widgetSizeProvider(
                      fixedSize: 10,
                      sizeDecidingVariable: arguments.screenBasedPixelHeight),
                ),
                Flexible(
                  child: Text(
                    waitingText,
                    textAlign: TextAlign.center, // maxLines: 10,
                    style: getDynamicTextStyle(
                        textStyle: Theme.of(context).textTheme.headline5,
                        sizeDecidingVariable: arguments.screenBasedPixelWidth),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: EdgeInsets.all(
                      widgetSizeProvider(
                          fixedSize: 18,
                          sizeDecidingVariable:
                              arguments.screenBasedPixelWidth),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello,",
                                    style: getDynamicTextStyle(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                        sizeDecidingVariable:
                                            arguments.screenBasedPixelWidth),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "${toBeginningOfSentenceCase(arguments.studentName?.split(' ')[0].trim().toLowerCase())} 👋",
                                      style: getDynamicTextStyle(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                          sizeDecidingVariable:
                                              arguments.screenBasedPixelWidth),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    widgetSizeProvider(
                                        fixedSize: 20,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    widgetSizeProvider(
                                        fixedSize: 5,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: FittedBox(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        FittedBox(
                                          child: Icon(
                                            Icons.timer,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: widgetSizeProvider(
                                                fixedSize: 24,
                                                sizeDecidingVariable: widget
                                                    .arguments
                                                    .screenBasedPixelWidth),
                                          ),
                                        ),
                                        SizedBox(
                                          width: widgetSizeProvider(
                                              fixedSize: 5,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                        ),
                                        SizedBox(
                                          width: widgetSizeProvider(
                                              fixedSize: 70,
                                              sizeDecidingVariable: arguments
                                                  .screenBasedPixelHeight),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              timerText,
                                              maxLines: 1,
                                              style: getDynamicTextStyle(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                  sizeDecidingVariable: arguments
                                                      .screenBasedPixelWidth),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: widgetSizeProvider(
                              fixedSize: 15,
                              sizeDecidingVariable:
                                  arguments.screenBasedPixelHeight),
                        ),
                        OrientationBuilder(
                          builder: (context, orientation) {
                            return GridView.builder(
                              controller: controller,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: widgetSizeProvider(
                                    fixedSize: 200,
                                    sizeDecidingVariable:
                                        arguments.screenBasedPixelWidth),
                                childAspectRatio: 3 / 2.5,
                                crossAxisSpacing: widgetSizeProvider(
                                    fixedSize: 20,
                                    sizeDecidingVariable:
                                        arguments.screenBasedPixelWidth),
                                mainAxisSpacing: widgetSizeProvider(
                                    fixedSize: 20,
                                    sizeDecidingVariable:
                                        arguments.screenBasedPixelWidth),
                              ),
                              itemCount: studentPortalOptions.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return Padding(
                                  padding: EdgeInsets.all(
                                    widgetSizeProvider(
                                        fixedSize: 15,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                        EdgeInsets.all(
                                          widgetSizeProvider(
                                              fixedSize: 20,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                        ),
                                      ),
                                      textStyle: MaterialStateProperty.all(
                                        getDynamicTextStyle(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .button,
                                            sizeDecidingVariable: arguments
                                                .screenBasedPixelWidth),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            widgetSizeProvider(
                                                fixedSize: 20,
                                                sizeDecidingVariable: widget
                                                    .arguments
                                                    .screenBasedPixelWidth),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      widget.onProcessingSomething.call(true);
                                      customAlertDialogBox(
                                        onIsDialogShowing: (bool value) {
                                          isDialogShowing = value;
                                        },
                                        isDialogShowing: isDialogShowing,
                                        dialogContent: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            studentPortalOptions[index]
                                                    ["internalOptionsMapList"]
                                                .length,
                                            (i) => Padding(
                                              padding: EdgeInsets.only(
                                                bottom: widgetSizeProvider(
                                                    fixedSize: 8,
                                                    sizeDecidingVariable: widget
                                                        .arguments
                                                        .screenBasedPixelWidth),
                                              ),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  minimumSize:
                                                      MaterialStateProperty.all<
                                                          Size?>(
                                                    Size.fromHeight(
                                                      widgetSizeProvider(
                                                          fixedSize: 56,
                                                          sizeDecidingVariable:
                                                              arguments
                                                                  .screenBasedPixelHeight),
                                                    ),
                                                  ),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                    EdgeInsets.only(
                                                      left: widgetSizeProvider(
                                                          fixedSize: 20,
                                                          sizeDecidingVariable:
                                                              arguments
                                                                  .screenBasedPixelWidth),
                                                      right: widgetSizeProvider(
                                                          fixedSize: 20,
                                                          sizeDecidingVariable:
                                                              arguments
                                                                  .screenBasedPixelWidth),
                                                    ),
                                                  ),
                                                  textStyle:
                                                      MaterialStateProperty.all(
                                                    getDynamicTextStyle(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .button,
                                                        sizeDecidingVariable:
                                                            arguments
                                                                .screenBasedPixelWidth),
                                                  ),
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        widgetSizeProvider(
                                                            fixedSize: 0,
                                                            sizeDecidingVariable:
                                                                arguments
                                                                    .screenBasedPixelWidth),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: studentPortalOptions[
                                                            index][
                                                        "internalOptionsMapList"]
                                                    [i]["action"],
                                                child: Text(
                                                  studentPortalOptions[index][
                                                          "internalOptionsMapList"]
                                                      [i]["name"],
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        context: context,
                                        dialogTitle: studentPortalOptions[index]
                                            ["name"],
                                        barrierDismissible: true,
                                        screenBasedPixelHeight:
                                            screenBasedPixelHeight,
                                        screenBasedPixelWidth:
                                            screenBasedPixelWidth,
                                        onProcessingSomething: (bool value) {
                                          widget.onProcessingSomething
                                              .call(value);
                                        },
                                      );
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            studentPortalOptions[index]["icon"],
                                            size: widgetSizeProvider(
                                                fixedSize: 24,
                                                sizeDecidingVariable: widget
                                                    .arguments
                                                    .screenBasedPixelWidth),
                                          ),
                                          SizedBox(
                                            height: widgetSizeProvider(
                                                fixedSize: 10,
                                                sizeDecidingVariable: widget
                                                    .arguments
                                                    .screenBasedPixelHeight),
                                          ),
                                          Text(
                                            studentPortalOptions[index]["name"],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

class StudentPortalArguments {
  dom.Document? studentPortalDocument;
  dom.Document? studentProfileAllViewDocument;
  String? studentName;
  HeadlessInAppWebView? headlessWebView;
  DateTime? sessionDateTime;
  bool processingSomething;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  StudentPortalArguments({
    required this.studentPortalDocument,
    required this.studentProfileAllViewDocument,
    required this.studentName,
    required this.headlessWebView,
    required this.sessionDateTime,
    required this.processingSomething,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
