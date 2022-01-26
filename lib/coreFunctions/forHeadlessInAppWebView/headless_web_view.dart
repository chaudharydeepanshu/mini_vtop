// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:html/parser.dart' show parse;
// import 'package:mini_vtop/basicFunctions/print_wrapped.dart';
// import '../manage_user_session.dart';
// import '../sign_out.dart';

InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      useShouldInterceptAjaxRequest: true,
    ),
    android: AndroidInAppWebViewOptions(
      useShouldInterceptRequest: true,
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));
//
// headlessInAppWebView({
//   required BuildContext context,
//   required String userEnteredUname,
//   required HeadlessInAppWebView? headlessWebView,
//   required ValueChanged<String> onCurrentFullUrl,
//   required ValueChanged<Map<String, dynamic>> onVtopLoginAjaxRequest,
//   required ValueChanged<InAppWebViewController> onWebViewController,
//   required ValueChanged<Image> onImage,
//   required ValueChanged<String> onCurrentStatus,
//   required ValueChanged<bool> onRestartHeadlessInAppWebView,
// }) {
//   return HeadlessInAppWebView(
//     initialUrlRequest:
//         URLRequest(url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop")),
//     initialOptions: options,
//     onReceivedServerTrustAuthRequest: (controller, challenge) async {
//       if (kDebugMode) {
//         print(challenge);
//       }
//       return ServerTrustAuthResponse(
//           action: ServerTrustAuthResponseAction.PROCEED);
//     },
//     onWebViewCreated: (controller) {
//       const snackBar = SnackBar(
//         content: Text('HeadlessInAppWebView created!'),
//         duration: Duration(seconds: 1),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     },
//     onConsoleMessage: (controller, consoleMessage) {
//       final snackBar = SnackBar(
//         content: Text('Console Message: ${consoleMessage.message}'),
//         duration: const Duration(seconds: 1),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
//       if (kDebugMode) {
//         print('Console Message: ${consoleMessage.message}');
//       }
//     },
//     shouldInterceptAjaxRequest:
//         (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// // print("ajaxRequest: ${ajaxRequest}");
// // ajaxRequest.headers?.setRequestHeader("Cookie", authState.setCookie);
//       return ajaxRequest;
//     },
//     onAjaxReadyStateChange:
//         (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// // print("ajaxRequest: ${ajaxRequest}");
// // print(ajaxRequest.status);
//       return AjaxRequestAction.PROCEED;
//     },
//     onAjaxProgress:
//         (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
// // printWrapped("ajaxRequest: ${ajaxRequest}");
// // await controller
// //     .evaluateJavascript(
// //         source:
// //             "new XMLSerializer().serializeToString(document);")
// //     .then((value) {
// //   printWrapped("Element: $value");
// // });
//       if (ajaxRequest.event?.type == AjaxRequestEventType.LOADEND) {
//         // print("ajaxRequest: ${ajaxRequest}");
//         if (ajaxRequest.url.toString() == "vtopLogin") {
//           // await controller.evaluateJavascript(
//           //     source:
//           //         '''new XMLSerializer().serializeToString(document.querySelector('img[alt="vtopCaptcha"]'));''').then(
//           //     (value) {
//           //   printWrapped("vtopCaptcha Element: $value");
//           // });
//           await controller.evaluateJavascript(
//               source:
//                   '''document.querySelector('img[alt="vtopCaptcha"]').src;''').then(
//               (value) {
//             String uri = value;
//             String base64String = uri.split(', ').last;
//             Uint8List _bytes = base64.decode(base64String);
//             // printWrapped("vtopCaptcha _bytes: $base64String");
//             Map<String, dynamic> vtopLoginAjaxRequestMap = {
//               "webViewController": controller,
//               "image": Image.memory(_bytes),
//               "currentStatus": "runHeadlessInAppWebView",
//             };
//             onVtopLoginAjaxRequest.call(vtopLoginAjaxRequestMap);
//
//             // setState(() {
//             //   webViewController = controller;
//             //   image = Image.memory(_bytes);
//             //   currentStatus = "runHeadlessInAppWebView";
//             // });
//
//             // print("vtopCaptcha _bytes: ${_bytes}");
//           });
//         } else if (ajaxRequest.url.toString() == "doLogin") {
//           // printWrapped("ajaxRequest: ${ajaxRequest}");
//           await controller
//               .evaluateJavascript(
//                   source: "new XMLSerializer().serializeToString(document);")
//               .then((value) async {
//             if (value.contains(userEnteredUname + "(STUDENT)")) {
//               printWrapped("User $userEnteredUname successfully signed in");
//               onCurrentStatus.call("userLoggedIn");
//               // setState(() {
//               //   currentStatus = "userLoggedIn";
//               // });
//               manageUserSession(
//                   context: context,
//                   headlessWebView: headlessWebView,
//                   onCurrentFullUrl: (String value) {
//                     onCurrentFullUrl.call(value);
//                   });
//             } else if (value.contains("User Id Not available")) {
//               printWrapped("User Id Not available");
//               //User Id Not available WHEN ENTERING WRONG USER ID
//               performSignOut(
//                   context: context,
//                   headlessWebView: headlessWebView,
//                   onCurrentFullUrl: (String value) {
//                     onCurrentStatus.call(value);
//                     // setState(() {
//                     //   currentFullUrl = value;
//                     // });
//                   });
//             } else if (value.contains("Invalid User Id / Password")) {
//               printWrapped("Most probably invalid password");
//               //Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
//               performSignOut(
//                   context: context,
//                   headlessWebView: headlessWebView,
//                   onCurrentFullUrl: (String value) {
//                     onCurrentStatus.call(value);
//                     // setState(() {
//                     //   currentFullUrl = value;
//                     // });
//                   });
//             } else if (value.contains("Invalid Captcha")) {
//               printWrapped("Invalid Captcha");
//               //Invalid Captcha WHEN ENTERING WRONG CAPTCHA
//               performSignOut(
//                   context: context,
//                   headlessWebView: headlessWebView,
//                   onCurrentFullUrl: (String value) {
//                     onCurrentStatus.call(value);
//                     // setState(() {
//                     //   currentFullUrl = value;
//                     // });
//                   });
//             } else {
//               printWrapped(
//                   "Can't find why something got wrong enable print ajaxRequest for doLogin and see the logs");
//               // printWrapped("ajaxRequest: ${ajaxRequest}");
//             }
//           });
//         } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
//           // printWrapped("ajaxRequest: ${ajaxRequest}");
//           // print("ajaxRequest: ${ajaxRequest}");
//           if (ajaxRequest.responseText != null) {
//             if (ajaxRequest.responseText!.contains(
//                 "You are logged out due to inactivity for more than 15 minutes")) {
//               onRestartHeadlessInAppWebView.call(true);
//             } else {
//               await controller.evaluateJavascript(source: '''
//                   document.querySelector('img[alt="vtopCaptcha"]').src;
//                   ''').then((value) {
//                 String uri = value;
//                 String base64String = uri.split(', ').last;
//                 Uint8List _bytes = base64.decode(base64String);
//                 // printWrapped("vtopCaptcha _bytes: $base64String");
//                 onImage.call(Image.memory(_bytes));
//                 // setState(() {
//                 //   image = Image.memory(_bytes);
//                 // });
//                 // print("vtopCaptcha _bytes: ${_bytes}");
//               });
//             }
//           }
//         } else if (ajaxRequest.url.toString() ==
//             "studentsRecord/StudentProfileAllView") {
//           var document = parse('${ajaxRequest.responseText}');
//           // print(document.outerHtml);
//           //document.querySelectorAll('table')[1];
//           // print("ajaxRequest: ${ajaxRequest}");
//         } else {
//           // print("ajaxRequest: ${ajaxRequest}");
//           //"You are logged out due to inactivity for more than 15 minutes"
//           // print("response: 232");
//           // await headlessWebView?.dispose();
//           // await headlessWebView?.run();
//         }
//       }
// // print(ajaxRequest.status);
//       return AjaxRequestAction.PROCEED;
//     },
//     onLoadStart: (controller, url) async {
//       final snackBar = SnackBar(
//         content: Text('onLoadStart $url'),
//         duration: const Duration(seconds: 1),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       onCurrentFullUrl.call(url?.toString() ?? '');
//       // setState(() {
//       //   currentFullUrl = url?.toString() ?? '';
//       // });
//     },
//     onLoadStop: (controller, url) async {
//       await controller
//           .evaluateJavascript(
//               source: "new XMLSerializer().serializeToString(document);")
//           .then((response) async {
//         // print(response);
//         if (response.contains(
//             "You are logged out due to inactivity for more than 15 minutes")) {
//           debugPrint("response: 232");
//           onRestartHeadlessInAppWebView.call(true);
//         } else if (response.contains("(STUDENT)")) {
//           onCurrentStatus.call("userLoggedIn");
//           manageUserSession(
//               context: context,
//               headlessWebView: headlessWebView,
//               onCurrentFullUrl: (String value) {
//                 onCurrentFullUrl.call(value);
//               });
//           // currentStatus = "userLoggedIn";
//         } else {
//           // log(url.toString());
//           if (url.toString() ==
//               "https://vtop.vitbhopal.ac.in/vtop/initialProcess") {
//             if (response.contains("openPage()")) {
//               debugPrint("response: 200");
//               await controller
//                   .evaluateJavascript(source: "openPage();")
//                   .whenComplete(() async {
//                 // await webViewController
//                 //     ?.evaluateJavascript(
//                 //         source:
//                 //             "new XMLSerializer().serializeToString(document);")
//                 //     .then((response) {
//                 // printWrapped(response.toString());
//                 // });
//               });
//             } else {
//               debugPrint("response: Empty response");
//               //print("response: $response");
//               //empty response <html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>
//             }
//           } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/") {
//             debugPrint("response: 302");
//           }
//         }
//       });
//       final snackBar = SnackBar(
//         content: Text('onLoadStop $url'),
//         duration: const Duration(seconds: 1),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       onCurrentFullUrl.call(url?.toString() ?? '');
//       // setState(() {
//       //   currentFullUrl = url?.toString() ?? '';
//       // });
//       // log("status: ${url!.}");
//     },
//   );
// }
