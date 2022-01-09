import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_vtop/basicFunctions/print_wrapped.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:ntp/ntp.dart';

import 'basicFunctions/proccessing_dialog.dart';

class StudentPortal extends StatefulWidget {
  const StudentPortal({
    Key? key,
    this.onShowStudentProfileAllView,
    this.loggedUserStatus,
    required this.arguments,
  }) : super(key: key);

  final String? loggedUserStatus;
  final ValueChanged<bool>? onShowStudentProfileAllView;
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
        "internalOptionsMapList": [
          {
            "name": "Profile",
            "action": () {
              // timer.cancel();
              // startTimeout();
              widget.onShowStudentProfileAllView?.call(true);
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

  @override
  Widget build(BuildContext context) {
    // print(widget.arguments.studentPortalDocument.outerHtml);
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                        fontSize: 17,
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          )
                        : Text(
                            "",
                            style: GoogleFonts.lato(
                              // color: Colors.white,
                              // textStyle: Theme.of(context).textTheme.headline1,
                              fontSize: 20,
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
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          timerText,
                          style: GoogleFonts.lato(
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
            GridView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2.5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: studentPortalOptions.length,
              itemBuilder: (BuildContext ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff04294f)),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20)),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 20)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      processingDialog(
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
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  tileColor: const Color(0xff04294f),
                                  textColor: Colors.white,
                                  onTap: studentPortalOptions[index]
                                      ["internalOptionsMapList"][i]["action"],
                                  // leading: FlutterLogo(size: 72.0),
                                  title: Text(studentPortalOptions[index]
                                      ["internalOptionsMapList"][i]["name"]),
                                  // subtitle: Text('Profile'),
                                  // trailing: Icon(Icons.more_vert),
                                  // isThreeLine: true,
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          barrierDismissible: true);
                      print("tapped");
                    },
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            studentPortalOptions[index]["name"],
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              // textStyle: Theme.of(context).textTheme.headline1,
                              fontSize: 20,
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
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     widget.onShowStudentProfileAllView?.call(true);
            //     // Navigator.pushNamed(
            //     //   context,
            //     //   PageRoutes.studentProfileAllView,
            //     //   arguments: StudentProfileAllViewArguments(
            //     //     currentStatus: null,
            //     //   ),
            //     // );
            //   },
            //   child: const Text("Profile"),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     debugPrint(widget.loggedUserStatus);
            //   },
            //   child: const Text("Print loggedUserStatus"),
            // ),
          ],
        ),
      ),
    );
  }
}

class StudentPortalArguments {
  var studentPortalDocument;
  var studentProfileAllViewDocument;
  String? studentName;
  HeadlessInAppWebView? headlessWebView;
  DateTime? sessionDateTime;

  StudentPortalArguments({
    required this.studentPortalDocument,
    required this.studentProfileAllViewDocument,
    required this.studentName,
    required this.headlessWebView,
    required this.sessionDateTime,
  });
}
