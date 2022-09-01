import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:mini_vtop/state/connection_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';

import 'package:mini_vtop/utils/captcha_parser.dart';

class HeadlessWebView extends ChangeNotifier {
  HeadlessWebView(this.read);

  /// The `ref.read` function
  final Reader read;

  late HeadlessInAppWebView _headlessWebView;
  HeadlessInAppWebView get headlessWebView => _headlessWebView;

  late InAppWebViewGroupOptions _options;
  String _url = "";
  String get url => _url;

  int _noOfHomePageBuilds = 0;
  int _noOfAjaxRequests = 0;

  late final UserLoginState readUserLoginStateProviderValue =
      read(userLoginStateProvider);

  late final ConnectionStatusState readConnectionStatusStateProviderValue =
      read(connectionStatusStateProvider);

  late final VTOPActions readVTOPActionsProviderValue =
      read(vtopActionsProvider);

  @override
  void dispose() {
    headlessWebView.dispose();
    super.dispose();
  }

  settingSomeVarsBeforeWebViewRestart({
    LoginStatus? loginStatus,
    ConnectionStatus? connectionStatus,
    ForgotUserIDSearchStatus? forgotUserIDSearchStatus,
    ForgotUserIDValidateStatus? forgotUserIDValidateStatus,
  }) {
    readConnectionStatusStateProviderValue.update(
        newStatus: connectionStatus ?? ConnectionStatus.connecting);
    readUserLoginStateProviderValue.updateLoginStatus(
        loginStatus: loginStatus ?? LoginStatus.loggedOut);
    readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
        status:
            forgotUserIDSearchStatus ?? ForgotUserIDSearchStatus.notSearching);
    readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
        status: forgotUserIDValidateStatus ??
            ForgotUserIDValidateStatus.notProcessing);
    readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
  }

  resetControlVars() {
    _noOfHomePageBuilds = 0;
    _noOfAjaxRequests = 0;
  }

  init() async {
    _options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: true,
          useShouldInterceptFetchRequest: true,
        ),
        android: AndroidInAppWebViewOptions(
            // useHybridComposition: true,
            ),
        ios: IOSInAppWebViewOptions());

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        log('HeadlessInAppWebView created!');
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        log('Console Message: ${consoleMessage.message}');
      },
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return ajaxRequest;
      },
      onAjaxReadyStateChange:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return AjaxRequestAction.PROCEED;
      },
      onAjaxProgress:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        // print(ajaxRequest.url.toString());
        if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
            !(await controller.isLoading())) {
          if (ajaxRequest.url.toString() == "vtopLogin") {
            _vtopLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            _doRefreshCaptchaAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doLogin") {
            _vtopDoLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            _vtopStudentProfileAllViewAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "examinations/examGradeView/StudentGradeHistory") {
            _vtopStudentGradeHistoryAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "forgotUserID") {
            _vtopForgotUserIDAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "vtop/forgotUserID/validate") {
            _vtopForgotUserIDSearchAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "forgotLoginID") {
            _vtopForgotUserIDValidateAjaxRequest(ajaxRequest: ajaxRequest);
          } else {
            log("ajaxRequest.url:- ${ajaxRequest.url.toString()}");
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      shouldInterceptFetchRequest:
          (InAppWebViewController controller, FetchRequest fetchRequest) async {
        // log(fetchRequest);
        return fetchRequest;
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) async {
        log('onLoadStart $url');
        _url = url?.toString() ?? '';
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        log('onLoadStop $url');
        _url = url?.toString() ?? '';
        _onLoadStopAction(url: url);
      },
    );

    runHeadlessInAppWebView();
  }

  runHeadlessInAppWebView() async {
    resetControlVars();
    try {
      await headlessWebView.dispose();
    } on Exception catch (exception) {
      log(exception.toString());
    } catch (error) {
      log(error.toString());
    }
    await headlessWebView.run();
  }

  _vtopForgotUserIDValidateAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            if (value.contains("Login ID is :")) {
              log("User ID found.");
              readVTOPActionsProviderValue.updateForgotUserIDValidatePageStatus(
                  status: VTOPPageStatus.loaded);
              readUserLoginStateProviderValue.setUserIDFromForgotUserIDValidate(
                  forgotUserIDValidateDocument: document);
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateStatus.successful);
            } else if (value.contains("Invalid OTP. Please try again.")) {
              log("OTP is invalid.");
              readVTOPActionsProviderValue.updateForgotUserIDValidatePageStatus(
                  status: VTOPPageStatus.loaded);
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateStatus.invalidOTP);
            } else if (value.contains("You are not authorized")) {
              log("You are not authorized.");
              readVTOPActionsProviderValue.updateForgotUserIDValidatePageStatus(
                  status: VTOPPageStatus.unknownResponse);
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateStatus.unknownResponse);
            } else {
              log("Unknown response");
              log(value.toString());
              readVTOPActionsProviderValue.updateForgotUserIDValidatePageStatus(
                  status: VTOPPageStatus.unknownResponse);
              settingSomeVarsBeforeWebViewRestart(
                  forgotUserIDValidateStatus:
                      ForgotUserIDValidateStatus.unknownResponse);
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateForgotUserIDValidatePageStatus(
              status: VTOPPageStatus.sessionTimeout);
          settingSomeVarsBeforeWebViewRestart(
              forgotUserIDValidateStatus:
                  ForgotUserIDValidateStatus.sessionTimedOut);
          runHeadlessInAppWebView();
        });
  }

  _vtopForgotUserIDSearchAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            // log(value);

            if (value.contains(
                "New OTP can be generated 10 minutes after last successful OTP was triggred")) {
              log("OTP is sent to email successfully");
              readVTOPActionsProviderValue.updateForgotUserIDSearchPageStatus(
                  status: VTOPPageStatus.loaded);
              readUserLoginStateProviderValue.setOTPTriggerWait(
                  forgotUserIDSearchDocument: document);
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchStatus.otpTriggerWait);
            } else if (value.contains("OTP has been sent to your email")) {
              log("OTP is sent to email successfully");
              readVTOPActionsProviderValue.updateForgotUserIDSearchPageStatus(
                  status: VTOPPageStatus.loaded);
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchStatus.found);
            } else if (value.contains("Invalid User id")) {
              log("User id is invalid");
              readVTOPActionsProviderValue.updateForgotUserIDSearchPageStatus(
                  status: VTOPPageStatus.loaded);
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchStatus.notFound);
            } else {
              log("Unknown response");
              // log(value.toString());
              readVTOPActionsProviderValue.updateForgotUserIDSearchPageStatus(
                  status: VTOPPageStatus.unknownResponse);
              settingSomeVarsBeforeWebViewRestart(
                  forgotUserIDSearchStatus:
                      ForgotUserIDSearchStatus.unknownResponse);
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateForgotUserIDSearchPageStatus(
              status: VTOPPageStatus.sessionTimeout);
          settingSomeVarsBeforeWebViewRestart(
              forgotUserIDSearchStatus:
                  ForgotUserIDSearchStatus.sessionTimedOut);
          runHeadlessInAppWebView();
        });
  }

  _vtopForgotUserIDAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            // Document document = parse('$value');
            // log(value);
            if (value.contains("V-TOP Forgot UserID")) {
              log("Forgot UserID page loaded successfully");
              readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                  status: VTOPPageStatus.loaded);
            } else {
              log("Unknown error");
              readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                  status: VTOPPageStatus.unknownResponse);
              settingSomeVarsBeforeWebViewRestart();
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
              status: VTOPPageStatus.sessionTimeout);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _doRefreshCaptchaAjaxRequest({required AjaxRequest ajaxRequest}) {
    // printWrapped("ajaxRequest: ${ajaxRequest}");

    if (ajaxRequest.responseText != null) {
      if (ajaxRequest.status == 200) {
        // _noOfAjaxRequests++;
        // if (_noOfAjaxRequests == 1) {
        if (ajaxRequest.responseText!.contains(
                "You are logged out due to inactivity for more than 15 minutes") ||
            ajaxRequest.responseText!
                .contains("You have been successfully logged out")) {
          // inActivityOrStatusNot200Response(
          //     dialogTitle: 'Session ended',
          //     dialogChildrenText: 'Starting new session\nplease wait...');
        } else {
          var document = parse('${ajaxRequest.responseText}');
          String? imageSrc = document
              .querySelector('img[alt="vtopCaptcha"]')
              ?.attributes["src"];

          // log(imageSrc.toString());

          if (imageSrc != null) {
            String uri = imageSrc;
            String base64String = uri.split(', ').last;
            Uint8List bytes = base64.decode(base64String);

            readUserLoginStateProviderValue.updateCaptchaImage(bytes: bytes);

            String solvedCaptcha = getSolvedCaptcha(imageBytes: bytes);
            // print(solvedCaptcha);

            readUserLoginStateProviderValue.setCaptcha(captcha: solvedCaptcha);
          }

          // printWrapped("vtopCaptcha _bytes: $base64String");

          // autoFillCaptcha(
          //     context: context,
          //     headlessWebView: headlessWebView,
          //     onCurrentFullUrl: (String value) {
          //       setState(() {
          //         currentFullUrl = value;
          //       });
          //     });
          //
          // setState(() {
          //   refreshingCaptcha = false;
          //   image = Image.memory(_bytes);
          // });
          // }
        }
      } else if (ajaxRequest.responseText!.contains(
              "You are logged out due to inactivity for more than 15 minutes") ||
          ajaxRequest.responseText!
              .contains("You have been successfully logged out")) {
        // inActivityOrStatusNot200Response(
        //     dialogTitle: 'Session ended',
        //     dialogChildrenText: 'Starting new session\nplease wait...');
      } else if (ajaxRequest.status != 200) {
        print("ajaxRequest.status != 200");
        // inActivityOrStatusNot200Response(
        //     dialogTitle: 'Request Status != 200',
        //     dialogChildrenText: 'Starting new session\nplease wait...');
      }
    }
  }

  _vtopDoLoginAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            // Document document = parse('$value');

            if (value.contains(
                "${readUserLoginStateProviderValue.userID}(STUDENT)")) {
              log("User Id ${readUserLoginStateProviderValue.userID} logged in.");

              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginStatus.loggedIn);
            } else if (value.contains("User Id Not available")) {
              log("User Id ${readUserLoginStateProviderValue.userID} is not available.");

              settingSomeVarsBeforeWebViewRestart(
                  loginStatus: LoginStatus.wrongUserId);
              runHeadlessInAppWebView();
            } else if (value.contains("Invalid User Id / Password")) {
              log("Password ${readUserLoginStateProviderValue.password} is wrong.");

              settingSomeVarsBeforeWebViewRestart(
                  loginStatus: LoginStatus.wrongPassword);
              runHeadlessInAppWebView();
            } else if (value.contains("Invalid Captcha")) {
              log("Captcha is invalid.");

              settingSomeVarsBeforeWebViewRestart(
                  loginStatus: LoginStatus.wrongCaptcha);
              runHeadlessInAppWebView();
            } else if (value.contains(
                "Number of Maximum Fail Attempts Reached. use Forgot Password")) {
              log("Maximum Fail Attempts Reached. use Forgot Password");

              settingSomeVarsBeforeWebViewRestart(
                  loginStatus: LoginStatus.maxAttemptsError);
              runHeadlessInAppWebView();
            } else {
              log("Unknown error.");
              settingSomeVarsBeforeWebViewRestart(
                  loginStatus: LoginStatus.unknownResponse);
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          settingSomeVarsBeforeWebViewRestart(
              loginStatus: LoginStatus.sessionTimedOut);
          runHeadlessInAppWebView();
        });
  }

  _vtopStudentProfileAllViewAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    // _credentialsFound();
    // setState(() {
    //   vtopConnectionStatusType = "Connected";
    // });
    if (ajaxRequest.status == 200) {
      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) {
        Document document = parse('$value');

        read(vtopDataProvider)
            .setStudentProfile(studentProfileViewDocument: document);

        readVTOPActionsProviderValue.updateStudentProfilePageStatus(
            status: VTOPPageStatus.loaded);

        // setState(() {
        // studentName = document
        //     .getElementById('exTab1')
        //     ?.children[1]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[2]
        //     .children[1]
        //     .innerHtml;
        // if (vtopMode == "Mini VTOP") {
        //   currentStatus = "userLoggedIn";
        // } else if (vtopMode == "Full VTOP") {
        //   currentStatus = "originalVTOP";
        // }
        // loggedUserStatus = "studentPortalScreen";
        // Navigator.of(context)
        //     .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
        // processingSomething = false;
        // });
      });
    } else if (ajaxRequest.responseText!.contains(
            "You are logged out due to inactivity for more than 15 minutes") ||
        ajaxRequest.responseText!
            .contains("You have been successfully logged out")) {
      // inActivityOrStatusNot200Response(
      //     dialogTitle: 'Session ended',
      //     dialogChildrenText: 'Starting new session\nplease wait...');
    } else if (ajaxRequest.status != 200) {
      // inActivityOrStatusNot200Response(
      //     dialogTitle: 'Request Status != 200',
      //     dialogChildrenText: 'Starting new session\nplease wait...');
    }
  }

  _vtopStudentGradeHistoryAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    log("ajaxRequest.status: ${ajaxRequest.status}");
    if (ajaxRequest.status == 200) {
      /// ajaxRequest.status == 200 means a successful operation without any issues.
      await headlessWebView.webViewController
          .evaluateJavascript(
              source: "new XMLSerializer().serializeToString(document);")
          .then((value) {
        Document document = parse('$value');

        read(vtopDataProvider)
            .setStudentAcademics(studentGradeHistoryDocument: document);

        readVTOPActionsProviderValue.updateStudentGradeHistoryPageStatus(
            status: VTOPPageStatus.loaded);

        // setState(() {
        // studentName = document
        //     .getElementById('exTab1')
        //     ?.children[1]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[0]
        //     .children[2]
        //     .children[1]
        //     .innerHtml;
        // if (vtopMode == "Mini VTOP") {
        //   currentStatus = "userLoggedIn";
        // } else if (vtopMode == "Full VTOP") {
        //   currentStatus = "originalVTOP";
        // }
        // loggedUserStatus = "studentPortalScreen";
        // Navigator.of(context)
        //     .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
        // processingSomething = false;
        // });
      });
    } else if (ajaxRequest.status == 231) {
      /// ajaxRequest.status == 231 loads the homepage for VTOP. Homepage not login page.
      /// If user logged in then logged in homepage for VTOP is loaded.
    } else if (ajaxRequest.status == 232) {
      /// ajaxRequest.status == 232 means the Session Timed out.
      /// The ajaxRequest.responseText should contain "You are logged out due to inactivity for more than 15 minutes"
      /// ajaxRequest.responseText!.contains("You are logged out due to inactivity for more than 15 minutes") should be true.
    } else if (ajaxRequest.status == 233) {
      /// ajaxRequest.status == 233 executes same operation as ajaxRequest.status == 200.
      /// But is still an error request.
      /// Todo: Find the situation in which this status is encountered and then handle that suitably.
    } else {
      /// Any other ajaxRequest.status executes same operation as ajaxRequest.status == 200.
    }
  }

  _vtopLoginAjaxRequest({required AjaxRequest ajaxRequest}) {
    // printWrapped("ajaxRequest: ${ajaxRequest}");

    //
    // debugPrint("noOfHomePageBuilds: ${noOfHomePageBuilds.toString()}");
    // debugPrint("noOfLoginAjaxRequests: ${noOfLoginAjaxRequests.toString()}");
    debugPrint(
        "vtopLogin ajaxRequest.status: ${ajaxRequest.status.toString()}");

    if (ajaxRequest.status == 200) {
      // _noOfAjaxRequests++;
      // if (_noOfAjaxRequests == 1) {
      var document = parse('${ajaxRequest.responseText}');

      String? imageSrc =
          document.querySelector('img[alt="vtopCaptcha"]')?.attributes["src"];
      // print(imageSrc!);

      // Fake captcha bytes for testing
      // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(
      //     'https://lh3.googleusercontent.com/drive-viewer/AJc5JmQhDPCm2QQMMUp-RLiJzFHsRu_PDc4pS-b9ihSXbOyVwjYjP6Ee6tKgjplTriedJvVmojOSGQY=w1920-h904'))
      //     .load(
      //     'https://lh3.googleusercontent.com/drive-viewer/AJc5JmQhDPCm2QQMMUp-RLiJzFHsRu_PDc4pS-b9ihSXbOyVwjYjP6Ee6tKgjplTriedJvVmojOSGQY=w1920-h904'))
      //     .buffer
      //     .asUint8List();

      //Placeholder image link for captcha fail
      //"https://via.placeholder.com/180x45.png?text=Captcha+Failed"

      if (imageSrc != null) {
        String uri = imageSrc;
        String base64String = uri.split(', ').last;
        Uint8List bytes = base64.decode(base64String);

        readUserLoginStateProviderValue.updateCaptchaImage(bytes: bytes);

        String solvedCaptcha = getSolvedCaptcha(imageBytes: bytes);
        // print(solvedCaptcha);

        readUserLoginStateProviderValue.setCaptcha(captcha: solvedCaptcha);
        // }
      }
    } else if (ajaxRequest.responseText!.contains(
            "You are logged out due to inactivity for more than 15 minutes") ||
        ajaxRequest.responseText!
            .contains("You have been successfully logged out")) {
      // inActivityOrStatusNot200Response(
      //     dialogTitle: 'Session ended',
      //     dialogChildrenText: 'Starting new session\nplease wait...');
    } else if (ajaxRequest.status != 200) {
      // inActivityOrStatusNot200Response(
      //     dialogTitle: 'Request Status != 200',
      //     dialogChildrenText: 'Starting new session\nplease wait...');
    }
  }

  _onLoadStopAction({required Uri? url}) async {
    if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/initialProcess" &&
        await headlessWebView.webViewController.getProgress() == 100) {
      await headlessWebView.webViewController
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
                  "You are logged out due to inactivity for more than 15 minutes" ||
              inactivityResponse == "You have been successfully logged out") {
            runHeadlessInAppWebView();
          } else if (value != initialHtml &&
              document.getElementsByTagName('button').isNotEmpty) {
            // printWrapped("value: $value");
            String? loginButtonText =
                document.getElementsByTagName('button')[0].text;
            debugPrint("loginButtonText: $loginButtonText");

            if (loginButtonText == 'Login to V-TOP') {
              _noOfHomePageBuilds++;

              debugPrint(
                  "noOfHomePageBuilds: ${_noOfHomePageBuilds.toString()}");
              //As soon as noOfHomePageBuilds == 1 load login screen and neglect other homepage builds
              if (_noOfHomePageBuilds == 1) {
                readConnectionStatusStateProviderValue.update(
                    newStatus: ConnectionStatus.connected);

                // declareAutoFillCaptchaConstants(
                //     onCurrentFullUrl: (String value) {
                //       currentFullUrl = value;
                //     },
                //     headlessWebView: headlessWebView,
                //     context: context);

                await headlessWebView.webViewController.evaluateJavascript(
                    source:
                        "document.getElementsByTagName('button')[0].click();");
              }
            }
          }
        },
      );
    } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/" &&
        await headlessWebView.webViewController.getProgress() == 100) {
      print("Already logged in");
      await headlessWebView.webViewController
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
            readConnectionStatusStateProviderValue.update(
                newStatus: ConnectionStatus.connected);

            readUserLoginStateProviderValue.updateLoginStatus(
                loginStatus: LoginStatus.loggedIn);

            // openStudentProfileAllView(forXAction: 'Logged in');
            //
            // studentPortalDocument = document;
          }
        }
      });
    }
  }

  _ajaxRequestCommonHandler(
      {required AjaxRequest ajaxRequest,
      required Function() ajaxRequestStatus200Action,
      required Function() ajaxRequestStatus232Action}) async {
    if (ajaxRequest.status == 200) {
      /// ajaxRequest.status == 200 means a successful operation without any issues.

      log("ajaxRequest.status: 200 encountered");
      ajaxRequestStatus200Action();
    } else if (ajaxRequest.status == 231) {
      /// ajaxRequest.status == 231 loads the homepage for VTOP. Homepage not login page.
      /// If user logged in then logged in homepage for VTOP is loaded.

      log("ajaxRequest.status: 231 encountered");
    } else if (ajaxRequest.status == 232) {
      /// ajaxRequest.status == 232 means the Session Timed out.
      /// The ajaxRequest.responseText should contain "You are logged out due to inactivity for more than 15 minutes"
      /// ajaxRequest.responseText!.contains("You are logged out due to inactivity for more than 15 minutes") should be true.

      log("ajaxRequest.status: 232 encountered");
      ajaxRequestStatus232Action();
    } else if (ajaxRequest.status == 233) {
      /// ajaxRequest.status == 233 executes same operation as ajaxRequest.status == 200.
      /// But is still an error request.
      /// Todo: Find the situation in which this status is encountered and then handle that suitably.

      log("ajaxRequest.status: 233 encountered");
    } else {
      /// Any other ajaxRequest.status executes same operation as ajaxRequest.status == 200.

      log("ajaxRequest.status: ${ajaxRequest.status} encountered");
    }
  }
}
