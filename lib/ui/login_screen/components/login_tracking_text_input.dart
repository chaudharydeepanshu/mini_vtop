import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_vtop/ui/login_screen/components/textfield_caret_management.dart';

class TrackingTextInput extends StatefulWidget {
  const TrackingTextInput(
      {Key? key,
      this.onCaretMoved,
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
      this.preFilledValue})
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

  final CaretMoved? onCaretMoved;
  final TextChanged? onTextChanged;
  // final String? hint;
  // final String? label;
  final bool isObscured;
  final String? preFilledValue;

  @override
  State<TrackingTextInput> createState() => _TrackingTextInputState();
}

class _TrackingTextInputState extends State<TrackingTextInput> {
  final GlobalKey _fieldKey = GlobalKey();
  late TextEditingController _textController;
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  void debounceListener() {
    // debugPrint("${widget.label} has focus: ${_focusNode.hasFocus}");
    // We debounce the listener as sometimes the caret position is updated
    // after the listener this assures us we get an accurate caret position.
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_fieldKey.currentContext != null) {
        // Find the render editable in the field.
        final RenderObject? fieldBox =
            _fieldKey.currentContext?.findRenderObject();
        var caretPosition =
            fieldBox is RenderBox ? getCaretPosition(fieldBox) : null;

        var textFieldSize = fieldBox is RenderBox ? fieldBox.size : null;

        widget.onCaretMoved?.call(
            globalCaretPosition: caretPosition, textFieldSize: textFieldSize);
      }
    });
    widget.onTextChanged?.call(_textController.text);
  }

  late bool isObscured;

  @override
  void initState() {
    if (widget.preFilledValue != null) {
      _textController = TextEditingController()..text = widget.preFilledValue!;
    } else {
      _textController = TextEditingController();
    }

    // Listening text field focus node to change animation depending on field.
    _focusNode.addListener(debounceListener);

    // Listening changes in text field controller to get updated cursor offset.
    _textController.addListener(debounceListener);

    // Used to decide and change password visibility in text field.
    isObscured = widget.isObscured;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TrackingTextInput oldWidget) {
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      fieldKey: _fieldKey,
      labelText: widget.labelText,
      controller: _textController,
      focusNode: _focusNode,
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

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.fieldKey,
    required this.labelText,
    required this.controller,
    this.focusNode,
    required this.helperText,
    required this.validator,
    required this.inputFormatters,
    required this.autoValidateMode,
    this.prefixIcon,
    required this.suffixIcon,
    required this.isObscured,
    required this.enableSuggestions,
    required this.autocorrect,
    required this.enabled,
    required this.readOnly,
  }) : super(key: key);

  final GlobalKey<State<StatefulWidget>>? fieldKey;
  final String labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? helperText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autoValidateMode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isObscured;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool? enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        labelText: labelText,
        disabledBorder: enabled!
            ? null
            : const UnderlineInputBorder(
                // borderSide:
                //     const BorderSide(color: Colors.transparent, width: 2.0),
                // borderRadius: BorderRadius.circular(0),
                ),
        // isDense: true,
        helperText: helperText,
        // enabledBorder: const UnderlineInputBorder(),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      enabled: enabled,
      readOnly: readOnly,
      obscureText: isObscured,
      // obscuringCharacter: "*",
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      autovalidateMode: autoValidateMode,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }
}
