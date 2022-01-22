import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:ntp/ntp.dart';
import 'package:url_launcher/url_launcher.dart';

import 'basicFunctions/proccessing_dialog.dart';
import 'coreFunctions/forHeadlessInAppWebView/headless_web_view.dart';

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
    return SafeArea(
      child: Column(
        children: <Widget>[
          // TextField(
          //   decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
          //   controller: urlController,
          //   keyboardType: TextInputType.url,
          //   onSubmitted: (value) {
          //     var url = Uri.parse(value);
          //     if (url.scheme.isEmpty) {
          //       url = Uri.parse("https://www.google.com/search?q=" + value);
          //     }
          //     widget.arguments.headlessWebView?.webViewController
          //         .loadUrl(urlRequest: URLRequest(url: url));
          //   },
          // ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  // key: webViewKey,
                  initialUrlRequest: URLRequest(
                      url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop")),
                  initialOptions: options,
                  onWebViewCreated: (controller) {
                    // widget.arguments.headlessWebView?.webViewController =
                    //     controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunch(url)) {
                        // Launch the App
                        await launch(
                          url,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {},
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {}
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          // ButtonBar(
          //   alignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     ElevatedButton(
          //       child: Icon(Icons.arrow_back),
          //       onPressed: () {
          //         widget.arguments.headlessWebView?.webViewController.goBack();
          //       },
          //     ),
          //     ElevatedButton(
          //       child: Icon(Icons.arrow_forward),
          //       onPressed: () {
          //         widget.arguments.headlessWebView?.webViewController
          //             .goForward();
          //       },
          //     ),
          //     ElevatedButton(
          //       child: Icon(Icons.refresh),
          //       onPressed: () {
          //         widget.arguments.headlessWebView?.webViewController.reload();
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
    );
    //   SingleChildScrollView(
    //   controller: controller,
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Column(
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Column(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   "Hello,",
    //                   style: GoogleFonts.lato(
    //                     // color: Colors.white,
    //                     // textStyle: Theme.of(context).textTheme.headline1,
    //                     fontSize: 17,
    //                     fontWeight: FontWeight.w700,
    //                     fontStyle: FontStyle.normal,
    //                   ),
    //                 ),
    //                 widget.arguments.studentName != null
    //                     ? Text(
    //                         "${toBeginningOfSentenceCase(widget.arguments.studentName?.split(' ')[0].trim().toLowerCase())} 👋",
    //                         style: GoogleFonts.lato(
    //                           // color: Colors.white,
    //                           // textStyle: Theme.of(context).textTheme.headline1,
    //                           fontSize: 20,
    //                           fontWeight: FontWeight.w700,
    //                           fontStyle: FontStyle.normal,
    //                         ),
    //                       )
    //                     : Text(
    //                         "",
    //                         style: GoogleFonts.lato(
    //                           // color: Colors.white,
    //                           // textStyle: Theme.of(context).textTheme.headline1,
    //                           fontSize: 20,
    //                           fontWeight: FontWeight.w700,
    //                           fontStyle: FontStyle.normal,
    //                         ),
    //                       ),
    //               ],
    //             ),
    //             Container(
    //               decoration: BoxDecoration(
    //                 color: const Color(0xff04294f),
    //                 //border: Border.all(color: Colors.blue, width: 10),
    //                 borderRadius: BorderRadius.circular(20.0),
    //               ),
    //               child: Padding(
    //                 padding: const EdgeInsets.all(5.0),
    //                 child: Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: <Widget>[
    //                     const Icon(
    //                       Icons.timer,
    //                       color: Colors.white,
    //                     ),
    //                     const SizedBox(
    //                       width: 5,
    //                     ),
    //                     Text(
    //                       timerText,
    //                       style: GoogleFonts.lato(
    //                         color: Colors.white,
    //                         fontWeight: FontWeight.w700,
    //                         fontStyle: FontStyle.normal,
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //         const SizedBox(
    //           height: 15,
    //         ),
    //         GridView.builder(
    //           controller: controller,
    //           scrollDirection: Axis.vertical,
    //           shrinkWrap: true,
    //           gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //               maxCrossAxisExtent: 200,
    //               childAspectRatio: 3 / 2.5,
    //               crossAxisSpacing: 20,
    //               mainAxisSpacing: 20),
    //           itemCount: studentPortalOptions.length,
    //           itemBuilder: (BuildContext ctx, index) {
    //             return Padding(
    //               padding: const EdgeInsets.all(15.0),
    //               child: ElevatedButton(
    //                 style: ButtonStyle(
    //                   backgroundColor:
    //                       MaterialStateProperty.all(const Color(0xff04294f)),
    //                   padding:
    //                       MaterialStateProperty.all(const EdgeInsets.all(20)),
    //                   textStyle: MaterialStateProperty.all(
    //                       const TextStyle(fontSize: 20)),
    //                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                     RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(20.0),
    //                     ),
    //                   ),
    //                 ),
    //                 onPressed: () {
    //                   processingDialog(
    //                       onIsDialogShowing: (bool value) {
    //                         isDialogShowing = value;
    //                       },
    //                       isDialogShowing: isDialogShowing,
    //                       dialogChildren: Column(
    //                         children: List.generate(
    //                           studentPortalOptions[index]
    //                                   ["internalOptionsMapList"]
    //                               .length,
    //                           (i) => Padding(
    //                             padding: const EdgeInsets.only(bottom: 8.0),
    //                             child: ListTile(
    //                               tileColor: const Color(0xff04294f),
    //                               textColor: Colors.white,
    //                               onTap: studentPortalOptions[index]
    //                                   ["internalOptionsMapList"][i]["action"],
    //                               // leading: FlutterLogo(size: 72.0),
    //                               title: Text(studentPortalOptions[index]
    //                                   ["internalOptionsMapList"][i]["name"]),
    //                               // subtitle: Text('Profile'),
    //                               // trailing: const CircularProgressIndicator(),
    //                               // isThreeLine: true,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                       context: context,
    //                       dialogTitle: Text(
    //                         studentPortalOptions[index]["name"],
    //                         style: GoogleFonts.lato(
    //                           // color: Colors.white,
    //                           // textStyle: Theme.of(context).textTheme.headline1,
    //                           fontSize: 20,
    //                           fontWeight: FontWeight.w700,
    //                           fontStyle: FontStyle.normal,
    //                         ),
    //                       ),
    //                       barrierDismissible: true);
    //                 },
    //                 child: FittedBox(
    //                   fit: BoxFit.contain,
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Icon(studentPortalOptions[index]["icon"]),
    //                       const SizedBox(
    //                         height: 10,
    //                       ),
    //                       Text(
    //                         studentPortalOptions[index]["name"],
    //                         style: GoogleFonts.lato(
    //                           color: Colors.white,
    //                           // textStyle: Theme.of(context).textTheme.headline1,
    //                           fontSize: 20,
    //                           fontWeight: FontWeight.w700,
    //                           fontStyle: FontStyle.normal,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             );
    //           },
    //         ),
    //         // ElevatedButton(
    //         //   onPressed: () {
    //         //     widget.onShowStudentProfileAllView?.call(true);
    //         //     // Navigator.pushNamed(
    //         //     //   context,
    //         //     //   PageRoutes.studentProfileAllView,
    //         //     //   arguments: StudentProfileAllViewArguments(
    //         //     //     currentStatus: null,
    //         //     //   ),
    //         //     // );
    //         //   },
    //         //   child: const Text("Profile"),
    //         // ),
    //         // ElevatedButton(
    //         //   onPressed: () {
    //         //     debugPrint(widget.loggedUserStatus);
    //         //   },
    //         //   child: const Text("Print loggedUserStatus"),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

class FullWebViewArguments {
  dom.Document? studentPortalDocument;
  dom.Document? studentProfileAllViewDocument;
  String? studentName;
  HeadlessInAppWebView? headlessWebView;
  DateTime? sessionDateTime;
  bool processingSomething;

  FullWebViewArguments({
    required this.studentPortalDocument,
    required this.studentProfileAllViewDocument,
    required this.studentName,
    required this.headlessWebView,
    required this.sessionDateTime,
    required this.processingSomething,
  });
}
