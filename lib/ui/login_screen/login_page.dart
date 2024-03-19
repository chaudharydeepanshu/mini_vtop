import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:minivtop/constants.dart';
import 'package:minivtop/db/flutter_secure_storage/secure_storage_repository.dart';
import 'package:minivtop/state/user_login_state.dart';
import 'package:minivtop/state/vtop_actions.dart';
import 'package:minivtop/ui/components/link_button.dart';
import 'package:minivtop/ui/login_screen/components/control_teddy.dart';
import 'package:minivtop/ui/login_screen/components/login_tracking_text_input.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';

import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/webview_state.dart';
import 'package:minivtop/ui/components/custom_snack_bar.dart';
import '../components/page_body_indicators.dart';
import 'package:minivtop/route/route.dart' as route;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    // Making a click on GoToLogin button.
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.openLoginPageAction();
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

                ref.listen(
                    userLoginStateProvider
                        .select((value) => value.loginResponseStatus),
                    (previous, next) {
                  //Checking if LoginResponse status is loggedIn and its a new status.
                  if (previous != next &&
                      next == LoginResponseStatus.loggedIn) {
                    if (Navigator.canPop(context)) {
                      // If true means login is opened over some kind of page.
                      // This situation should occur only for session timeouts logins on after login pages.
                      Navigator.pop(context);
                    } else {
                      // If false means login is the initial page and login should open the dashboard.
                      Navigator.pushReplacementNamed(
                        context,
                        route.dashboardPage,
                      );
                    }
                  }
                });

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
                    readVTOPActionsProviderValue.openLoginPageAction();
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
                        location: Location.beforeHomeScreen);
              },
            ),
            onRefresh: () async {
              final VTOPActions readVTOPActionsProviderValue =
                  ref.read(vtopActionsProvider);
              readVTOPActionsProviderValue.openLoginPageAction();
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
  const TeddyLoginScreen({super.key});

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

  bool autoLogin = false;

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
        const SizedBox(
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
              // CheckboxListTile(
              //   value: autoLogin,
              //   title: const Text("Enable Auto login?"),
              //   onChanged: null,
              //   //     (bool? value) {
              //   //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //   //   setState(() {
              //   //     autoLogin = value ?? false;
              //   //   });
              //   // },
              // ),
              const SaveCredentialsListTile(),
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
              const UserAgreementText(),
            ],
          ),
        ),
      ],
    );
  }
}

class UserAgreementText extends StatelessWidget {
  const UserAgreementText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'By logging in, you accept our ',
              style: Theme.of(context).textTheme.bodySmall,
              children: <InlineSpan>[
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: LinkButton(
                      urlLabel: "Terms and Conditions",
                      url: termsAndConditionsUrl),
                ),
                const TextSpan(
                  text: ' and ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: LinkButton(
                      urlLabel: "Privacy Policy", url: privacyPolicyUrl),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SaveCredentialsListTile extends StatelessWidget {
  const SaveCredentialsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        bool shouldSaveCredentials = ref.watch(userLoginStateProvider
            .select((value) => value.shouldSaveCredentials));

        bool isCredentialsFound = ref.watch(
            userLoginStateProvider.select((value) => value.isCredentialsFound));

        return !isCredentialsFound
            ? CheckboxListTile(
                value: shouldSaveCredentials,
                title: const Text("Save Credentials locally?"),
                onChanged: (bool? value) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ref
                      .read(userLoginStateProvider)
                      .updateShouldSaveCredentialsStatus(
                          status: value ?? false);
                },
              )
            : const SizedBox();
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {super.key, required this.controlTeddy, required this.formKey});

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

              LoginResponseStatus loginStatus = ref.watch(userLoginStateProvider
                  .select((value) => value.loginResponseStatus));

              ref.listen(
                  userLoginStateProvider.select(
                      (value) => value.loginResponseStatus), (previous, next) {
                // if (next == LoginResponseStatus.loggedIn) {
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     Navigator.pushReplacementNamed(
                //       context,
                //       route.dashboardPage,
                //     );
                //   });
                // }
                if (previous != next) {
                  //---------- Showing SnackBar ----------
                  final LoginResponseStatus loginStatus =
                      ref.read(userLoginStateProvider).loginResponseStatus;

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
                    readVTOPActionsProviderValue.performCaptchaRefreshAction();
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

                          readVTOPActionsProviderValue.performSignInAction();
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

class EmailPasswordFields extends StatelessWidget {
  const EmailPasswordFields({super.key, required this.controlTeddy});

  final ControlTeddy controlTeddy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            String userID = ref.read(userLoginStateProvider).userID;

            return TrackingTextInput(
              preFilledValue: userID,
              prefixIcon: const Icon(Icons.badge),
              helperText: 'Ex:- 20BCEXXXXX',
              labelText: 'UserID',
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
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
                    textFieldSize: textFieldSize, caret: globalCaretPosition);
              },
              onTextChanged: (String value) {
                ref.read(userLoginStateProvider).setUserID(userID: value);
                // print(value);
              },
            );
          },
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ForgotDetailButtons(
              label: "Forgot UserID?",
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  route.forgotUserIDPage,
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
            );
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            String password = ref.read(userLoginStateProvider).password;

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
                controlTeddy.coverEyes(cover: globalCaretPosition != null);
                controlTeddy.lookAt(textFieldSize: textFieldSize, caret: null);
              },
              onTextChanged: (String value) {
                controlTeddy.password = value;
                ref.read(userLoginStateProvider).setPassword(password: value);
              },
            );
          },
        ),
        const ForgotDetailButtons(
          label: "Forgot Password?",
          onPressed: null,
        ),
      ],
    );
  }
}

class FakeEmailPasswordFields extends StatelessWidget {
  const FakeEmailPasswordFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          children: [
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                String userID = ref.read(userLoginStateProvider).userID;

                return TrackingTextInput(
                  preFilledValue: userID,
                  prefixIcon: const Icon(Icons.badge),
                  labelText: 'UserID',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
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
                  enabled: false,
                  readOnly: true,
                );
              },
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                String password = ref.read(userLoginStateProvider).password;

                return TrackingTextInput(
                  preFilledValue: password,
                  prefixIcon: const Icon(Icons.password),
                  labelText: 'VTOP Password',
                  inputFormatters: const [],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter VTOP password';
                    }
                    return null;
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  enableObscuredSuffixIcon: false,
                  isObscured: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  enabled: false,
                  readOnly: true,
                );
              },
            ),
          ],
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  SecureStorageRepository().clearVTOPCredentials();
                  ref.read(userLoginStateProvider).setUserID(userID: "");
                  ref.read(userLoginStateProvider).setPassword(password: "");
                  ref
                      .read(userLoginStateProvider)
                      .updateIsCredentialsFoundStatus(status: false);
                },
                label: const Text('Clear'),
                icon: const Icon(Icons.clear),
              ),
            );
          },
        ),
      ],
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields(
      {super.key, required this.controlTeddy, required this.formKey});

  final ControlTeddy controlTeddy;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        String autoCaptcha = ref
            .watch(userLoginStateProvider.select((value) => value.autoCaptcha));

        final bool isCredentialsFound = ref.watch(
            userLoginStateProvider.select((value) => value.isCredentialsFound));

        return Form(
          key: formKey,
          child: Column(
            children: [
              isCredentialsFound
                  ? const FakeEmailPasswordFields()
                  : EmailPasswordFields(controlTeddy: controlTeddy),
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
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
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
  const ForgotDetailButtons({super.key, this.onPressed, required this.label});

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
  const CaptchaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
  const CaptchaIconButton({super.key});

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

                    readVTOPActionsProviderValue.performCaptchaRefreshAction();

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                : null,
            icon: const Icon(Icons.refresh));
      },
    );
  }
}

class CaptchaImage extends StatelessWidget {
  const CaptchaImage({super.key});

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
