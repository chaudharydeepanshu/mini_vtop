import 'package:flutter/material.dart';
import 'package:minivtop/ui/components/dynamic_theme_switch_tile.dart';
import 'package:minivtop/ui/components/reset_app_theme_settings.dart';
import 'package:minivtop/ui/components/theme_chooser_widget.dart';
import 'package:minivtop/ui/components/theme_mode_switcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("App Theming",
                    style: Theme.of(context).textTheme.bodyMedium),
                const ResetAppThemeSettings(),
              ],
            ),
          ),
          const ThemeChooserWidget(),
          const DynamicThemeSwitchTile(),
          const ThemeModeSwitcher(),
        ],
      ),
    );
  }
}
