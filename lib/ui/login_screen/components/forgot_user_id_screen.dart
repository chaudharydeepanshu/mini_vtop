import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/ui/components/custom_snack_bar.dart';
import 'package:mini_vtop/ui/login_screen/components/login_tracking_text_input.dart';
import 'package:mini_vtop/ui/login_screen/components/upper_case_text_formatter.dart';

import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';

class ForgotUserID extends ConsumerStatefulWidget {
  const ForgotUserID({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotUserID> createState() => _ForgotUserIDState();
}

class _ForgotUserIDState extends ConsumerState<ForgotUserID> {
  final GlobalKey<FormFieldState> erpIDOrRegNoFormFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> emailOTPFormFieldKey =
      GlobalKey<FormFieldState>();

  @override
  void initState() {
    // Resetting to clear any previous state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userLoginStateProvider).updateForgotUserIDSearchStatus(
          status: ForgotUserIDSearchResponseStatus.notSearching);
      ref.read(userLoginStateProvider).updateForgotUserIDValidateStatus(
          status: ForgotUserIDValidateResponseStatus.notProcessing);
    });

    // Making a click on ForgotUserID button.
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.forgotUserIDAction(context: context);

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
          title: const Text("Forgot UserID"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                // Watching forgotUserID page status.
                final VTOPPageStatus forgotUserIDPageStatus = ref.watch(
                    vtopActionsProvider
                        .select((value) => value.forgotUserIDPageStatus));

                final VTOPStatus vtopStatus = ref.watch(
                    vtopActionsProvider.select((value) => value.vtopStatus));

                //----------- Listener for reloading forgot user id page if session gets timed out or WebView gets reloaded -----------
                // Listening to session status change.
                ref.listen(
                    vtopActionsProvider.select((value) => value.vtopStatus),
                    (previous, next) {
                  //Checking if VTOPStatus status is sessionActive and its a new status.
                  if (next == VTOPStatus.homepage && previous != next) {
                    // If true then opening the login page.
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);
                    readVTOPActionsProviderValue.openLoginPageAction(
                        context: context);
                  }
                  //Checking if login page status is loaded and its a new status.
                  else if (next == VTOPStatus.studentLoginPage &&
                      previous != next) {
                    // If true then making a click on ForgotUserID button and setting page status to processing.
                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);
                    readVTOPActionsProviderValue.forgotUserIDAction(
                        context: context);
                    readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                        status: VTOPPageStatus.processing);
                  }
                });
                //----------------------

                // Listening for validation status.
                ref.listen(
                    userLoginStateProvider
                        .select((value) => value.forgotUserIDValidateStatus),
                    (previous, next) {
                  //Checking if validation status is successful and its a new validation status.
                  if (next == ForgotUserIDValidateResponseStatus.successful &&
                      previous != next) {
                    // If true then showing the dialog with user id.
                    final String userID =
                        ref.read(userLoginStateProvider).userID;
                    userIDDialog(context: context, userID: userID);
                  }
                });

                return forgotUserIDPageStatus == VTOPPageStatus.loaded
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              ForgotUserIDSearchResponseStatus
                                  forgotUserIDSearchStatus = ref.watch(
                                      userLoginStateProvider.select((value) =>
                                          value.forgotUserIDSearchStatus));

                              return Form(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.looks_one),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextInput(
                                            fieldKey: erpIDOrRegNoFormFieldKey,
                                            prefixIcon: const Icon(Icons.badge),
                                            helperText: 'Ex:- 20BCEXXXXX',
                                            labelText: 'ERP ID / Reg. No.',
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9A-Z]")),
                                            ],
                                            validator: (String? value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter ERP ID / Reg. No.';
                                              }
                                              return null;
                                            },
                                            autoValidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            isObscured: false,
                                            enableSuggestions: true,
                                            autocorrect: false,
                                            enabled: true,
                                            readOnly: false,
                                            onTextChanged: (String value) {
                                              ref
                                                  .read(userLoginStateProvider)
                                                  .setErpIDOrRegNo(
                                                      erpIDOrRegNo: value);

                                              ref
                                                  .read(userLoginStateProvider)
                                                  .updateForgotUserIDSearchStatus(
                                                      status:
                                                          ForgotUserIDSearchResponseStatus
                                                              .notSearching);
                                              // print(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.looks_two),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ForgotUserIDSearchButton(
                                            formFieldKey:
                                                erpIDOrRegNoFormFieldKey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.looks_3),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextInput(
                                            fieldKey: emailOTPFormFieldKey,
                                            // helperText: 'Ex:- 20BCEXXXXX',
                                            prefixIcon: const Icon(Icons.pin),
                                            labelText: 'Email OTP',
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9A-Z]")),
                                            ],
                                            validator: (String? value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter OTP received on email.';
                                              }
                                              return null;
                                            },
                                            autoValidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            isObscured: false,
                                            enableSuggestions: true,
                                            autocorrect: false,
                                            enabled: forgotUserIDSearchStatus ==
                                                        ForgotUserIDSearchResponseStatus
                                                            .found ||
                                                    forgotUserIDSearchStatus ==
                                                        ForgotUserIDSearchResponseStatus
                                                            .otpTriggerWait
                                                ? true
                                                : false,
                                            readOnly: false,
                                            onTextChanged: (String value) {
                                              ref
                                                  .read(userLoginStateProvider)
                                                  .setEmailOTP(emailOTP: value);
                                              // print(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.looks_4),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ForgotUserIDValidateButton(
                                            formFieldKey: emailOTPFormFieldKey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : forgotUserIDPageStatus == VTOPPageStatus.processing
                        ? Center(
                            child: SpinKitThreeBounce(
                              size: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : vtopStatus == VTOPStatus.sessionTimedOut
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SpinKitThreeBounce(
                                      size: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    const Text(
                                        "Session timed out! Reconnecting.")
                                  ],
                                ),
                              )
                            : vtopStatus == VTOPStatus.error
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SpinKitThreeBounce(
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        const Text(
                                            "Error occurred! Reconnecting.")
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      "Unknown Status",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  );
              },
            ),
            onRefresh: () async {
              final VTOPActions readVTOPActionsProviderValue =
                  ref.read(vtopActionsProvider);
              readVTOPActionsProviderValue.forgotUserIDAction(context: context);
              readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                  status: VTOPPageStatus.processing);
            },
          ),
        ),
      ),
    );
  }
}

// showBanner({required BuildContext context, required String contentText}) {
//   String? contentText;
//   Color? backgroundColor;
//   Duration? duration;
//   IconData? iconData;
//   Color? iconAndTextColor;
//
//   return ScaffoldMessenger.of(context).showMaterialBanner(
//     MaterialBanner(
//       padding: const EdgeInsets.all(20),
//       content: Text(contentText),
//       leading: const Icon(Icons.info),
//       backgroundColor: Theme.of(context).colorScheme.onSurface,
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {},
//           child: const Text('DISMISS'),
//         ),
//       ],
//     ),
//   );
// }

Future<void> userIDDialog(
    {required BuildContext context, required String userID}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Your User ID'),
        content: Text(userID),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class ForgotUserIDSearchButton extends StatelessWidget {
  const ForgotUserIDSearchButton({Key? key, required this.formFieldKey})
      : super(key: key);

  final GlobalKey<FormFieldState> formFieldKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              ForgotUserIDSearchResponseStatus forgotUserIDSearchStatus =
                  ref.watch(userLoginStateProvider
                      .select((value) => value.forgotUserIDSearchStatus));

              ref.listen(
                  userLoginStateProvider
                      .select((value) => value.forgotUserIDSearchStatus),
                  (previous, next) {
                if (previous != next) {
                  final ForgotUserIDSearchResponseStatus
                      forgotUserIDSearchStatus =
                      ref.read(userLoginStateProvider).forgotUserIDSearchStatus;

                  final Duration otpTriggerWait =
                      ref.read(userLoginStateProvider).otpTriggerWait;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  SnackBar? snackBar = forgotUserIDSearchSnackBar(
                      status: forgotUserIDSearchStatus,
                      otpTriggerWait: otpTriggerWait,
                      context: context);
                  if (snackBar != null) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              });

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  if (formFieldKey.currentState!.validate()) {
                    FocusManager.instance.primaryFocus?.unfocus();

                    ref
                        .read(userLoginStateProvider)
                        .updateForgotUserIDSearchStatus(
                            status: ForgotUserIDSearchResponseStatus.searching);

                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);

                    readVTOPActionsProviderValue.forgotUserIDSearchAction(
                        context: context);
                  }
                },
                child: Center(
                  child: forgotUserIDSearchStatus !=
                          ForgotUserIDSearchResponseStatus.searching
                      ? const Text('Search & Send OTP')
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

class ForgotUserIDValidateButton extends StatelessWidget {
  const ForgotUserIDValidateButton({Key? key, required this.formFieldKey})
      : super(key: key);

  final GlobalKey<FormFieldState> formFieldKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              ForgotUserIDSearchResponseStatus forgotUserIDSearchStatus =
                  ref.watch(userLoginStateProvider
                      .select((value) => value.forgotUserIDSearchStatus));

              ForgotUserIDValidateResponseStatus forgotUserIDValidateStatus =
                  ref.watch(userLoginStateProvider
                      .select((value) => value.forgotUserIDValidateStatus));

              ref.listen(
                  userLoginStateProvider
                      .select((value) => value.forgotUserIDValidateStatus),
                  (previous, next) {
                if (previous != next) {
                  final ForgotUserIDValidateResponseStatus
                      forgotUserIDValidateStatus = ref
                          .read(userLoginStateProvider)
                          .forgotUserIDValidateStatus;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  SnackBar? snackBar = forgotUserIDValidateSnackBar(
                      status: forgotUserIDValidateStatus, context: context);
                  if (snackBar != null) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              });

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: forgotUserIDSearchStatus ==
                            ForgotUserIDSearchResponseStatus.found ||
                        forgotUserIDSearchStatus ==
                            ForgotUserIDSearchResponseStatus.otpTriggerWait
                    ? () {
                        if (formFieldKey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();

                          ref
                              .read(userLoginStateProvider)
                              .updateForgotUserIDValidateStatus(
                                  status: ForgotUserIDValidateResponseStatus
                                      .processing);

                          final VTOPActions readVTOPActionsProviderValue =
                              ref.read(vtopActionsProvider);

                          readVTOPActionsProviderValue
                              .forgotUserIDValidateAction(context: context);
                        }
                      }
                    : null,
                child: Center(
                  child: forgotUserIDValidateStatus !=
                          ForgotUserIDValidateResponseStatus.processing
                      ? const Text('Validate')
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

SnackBar? forgotUserIDSearchSnackBar(
    {required ForgotUserIDSearchResponseStatus status,
    Duration? otpTriggerWait,
    required BuildContext context}) {
  String? contentText;
  Color? backgroundColor;
  Duration? duration;
  IconData? iconData;
  Color? iconAndTextColor;

  if (status == ForgotUserIDSearchResponseStatus.notFound) {
    contentText = 'ERP ID / Reg. No. invalid! Please try again.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == ForgotUserIDSearchResponseStatus.unknownResponse) {
    contentText =
        'Unknown response! Please try again latter or use official VTOP for now.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == ForgotUserIDSearchResponseStatus.otpTriggerWait) {
    contentText =
        'OTP already sent so use that.${otpTriggerWait != null && otpTriggerWait != Duration.zero ? "\nFor generating new OTP please wait ${otpTriggerWait > const Duration(minutes: 1) ? "${otpTriggerWait.inMinutes} minutes" : "${otpTriggerWait.inSeconds} seconds"} more." : ""}';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  } else if (status == ForgotUserIDSearchResponseStatus.found) {
    contentText = 'Verified! Enter OTP sent via Email.';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  } else if (status == ForgotUserIDSearchResponseStatus.searching) {
    contentText = 'Searching! Please wait.';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  }

  return customSnackBar(
    context: context,
    contentText: contentText,
    backgroundColor: backgroundColor,
    duration: duration,
    iconData: iconData,
    iconAndTextColor: iconAndTextColor,
  );
}

SnackBar? forgotUserIDValidateSnackBar(
    {required ForgotUserIDValidateResponseStatus status,
    required BuildContext context}) {
  String? contentText;
  Color? backgroundColor;
  Duration? duration;
  IconData? iconData;
  Color? iconAndTextColor;

  if (status == ForgotUserIDValidateResponseStatus.invalidOTP) {
    contentText = 'OTP was invalid! Please try again.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == ForgotUserIDValidateResponseStatus.unknownResponse) {
    contentText =
        'Unknown response! Please try again latter or use official VTOP for now.';
    backgroundColor = Theme.of(context).colorScheme.errorContainer;
    duration = const Duration(days: 365);
    iconData = Icons.warning;
    iconAndTextColor = Theme.of(context).colorScheme.error;
  } else if (status == ForgotUserIDValidateResponseStatus.successful) {
    contentText = 'Found it!';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  } else if (status == ForgotUserIDValidateResponseStatus.processing) {
    contentText = 'Processing! Please wait.';
    backgroundColor = null;
    duration = null;
    iconData = null;
    iconAndTextColor = null;
  }

  return customSnackBar(
    context: context,
    contentText: contentText,
    backgroundColor: backgroundColor,
    duration: duration,
    iconData: iconData,
    iconAndTextColor: iconAndTextColor,
  );
}

class TextInput extends StatefulWidget {
  const TextInput(
      {Key? key,
      this.onTextChanged,
      // this.hint,
      // this.label,
      this.isObscured = false,
      required this.labelText,
      this.helperText,
      this.validator,
      this.inputFormatters,
      this.autoValidateMode,
      required this.enableSuggestions,
      required this.autocorrect,
      this.enabled,
      required this.readOnly,
      this.prefixIcon,
      this.preFilledValue,
      this.fieldKey})
      : super(key: key);

  final String labelText;
  final String? helperText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autoValidateMode;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool? enabled;
  final bool readOnly;
  final Widget? prefixIcon;

  final ValueChanged<String>? onTextChanged;
  // final String? hint;
  // final String? label;
  final bool isObscured;
  final String? preFilledValue;
  final GlobalKey<FormFieldState>? fieldKey;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late final GlobalKey<FormFieldState> _fieldKey =
      widget.fieldKey ?? GlobalKey<FormFieldState>();
  late TextEditingController _textController;

  late bool isObscured;

  void textControllerListener() {
    widget.onTextChanged?.call(_textController.text);
  }

  @override
  void initState() {
    if (widget.preFilledValue != null) {
      _textController = TextEditingController()..text = widget.preFilledValue!;
    } else {
      _textController = TextEditingController();
    }

    // Listening changes in text field controller to get updated cursor offset.
    _textController.addListener(textControllerListener);

    // Used to decide and change password visibility in text field.
    isObscured = widget.isObscured;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextInput oldWidget) {
    if (oldWidget.preFilledValue != widget.preFilledValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.preFilledValue != null) {
          _textController.text = widget.preFilledValue!;
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      fieldKey: _fieldKey,
      labelText: widget.labelText,
      controller: _textController,
      helperText: widget.helperText,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      autoValidateMode: widget.autoValidateMode,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.isObscured
          ? IconButton(
              icon: Icon(
                isObscured ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isObscured = !isObscured;
                });
              },
            )
          : const SizedBox(),
      isObscured: isObscured,
      enableSuggestions: widget.enableSuggestions,
      autocorrect: widget.autocorrect,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
    );
  }
}
