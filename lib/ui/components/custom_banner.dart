import 'package:flutter/material.dart';

showBanner({
  required BuildContext context,
  required String? contentText,
  required Color? backgroundColor,
  required Duration? duration,
  required IconData? iconData,
  required Color? iconAndTextColor,
  required void Function()? onAction,
  required String? actionText,
}) {
  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

  if (contentText != null) {
    return ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: Text(
          contentText,
          style: const TextStyle().copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(
                color: iconAndTextColor ??
                    Theme.of(context).colorScheme.onSurface),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Icon(iconData ?? Icons.info,
                  color: iconAndTextColor ??
                      Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
        // backgroundColor: Theme.of(context).colorScheme.onSurface,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (onAction != null) {
                onAction();
              }
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(actionText ?? "DISMISS"),
          ),
        ],
      ),
    );
  } else {
    return null;
  }
}
