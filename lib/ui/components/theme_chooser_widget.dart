import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/ui/components/color_picker.dart';

class ThemeChooserWidget extends StatelessWidget {
  const ThemeChooserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Color userColorSchemeSeedColor = ref.watch(appThemeStateProvider
            .select((value) => value.userColorSchemeSeedColor));
        return ListTile(
          title: const Text('Choose Theme Color'),
          subtitle: Text(
            '${ColorTools.materialNameAndCode(userColorSchemeSeedColor)} '
            'aka '
            '${ColorTools.nameThatColor(userColorSchemeSeedColor)}',
          ),
          leading: const Icon(Icons.palette),
          trailing: ColorIndicator(
            width: 44,
            height: 44,
            borderRadius: 22,
            color: userColorSchemeSeedColor,
          ),
          onTap: () async {
            // Store current color before we open the dialog.
            final Color colorBeforeDialog = userColorSchemeSeedColor;
            // Wait for the picker to close, if dialog was dismissed,
            // then restore the color we had before it was opened.
            bool dialogStatus = await colorPickerDialog(
                context: context,
                dialogPickerColor: userColorSchemeSeedColor,
                onColorChanged: (Color value) {
                  ref.read(appThemeStateProvider).updateUserTheme(value);
                });

            if (!dialogStatus) {
              ref
                  .read(appThemeStateProvider)
                  .updateUserTheme(colorBeforeDialog);
            }
          },
        );
      },
    );
  }
}
