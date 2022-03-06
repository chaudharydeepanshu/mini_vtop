import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoCalc {
  static PackageInfo? packageInfo;
  static String? appName;
  static String? packageName;
  static String? version;
  static String? buildNumber;

  Future<void> init(BuildContext context) async {
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
    version = packageInfo!.version;
    buildNumber = packageInfo!.buildNumber;
  }
}
