import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';

class ThemeModeSwitcher extends StatelessWidget {
  const ThemeModeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ThemeMode themeMode =
            ref.watch(appThemeStateProvider.select((value) => value.themeMode));
        String buttonText = themeMode == ThemeMode.light
            ? "Light"
            : themeMode == ThemeMode.dark
                ? "Dark"
                : "System";
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
