import 'package:flutter/material.dart';
import 'package:minivtop/main.dart';
import 'package:minivtop/shared_preferences/preferences.dart';

/// [SwitchListTile] for enabling or disabling crashlytics data collection.
class CrashlyticsSwitchTile extends StatefulWidget {
  /// Defining [CrashlyticsSwitchTile] constructor.
  const CrashlyticsSwitchTile({super.key});

  @override
  State<CrashlyticsSwitchTile> createState() => _CrashlyticsSwitchTileState();
}

class _CrashlyticsSwitchTileState extends State<CrashlyticsSwitchTile> {
  bool isCrashlyticsEnabled =
      crashlyticsInstance.isCrashlyticsCollectionEnabled;

  @override
  Widget build(BuildContext context) {
    String crashlyticsListTileTitle = "Crashlytics";
    String crashlyticsListTileSubtitle = "Share crash-reports for bugs fixing";

    return SwitchListTile(
      title: Text(crashlyticsListTileTitle),
      subtitle: Text(
        crashlyticsListTileSubtitle,
      ),
      secondary: const Icon(Icons.bug_report),
      value: isCrashlyticsEnabled,
      onChanged: (bool? value) async {
        await Preferences.persistCrashlyticsCollectionStatus(
          !isCrashlyticsEnabled,
        );
        setState(() {
          isCrashlyticsEnabled =
              crashlyticsInstance.isCrashlyticsCollectionEnabled;
        });
      },
    );
  }
}

/// [SwitchListTile] for enabling or disabling analytics data collection.
class AnalyticsSwitchTile extends StatefulWidget {
  /// Defining [AnalyticsSwitchTile] constructor.
  const AnalyticsSwitchTile({super.key});

  @override
  State<AnalyticsSwitchTile> createState() => _AnalyticsSwitchTileState();
}

class _AnalyticsSwitchTileState extends State<AnalyticsSwitchTile> {
  bool isAnalyticsEnabled = Preferences.analyticsCollectionStatus;

  @override
  Widget build(BuildContext context) {
    String analyticsListTileTitle = "Analytics";
    String analyticsListTileSubtitle = "Share app usage for app improvement";

    return SwitchListTile(
      title: Text(analyticsListTileTitle),
      subtitle: Text(
        analyticsListTileSubtitle,
      ),
      secondary: const Icon(Icons.analytics),
      value: isAnalyticsEnabled,
      onChanged: (bool? value) async {
        await Preferences.persistAnalyticsCollectionStatus(!isAnalyticsEnabled);
        setState(() {
          isAnalyticsEnabled = Preferences.analyticsCollectionStatus;
        });
      },
    );
  }
}
