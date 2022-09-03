import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showCustomSnackBar(
    {String? contentText,
    Color? backgroundColor,
    Duration? duration,
    IconData? iconData,
    Color? iconAndTextColor,
    required BuildContext context}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  if (contentText != null) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      border: Border.all(
                          color: iconAndTextColor ??
                              Theme.of(context).colorScheme.surface),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Icon(iconData ?? Icons.info,
                            color: iconAndTextColor ??
                                Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  contentText,
                  style: const TextStyle().copyWith(
                    color: iconAndTextColor ??
                        Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      // action: SnackBarAction(
      //   label: 'Ok',
      //   onPressed: () {},
      // ),
    ));
  } else {
    return null;
  }
}
