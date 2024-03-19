import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/shared_preferences/preferences.dart';
import 'package:minivtop/state/providers.dart';

class ResetAppThemeSettings extends StatelessWidget {
  const ResetAppThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () async {
            sharedPreferencesInstance.remove(themeModePerfKey);
            sharedPreferencesInstance.remove(userThemeSeedColorValuePerfKey);
            sharedPreferencesInstance.remove(dynamicThemeStatusPerfKey);
            // sharedPreferencesInstance.remove(onBoardingStatusPerfKey);
            ref.read(appThemeStateProvider).updateTheme();
          },
          child: const Text('Reset'),
        );
      },
    );
  }
}
