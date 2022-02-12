import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mini_vtop/coreFunctions/choose_correct_initial_appbar.dart';
import 'package:mini_vtop/coreFunctions/manage_user_session.dart';
import 'package:mini_vtop/sharedPreferences/app_theme_shared_preferences.dart';
import 'package:mini_vtop/ui/AppTheme/app_theme_data.dart';
import 'package:mini_vtop/ui/student_profile_all_view.dart';
import 'package:mini_vtop/ui/time_table.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'basicFunctions/dismiss_keyboard.dart';
import 'basicFunctions/print_wrapped.dart';
import 'basicFunctions/proccessing_dialog.dart';
import 'basicFunctions/widget_size_limiter.dart';
import 'browser/models/browser_model.dart';
import 'browser/models/webview_model.dart';
import 'coreFunctions/auto_captcha.dart';
import 'coreFunctions/call_time_table.dart';
import 'coreFunctions/choose_correct_drawer.dart';
import 'coreFunctions/choose_correct_initial_body.dart';
import 'coreFunctions/forHeadlessInAppWebView/headless_web_view.dart';
import 'coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';
import 'coreFunctions/sign_out.dart';
import 'navigation/page_routes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
late final dynamic webArchiveDir;

late final dynamic tabViewerBottomOffset1;
late final dynamic tabViewerBottomOffset2;
late final dynamic tabViewerBottomOffset3;

const tabViewerTopOffset1 = 0.0;
const tabViewerTopOffset2 = 10.0;
const tabViewerTopOffset3 = 20.0;

const tabViewerTopScaleTopOffset = 250.0;
const tabViewerTopScaleBottomOffset = 230.0;

class TestClass {
  static void callback(String id, DownloadTaskStatus status, int progress) {}
}
// ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int? retrieveSavedThemeModeIndex = await retrieveSavedThemeMode();
  final ThemeMode savedThemeMode = retrieveSavedThemeModeIndex == 0
      ? ThemeMode.system
      : retrieveSavedThemeModeIndex == 1
          ? ThemeMode.light
          : ThemeMode.dark;
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
  webArchiveDir = (await getApplicationSupportDirectory()).path;

  if (Platform.isIOS) {
    tabViewerBottomOffset1 = 130.0;
    tabViewerBottomOffset2 = 140.0;
    tabViewerBottomOffset3 = 150.0;
  } else {
    tabViewerBottomOffset1 = 110.0;
    tabViewerBottomOffset2 = 120.0;
    tabViewerBottomOffset3 = 130.0;
  }

  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
    FlutterDownloader.registerCallback(TestClass.callback);
  } else if (Platform.isWindows) {
// iOS-specific code
  }

  // ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑

  runApp(
    // ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel!.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(WebViewModel()),
        ),
      ],
      // ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑
      child: MyApp(
        savedThemeMode: savedThemeMode,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  final ThemeMode? savedThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode? themeMode = widget.savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        title: 'Mini VTOP',
        // darkTheme: darkTheme,
        // theme: theme,
        // themeMode: ThemeMode.system,
        themeMode: themeMode,
        theme: ThemeClass.lightTheme,
        darkTheme: ThemeClass.darkTheme,
        // darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Home(
          themeMode: themeMode,
          onThemeMode: (ThemeMode value) {
            setState(() {
              themeMode = value;
              saveThemeMode(value == ThemeMode.system
                  ? 0
                  : value == ThemeMode.light
                      ? 1
                      : 2);
            });
          },

          // child: Home(
          //   savedThemeMode: savedThemeMode ?? firstRunAfterInstallThemeMode,
          // ),
        ),
        routes: {
          PageRoutes.studentProfileAllView: (context) => StudentProfileAllView(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as StudentProfileAllViewArguments,
              ),
          PageRoutes.timeTable: (context) => TimeTable(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as TimeTableArguments,
              ),
        },
      ),
    );
  }
}

class Home extends StatefulWidget with PreferredSizeWidget {
  const Home({Key? key, this.themeMode, this.onThemeMode}) : super(key: key);

  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeMode;

  @override
  _HomeState createState() => _HomeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool? darkModeOn;
  String? theme;

  themeCalc() async {
    if (widget.themeMode == ThemeMode.light) {
      setState(() {
        theme = 'Light';
      });
    } else if (widget.themeMode == ThemeMode.dark) {
      setState(() {
        theme = 'Dark';
      });
    } else if (widget.themeMode == ThemeMode.system) {
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

  String vtopConnectionStatusType = "Initiated";

  String vtopConnectionStatusErrorType = "None";

  String vtopLoginErrorType = "None";

  late double screenBasedPixelWidth;

  late double screenBasedPixelHeight;

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

  String semesterSubId = "BL20212210";

  bool isDialogShowing = false;

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

  Future<void> _retrieveSemesterSubId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubId')) {
      return;
    }

    setState(() {
      semesterSubId = prefs.getString('semesterSubId')!;
    });
  }

  Future<String> _justRetrieveSemesterSubId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubId')) {
      return "BL20212210";
    }

    return prefs.getString('semesterSubId')!;
  }

  Future<void> _saveSessionDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionDateTime', sessionDateTime.toString());
  }

  Future<void> _saveSemesterSubId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('semesterSubId', semesterSubId.toString());
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

  late Timer timer;
  late Brightness brightness;

  void checkInternetConnection() async {
    if (!await InternetConnectionChecker().hasConnection &&
        vtopConnectionStatusType != "Connected") {
      debugPrint(
          "InternetConnectionChecker plugin detected no internet access");
      setState(() {
        currentStatus = "launchLoadingScreen";
        vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
        vtopConnectionStatusType = "Error";
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
    _retrieveSemesterSubId();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          // url: Uri.parse("")),
          url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
      initialOptions: options,
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        if (kDebugMode) {
          print(challenge);
        }
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null &&
            (sslError.iosError != null || sslError.androidError != null)) {
          if (Platform.isIOS && sslError.iosError == IOSSslError.UNSPECIFIED) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onDownloadStart: (controller, url) async {
        String path = url.path;
        String fileName = path.substring(path.lastIndexOf('/') + 1);
        if (Platform.isAndroid) {
          final taskId = await FlutterDownloader.enqueue(
            url: url.toString(),
            fileName: fileName,
            savedDir: (await getTemporaryDirectory()).path,
            showNotification: true,
            openFileFromNotification: true,
            saveInPublicStorage: true,
          );
        } else if (Platform.isWindows) {
// iOS-specific code
        }
      },
      onWebViewCreated: (controller) async {
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        checkInternetConnection();
        Future.delayed(const Duration(seconds: 5), () async {
          if (vtopConnectionStatusType == "Initiated") {
            setState(() {
              vtopConnectionStatusType = "Connecting";
            });
          }
        });
        // vtopConnectionStatusType = "Initiated";
        timer = Timer.periodic(const Duration(seconds: 20), (Timer t) {
          if (currentStatus == "launchLoadingScreen" &&
              vtopConnectionStatusErrorType == "None") {
            debugPrint(
                "restarting headlessInAppWebView as webview is taking too long");

            if (processingSomething == true) {
              Navigator.of(context).pop();
              setState(() {
                processingSomething = false;
              });
            }

            runHeadlessInAppWebView(
              headlessWebView: headlessWebView,
              onCurrentFullUrl: (String value) {
                currentFullUrl = value;
              },
            );
          }
        });

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
                vtopConnectionStatusType = "Connected";
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
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              debugPrint(
                  "You are logged out due to inactivity for more than 15 minutes");
              debugPrint(
                  "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
              performSignOut(
                context: context,
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  setState(() {
                    currentFullUrl = value;
                  });
                },
                onError: (String value) {
                  debugPrint("Updating Ui based on the error received");
                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }
                  if (value == "net::ERR_INTERNET_DISCONNECTED") {
                    debugPrint(
                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                    setState(() {
                      currentStatus = "launchLoadingScreen";
                      vtopConnectionStatusErrorType =
                          "net::ERR_INTERNET_DISCONNECTED";
                      vtopConnectionStatusType = "Error";
                    });
                  }
                },
              );

              WidgetsBinding.instance?.addPostFrameCallback((_) {
                processingSomething = true;
                customDialogBox(
                  isDialogShowing: isDialogShowing,
                  context: context,
                  onIsDialogShowing: (bool value) {
                    setState(() {
                      isDialogShowing = value;
                    });
                  },
                  dialogTitle: Text(
                    'You logged out',
                    style: TextStyle(
                      fontSize: widgetSizeProvider(
                          fixedSize: 24,
                          sizeDecidingVariable: screenBasedPixelWidth),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  dialogChildren: Column(
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
                        style: TextStyle(
                          fontSize: widgetSizeProvider(
                              fixedSize: 20,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                  screenBasedPixelHeight: screenBasedPixelHeight,
                  screenBasedPixelWidth: screenBasedPixelWidth,
                  onProcessingSomething: (bool value) {
                    setState(() {
                      processingSomething = value;
                    });
                  },
                ).then((_) => isDialogShowing = false);
              });
            } else if (ajaxRequest.status != 200) {
              debugPrint(
                  "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

              if (processingSomething == true) {
                Navigator.of(context).pop();
                setState(() {
                  processingSomething = false;
                });
              }

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
            await controller
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              if (ajaxRequest.status == 200) {
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
                } else if (value.contains(
                    "You are logged out due to inactivity for more than 15 minutes")) {
                  printWrapped(
                      "Most probably session expired due to inactivity");
                  //Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
                  vtopLoginErrorType = "Session expired due to inactivity";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else {
                  printWrapped(
                      "Can't find why something got wrong enable print ajaxRequest for doLogin and see the logs");
                  printWrapped("ajaxRequest: $ajaxRequest");
                  vtopLoginErrorType = "Something is wrong! Please retry.";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                }
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                debugPrint(
                    "You are logged out due to inactivity for more than 15 minutes");
                debugPrint(
                    "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
                performSignOut(
                  context: context,
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                  onError: (String value) {
                    debugPrint("Updating Ui based on the error received");
                    if (processingSomething == true) {
                      Navigator.of(context).pop();
                      setState(() {
                        processingSomething = false;
                      });
                    }
                    if (value == "net::ERR_INTERNET_DISCONNECTED") {
                      debugPrint(
                          "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                      setState(() {
                        currentStatus = "launchLoadingScreen";
                        vtopConnectionStatusErrorType =
                            "net::ERR_INTERNET_DISCONNECTED";
                        vtopConnectionStatusType = "Error";
                      });
                    }
                  },
                );

                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  processingSomething = true;
                  customDialogBox(
                    isDialogShowing: isDialogShowing,
                    context: context,
                    onIsDialogShowing: (bool value) {
                      setState(() {
                        isDialogShowing = value;
                      });
                    },
                    dialogTitle: Text(
                      'You logged out',
                      style: TextStyle(
                        fontSize: widgetSizeProvider(
                            fixedSize: 24,
                            sizeDecidingVariable: screenBasedPixelWidth),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    dialogChildren: Column(
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
                          style: TextStyle(
                            fontSize: widgetSizeProvider(
                                fixedSize: 20,
                                sizeDecidingVariable: screenBasedPixelWidth),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                    screenBasedPixelHeight: screenBasedPixelHeight,
                    screenBasedPixelWidth: screenBasedPixelWidth,
                    onProcessingSomething: (bool value) {
                      setState(() {
                        processingSomething = value;
                      });
                    },
                  ).then((_) => isDialogShowing = false);
                });
              } else if (ajaxRequest.status != 200) {
                debugPrint(
                    "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

                if (processingSomething == true) {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }

                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
              }
            });
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            // printWrapped("ajaxRequest: ${ajaxRequest}");
            // print("ajaxRequest: ${ajaxRequest}");
            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.status == 200) {
                if (ajaxRequest.responseText!.contains(
                        "You are logged out due to inactivity for more than 15 minutes") ||
                    ajaxRequest.responseText!
                        .contains("You have been successfully logged out")) {
                  debugPrint(
                      "You are logged out due to inactivity for more than 15 minutes");
                  debugPrint(
                      "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
                  performSignOut(
                    context: context,
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                    onError: (String value) {
                      debugPrint("Updating Ui based on the error received");
                      if (processingSomething == true) {
                        Navigator.of(context).pop();
                        setState(() {
                          processingSomething = false;
                        });
                      }
                      if (value == "net::ERR_INTERNET_DISCONNECTED") {
                        debugPrint(
                            "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                        setState(() {
                          currentStatus = "launchLoadingScreen";
                          vtopConnectionStatusErrorType =
                              "net::ERR_INTERNET_DISCONNECTED";
                          vtopConnectionStatusType = "Error";
                        });
                      }
                    },
                  );

                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    processingSomething = true;
                    customDialogBox(
                      isDialogShowing: isDialogShowing,
                      context: context,
                      onIsDialogShowing: (bool value) {
                        setState(() {
                          isDialogShowing = value;
                        });
                      },
                      dialogTitle: Text(
                        'You logged out',
                        style: TextStyle(
                          fontSize: widgetSizeProvider(
                              fixedSize: 24,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      dialogChildren: Column(
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
                            style: TextStyle(
                              fontSize: widgetSizeProvider(
                                  fixedSize: 20,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      barrierDismissible: false,
                      screenBasedPixelHeight: screenBasedPixelHeight,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                    ).then((_) => isDialogShowing = false);
                  });
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
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                debugPrint(
                    "You are logged out due to inactivity for more than 15 minutes");
                debugPrint(
                    "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
                performSignOut(
                  context: context,
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                  onError: (String value) {
                    debugPrint("Updating Ui based on the error received");
                    if (processingSomething == true) {
                      Navigator.of(context).pop();
                      setState(() {
                        processingSomething = false;
                      });
                    }
                    if (value == "net::ERR_INTERNET_DISCONNECTED") {
                      debugPrint(
                          "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                      setState(() {
                        currentStatus = "launchLoadingScreen";
                        vtopConnectionStatusErrorType =
                            "net::ERR_INTERNET_DISCONNECTED";
                        vtopConnectionStatusType = "Error";
                      });
                    }
                  },
                );

                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  processingSomething = true;
                  customDialogBox(
                    isDialogShowing: isDialogShowing,
                    context: context,
                    onIsDialogShowing: (bool value) {
                      setState(() {
                        isDialogShowing = value;
                      });
                    },
                    dialogTitle: Text(
                      'You logged out',
                      style: TextStyle(
                        fontSize: widgetSizeProvider(
                            fixedSize: 24,
                            sizeDecidingVariable: screenBasedPixelWidth),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    dialogChildren: Column(
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
                          style: TextStyle(
                            fontSize: widgetSizeProvider(
                                fixedSize: 20,
                                sizeDecidingVariable: screenBasedPixelWidth),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                    screenBasedPixelHeight: screenBasedPixelHeight,
                    screenBasedPixelWidth: screenBasedPixelWidth,
                    onProcessingSomething: (bool value) {
                      setState(() {
                        processingSomething = value;
                      });
                    },
                  ).then((_) => isDialogShowing = false);
                });
              } else if (ajaxRequest.status != 200) {
                debugPrint(
                    "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

                if (processingSomething == true) {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }

                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
              }
            }
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            // var document = parse('${ajaxRequest.responseText}');
            if (requestType == "New login") {
              _credentialsFound();
              setState(() {
                vtopConnectionStatusType = "Connected";
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
                vtopConnectionStatusType = "Connected";
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
            } else if (requestType == "Fake") {
              debugPrint(
                  "Fake request executed by calling callStudentProfileAllView() with onRequestType as Fake");
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

                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }

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
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      screenBasedPixelHeight: screenBasedPixelHeight,
                    ),
                  ).whenComplete(() {
                    setState(() {
                      loggedUserStatus = "studentProfileAllView";
                    });
                  });
                });
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                debugPrint(
                    "You are logged out due to inactivity for more than 15 minutes");
                debugPrint(
                    "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
                performSignOut(
                  context: context,
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                  onError: (String value) {
                    debugPrint("Updating Ui based on the error received");
                    if (processingSomething == true) {
                      Navigator.of(context).pop();
                      setState(() {
                        processingSomething = false;
                      });
                    }
                    if (value == "net::ERR_INTERNET_DISCONNECTED") {
                      debugPrint(
                          "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                      setState(() {
                        currentStatus = "launchLoadingScreen";
                        vtopConnectionStatusErrorType =
                            "net::ERR_INTERNET_DISCONNECTED";
                        vtopConnectionStatusType = "Error";
                      });
                    }
                  },
                );

                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  processingSomething = true;
                  customDialogBox(
                    isDialogShowing: isDialogShowing,
                    context: context,
                    onIsDialogShowing: (bool value) {
                      setState(() {
                        isDialogShowing = value;
                      });
                    },
                    dialogTitle: Text(
                      'You logged out',
                      style: TextStyle(
                        fontSize: widgetSizeProvider(
                            fixedSize: 24,
                            sizeDecidingVariable: screenBasedPixelWidth),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    dialogChildren: Column(
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
                          style: TextStyle(
                            fontSize: widgetSizeProvider(
                                fixedSize: 20,
                                sizeDecidingVariable: screenBasedPixelWidth),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                    screenBasedPixelHeight: screenBasedPixelHeight,
                    screenBasedPixelWidth: screenBasedPixelWidth,
                    onProcessingSomething: (bool value) {
                      setState(() {
                        processingSomething = value;
                      });
                    },
                  ).then((_) => isDialogShowing = false);
                });
              } else if (ajaxRequest.status != 200) {
                debugPrint(
                    "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

                if (processingSomething == true) {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }

                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
              }
            }
            // print(document.outerHtml);
            //document.querySelectorAll('table')[1];
            // print("ajaxRequest: ${ajaxRequest}");
          } else if (ajaxRequest.url.toString() == "processLogout") {
            // print("ajaxRequest: ${ajaxRequest}");
            if (processingSomething == true) {
              Navigator.of(context).pop();
              setState(() {
                processingSomething = false;
              });
            }
            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                setState(() {
                  currentStatus = "launchLoadingScreen";
                  vtopConnectionStatusType = "Initiated";
                });

                debugPrint(
                    "called inactivityResponse or successfullyLogout Action https://vtop.vitbhopal.ac.in/vtop for processLogout");
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
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
                    if (requestType == "Real") {
                      debugPrint("new semesterSubId: $semesterSubId");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubId()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "Update") {
                      debugPrint("new semesterSubId: $semesterSubId");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "$semesterSubId";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    }
                  }
                });
              }
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              debugPrint(
                  "You are logged out due to inactivity for more than 15 minutes");
              debugPrint(
                  "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
              performSignOut(
                context: context,
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  setState(() {
                    currentFullUrl = value;
                  });
                },
                onError: (String value) {
                  debugPrint("Updating Ui based on the error received");
                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }
                  if (value == "net::ERR_INTERNET_DISCONNECTED") {
                    debugPrint(
                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                    setState(() {
                      currentStatus = "launchLoadingScreen";
                      vtopConnectionStatusErrorType =
                          "net::ERR_INTERNET_DISCONNECTED";
                      vtopConnectionStatusType = "Error";
                    });
                  }
                },
              );

              WidgetsBinding.instance?.addPostFrameCallback((_) {
                processingSomething = true;
                customDialogBox(
                  isDialogShowing: isDialogShowing,
                  context: context,
                  onIsDialogShowing: (bool value) {
                    setState(() {
                      isDialogShowing = value;
                    });
                  },
                  dialogTitle: Text(
                    'You logged out',
                    style: TextStyle(
                      fontSize: widgetSizeProvider(
                          fixedSize: 24,
                          sizeDecidingVariable: screenBasedPixelWidth),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  dialogChildren: Column(
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
                        style: TextStyle(
                          fontSize: widgetSizeProvider(
                              fixedSize: 20,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                  screenBasedPixelHeight: screenBasedPixelHeight,
                  screenBasedPixelWidth: screenBasedPixelWidth,
                  onProcessingSomething: (bool value) {
                    setState(() {
                      processingSomething = value;
                    });
                  },
                ).then((_) => isDialogShowing = false);
              });
            } else if (ajaxRequest.status != 200) {
              debugPrint(
                  "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

              if (processingSomething == true) {
                Navigator.of(context).pop();
                setState(() {
                  processingSomething = false;
                });
              }

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
                  .then((value) async {
                var document = parse('$value');
                setState(() {
                  timeTableDocument = document;
                });
                if (processingSomething == true) {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }
                if (requestType == "Real") {
                  // semesterSubId = await _justRetrieveSemesterSubId();
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
                      screenBasedPixelHeight: screenBasedPixelHeight,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      semesterSubId: await _justRetrieveSemesterSubId(),
                      onSemesterSubIdChange: (String value) {
                        setState(() {
                          semesterSubId = value;
                          requestType = "Update";
                          callTimeTable(
                            context: context,
                            headlessWebView: headlessWebView,
                            onCurrentFullUrl: (String value) {
                              currentFullUrl = value;
                            },
                            processingSomething: true,
                            onProcessingSomething: (bool value) {
                              processingSomething = true;
                            },
                            onError: (String value) {
                              debugPrint(
                                  "Updating Ui based on the error received");
                              if (processingSomething == true) {
                                Navigator.of(context).pop();
                                setState(() {
                                  processingSomething = false;
                                });
                              }
                              if (value == "net::ERR_INTERNET_DISCONNECTED") {
                                debugPrint(
                                    "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                setState(() {
                                  currentStatus = "launchLoadingScreen";
                                  vtopConnectionStatusErrorType =
                                      "net::ERR_INTERNET_DISCONNECTED";
                                  vtopConnectionStatusType = "Error";
                                });
                              }
                            },
                          );
                        });
                      },
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                    ),
                  ).whenComplete(() {
                    setState(() {
                      loggedUserStatus = "timeTable";
                    });
                  });
                } else if (requestType == "Update") {
                  debugPrint("Table Update Ran");
                  Navigator.pushReplacementNamed(
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
                      screenBasedPixelHeight: screenBasedPixelHeight,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      semesterSubId: semesterSubId,
                      onSemesterSubIdChange: (String value) {
                        setState(() {
                          semesterSubId = value;
                          requestType = "Update";
                          callTimeTable(
                            context: context,
                            headlessWebView: headlessWebView,
                            onCurrentFullUrl: (String value) {
                              currentFullUrl = value;
                            },
                            processingSomething: true,
                            onProcessingSomething: (bool value) {
                              processingSomething = true;
                            },
                            onError: (String value) {
                              debugPrint(
                                  "Updating Ui based on the error received");
                              if (processingSomething == true) {
                                Navigator.of(context).pop();
                                setState(() {
                                  processingSomething = false;
                                });
                              }
                              if (value == "net::ERR_INTERNET_DISCONNECTED") {
                                debugPrint(
                                    "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                setState(() {
                                  currentStatus = "launchLoadingScreen";
                                  vtopConnectionStatusErrorType =
                                      "net::ERR_INTERNET_DISCONNECTED";
                                  vtopConnectionStatusType = "Error";
                                });
                              }
                            },
                          );
                        });
                      },
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                    ),
                  ).whenComplete(() {
                    setState(() {
                      loggedUserStatus = "timeTable";
                    });
                  });
                }
              });
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              debugPrint(
                  "You are logged out due to inactivity for more than 15 minutes");
              debugPrint(
                  "called inactivityResponse or successfullyLoggedOut Action for doLogin ajaxRequest");
              performSignOut(
                context: context,
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  setState(() {
                    currentFullUrl = value;
                  });
                },
                onError: (String value) {
                  debugPrint("Updating Ui based on the error received");
                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }
                  if (value == "net::ERR_INTERNET_DISCONNECTED") {
                    debugPrint(
                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                    setState(() {
                      currentStatus = "launchLoadingScreen";
                      vtopConnectionStatusErrorType =
                          "net::ERR_INTERNET_DISCONNECTED";
                      vtopConnectionStatusType = "Error";
                    });
                  }
                },
              );

              WidgetsBinding.instance?.addPostFrameCallback((_) {
                processingSomething = true;
                customDialogBox(
                  isDialogShowing: isDialogShowing,
                  context: context,
                  onIsDialogShowing: (bool value) {
                    setState(() {
                      isDialogShowing = value;
                    });
                  },
                  dialogTitle: Text(
                    'You logged out',
                    style: TextStyle(
                      fontSize: widgetSizeProvider(
                          fixedSize: 24,
                          sizeDecidingVariable: screenBasedPixelWidth),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  dialogChildren: Column(
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
                        style: TextStyle(
                          fontSize: widgetSizeProvider(
                              fixedSize: 20,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                  screenBasedPixelHeight: screenBasedPixelHeight,
                  screenBasedPixelWidth: screenBasedPixelWidth,
                  onProcessingSomething: (bool value) {
                    setState(() {
                      processingSomething = value;
                    });
                  },
                ).then((_) => isDialogShowing = false);
              });
            } else if (ajaxRequest.status != 200) {
              debugPrint(
                  "restarting headlessInAppWebView as studentsRecord/StudentProfileAllView ajaxRequest.status != 200");

              if (processingSomething == true) {
                Navigator.of(context).pop();
                setState(() {
                  processingSomething = false;
                });
              }

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
        setState(() {
          currentFullUrl = url?.toString() ?? '';
        });
      },
      onLoadError: (InAppWebViewController controller, Uri? url, int code,
          String message) async {
        debugPrint("error $url: $code, $message");
        if (await InternetConnectionChecker().hasConnection) {
          setState(() {
            vtopConnectionStatusType = "Error";
            vtopConnectionStatusErrorType = message;
          });
        } else {
          vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
          vtopConnectionStatusType = "Error";
        }

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

    runHeadlessInAppWebView(
        onCurrentFullUrl: (String value) {
          setState(() {
            currentFullUrl = value;
          });
        },
        headlessWebView: headlessWebView);

    // Future.delayed(const Duration(seconds: 4), () async {
    // setState(() {
    //   vtopConnectionStatusType = "Connecting";
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
    // Reassigning new values to brightness, darkModeOn,and themeCalc() on every setstate
    // so that they get accurate values if parent widgets update these value
    brightness = WidgetsBinding.instance!.window.platformBrightness;
    darkModeOn = (widget.themeMode == ThemeMode.system &&
            brightness == Brightness.dark) ||
        widget.themeMode == ThemeMode.dark;
    themeCalc();
    debugPrint('darkModeOn: $darkModeOn, theme: $theme');

    // currentStatus = "launchLoadingScreen";
    // currentStatus = "userLoggedIn";
    debugPrint("loggedUserStatus: $loggedUserStatus");
    debugPrint("currentStatus: $currentStatus");
    debugPrint("processingSomething: $processingSomething");

    screenBasedPixelWidth = MediaQuery.of(context).size.width * 0.0027625;
    screenBasedPixelHeight = MediaQuery.of(context).size.height * 0.00169;

    chooseCorrectBody(
      onBody: (Widget value) {
        body = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
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
      vtopConnectionStatusType: vtopConnectionStatusType,
      vtopConnectionStatusErrorType: vtopConnectionStatusErrorType,
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
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        setState(() {
          vtopConnectionStatusErrorType = "None";
          vtopConnectionStatusType = "Initiated";
          debugPrint(
              "restarting headlessInAppWebView manually as vtopConnectionStatusType has error");
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
      themeMode: widget.themeMode,
      onThemeMode: (ThemeMode value) {
        widget.onThemeMode?.call(value);
      },
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
    );

    chooseCorrectAppbar(
      onAppbar: (Widget value) {
        appbar = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
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
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          processingSomething = false;
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
    );

    chooseCorrectDrawer(
      onDrawer: (Widget? value) {
        drawer = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
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
      themeMode: widget.themeMode,
      onThemeMode: (ThemeMode value) {
        widget.onThemeMode?.call(value);
      },
      onRequestType: (String value) {
        setState(() {
          requestType = value;
        });
      },
      onTryAutoLoginStatus: (bool value) {
        _clearTryAutoLoginStatus();
        setState(() {
          tryAutoLoginStatus = value;
          _saveTryAutoLoginStatus();
        });
      },
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          processingSomething = false;
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
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
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(1.0, 0), end: const Offset(0, 0))
                    .animate(animation),
                child: child,
              );
            },
            child: body),
        drawer: Padding(
          padding: EdgeInsets.only(
            right: widgetSizeProvider(
                fixedSize: 80, sizeDecidingVariable: screenBasedPixelWidth),
          ),
          child: drawer,
        ),
      ),
    );
  }
}
