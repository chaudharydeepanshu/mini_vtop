import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:ntp/ntp.dart';

import '../basicFunctions/proccessing_dialog.dart';

class StudentPortal extends StatefulWidget {
  const StudentPortal({
    Key? key,
    this.onShowStudentProfileAllView,
    this.loggedUserStatus,
    required this.arguments,
    this.onTimeTable,
  }) : super(key: key);

  final String? loggedUserStatus;
  final ValueChanged<bool>? onShowStudentProfileAllView;
  final ValueChanged<bool>? onTimeTable;
  final StudentPortalArguments arguments;

  @override
  _StudentPortalState createState() => _StudentPortalState();
}

class _StudentPortalState extends State<StudentPortal> {
  ScrollController controller = ScrollController();
  List<Map> studentPortalOptions = [];
  bool isDialogShowing = false;

  @override
  void initState() {
    studentPortalOptions = [
      {
        "name": "Your Info",
        "icon": Icons.work,
        "internalOptionsMapList": [
          {
            "name": "Profile",
            "action": () {
              // timer.cancel();
              // startTimeout();
              widget.onShowStudentProfileAllView?.call(true);
              Navigator.of(context).pop();
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                customDialogBox(
                  isDialogShowing: isDialogShowing,
                  context: context,
                  onIsDialogShowing: (bool value) {
                    setState(() {
                      isDialogShowing = value;
                    });
                  },
                  dialogTitle: Text(
                    'Requesting Data',
                    style: TextStyle(fontSize: screenBasedPixelWidth * 24),
                    textAlign: TextAlign.center,
                  ),
                  dialogChildren: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenBasedPixelWidth * 36,
                        width: screenBasedPixelWidth * 36,
                        child: CircularProgressIndicator(
                          strokeWidth: screenBasedPixelWidth * 4.0,
                        ),
                      ),
                      Text(
                        'Please wait...',
                        style: TextStyle(fontSize: screenBasedPixelWidth * 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  barrierDismissible: true,
                  screenBasedPixelHeight: screenBasedPixelHeight,
                  screenBasedPixelWidth: screenBasedPixelWidth,
                ).then((_) => isDialogShowing = false);
              });
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
              // timer.cancel();
              // startTimeout();
              widget.onTimeTable?.call(true);
              Navigator.of(context).pop();
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                customDialogBox(
                  isDialogShowing: isDialogShowing,
                  context: context,
                  onIsDialogShowing: (bool value) {
                    setState(() {
                      isDialogShowing = value;
                    });
                  },
                  dialogTitle: Text(
                    'Requesting Data',
                    style: TextStyle(fontSize: screenBasedPixelWidth * 24),
                    textAlign: TextAlign.center,
                  ),
                  dialogChildren: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenBasedPixelWidth * 36,
                        width: screenBasedPixelWidth * 36,
                        child: CircularProgressIndicator(
                          strokeWidth: screenBasedPixelWidth * 4.0,
                        ),
                      ),
                      Text(
                        'Please wait...',
                        style: TextStyle(fontSize: screenBasedPixelWidth * 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  barrierDismissible: true,
                  screenBasedPixelHeight: screenBasedPixelHeight,
                  screenBasedPixelWidth: screenBasedPixelWidth,
                ).then((_) => isDialogShowing = false);
              });
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

  late Timer timer;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout() async {
    DateTime? sessionDateTime = widget.arguments.sessionDateTime;
    DateTime dateTimeNow = await NTP.now();
    int differenceInSeconds = dateTimeNow
        .difference(sessionDateTime!)
        .inSeconds; //todo: this is getting null sometimes so fix it

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

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    screenBasedPixelWidth = widget.arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.arguments.screenBasedPixelHeight;
    // debugPrint("isDialogShowing: $isDialogShowing");
    // if (widget.arguments.processingSomething == false &&
    //     isDialogShowing == true) {
    //   // _controller3 = TextEditingController(text: "");
    //   // Future.delayed(const Duration(milliseconds: 500), () async {
    //   Navigator.of(context).pop();
    //   debugPrint("dialogBox popped");
    //   // });
    // }

    // print(widget.arguments.studentPortalDocument.outerHtml);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello,",
                            style: GoogleFonts.lato(
                              // color: Colors.white,
                              // textStyle: Theme.of(context).textTheme.headline1,
                              fontSize: screenBasedPixelWidth * 17,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          widget.arguments.studentName != null
                              ? Text(
                                  "${toBeginningOfSentenceCase(widget.arguments.studentName?.split(' ')[0].trim().toLowerCase())} 👋",
                                  style: GoogleFonts.lato(
                                    // color: Colors.white,
                                    // textStyle: Theme.of(context).textTheme.headline1,
                                    fontSize: screenBasedPixelWidth * 20,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                  ),
                                )
                              : Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    // color: Colors.white,
                                    // textStyle: Theme.of(context).textTheme.headline1,
                                    fontSize: screenBasedPixelWidth * 20,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff04294f),
                          //border: Border.all(color: Colors.blue, width: 10),
                          borderRadius: BorderRadius.circular(
                              screenBasedPixelWidth * 20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                size: screenBasedPixelWidth * 24,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: screenBasedPixelWidth * 5,
                              ),
                              Text(
                                timerText,
                                style: GoogleFonts.lato(
                                  fontSize: screenBasedPixelWidth * 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  OrientationBuilder(
                    builder: (context, orientation) {
                      return GridView.builder(
                        controller: controller,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: screenBasedPixelWidth * 200,
                            childAspectRatio: 3 / 2.5,
                            crossAxisSpacing: screenBasedPixelWidth * 20,
                            mainAxisSpacing: screenBasedPixelWidth * 20),
                        itemCount: studentPortalOptions.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Padding(
                            padding:
                                EdgeInsets.all(screenBasedPixelWidth * 15.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff04294f)),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(screenBasedPixelWidth * 20)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: screenBasedPixelWidth * 20)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenBasedPixelWidth * 20.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                customDialogBox(
                                  onIsDialogShowing: (bool value) {
                                    isDialogShowing = value;
                                  },
                                  isDialogShowing: isDialogShowing,
                                  dialogChildren: Column(
                                    children: List.generate(
                                      studentPortalOptions[index]
                                              ["internalOptionsMapList"]
                                          .length,
                                      (i) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            minimumSize: MaterialStateProperty
                                                .all<Size?>(
                                              Size.fromHeight(
                                                  screenBasedPixelHeight * 56),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    const Color(0xff04294f)),
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.only(
                                                    left:
                                                        screenBasedPixelWidth *
                                                            20,
                                                    right:
                                                        screenBasedPixelWidth *
                                                            20)),
                                            textStyle: MaterialStateProperty
                                                .all(TextStyle(
                                                    fontSize:
                                                        screenBasedPixelWidth *
                                                            20)),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        screenBasedPixelWidth *
                                                            0.0),
                                              ),
                                            ),
                                          ),
                                          onPressed: studentPortalOptions[index]
                                                  ["internalOptionsMapList"][i]
                                              ["action"],
                                          child: Text(
                                            studentPortalOptions[index]
                                                    ["internalOptionsMapList"]
                                                [i]["name"],
                                            style: TextStyle(
                                                fontSize:
                                                    screenBasedPixelWidth * 18),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  context: context,
                                  dialogTitle: Text(
                                    studentPortalOptions[index]["name"],
                                    style: GoogleFonts.lato(
                                      // color: Colors.white,
                                      // textStyle: Theme.of(context).textTheme.headline1,
                                      fontSize: screenBasedPixelWidth * 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  barrierDismissible: true,
                                  screenBasedPixelHeight:
                                      screenBasedPixelHeight,
                                  screenBasedPixelWidth: screenBasedPixelWidth,
                                );
                              },
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      studentPortalOptions[index]["icon"],
                                      size: screenBasedPixelWidth * 24,
                                    ),
                                    SizedBox(
                                      height: screenBasedPixelWidth * 10,
                                    ),
                                    Text(
                                      studentPortalOptions[index]["name"],
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        // textStyle: Theme.of(context).textTheme.headline1,
                                        fontSize: screenBasedPixelWidth * 20,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                      ),
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
