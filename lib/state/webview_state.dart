import 'dart:convert';
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

  resetControlVars() {
    _noOfHomePageBuilds = 0;
    _noOfAjaxRequests = 0;
  }

  init() async {
    _options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: true,
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
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print('Console Message: ${consoleMessage.message}');
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
        if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
            !(await controller.isLoading())) {
          if (ajaxRequest.url.toString() == "vtopLogin") {
            print("vtopLogin");
            _vtopLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            _doRefreshCaptchaAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doLogin") {
            _vtopDoLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            _vtopStudentProfileAllViewAjaxRequest(ajaxRequest: ajaxRequest);
          } else {
            print(ajaxRequest.url.toString());
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) async {
        print('onLoadStart $url');
        _url = url?.toString() ?? '';
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        print('onLoadStop $url');
        _url = url?.toString() ?? '';
        _onLoadStopAction(url: url);
      },
    );

    runHeadlessInAppWebView();
  }

  runHeadlessInAppWebView() async {
    await headlessWebView.dispose();
    await headlessWebView.run();
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
// print("ajaxRequest: ${ajaxRequest}");
    await headlessWebView.webViewController
        .evaluateJavascript(
            source: "new XMLSerializer().serializeToString(document);")
        .then((value) async {
      if (ajaxRequest.status == 200) {
        if (value.contains(
            readUserLoginStateProviderValue.registrationNumber + "(STUDENT)")) {
          print(
              "User ${readUserLoginStateProviderValue.registrationNumber} successfully signed in");

          readUserLoginStateProviderValue.updateLoginStatus(loginStatus: true);

//        _saveUnamePasswd();
//           sessionDateTime = await NTP.now().then((value) {
//             _saveSessionDateTime();
//             debugPrint(
//                 'NTP DateTime: $sessionDateTime, DateTime: ${DateTime.now().toString()}');
//
//             manageUserSession(
//               context: context,
//               headlessWebView: headlessWebView,
//               onCurrentFullUrl: (String value) {
//                 setState(() {
//                   currentFullUrl = value;
//                 });
//               },
//               onProcessingSomething: (bool value) {
//                 setState(() {
//                   processingSomething = value;
//                 });
//               },
//               onRequestType: (String value) {
//                 setState(() {
//                   requestType = value;
//                 });
//               },
//               onError: (String value) {
//                 debugPrint("Updating Ui based on the error received");
//                 if (processingSomething == true) {
//                   Navigator.of(context).pop();
//                   processingSomething = false;
//                 }
//                 if (value == "net::ERR_INTERNET_DISCONNECTED") {
//                   debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
//                   setState(() {
//                     currentStatus = "launchLoadingScreen";
//                     vtopConnectionStatusErrorType =
//                         "net::ERR_INTERNET_DISCONNECTED";
//                     vtopConnectionStatusType = "Error";
//                   });
//                 }
//               },
//             );
//             openStudentProfileAllView(forXAction: 'New login');
// // Actually we are using openStudentProfileAllView() to get profile document
// // and then setting the currentStatus = "userLoggedIn" in the studentsRecord/StudentProfileAllView ajax request.
//
//             setState(() {
//               studentPortalDocument = parse('${ajaxRequest.responseText}');
//             });
//             return value;
//           });
        } else if (value.contains("User Id Not available")) {
          print("User Id Not available");
// User Id Not available WHEN ENTERING WRONG USER ID
// processingSomething = false;
// We commented the statement because we put this inside the onloadstop.
// We know that processing is already validated but we still want to show the dialog until user sees the updated login page
//           vtopLoginErrorType = "User Id Not available";
//           runHeadlessInAppWebView(
//             headlessWebView: headlessWebView,
//             onCurrentFullUrl: (String value) {
//               setState(() {
//                 currentFullUrl = value;
//               });
//             },
//           );
        } else if (value.contains("Invalid User Id / Password")) {
          print("Most probably invalid password");
//Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
//           vtopLoginErrorType = "Most probably invalid password";
//           runHeadlessInAppWebView(
//             headlessWebView: headlessWebView,
//             onCurrentFullUrl: (String value) {
//               setState(() {
//                 currentFullUrl = value;
//               });
//             },
//           );
        } else if (value.contains("Invalid Captcha")) {
          print("Invalid Captcha");
//Invalid Captcha WHEN ENTERING WRONG CAPTCHA
//           vtopLoginErrorType = "Invalid Captcha";
//           runHeadlessInAppWebView(
//             headlessWebView: headlessWebView,
//             onCurrentFullUrl: (String value) {
//               setState(() {
//                 currentFullUrl = value;
//               });
//             },
//           );
        } else if (value.contains(
                "You are logged out due to inactivity for more than 15 minutes") ||
            ajaxRequest.responseText!
                .contains("You have been successfully logged out")) {
          print("Most probably session expired due to inactivity");
//Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
//           vtopLoginErrorType = "Session expired due to inactivity";
//           runHeadlessInAppWebView(
//             headlessWebView: headlessWebView,
//             onCurrentFullUrl: (String value) {
//               setState(() {
//                 currentFullUrl = value;
//               });
//             },
//           );
        } else {
          print(
              "Can't find why something got wrong enable print ajaxRequest for doLogin and see the logs");
          // printWrapped("ajaxRequest: $ajaxRequest");
          // vtopLoginErrorType = "Something is wrong! Please retry.";
          // runHeadlessInAppWebView(
          //   headlessWebView: headlessWebView,
          //   onCurrentFullUrl: (String value) {
          //     setState(() {
          //       currentFullUrl = value;
          //     });
          //   },
          // );
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

  // _vtopStudentProfileAllViewAjaxRequest(
  //     {required AjaxRequest ajaxRequest}) async {
  //   // _credentialsFound();
  //   // setState(() {
  //   //   vtopConnectionStatusType = "Connected";
  //   // });
  //   if (ajaxRequest.status == 200) {
  //     await headlessWebView.webViewController
  //         .evaluateJavascript(
  //             source: "new XMLSerializer().serializeToString(document);")
  //         .then((value) {
  //       Document document = parse('$value');
  //
  //       read(vtopDataProvider)
  //           .setStudentProfile(studentProfileViewDocument: document);
  //
  //       // setState(() {
  //       // studentName = document
  //       //     .getElementById('exTab1')
  //       //     ?.children[1]
  //       //     .children[0]
  //       //     .children[0]
  //       //     .children[0]
  //       //     .children[0]
  //       //     .children[0]
  //       //     .children[2]
  //       //     .children[1]
  //       //     .innerHtml;
  //       // if (vtopMode == "Mini VTOP") {
  //       //   currentStatus = "userLoggedIn";
  //       // } else if (vtopMode == "Full VTOP") {
  //       //   currentStatus = "originalVTOP";
  //       // }
  //       // loggedUserStatus = "studentPortalScreen";
  //       // Navigator.of(context)
  //       //     .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
  //       // processingSomething = false;
  //       // });
  //     });
  //   } else if (ajaxRequest.responseText!.contains(
  //           "You are logged out due to inactivity for more than 15 minutes") ||
  //       ajaxRequest.responseText!
  //           .contains("You have been successfully logged out")) {
  //     // inActivityOrStatusNot200Response(
  //     //     dialogTitle: 'Session ended',
  //     //     dialogChildrenText: 'Starting new session\nplease wait...');
  //   } else if (ajaxRequest.status != 200) {
  //     // inActivityOrStatusNot200Response(
  //     //     dialogTitle: 'Request Status != 200',
  //     //     dialogChildrenText: 'Starting new session\nplease wait...');
  //   }
  // }

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
                loginStatus: true);

            // openStudentProfileAllView(forXAction: 'Logged in');
            //
            // studentPortalDocument = document;
          }
        }
      });
    }
  }
}
