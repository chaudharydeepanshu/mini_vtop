import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';

class DynamicThemeSwitchTile extends StatelessWidget {
  const DynamicThemeSwitchTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        bool isDynamicThemeEnabled = ref.watch(appThemeStateProvider
            .select((value) => value.isDynamicThemeEnabled));
        ColorScheme? lightDynamicColorScheme = ref.watch(appThemeStateProvider
            .select((value) => value.lightDynamicColorScheme));

        return lightDynamicColorScheme != null
            ? SwitchListTile(
                title: const Text("Enable Dynamic Theme"),
                subtitle: const Text("Wallpaper as theme"),
                secondary: const Icon(Icons.wallpaper),
                value: isDynamicThemeEnabled,
                onChanged: (bool? value) {
                  ref.read(appThemeStateProvider).updateDynamicThemeStatus();
                },
              )
            : const SizedBox();
      },
    );
  }
}
