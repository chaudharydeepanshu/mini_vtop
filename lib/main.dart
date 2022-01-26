import 'dart:async';
import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:mini_vtop/coreFunctions/choose_correct_initial_appbar.dart';
import 'package:mini_vtop/coreFunctions/manage_user_session.dart';
import 'package:mini_vtop/ui/student_profile_all_view.dart';
import 'package:mini_vtop/ui/time_table.dart';
import 'package:ntp/ntp.dart';
import 'basicFunctions/dismiss_keyboard.dart';
import 'basicFunctions/print_wrapped.dart';
import 'coreFunctions/auto_captcha.dart';
import 'coreFunctions/choose_correct_drawer.dart';
import 'coreFunctions/choose_correct_initial_body.dart';
import 'coreFunctions/forHeadlessInAppWebView/headless_web_view.dart';
import 'coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';
import 'navigation/page_routes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  final AdaptiveThemeMode? savedThemeMode;
  final AdaptiveThemeMode firstRunAfterInstallThemeMode =
      AdaptiveThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        primarySwatch: Colors.blue,
        platform: TargetPlatform.android,
        scaffoldBackgroundColor: Colors.white,
        primaryTextTheme: const TextTheme(
          headline6: TextStyle(color: Colors.black),
        ),
        //iconTheme: IconThemeData(color: Colors.black),
        cardTheme: CardTheme(
          color: Colors.grey.shade400,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade300,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.grey.shade300,
        ),
      ),
      dark: ThemeData.dark().copyWith(
        // iconTheme: IconThemeData(color: Colors.black),
        // scaffoldBackgroundColor: Color(0xFF121212),
        // canvasColor: Color(0xFF121212),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.white),
          fillColor: MaterialStateProperty.all(Colors.lightBlueAccent),
        ),
        cardTheme: const CardTheme(
          color: Color(0xff424242),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF222222),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Color(0xFF222222),
        ),
      ),
      initial: savedThemeMode ?? firstRunAfterInstallThemeMode,
      builder: (theme, darkTheme) => DismissKeyboard(
        child: MaterialApp(
          title: 'Mini VTOP',
          darkTheme: darkTheme,
          theme: theme,
          themeMode: ThemeMode.system,
          // darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: Home(
            savedThemeMode: savedThemeMode ?? firstRunAfterInstallThemeMode,
          ),
          routes: {
            PageRoutes.studentProfileAllView: (context) =>
                StudentProfileAllView(
                  arguments: ModalRoute.of(context)!.settings.arguments
                      as StudentProfileAllViewArguments?,
                ),
            PageRoutes.timeTable: (context) => TimeTable(
                  arguments: ModalRoute.of(context)!.settings.arguments
                      as TimeTableArguments?,
                ),
          },
        ),
      ),
    );
  }
}

class Home extends StatefulWidget with PreferredSizeWidget {
  const Home({Key? key, this.savedThemeMode}) : super(key: key);

  final AdaptiveThemeMode? savedThemeMode;

  @override
  _HomeState createState() => _HomeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool? darkModeOn;
  String? theme;

  themeCalc() async {
    if (AdaptiveTheme.of(context).mode.isLight) {
      setState(() {
        theme = 'Light';
      });
    } else if (AdaptiveTheme.of(context).mode.isDark) {
      setState(() {
        theme = 'Dark';
      });
    } else if (AdaptiveTheme.of(context).mode.isSystem) {
      setState(() {
        theme = 'System';
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    var brightness = WidgetsBinding.instance!.window.platformBrightness;
    debugPrint(brightness.name);
    // > should print light / dark when you switch
    themeCalc();
    setState(() {
      darkModeOn = (theme == 'Dark') ||
          (brightness == Brightness.dark && theme == 'System');
    });
    super.didChangePlatformBrightness();
  }

  InAppWebViewController? webViewController;

  HeadlessInAppWebView? headlessWebView;
  String currentFullUrl = "";
  String serializedDocument = "";
  Image? image;

  String userEnteredUname = "";
  String userEnteredPasswd = "";
  String autoCaptcha = '';

  String? loggedUserStatus;

  String? currentStatus = "launchLoadingScreen";

  bool processingSomething = false;
  bool refreshingCaptcha = true;

  DateTime? sessionDateTime;

  String? vtopStatusType;

  String vtopLoginErrorType = "None";

  late Widget body;

  late Widget appbar;

  late Widget? drawer;

  int noOfHomePageBuilds = 0;

  int noOfLoginAjaxRequests = 0;

  String requestType = "Empty";

  String? studentName;

  bool credentialsFound = false;

  dom.Document? studentPortalDocument;

  dom.Document? studentProfileAllViewDocument;

  dom.Document? timeTableDocument;

  bool tryAutoLoginStatus = false;

  getStudentName({required String forXAction}) async {
    await headlessWebView?.webViewController.evaluateJavascript(source: '''
                               document.getElementById("STA002").click();
                                ''');
    requestType = forXAction;
  }

  Future<void> _credentialsFound() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userEnteredPasswd') &&
        !prefs.containsKey('userEnteredUname')) {
      credentialsFound = false;
      return;
    }
    setState(() {
      credentialsFound = true;
    });
  }

  Future<void> _retrieveUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('userEnteredPasswd') &&
        !prefs.containsKey('userEnteredUname')) {
      return;
    }

    setState(() {
      userEnteredUname = prefs.getString('userEnteredUname')!;
      userEnteredPasswd = prefs.getString('userEnteredPasswd')!;
    });
  }

  Future<void> _retrieveSessionDateTime() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('sessionDateTime')) {
      return;
    }

    setState(() {
      sessionDateTime = DateTime.parse(prefs.getString('sessionDateTime')!);
    });
  }

  Future<void> _retrieveTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('tryAutoLoginStatus')) {
      return;
    }

    setState(() {
      tryAutoLoginStatus = prefs.getBool('tryAutoLoginStatus')!;
    });
  }

  Future<void> _saveSessionDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionDateTime', sessionDateTime.toString());
  }

  Future<void> _saveTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('tryAutoLoginStatus', tryAutoLoginStatus);
  }

  Future<void> _saveUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userEnteredUname', userEnteredUname);
    prefs.setString('userEnteredPasswd', userEnteredPasswd);
  }

  Future<void> _clearUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the name is saved before or not
    if (!prefs.containsKey('userEnteredUname') &&
        !prefs.containsKey('userEnteredPasswd')) {
      return;
    }

    await prefs.remove('userEnteredUname');
    await prefs.remove('userEnteredPasswd');
    setState(() {
      userEnteredUname = '';
      userEnteredPasswd = "";

      credentialsFound = false;
    });
  }

  Future<void> _clearTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the name is saved before or not
    if (!prefs.containsKey('tryAutoLoginStatus')) {
      return;
    }

    await prefs.remove('tryAutoLoginStatus');
    setState(() {
      tryAutoLoginStatus = false;
    });
  }

  bool isStopped = false;

  @override
  void initState() {
    super.initState();

    AdaptiveTheme.of(context).modeChangeNotifier.addListener(() {
      WidgetsBinding.instance!.addObserver(this); //most important
      var brightness = WidgetsBinding.instance!.window.platformBrightness;
      debugPrint(brightness.name);
      // > should print Brightness.light / Brightness.dark when you switch
      themeCalc();
      setState(() {
        darkModeOn = (theme == 'Dark') ||
            (brightness == Brightness.dark && theme == 'System');
      });
    });
    WidgetsBinding.instance!.addObserver(this); //most important
    var brightness = WidgetsBinding.instance!.window.platformBrightness;
    debugPrint(brightness.name);
    // > should print Brightness.light / Brightness.dark when you switch
    themeCalc();
    setState(() {
      darkModeOn = (theme == 'Dark') ||
          (brightness == Brightness.dark && theme == 'System');
    });

    _retrieveUnamePasswd();
    _credentialsFound();
    _retrieveSessionDateTime();
    _retrieveTryAutoLoginStatus();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
      initialOptions: options,
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        if (kDebugMode) {
          print(challenge);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onWebViewCreated: (controller) async {
        Future.delayed(const Duration(seconds: 5), () async {
          if (vtopStatusType == null) {
            setState(() {
              vtopStatusType = "Connecting";
            });
          }
        });
        vtopStatusType = null;

        // const snackBar = SnackBar(
        //   content: Text('HeadlessInAppWebView created!'),
        //   duration: Duration(seconds: 1),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      androidShouldInterceptRequest: (controller, webResourceRequest) {
        debugPrint('Console Message: $webResourceRequest');
        return null!;
      },
      onConsoleMessage: (controller, consoleMessage) {
        // final snackBar = SnackBar(
        //   content: Text('Console Message: ${consoleMessage.message}'),
        //   duration: const Duration(seconds: 1),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);

        if (kDebugMode) {
          print('Console Message: ${consoleMessage.message}');
        }

        if (consoleMessage.message.contains("solvedCaptcha:")) {
          setState(() {
            autoCaptcha = consoleMessage.message.split(' ').sublist(1)[0];
          });
        }
      },
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// print("ajaxRequest: ${ajaxRequest}");
// ajaxRequest.headers?.setRequestHeader("Cookie", authState.setCookie);
        return ajaxRequest;
      },
      onAjaxReadyStateChange:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// print("ajaxRequest: ${ajaxRequest}");
// print(ajaxRequest.status);
        return AjaxRequestAction.PROCEED;
      },
      onAjaxProgress:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// printWrapped("ajaxRequest: ${ajaxRequest}");
// await controller
//     .evaluateJavascript(
//         source:
//             "new XMLSerializer().serializeToString(document);")
//     .then((value) {
//   printWrapped("Element: $value");
// });
        if (ajaxRequest.event?.type == AjaxRequestEventType.LOADEND) {
          // printWrapped("ajaxRequest: ${ajaxRequest}");
          if (ajaxRequest.url.toString() == "vtopLogin") {
            // if (ajaxRequest.status == 200) {
            //   noOfLoginAjaxRequests++;
            // } else {
            //   noOfHomePageBuilds--;
            // }
            debugPrint(noOfHomePageBuilds.toString());
            debugPrint(noOfLoginAjaxRequests.toString());
            debugPrint(ajaxRequest.status.toString());
            // if (noOfLoginAjaxRequests == noOfHomePageBuilds) {
            if (ajaxRequest.status == 200) {
              // await controller.evaluateJavascript(
              //     source:
              //         '''document.querySelector('img[alt="vtopCaptcha"]').src;''').then(
              //     (value) {
              var document = parse('${ajaxRequest.responseText}');
              String? imageSrc = document
                  .querySelector('img[alt="vtopCaptcha"]')
                  ?.attributes["src"];
              // print(imageSrc!);
              String uri = imageSrc!;
              String base64String = uri.split(', ').last;
              Uint8List _bytes = base64.decode(base64String);
              // printWrapped("vtopCaptcha _bytes: $base64String");
              // Map<String, dynamic> vtopLoginAjaxRequestMap = {
              //   "webViewController": controller,
              //   "image": Image.memory(_bytes),
              //   "currentStatus": "runHeadlessInAppWebView",
              // };
              // onVtopLoginAjaxRequest.call(vtopLoginAjaxRequestMap);

              autoFillCaptcha(
                  context: context,
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  });

              setState(() {
                vtopStatusType = "Connected";
              });

              Future.delayed(const Duration(milliseconds: 2480), () async {
                setState(() {
                  // webViewController = controller;
                  image = Image.memory(_bytes);
                  currentStatus = "signInScreen";
                  processingSomething = false;
                  refreshingCaptcha = false;
                });
              });
            } else {
              debugPrint(
                  "restarting headlessInAppWebView as vtopLogin ajaxRequest.status != 200");
              runHeadlessInAppWebView(
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  currentFullUrl = value;
                },
              );
            }
            // print("vtopCaptcha _bytes: ${_bytes}");
            // });
            // });
            // }
          } else if (ajaxRequest.url.toString() == "doLogin") {
            // print("ajaxRequest: ${ajaxRequest}");
            if (ajaxRequest.status == 200) {
              await controller
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) async {
                if (value.contains(userEnteredUname + "(STUDENT)")) {
                  printWrapped("User $userEnteredUname successfully signed in");
                  // onCurrentStatus.call("userLoggedIn");
                  // Navigator.of(context)
                  //     .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
                  _saveUnamePasswd();
                  sessionDateTime = await NTP.now();
                  _saveSessionDateTime();
                  debugPrint(
                      'NTP DateTime: $sessionDateTime, DateTime: ${DateTime.now().toString()}');
                  declareManageUserSessionConstants(
                      onCurrentFullUrl: (String value) {
                        currentFullUrl = value;
                      },
                      headlessWebView: headlessWebView,
                      context: context);
                  manageUserSession(
                    context: context,
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                  getStudentName(forXAction: 'New login');

                  setState(() {
                    // currentStatus = "userLoggedIn";
                    // loggedUserStatus = "studentPortalScreen";
                    // processingSomething = false;
                    studentPortalDocument =
                        parse('${ajaxRequest.responseText}');
                  });

                  // manageUserSession(
                  //     context: context,
                  //     headlessWebView: headlessWebView,
                  //     onCurrentFullUrl: (String value) {
                  //       setState(() {
                  //         currentFullUrl = value;
                  //       });
                  //     });
                } else if (value.contains("User Id Not available")) {
                  printWrapped("User Id Not available");
                  //User Id Not available WHEN ENTERING WRONG USER ID
                  // processingSomething = false; // we put this inside the onloadstop // the processing is already validated but we still want to show the dialog until user sees the updated login page
                  vtopLoginErrorType = "User Id Not available";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else if (value.contains("Invalid User Id / Password")) {
                  printWrapped("Most probably invalid password");
                  //Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
                  vtopLoginErrorType = "Most probably invalid password";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else if (value.contains("Invalid Captcha")) {
                  printWrapped("Invalid Captcha");
                  //Invalid Captcha WHEN ENTERING WRONG CAPTCHA
                  vtopLoginErrorType = "Invalid Captcha";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                  // print(
                  //     "called Action https://vtop.vitbhopal.ac.in/vtop for Invalid Captcha");
                  // await controller.evaluateJavascript(
                  //     source:
                  //         '''window.location.href = "https://vtop.vitbhopal.ac.in/vtop";''');
                } else {
                  printWrapped(
                      "Can't find why something got wrong enable print ajaxRequest for doLogin and see the logs");
                  // printWrapped("ajaxRequest: ${ajaxRequest}");
                }
              });
            } else {
              debugPrint(
                  "restarting headlessInAppWebView as doLogin ajaxRequest.status != 200");
              runHeadlessInAppWebView(
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  currentFullUrl = value;
                },
              );
            }
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            // printWrapped("ajaxRequest: ${ajaxRequest}");
            // print("ajaxRequest: ${ajaxRequest}");
            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.responseText!.contains(
                  "You are logged out due to inactivity for more than 15 minutes")) {
                // onRestartHeadlessInAppWebView.call(true);
                // runHeadlessInAppWebView(
                //   headlessWebView: headlessWebView,
                //   onCurrentFullUrl: (String value) {
                //     setState(() {
                //       currentFullUrl = value;
                //     });
                //   },
                // );
                debugPrint(
                    "called inactivityResponse Action https://vtop.vitbhopal.ac.in/vtop for doRefreshCaptcha");
                await controller.evaluateJavascript(
                    source:
                        '''window.location.href = "https://vtop.vitbhopal.ac.in/vtop";''');
              } else {
                // await controller.evaluateJavascript(source: '''
                //   document.querySelector('img[alt="vtopCaptcha"]').src;
                //   ''').then((value) {
                var document = parse('${ajaxRequest.responseText}');
                String? imageSrc = document
                    .querySelector('img[alt="vtopCaptcha"]')
                    ?.attributes["src"];
                String uri = imageSrc!;
                String base64String = uri.split(', ').last;
                Uint8List _bytes = base64.decode(base64String);
                // printWrapped("vtopCaptcha _bytes: $base64String");
                // onImage.call(Image.memory(_bytes));

                autoFillCaptcha(
                    context: context,
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    });

                setState(() {
                  refreshingCaptcha = false;
                  image = Image.memory(_bytes);
                  // loaded(uri, image!);
                });
                // print("vtopCaptcha _bytes: ${_bytes}");
                // });
              }
            }
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            // var document = parse('${ajaxRequest.responseText}');
            if (requestType == "New login") {
              _credentialsFound();
              setState(() {
                vtopStatusType = "Connected";
              });

              await headlessWebView?.webViewController
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) {
                var document = parse('$value');
                setState(() {
                  studentProfileAllViewDocument = document;
                  studentName = studentProfileAllViewDocument
                      ?.getElementById('exTab1')
                      ?.children[1]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[2]
                      .children[1]
                      .innerHtml;
                  currentStatus = "userLoggedIn";
                  loggedUserStatus = "studentPortalScreen";
                  Navigator.of(context)
                      .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
                  processingSomething = false;
                });
              });
            } else if (requestType == "Logged in") {
              _credentialsFound();
              declareManageUserSessionConstants(
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                  headlessWebView: headlessWebView,
                  context: context);
              manageUserSession(
                context: context,
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  setState(() {
                    currentFullUrl = value;
                  });
                },
              );
              setState(() {
                vtopStatusType = "Connected";
              });

              Future.delayed(const Duration(milliseconds: 2480), () async {
                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) {
                  var document = parse('$value');
                  setState(() {
                    studentProfileAllViewDocument = document;
                    studentName = studentProfileAllViewDocument
                        ?.getElementById('exTab1')
                        ?.children[1]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[2]
                        .children[1]
                        .innerHtml;
                    currentStatus = "userLoggedIn";
                    loggedUserStatus = "studentPortalScreen";
                  });
                });
              });
            } else if (requestType == "Real") {
              if (ajaxRequest.status == 200) {
                requestType = "Empty";

                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) {
                  var document = parse('$value');
                  setState(() {
                    studentProfileAllViewDocument = document;
                  });

                  setState(() {
                    processingSomething = false;
                  });

                  Navigator.of(context).pop();

                  Navigator.pushNamed(
                    context,
                    PageRoutes.studentProfileAllView,
                    arguments: StudentProfileAllViewArguments(
                      currentStatus: currentStatus,
                      onShowStudentProfileAllViewDispose: (bool value) {
                        debugPrint("studentProfileAllView disposed");
                        WidgetsBinding.instance
                            ?.addPostFrameCallback((_) => setState(() {
                                  loggedUserStatus = "studentPortalScreen";
                                }));
                      },
                      studentProfileAllViewDocument:
                          studentProfileAllViewDocument,
                    ),
                  ).whenComplete(() {
                    setState(() {
                      loggedUserStatus = "studentProfileAllView";
                    });
                  });
                });
              } else {
                debugPrint(
                    "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

                setState(() {
                  processingSomething = false;
                });

                Navigator.of(context).pop();

                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
                // Navigator.of(context).pop();
                // debugPrint("dialogBox popped");
              }
            }
            // print(document.outerHtml);
            //document.querySelectorAll('table')[1];
            // print("ajaxRequest: ${ajaxRequest}");
          } else if (ajaxRequest.url.toString() == "processLogout") {
            _clearTryAutoLoginStatus();
            // print("ajaxRequest: ${ajaxRequest}");
            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.responseText!.contains(
                  "You are logged out due to inactivity for more than 15 minutes")) {
                // onRestartHeadlessInAppWebView.call(true);
                currentStatus = "launchLoadingScreen";
                // runHeadlessInAppWebView(
                //   headlessWebView: headlessWebView,
                //   onCurrentFullUrl: (String value) {
                //     setState(() {
                //       currentFullUrl = value;
                //     });
                //   },
                // );
                debugPrint(
                    "called inactivityResponse Action https://vtop.vitbhopal.ac.in/vtop for processLogout");
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
              } else if (ajaxRequest.responseText!
                  .contains("You have been successfully logged out")) {
                debugPrint("You have been successfully logged out");
                //--------------Temporary-----------------//
                currentStatus = "launchLoadingScreen";
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                );
                debugPrint(
                    "called inactivityResponse Action https://vtop.vitbhopal.ac.in/vtop for processLogout");
                // await controller.evaluateJavascript(
                //     source:
                //         '''window.location.href = "https://vtop.vitbhopal.ac.in/vtop";''');
                //--------------Temporary-----------------//
              }
            }
          } else if (ajaxRequest.url.toString() ==
              "academics/common/StudentTimeTable") {
            // debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              bool waitStatus = true;
              while (waitStatus == true) {
                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) async {
                  if (value.contains("Please wait")) {
                    // waitStatus = true;
                  } else {
                    waitStatus = false;
                    await headlessWebView?.webViewController
                        .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "BL20212210";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                  }
                });
              }
            } else {
              setState(() {
                processingSomething = false;
              });

              Navigator.of(context).pop();

              debugPrint(
                  "restarting headlessInAppWebView as academics/common/StudentTimeTable ajaxRequest.status != 200");
              runHeadlessInAppWebView(
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  currentFullUrl = value;
                },
              );
            }
          } else if (ajaxRequest.url.toString() == "processViewTimeTable") {
            // debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              await headlessWebView?.webViewController
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) {
                var document = parse('$value');
                setState(() {
                  timeTableDocument = document;
                });
                setState(() {
                  processingSomething = false;
                });

                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  PageRoutes.timeTable,
                  arguments: TimeTableArguments(
                    currentStatus: currentStatus,
                    onTimeTableDocumentDispose: (bool value) {
                      debugPrint("timeTable disposed");
                      WidgetsBinding.instance
                          ?.addPostFrameCallback((_) => setState(() {
                                loggedUserStatus = "studentPortalScreen";
                              }));
                    },
                    timeTableDocument: timeTableDocument,
                  ),
                ).whenComplete(() {
                  setState(() {
                    loggedUserStatus = "timeTable";
                  });
                });
              });
            } else {
              setState(() {
                processingSomething = false;
              });

              Navigator.of(context).pop();

              debugPrint(
                  "restarting headlessInAppWebView as processViewTimeTable ajaxRequest.status != 200");
              runHeadlessInAppWebView(
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  currentFullUrl = value;
                },
              );
            }
          } else {
            printWrapped("ajaxRequest: $ajaxRequest");
            //"You are logged out due to inactivity for more than 15 minutes"
            // print("response: 232");
            // await headlessWebView?.dispose();
            // await headlessWebView?.run();
          }
        }
// print(ajaxRequest.status);
        return AjaxRequestAction.PROCEED;
      },
      onLoadStart: (controller, url) async {
        noOfHomePageBuilds = 0;
        noOfLoginAjaxRequests = 0;

        debugPrint("noOfHomePageBuilds onLoadStart: $noOfHomePageBuilds");
        // final snackBar = SnackBar(
        //   content: Text('onLoadStart $url'),
        //   duration: const Duration(seconds: 1),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // onCurrentFullUrl.call(url?.toString() ?? '');
        setState(() {
          currentFullUrl = url?.toString() ?? '';
        });
      },
      onLoadStop: (controller, url) async {
        // Future.delayed(const Duration(seconds: 2), () async {
        // print(await headlessWebView?.webViewController.getProgress());

        if (url.toString() ==
                "https://vtop.vitbhopal.ac.in/vtop/initialProcess" &&
            await headlessWebView?.webViewController.getProgress() == 100) {
          await headlessWebView?.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then(
            (value) async {
              var document = parse('$value');
              String initialHtml =
                  '<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>';
              String? inactivityResponse = document
                  .getElementById('closedHTML')
                  ?.children[0]
                  .children[0]
                  .children[0]
                  .children[1]
                  .children[0]
                  .children[0]
                  .children[0]
                  .children[0]
                  .innerHtml;

              if (inactivityResponse ==
                  "You are logged out due to inactivity for more than 15 minutes") {
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                );
                // await headlessWebView?.webViewController.evaluateJavascript(
                //     source:
                //         '''window.location.href = "https://vtop.vitbhopal.ac.in/vtop";''');
              } else if (value != initialHtml &&
                  document.getElementsByTagName('button').isNotEmpty) {
                // printWrapped("value: $value");
                String? loginButtonText =
                    document.getElementsByTagName('button')[0].text;
                debugPrint("loginButtonText: $loginButtonText");

                if (loginButtonText == 'Login to V-TOP') {
                  noOfHomePageBuilds++;

                  debugPrint(
                      "noOfHomePageBuilds: ${noOfHomePageBuilds.toString()}");
                  if (noOfHomePageBuilds == 1) {
                    declareAutoFillCaptchaConstants(
                        onCurrentFullUrl: (String value) {
                          currentFullUrl = value;
                        },
                        headlessWebView: headlessWebView,
                        context: context);

                    await headlessWebView?.webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('button')[0].click();");
                  }
                }
              }
            },
          );
        } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/" &&
            await headlessWebView?.webViewController.getProgress() == 100) {
          await headlessWebView?.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            var document = parse('$value');
            String? studentId = document
                .getElementById('page-holder')
                ?.children[0]
                .children[0]
                .children[0]
                .children[1]
                .children[0]
                .children[0]
                .children[0]
                .children[0]
                .children[1]
                .innerHtml;
            if (studentId != null) {
              if (studentId.contains("(STUDENT)")) {
                getStudentName(forXAction: 'Logged in');

                studentPortalDocument = document;
                // print(url.toString());
              }
            }
          });
        }
        // });
        // await controller
        //     .evaluateJavascript(
        //         source: "new XMLSerializer().serializeToString(document);")
        //     .then((response) async {
        //   var document = parse('$response');
        //
        //   String? inactivityResponse = document
        //       .getElementById('closedHTML')
        //       ?.children[0]
        //       .children[0]
        //       .children[0]
        //       .children[1]
        //       .children[0]
        //       .children[0]
        //       .children[0]
        //       .children[0]
        //       .innerHtml;
        //
        //   // print(response);
        //   if (inactivityResponse ==
        //       "You are logged out due to inactivity for more than 15 minutes") {
        //     debugPrint("response: 232");
        //     // onRestartHeadlessInAppWebView.call(true);
        //
        //     print(
        //         "called inactivityResponse Action https://vtop.vitbhopal.ac.in/vtop for onLoadStop");
        //     await controller.evaluateJavascript(
        //         source:
        //             '''window.location.href = "https://vtop.vitbhopal.ac.in/vtop";''');
        //     // runHeadlessInAppWebView(
        //     //   headlessWebView: headlessWebView,
        //     //   onCurrentFullUrl: (String value) {
        //     //     setState(() {
        //     //       currentFullUrl = value;
        //     //     });
        //     //   },
        //     // );
        //   } else if (response.contains("(STUDENT)")) {
        //     // onCurrentStatus.call("userLoggedIn");
        //     currentStatus = "userLoggedIn";
        //     loggedUserStatus = "studentPortalScreen";
        //   } else {
        //     // log(url.toString());
        //     // printWrapped(response);
        //     if (url.toString() ==
        //         "https://vtop.vitbhopal.ac.in/vtop/initialProcess") {
        //       printWrapped(await headlessWebView?.webViewController
        //           .evaluateJavascript(
        //               source:
        //                   "new XMLSerializer().serializeToString(document);"));
        //       if (response.contains("openPage()")) {
        //         debugPrint("response: 200");
        //         await headlessWebView?.webViewController.evaluateJavascript(
        //             source:
        //                 '''ajaxCall("vtopLogin",null,"page_outline");''').then(
        //             (value) async {
        //           // await webViewController
        //           //     ?.evaluateJavascript(
        //           //         source:
        //           //             "new XMLSerializer().serializeToString(document);")
        //           //     .then((response) {
        //           //   printWrapped(response.toString());
        //           // });
        //         });
        //       } else {
        //         debugPrint("response: Empty response");
        //         //print("response: $response");
        //         //empty response <html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>
        //       }
        //     } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/") {
        //       debugPrint("response: 302");
        //     }
        //   }
        // });
        // final snackBar = SnackBar(
        //   content: Text('onLoadStop $url'),
        //   duration: const Duration(seconds: 1),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // onCurrentFullUrl.call(url?.toString() ?? '');
        setState(() {
          currentFullUrl = url?.toString() ?? '';
        });
        // log("status: ${url!.}");
      },
      onLoadError: (InAppWebViewController controller, Uri? url, int code,
          String message) async {
        debugPrint("error $url: $code, $message");
        setState(() {
          vtopStatusType = message;
        });

//         var tRexHtml = await controller.getTRexRunnerHtml();
//         var tRexCss = await controller.getTRexRunnerCss();
//
//         controller.loadData(data: """
// <html>
//   <head>
//     <meta charset="utf-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0,maximum-scale=1.0, user-scalable=no">
//     <style>$tRexCss</style>
//   </head>
//   <body>
//     $tRexHtml
//     <p>
//       URL $url failed to load.
//     </p>
//     <p>
//       Error: $code, $message
//     </p>
//   </body>
// </html>
//                   """);
      },
      onLoadHttpError: (InAppWebViewController controller, Uri? url,
          int statusCode, String description) async {
        debugPrint("HTTP error $url: $statusCode, $description");
      },
    );
    //     headlessInAppWebView(
    //   context: context,
    //   userEnteredUname: userEnteredUname,
    //   headlessWebView: headlessWebView,
    //   onCurrentFullUrl: (String value) {
    //     setState(() {
    //       currentFullUrl = value;
    //     });
    //   },
    //   onWebViewController: (InAppWebViewController value) {
    //     setState(() {
    //       webViewController = value;
    //     });
    //   },
    //   onImage: (Image value) {
    //     setState(() {
    //       image = value;
    //     });
    //   },
    //   onCurrentStatus: (String value) {
    //     setState(() {
    //       currentStatus = value;
    //     });
    //   },
    //   onVtopLoginAjaxRequest: (Map<String, dynamic> value) {
    //     setState(() {
    //       currentStatus = value["currentStatus"];
    //       webViewController = value["webViewController"];
    //       image = value["image"];
    //     });
    //   },
    //   onRestartHeadlessInAppWebView: (bool value) {
    //     runHeadlessInAppWebView(
    //         onCurrentFullUrl: (String value) {
    //           setState(() {
    //             currentFullUrl = value;
    //           });
    //         },
    //         headlessWebView: headlessWebView);
    //   },
    // );

    runHeadlessInAppWebView(
        onCurrentFullUrl: (String value) {
          setState(() {
            currentFullUrl = value;
          });
        },
        headlessWebView: headlessWebView);

    // Future.delayed(const Duration(seconds: 4), () async {
    // setState(() {
    //   vtopStatusType = "Connecting";
    // });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    headlessWebView?.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '$darkModeOn, $theme, ${AdaptiveTheme.of(context).mode.isLight}');
    // currentStatus = "launchLoadingScreen";
    // currentStatus = "signInScreen";
    debugPrint("loggedUserStatus: $loggedUserStatus");
    debugPrint("currentStatus: $currentStatus");
    debugPrint("processingSomething: $processingSomething");

    chooseCorrectBody(
      onBody: (Widget value) {
        // setState(() {
        body = value;
        // });
      },
      tryAutoLoginStatus: tryAutoLoginStatus,
      sessionDateTime: sessionDateTime,
      autoCaptcha: autoCaptcha,
      credentialsFound: credentialsFound,
      studentProfileAllViewDocument: studentProfileAllViewDocument,
      studentPortalDocument: studentPortalDocument,
      vtopLoginErrorType: vtopLoginErrorType,
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          setState(() {
            refreshingCaptcha = value;
          });
        });
      },
      currentFullUrl: currentFullUrl,
      vtopStatusType: vtopStatusType,
      onVtopLoginErrorType: (String value) {
        setState(() {
          vtopLoginErrorType = value;
        });
      },
      onRequestType: (String value) {
        setState(() {
          requestType = "Real";
        });
      },
      studentName: studentName,
      onClearUnamePasswd: (bool value) {
        _clearUnamePasswd();
      },
      onRetryOnError: (bool value) {
        setState(() {
          vtopLoginErrorType = "None";
          debugPrint(
              "restarting headlessInAppWebView manually as vtopStatusType has error");
          runHeadlessInAppWebView(
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              currentFullUrl = value;
            },
          );
        });
      },
      onTryAutoLoginStatus: (bool value) {
        setState(() {
          tryAutoLoginStatus = value;
          _saveTryAutoLoginStatus();
        });
      },
    );

    chooseCorrectAppbar(
      onAppbar: (Widget value) {
        appbar = value;
      },
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          refreshingCaptcha = value;
        });
      },
      currentFullUrl: currentFullUrl,
      onCurrentStatus: (String value) {
        setState(() {
          currentStatus = value;
        });
      },
      scaffoldKey: _scaffoldKey,
    );

    chooseCorrectDrawer(
      onDrawer: (Widget? value) {
        drawer = value;
      },
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          refreshingCaptcha = value;
        });
      },
      currentFullUrl: currentFullUrl,
      onCurrentStatus: (String value) {
        setState(() {
          currentStatus = value;
        });
      },
      savedThemeMode: widget.savedThemeMode,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // statusBarColor:
        //     darkModeOn! ? Colors.black : Colors.white, //Colors.transparent,
        // statusBarIconBrightness:
        //     darkModeOn! ? Brightness.light : Brightness.dark,
        // statusBarBrightness: !kIsWeb && Platform.isAndroid && darkModeOn!
        //     ? Brightness.dark
        //     : Brightness.light,
        systemNavigationBarColor: darkModeOn! ? Colors.black : Colors.white,
        // systemNavigationBarDividerColor:
        //     darkModeOn! ? Colors.white10 : Colors.grey,
        systemNavigationBarIconBrightness:
            darkModeOn! ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: widget.preferredSize,
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(1.0, 0), end: const Offset(0, 0))
                      .animate(animation),
                  child: child,
                );
              },
              child: appbar),
        ),
        body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            // transitionBuilder: (child, animation) {
            //   const begin = Offset(0.0, 1.0);
            //   const end = Offset.zero;
            //   const curve = Curves.ease;
            //
            //   final tween = Tween(begin: begin, end: end);
            //   final curvedAnimation = CurvedAnimation(
            //     parent: animation,
            //     curve: curve,
            //   );
            //
            //   return SlideTransition(
            //     position: tween.animate(curvedAnimation),
            //     child: child,
            //   );
            // },
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(1.0, 0), end: const Offset(0, 0))
                    .animate(animation),
                child: child,
              );
            },
            child: body),
        drawer: drawer,
      ),
    );
  }
}
