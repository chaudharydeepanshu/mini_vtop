import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';

class ThemeModeSwitcher extends StatelessWidget {
  const ThemeModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ThemeMode themeMode =
            ref.watch(appThemeStateProvider.select((value) => value.themeMode));
        String buttonText = themeMode == ThemeMode.light
            ? "Light Theme Mode"
            : themeMode == ThemeMode.dark
                ? "Dark Theme Mode"
                : "Auto/System Theme Mode";
        IconData iconData = themeMode == ThemeMode.light
            ? Icons.light_mode
            : themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.android;
        return ListTile(
          leading: Icon(iconData),
          title: const Text('Theme Mode'),
          subtitle: Text(buttonText),
          onTap: () {
            ref.read(appThemeStateProvider).updateThemeMode();
          },
        );
      },
    );
  }
}
