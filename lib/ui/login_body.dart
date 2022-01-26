import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../basicFunctions/direct_pop.dart';
import '../basicFunctions/proccessing_dialog.dart';
import '../basicFunctions/stop_pop.dart';
import '../basicFunctions/upper_case_text_formatter.dart';

class LoginSection extends StatefulWidget {
  const LoginSection({
    Key? key,
    required this.arguments,
    this.onCurrentStatus,
    this.onPerformSignIn,
    this.onPerformSignOut,
    this.onRefreshCaptcha,
    required this.onVtopLoginErrorType,
    required this.onClearUnamePasswd,
    required this.onTryAutoLoginStatus,
  }) : super(key: key);

  final LoginSectionArguments arguments;
  final ValueChanged<String>? onCurrentStatus;
  final ValueChanged<Map<String, dynamic>>? onPerformSignIn;
  final ValueChanged<bool>? onPerformSignOut;
  final ValueChanged<Map<String, dynamic>>? onRefreshCaptcha;
  final ValueChanged<String> onVtopLoginErrorType;
  final ValueChanged<bool> onClearUnamePasswd;
  final ValueChanged<bool> onTryAutoLoginStatus;

  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  TextEditingController? _controller;
  TextEditingController? _controller2;
  TextEditingController? _controller3;

  late HeadlessInAppWebView? headlessWebView;
  late Image? image;
  late String? currentStatus;
  String? uname = "";
  String? passwd = "";
  String? captchaCheck = "";
  Map<String, dynamic> signInCredentialsMap = {};

  @override
  void didUpdateWidget(LoginSection oldWidget) {
    if (oldWidget.arguments.image != widget.arguments.image) {
      image = widget.arguments.image;
    }
    if (oldWidget.arguments.autoCaptcha != widget.arguments.autoCaptcha) {
      _controller3 = TextEditingController(text: widget.arguments.autoCaptcha);
    }

    super.didUpdateWidget(oldWidget);
  }
  //setState in parent widget will not completely rebuild its inner Stateful Widget so the initstate of child widget will not rerun and updated argument value doesn't update in the ui. To bypass that we can redefine initstate values also in build method but it is better to just use the didUpdateWidget as it is designed for that. Another method would be to just assign a completely new key to the child widget which will force complete rebuild

  Widget animationOfLoginScreen = Image.asset(
    "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Sign_In_transparent_by_Icons8.gif",
    scale: 0.1,
    width: 5000,
    height: 5000,
    key: const ValueKey<int>(0),
  );

  late Widget usernameRealField;
  late Widget passwordRealField;

  late Widget usernameFakeField;
  late Widget passwordFakeField;

  late Widget credentialsWidget;

  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.arguments.userEnteredUname);
    _controller2 =
        TextEditingController(text: widget.arguments.userEnteredPasswd);
    _controller3 = TextEditingController(text: widget.arguments.autoCaptcha);

    //headlessWebView = widget.arguments?.headlessWebView;
    image = widget.arguments.image;
    currentStatus = widget.arguments.currentStatus;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.arguments.userEnteredUname.isNotEmpty &&
          widget.arguments.userEnteredPasswd.isNotEmpty &&
          widget.arguments.autoCaptcha.isNotEmpty &&
          widget.arguments.tryAutoLoginStatus == true) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
        if (_formKey.currentState!.validate()) {
          processingDialog(
            isDialogShowing: isFirstDialogShowing,
            context: context,
            onIsDialogShowing: (bool value) {
              setState(() {
                isFirstDialogShowing = value;
              });
            },
            dialogTitle: const Text('Sending login request'),
            dialogChildren: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text('Please wait...'),
              ],
            ),
            barrierDismissible: false,
          ).then((_) => isFirstDialogShowing = false);
          debugPrint("dialogBox initiated");
          signInCredentialsMap = {
            "uname": '${_controller?.value.text.toUpperCase()}',
            "passwd": '${_controller2?.value.text}',
            "captchaCheck": '${_controller3?.value.text.toUpperCase()}',
            "refreshingCaptcha": true,
            "processingSomething": true,
          };
          widget.onPerformSignIn?.call(signInCredentialsMap);
        }
      }
    });

    // InAppWebViewController? controller =
    //     widget.arguments?.headlessWebView.webViewController;

    // headlessWebView?.onAjaxProgress
    //     ?.call(controller!, ajaxRequest!)
    //     .then((value) {
    //   print("ajaxRequest: ${ajaxRequest}");
    //   return AjaxRequestAction.PROCEED;
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller2?.dispose();
    _controller3?.dispose();
  }

  bool isFirstDialogShowing = false;
  bool isSecondDialogShowing = false;

  // Future<void> _showMyDialog() async {
  //   _isDialogShowing = true; // set it `true` since dialog is being displayed
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Sending login request'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: const <Widget>[
  //               CircularProgressIndicator(),
  //               Text('Please wait...'),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // if (widget.arguments?.processingSomething == true &&
    //     _isDialogShowing == false) {
    //   WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
    //         _showMyDialog();
    //       }));
    // } else

    if (widget.arguments.vtopLoginErrorType != "None" &&
        isFirstDialogShowing == true &&
        isSecondDialogShowing == false &&
        widget.arguments.processingSomething == true) {
      Navigator.of(context).pop();
      debugPrint("credential dialogBox popped");
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        processingDialog(
          isDialogShowing: isSecondDialogShowing,
          context: context,
          onIsDialogShowing: (bool value) {
            setState(() {
              isSecondDialogShowing = value;
            });
          },
          dialogTitle: const Text('Re-requesting login page'),
          dialogChildren: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text('Please wait...'),
            ],
          ),
          barrierDismissible: false,
        ).then((_) => isSecondDialogShowing = false);
      });
    }
    debugPrint("isDialogShowing: $isFirstDialogShowing");
    if (widget.arguments.processingSomething == false &&
        isSecondDialogShowing == true) {
      // _controller3 = TextEditingController(text: "");
      Future.delayed(const Duration(milliseconds: 500), () async {
        Navigator.of(context).pop();
        debugPrint("dialogBox popped");
      });
    }

    return WillPopScope(
      onWillPop: () {
        return !isFirstDialogShowing
            ? stopPop()
            : directPop(); //will stop popping login screen
      },
      child: Center(
        child: SingleChildScrollView(
          // padding: EdgeInsets.zero,
          // physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height -
                  Scaffold.of(context).appBarMaxHeight!,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //   padding: const EdgeInsets.all(20.0),
                    //   child: Text(
                    //       "URL: ${(widget.arguments.currentFullUrl.length > 50) ? widget.arguments.currentFullUrl.substring(0, 50) + "..." : widget.arguments.currentFullUrl}"),
                    // ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: SizedBox(
                          height: 250,
                          width: 250,
                          child: animationOfLoginScreen,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          widget.arguments.vtopLoginErrorType != "None"
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xfff04e23),
                                      // border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0, left: 8.0),
                                              child: Icon(Icons.error),
                                            ),
                                            Text(widget
                                                .arguments.vtopLoginErrorType),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 51,
                                          height: 40,
                                          child: Material(
                                            color: Colors.transparent,
                                            shape: const StadiumBorder(),
                                            child: Tooltip(
                                              message: "Close",
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    widget.onVtopLoginErrorType
                                                        .call("None");
                                                  });
                                                },
                                                customBorder:
                                                    const StadiumBorder(),
                                                focusColor: Colors.black
                                                    .withOpacity(0.1),
                                                highlightColor: Colors.black
                                                    .withOpacity(0.1),
                                                splashColor: Colors.black
                                                    .withOpacity(0.1),
                                                hoverColor: Colors.black
                                                    .withOpacity(0.1),
                                                child: const Icon(
                                                  Icons.close_outlined,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: widget.arguments.credentialsFound
                                ? Stack(
                                    children: [
                                      Column(
                                        children: [
                                          TextFormField(
                                            controller: _controller,
                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xff04294f),
                                              // icon: const Icon(Icons.favorite),
                                              labelText: 'Username',
                                              // labelStyle: TextStyle(
                                              //   color: Color(0xFF6200EE),
                                              // ),
                                              // helperText: 'Ex:- 20BCEXXXXX',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder: UnderlineInputBorder(
                                                  // borderSide: BorderSide(color: Color(0xFF6200EE)),
                                                  ),
                                            ),
                                            enabled: false,
                                            readOnly: widget
                                                .arguments.credentialsFound,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter username';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9A-Z]")),
                                            ],
                                            onChanged: (String value) {
                                              setState(() {
                                                uname = value;
                                              });
                                            },
                                          ),
                                          TextFormField(
                                            controller: _controller2,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: 'Password',
                                              // suffixIcon: IconButton(
                                              //   icon: Icon(
                                              //     isObscure ? Icons.visibility : Icons.visibility_off,
                                              //   ),
                                              //   onPressed: () {
                                              //     setState(() {
                                              //       isObscure = !isObscure;
                                              //     });
                                              //   },
                                              // ),
                                              // helperText: 'Ex:- password123 ig🤔',
                                              enabledBorder:
                                                  UnderlineInputBorder(),
                                            ),
                                            enabled: false,
                                            readOnly: widget
                                                .arguments.credentialsFound,
                                            obscureText: isObscure,
                                            obscuringCharacter: "*",
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter password';
                                              }
                                              return null;
                                            },
                                            onChanged: (String value) {
                                              setState(() {
                                                passwd = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 118,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          const Color(
                                                              0xff04294f)),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          const EdgeInsets.only(
                                                              top: 17,
                                                              bottom: 17,
                                                              left: 17,
                                                              right: 17)),
                                                  textStyle:
                                                      MaterialStateProperty.all(
                                                          const TextStyle(
                                                              fontSize: 20)),
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _controller =
                                                        TextEditingController(
                                                            text: "");
                                                    _controller2 =
                                                        TextEditingController(
                                                            text: "");
                                                  });

                                                  widget.onClearUnamePasswd
                                                      .call(true);
                                                },
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.close_outlined),
                                                    Text(
                                                      "Clear",
                                                      style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      TextFormField(
                                        controller: _controller,
                                        // initialValue: 'Input text',
                                        // maxLength: 20,
                                        decoration: const InputDecoration(
                                          filled: true,
                                          // fillColor: Color(0xff04294f),
                                          // icon: const Icon(Icons.favorite),
                                          labelText: 'Username',
                                          // labelStyle: TextStyle(
                                          //   color: Color(0xFF6200EE),
                                          // ),
                                          helperText: 'Ex:- 20BCEXXXXX',
                                          // suffixIcon: Icon(
                                          //   Icons.check_circle,
                                          // ),
                                          enabledBorder: UnderlineInputBorder(
                                              // borderSide: BorderSide(color: Color(0xFF6200EE)),
                                              ),
                                        ),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter username';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9A-Z]")),
                                        ],
                                        onChanged: (String value) {
                                          setState(() {
                                            uname = value;
                                          });
                                        },
                                      ),
                                      TextFormField(
                                        controller: _controller2,
                                        decoration: InputDecoration(
                                          filled: true,
                                          labelText: 'Password',
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isObscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isObscure = !isObscure;
                                              });
                                            },
                                          ),
                                          helperText: 'Ex:- password123 ig🤔',
                                          enabledBorder:
                                              const UnderlineInputBorder(),
                                        ),
                                        obscureText: isObscure,
                                        obscuringCharacter: "*",
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter password';
                                          }
                                          return null;
                                        },
                                        onChanged: (String value) {
                                          setState(() {
                                            passwd = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                child: Shimmer(
                                  duration: const Duration(
                                      seconds: 1), //Default value
                                  interval: const Duration(
                                      seconds:
                                          0), //Default value: Duration(seconds: 0)
                                  color: Colors.pink, //Default value
                                  colorOpacity: 0.2, //Default value
                                  enabled: widget.arguments
                                      .refreshingCaptcha, //Default value
                                  direction: const ShimmerDirection
                                      .fromLTRB(), //Default Value
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                    height: 45,
                                    width: 180,
                                    child: widget.arguments.refreshingCaptcha ==
                                            true
                                        ? const SizedBox()
                                        : image,
                                  ),
                                ),
                                // Html(
                                //   data: serializedDocument,
                                // ),
                                // Text("Document: $serializedDocument"),
                              ),
                              SizedBox(
                                width: 51,
                                height: 40,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: const StadiumBorder(),
                                  child: Tooltip(
                                    message: "Refresh Captcha",
                                    child: InkWell(
                                      onTap: () {
                                        // _controller3 =
                                        //     TextEditingController(text: "");
                                        signInCredentialsMap = {
                                          "uname":
                                              '${_controller?.value.text.toUpperCase()}',
                                          "passwd":
                                              '${_controller2?.value.text}',
                                          "refreshingCaptcha": true,
                                        };
                                        widget.onRefreshCaptcha
                                            ?.call(signInCredentialsMap);
                                      },
                                      customBorder: const StadiumBorder(),
                                      focusColor: Colors.black.withOpacity(0.1),
                                      highlightColor:
                                          Colors.black.withOpacity(0.1),
                                      splashColor:
                                          Colors.black.withOpacity(0.1),
                                      hoverColor: Colors.black.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.refresh,
                                        size: 24,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     signInCredentialsMap = {
                              //       "uname": '${_controller?.value.text.toUpperCase()}',
                              //       "passwd": '${_controller2?.value.text}',
                              //       "refreshingCaptcha": true,
                              //     };
                              //     widget.onRefreshCaptcha?.call(signInCredentialsMap);
                              //   },
                              //   child: const Text("Refresh Captcha"),
                              // ),
                            ],
                          ),
                          TextFormField(
                            controller: _controller3,
                            decoration: const InputDecoration(
                              filled: true,
                              labelText: 'Captcha',
                              helperText: '',
                              enabledBorder: UnderlineInputBorder(),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter captcha';
                              }
                              return null;
                            },
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9A-Z]")),
                            ],
                            onChanged: (String value) {
                              setState(() {
                                captchaCheck = value;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text(
                              'Enable auto sign in.\nNote:- It tries only one time as it could fail and can be disabled through manual logout',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: widget.arguments.tryAutoLoginStatus,
                            onChanged: (bool? value) {
                              widget.onTryAutoLoginStatus
                                  .call(!widget.arguments.tryAutoLoginStatus);
                            },
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff04294f)),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.only(
                                      top: 17,
                                      bottom: 17,
                                      left: 30,
                                      right: 30)),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(fontSize: 20)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus &&
                                  currentFocus.focusedChild != null) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                              if (_formKey.currentState!.validate()) {
                                processingDialog(
                                  isDialogShowing: isFirstDialogShowing,
                                  context: context,
                                  onIsDialogShowing: (bool value) {
                                    setState(() {
                                      isFirstDialogShowing = value;
                                    });
                                  },
                                  dialogTitle:
                                      const Text('Sending login request'),
                                  dialogChildren: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(),
                                      Text('Please wait...'),
                                    ],
                                  ),
                                  barrierDismissible: false,
                                ).then((_) => isFirstDialogShowing = false);
                                debugPrint("dialogBox initiated");
                                signInCredentialsMap = {
                                  "uname":
                                      '${_controller?.value.text.toUpperCase()}',
                                  "passwd": '${_controller2?.value.text}',
                                  "captchaCheck":
                                      '${_controller3?.value.text.toUpperCase()}',
                                  "refreshingCaptcha": true,
                                  "processingSomething": true,
                                };
                                widget.onPerformSignIn
                                    ?.call(signInCredentialsMap);
                              }
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                // textStyle: Theme.of(context).textTheme.headline1,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ElevatedButton(
                    //   onPressed: () async {
                    //     widget.onPerformSignOut?.call(true);
                    //   },
                    //   child: const Text('Logout'),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginSectionArguments {
  String currentStatus;
  String userEnteredUname;
  String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  bool processingSomething;
  Image? image;
  bool refreshingCaptcha;
  String currentFullUrl;
  String vtopLoginErrorType;
  bool credentialsFound;
  String autoCaptcha;
  bool tryAutoLoginStatus;

  LoginSectionArguments({
    required this.currentStatus,
    required this.userEnteredUname,
    required this.userEnteredPasswd,
    //   required this.headlessWebView,
    required this.image,
    required this.processingSomething,
    required this.refreshingCaptcha,
    required this.currentFullUrl,
    required this.vtopLoginErrorType,
    required this.credentialsFound,
    required this.autoCaptcha,
    required this.tryAutoLoginStatus,
  });
}
