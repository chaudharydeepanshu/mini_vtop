import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoCalc extends ChangeNotifier {
  late PackageInfo packageInfo;
  late String appName;
  late String packageName;
  late String version;
  late String buildNumber;

  Future init(PackageInfo info) async {
    packageInfo = info;
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
