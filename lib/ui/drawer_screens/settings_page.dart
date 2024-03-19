import 'package:flutter/material.dart';
import 'package:minivtop/ui/components/crashlytics_analytics_switch.dart';
import 'package:minivtop/ui/components/dynamic_theme_switch_tile.dart';
import 'package:minivtop/ui/components/reset_app_theme_settings.dart';
import 'package:minivtop/ui/components/theme_chooser_widget.dart';
import 'package:minivtop/ui/components/theme_mode_switcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                Text("Theming", style: Theme.of(context).textTheme.bodyMedium),
                const ResetAppThemeSettings(),
              ],
            ),
          ),
          const ThemeChooserWidget(),
          const DynamicThemeSwitchTile(),
          const ThemeModeSwitcher(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Usage & Diagnostics",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const CrashlyticsSwitchTile(),
          const AnalyticsSwitchTile(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Note: For a free & small app user reports are the only way to "
              "keep track of bugs.\n\nThe information collected is secure, "
              "does not contain any sensitive user information, and is only"
              " used for app development purposes.\n\nStill, if you don't "
              "want to share, we understand.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }
}
