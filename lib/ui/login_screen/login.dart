import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/ui/login_screen/components/control_teddy.dart';
import 'package:mini_vtop/ui/login_screen/components/login_tracking_text_input.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/webview_state.dart';
import 'package:mini_vtop/ui/components/custom_snack_bar.dart';
import 'package:mini_vtop/ui/home_screen/home_screen.dart';
import '../../state/connection_state.dart';
import '../components/error_indicators.dart';
import '../components/page_body_indicators.dart';
import 'components/forgot_user_id_screen.dart';
import 'components/upper_case_text_formatter.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  @override
  void initState() {
    // // Resetting to clear any previous state
    // ref.read(userLoginStateProvider).updateForgotUserIDSearchStatus(
    //     status: ForgotUserIDSearchResponseStatus.notSearching);
    // ref.read(userLoginStateProvider).updateForgotUserIDValidateStatus(
    //     status: ForgotUserIDValidateResponseStatus.notProcessing);

    // Making a click on GoToLogin button.
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.openLoginPageAction(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("VTOP Login"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                // Watching loginPageStatus page status.
                final VTOPPageStatus loginPageStatus = ref.watch(
                    vtopActionsProvider
                        .select((value) => value.loginPageStatus));

                //----------- Listener for reloading login page if session gets timed out or WebView gets reloaded -----------

                // Listening to session status change.
                ref.listen(
                    vtopActionsProvider.select((value) => value.vtopStatus),
                    (previous, next) {
                  //Checking if VTOPStatus status is sessionTimedOut and its a new status.
                  if (previous != next && next == VTOPStatus.sessionTimedOut) {
                    // Showing session timeout banner.
                    // If true then we are connecting.
                  }

                  //Checking if VTOPStatus status is homepage and its a new status.
                  if (previous != next && next == VTOPStatus.homepage) {
                    // Remove session timeout banner.
                    // If true then we are on homepage.
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);
                    // Opening login page.
                    readVTOPActionsProviderValue.openLoginPageAction(
                        context: context);
                    readVTOPActionsProviderValue.updateLoginPageStatus(
                        status: VTOPPageStatus.processing);
                  }
                });
                //----------------------

                return loginPageStatus == VTOPPageStatus.loaded
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: TeddyLoginScreen(),
                      )
                    : PageBodyIndicators(
                        pageStatus: loginPageStatus,
                        errorLocation: ErrorLocation.beforeHomeScreen);
              },
            ),
            onRefresh: () async {
              final VTOPActions readVTOPActionsProviderValue =
                  ref.read(vtopActionsProvider);
              readVTOPActionsProviderValue.openLoginPageAction(
                  context: context);
              readVTOPActionsProviderValue.updateLoginPageStatus(
                  status: VTOPPageStatus.processing);
            },
          ),
        ),
      ),
    );
  }
}

class TeddyLoginScreen extends StatefulWidget {
  const TeddyLoginScreen({Key? key}) : super(key: key);

  @override
  State<TeddyLoginScreen> createState() => _TeddyLoginScreenState();
}

class _TeddyLoginScreenState extends State<TeddyLoginScreen> {
  late ControlTeddy controlTeddy;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controlTeddy = ControlTeddy();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String password = "";
  String registrationNumber = "";
  String captcha = "";
  bool autoLogin = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Container(
        //   height: 200,
        //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        //   child: RiveAnimation.asset(
        //     "assets/rive/animated_login_screen.riv",
        //     animations: const ['idle', 'curves'],
        //     alignment: Alignment.bottomCenter,
        //     fit: BoxFit.contain,
        //     onInit: _controlTeddy.onRiveInit,
        //   ),
        // ),
        SizedBox(
          width: 150,
          height: 150,
          child: RiveAnimation.asset(
            'assets/rive/bachelor_cap.riv',
            fit: BoxFit.contain,
          ),
        ),
        // const Icon(
        //   Icons.school,
        //   size: 150,
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              LoginFields(
                controlTeddy: controlTeddy,
                formKey: formKey,
              ),
              const SizedBox(
                height: 10,
              ),
              CheckboxListTile(
                value: autoLogin,
                title: const Text("Enable Auto login?"),
                onChanged: (bool? value) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    autoLogin = value ?? false;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              LoginButton(
                controlTeddy: controlTeddy,
                formKey: formKey,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "By logging in, you accept our Terms and Conditions and Privacy Policy",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {Key? key, required this.controlTeddy, required this.formKey})
      : super(key: key);

  final ControlTeddy controlTeddy;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              // Keeping track of captcha loading to disable enable button
              bool captchaLoading = true;
              Uint8List? captchaImageBytes = ref.watch(
                  userLoginStateProvider.select((value) => value.captchaImage));
              if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
                captchaLoading = false;
              } else {
                captchaLoading = true;
              }

              LoginResponseStatus loginStatus = ref.watch(
                  userLoginStateProvider.select((value) => value.loginStatus));

              ref.listen(
                  userLoginStateProvider.select((value) => value.loginStatus),
                  (previous, next) {
                if (next == LoginResponseStatus.loggedIn) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  });
                }
                if (previous != next) {
                  //---------- Showing SnackBar ----------
                  final LoginResponseStatus loginStatus =
                      ref.read(userLoginStateProvider).loginStatus;

                  showLoginSnackBar(status: loginStatus, context: context);

                  //--------------------
                  // ---------- Refreshing captcha ----------
                  if (next == LoginResponseStatus.maxAttemptsError ||
                      next == LoginResponseStatus.wrongUserId ||
                      next == LoginResponseStatus.wrongPassword ||
                      next == LoginResponseStatus.wrongCaptcha ||
                      next == LoginResponseStatus.loggedOut) {
                    // Only refresh if the above is true otherwise the login wont succeed.
                    // Because when status changes to processing the captcha will get refreshed before login causing failure.
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);
                    readVTOPActionsProviderValue.performCaptchaRefreshAction(
                        context: context);
                    // --------------------
                  }
                }
              });

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: !captchaLoading
                    ? () {
                        if (formKey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          controlTeddy.submitPassword();

                          ref.read(userLoginStateProvider).updateLoginStatus(
                              loginStatus: LoginResponseStatus.processing);

                          final VTOPActions readVTOPActionsProviderValue =
                              ref.read(vtopActionsProvider);

                          readVTOPActionsProviderValue.performSignInAction(
                              context: context);
                        }
                      }
                    : null,
                child: Center(
                  child: loginStatus != LoginResponseStatus.processing
                      ? const Text('Login')
                      : SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showLoginSnackBar(
    {required LoginResponseStatus status, required BuildContext context}) {
  String? contentText;
  Color? backgroundColor;
  Duration? duration;
  IconData? iconData;
  Color? iconAndTextColor;

  if (status == LoginResponseStatus.wrongCaptcha) {
    contentText = 'Captcha was invalid! Please try again.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == LoginResponseStatus.wrongPassword) {
    contentText = 'Password was wrong! Please try again.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == LoginResponseStatus.wrongUserId) {
    contentText = 'User Id was wrong! Please try again.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == LoginResponseStatus.maxAttemptsError) {
    contentText = 'Max fail attempts reached! Please use forget password.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == LoginResponseStatus.loggedIn) {
    contentText = 'Successfully logged in!';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  } else if (status == LoginResponseStatus.processing) {
    contentText = 'Processing login! Please wait.';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  }

  return showCustomSnackBar(
    context: context,
    contentText: contentText,
    backgroundColor: backgroundColor,
    duration: duration,
    iconData: iconData,
    iconAndTextColor: iconAndTextColor,
  );
}

class LoginFields extends StatelessWidget {
  const LoginFields(
      {Key? key, required this.controlTeddy, required this.formKey})
      : super(key: key);

  final ControlTeddy controlTeddy;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        String autoCaptcha = ref
            .watch(userLoginStateProvider.select((value) => value.autoCaptcha));

        String userID = ref.read(userLoginStateProvider).userID;

        String password = ref.read(userLoginStateProvider).password;

        return Form(
          key: formKey,
          child: Column(
            children: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TrackingTextInput(
                    preFilledValue: userID,
                    prefixIcon: const Icon(Icons.badge),
                    helperText: 'Ex:- 20BCEXXXXX',
                    labelText: 'UserID',
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter UserID';
                      }
                      return null;
                    },
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    isObscured: false,
                    enableSuggestions: true,
                    autocorrect: false,
                    enabled: true,
                    readOnly: false,
                    onCaretMoved: (
                        {Offset? globalCaretPosition, Size? textFieldSize}) {
                      controlTeddy.lookAt(
                          textFieldSize: textFieldSize,
                          caret: globalCaretPosition);
                    },
                    onTextChanged: (String value) {
                      ref.read(userLoginStateProvider).setUserID(userID: value);
                      // print(value);
                    },
                  );
                },
              ),
              ForgotDetailButtons(
                label: "Forgot UserID?",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotUserID(),
                    ),
                  ).then((value) {
                    final HeadlessWebView readHeadlessWebViewProviderValue =
                        ref.read(headlessWebViewProvider);
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);
                    readVTOPActionsProviderValue.updateVTOPStatus(
                        status: VTOPStatus.sessionTimedOut);
                    readHeadlessWebViewProviderValue.settingSomeVars();
                    readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TrackingTextInput(
                    preFilledValue: password,
                    prefixIcon: const Icon(Icons.password),
                    helperText: 'Ex:- password123',
                    labelText: 'VTOP Password',
                    inputFormatters: const [],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter VTOP password';
                      }
                      return null;
                    },
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    isObscured: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    enabled: true,
                    readOnly: false,
                    onCaretMoved: (
                        {Offset? globalCaretPosition, Size? textFieldSize}) {
                      controlTeddy.coverEyes(
                          cover: globalCaretPosition != null);
                      controlTeddy.lookAt(
                          textFieldSize: textFieldSize, caret: null);
                    },
                    onTextChanged: (String value) {
                      controlTeddy.password = value;
                      ref
                          .read(userLoginStateProvider)
                          .setPassword(password: value);
                    },
                  );
                },
              ),
              ForgotDetailButtons(
                label: "Forgot Password?",
                onPressed: () {},
              ),
              const SizedBox(
                height: 10,
              ),
              const CaptchaSection(),
              const SizedBox(
                height: 10,
              ),
              TrackingTextInput(
                prefixIcon: const Icon(Icons.smart_toy),
                helperText: '🤖🤖🤖',
                labelText: 'Captcha',
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter captcha';
                  }
                  return null;
                },
                autoValidateMode: AutovalidateMode.onUserInteraction,
                isObscured: false,
                enableSuggestions: false,
                autocorrect: false,
                enabled: true,
                readOnly: false,
                onCaretMoved: (
                    {Offset? globalCaretPosition, Size? textFieldSize}) {
                  controlTeddy.coverEyes(cover: globalCaretPosition != null);
                  controlTeddy.lookAt(
                      textFieldSize: textFieldSize, caret: null);
                },
                onTextChanged: (String value) {
                  ref.read(userLoginStateProvider).setCaptcha(captcha: value);
                },
                preFilledValue: autoCaptcha,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ForgotDetailButtons extends StatelessWidget {
  const ForgotDetailButtons({Key? key, this.onPressed, required this.label})
      : super(key: key);

  final void Function()? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Keeping track of captcha loading to disable enable button
        bool captchaLoading = true;
        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));
        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          captchaLoading = false;
        } else {
          captchaLoading = true;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                // minimumSize: Size(0, 0),
              ),
              onPressed: !captchaLoading ? onPressed : null,
              child: Text(label),
            ),
          ],
        );
      },
    );
  }
}

class CaptchaSection extends StatelessWidget {
  const CaptchaSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CaptchaImage(),
        SizedBox(
          width: 10,
        ),
        CaptchaIconButton(),
      ],
    );
  }
}

class CaptchaIconButton extends StatelessWidget {
  const CaptchaIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Keeping track of captcha loading to disable enable button
        bool captchaLoading = true;
        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));
        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          captchaLoading = false;
        } else {
          captchaLoading = true;
        }

        return IconButton(
            onPressed: !captchaLoading
                ? () {
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);

                    readVTOPActionsProviderValue.performCaptchaRefreshAction(
                        context: context);

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                : null,
            icon: const Icon(Icons.refresh));
      },
    );
  }
}

class CaptchaImage extends StatelessWidget {
  const CaptchaImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Image? image;

        bool captchaLoading = true;

        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));

        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          image = Image.memory(
            captchaImageBytes,
            fit: BoxFit.cover,
          );

          captchaLoading = false;
        } else {
          captchaLoading = true;
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          width: 180,
          height: 45,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Stack(
            children: [
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceVariant,
                highlightColor: Theme.of(context).colorScheme.primary,
                enabled: captchaLoading,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              image ?? const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
