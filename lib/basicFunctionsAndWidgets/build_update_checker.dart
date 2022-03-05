import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:mini_vtop/basicFunctionsAndWidgets/stop_pop.dart';

import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/proccessing_dialog.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/settings.dart';
import 'custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import 'package:dio/dio.dart';
import 'direct_pop.dart';
import 'package:open_file/open_file.dart';

import 'get_cache_file_path_from_file_name.dart';
import 'lifecycle_event_handler.dart';

class BuildUpdateChecker extends StatefulWidget {
  const BuildUpdateChecker(
      {Key? key,
      required this.screenBasedPixelWidth,
      required this.screenBasedPixelHeight,
      required this.onPressedUpdate,
      required this.onProcessingSomething})
      : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final ValueChanged<bool> onProcessingSomething;
  final ValueChanged<String?> onPressedUpdate;

  @override
  _BuildUpdateCheckerState createState() => _BuildUpdateCheckerState();
}

class _BuildUpdateCheckerState extends State<BuildUpdateChecker> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;
  late final double _screenBasedPixelHeight = widget.screenBasedPixelHeight;

  bool installPackagesPermissionPermanentlyDenied = false;
  bool installPackagesPermissionFirstRun = true;
  late List<Widget>
      dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission;
  late List<Widget> dialogActionButtonsListForDeniedInstallPackagesPermission;
  late String dialogTextForPermanentlyDeniedInstallPackagesPermission;
  late String dialogTextForDeniedInstallPackagesPermission;

  bool storagePermissionPermanentlyDenied = false;
  bool storagePermissionFirstRun = true;
  late List<Widget>
      dialogActionButtonsListForPermanentlyDeniedStoragePermission;
  late List<Widget> dialogActionButtonsListForDeniedStoragePermission;
  late String dialogTextForPermanentlyDeniedStoragePermission;
  late String dialogTextForDeniedStoragePermission;

  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  Future<void> packageInfoCalc() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo!.appName;
      packageName = packageInfo!.packageName;
      version = packageInfo!.version;
      buildNumber = packageInfo!.buildNumber;
    });
  }

  Version? currentVersion;
  Version? latestVersion;
  String? releaseDescription;
  String? releaseDownloadUrl;
  double? downloadProgress;
  String? releaseFileName;
  String? releaseSavePath;

  @override
  void initState() {
    packageInfoCalc().whenComplete(() {
      currentVersion = Version.parse("$version+$buildNumber");
    });

    if (installPackagesPermissionFirstRun) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        debugPrint('build complete');
        if (await Permission.requestInstallPackages.isGranted == true) {
          setState(() {
            installPackagesPermissionPermanentlyDenied = false;
          });
        } else {
          getBoolValuesSF() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            //Return bool
            bool storagePermissionPermanentlyDeniedBoolValue = prefs.getBool(
                    'installPackagesPermissionPermanentlyDeniedBoolValue') ??
                false;
            debugPrint(prefs
                .getBool('installPackagesPermissionPermanentlyDeniedBoolValue')
                .toString());
            return storagePermissionPermanentlyDeniedBoolValue;
          }

          bool value = await getBoolValuesSF();
          setState(() {
            installPackagesPermissionPermanentlyDenied = value;
          });
        }
        installPackagesPermissionFirstRun = false;
        return;
      });
    }
    if (storagePermissionFirstRun) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        debugPrint('build complete');
        if (await Permission.storage.isGranted == true) {
          setState(() {
            storagePermissionPermanentlyDenied = false;
          });
        } else {
          getBoolValuesSF() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            //Return bool
            bool storagePermissionPermanentlyDeniedBoolValue =
                prefs.getBool('storagePermissionPermanentlyDeniedBoolValue') ??
                    false;
            debugPrint(prefs
                .getBool('storagePermissionPermanentlyDeniedBoolValue')
                .toString());
            return storagePermissionPermanentlyDeniedBoolValue;
          }

          bool value = await getBoolValuesSF();
          setState(() {
            storagePermissionPermanentlyDenied = value;
          });
        }
        storagePermissionFirstRun = false;
        return;
      });
    }

    WidgetsBinding.instance!
        .addObserver(LifecycleEventHandler(resumeCallBack: () async {
      debugPrint('resumeCallBack');
      if (await Permission.requestInstallPackages.isGranted == true) {
        if (mounted) {
          setState(() {
            installPackagesPermissionPermanentlyDenied = false;
          });
        }
        addBoolToSF() async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool(
              'installPackagesPermissionPermanentlyDeniedBoolValue', false);
        }

        addBoolToSF();
      }
      if (await Permission.storage.isGranted == true) {
        if (mounted) {
          setState(() {
            installPackagesPermissionPermanentlyDenied = false;
          });
        }
        addBoolToSF() async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('storagePermissionPermanentlyDeniedBoolValue', false);
        }

        addBoolToSF();
      }
    }));

    dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission = [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'NOT NOW',
        ),
      ),
      CustomTextButton(
        onPressed: () async {
          Navigator.pop(context);
          await openAppSettings().then((value) {
            debugPrint('setting could be opened: $value');
            return null;
          });
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'SETTINGS',
        ),
      ),
    ];

    dialogActionButtonsListForDeniedInstallPackagesPermission = [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'OK',
        ),
      ),
    ];

    dialogTextForPermanentlyDeniedInstallPackagesPermission =
        'In order to install update, Mini VTOP app require access to install unknown apps permission.\nTo allow this permission tap Settings > Advanced > Install unknown apps and select "Allow from this source".';
    dialogTextForDeniedInstallPackagesPermission =
        'In order to install update, Mini VTOP app requires access to install unknown apps permission. Please allow access it continue further.';

    dialogActionButtonsListForPermanentlyDeniedStoragePermission = [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'NOT NOW',
        ),
      ),
      CustomTextButton(
        onPressed: () async {
          Navigator.pop(context);
          await openAppSettings().then((value) {
            debugPrint('setting could be opened: $value');
            return null;
          });
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'SETTINGS',
        ),
      ),
    ];

    dialogActionButtonsListForDeniedStoragePermission = [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'OK',
        ),
      ),
    ];

    dialogTextForPermanentlyDeniedStoragePermission =
        'In order to install update, Mini VTOP app requires access to photos and media permission.\nTo allow this permission tap Settings > Permissions > Files and Media and select "Allow access to media only".';
    dialogTextForDeniedStoragePermission =
        'In order to install update, Mini VTOP app requires access to photos and media permission. Please allow access it continue further.';

    super.initState();
  }

  @override
  void didUpdateWidget(BuildUpdateChecker oldWidget) {
    if (oldWidget != widget) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _makeGetRequest() async {
    // make request
    var url = Uri.parse(
        "https://api.github.com/repos/deepuc/mini_vtop_updater/releases");
    http.Response response = await http.get(url);

    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String? contentType = headers['content-type'];
    String json = response.body;
    Map<String, dynamic> data = jsonDecode(json)[0];
    latestVersion = Version.parse("${data["tag_name"].substring(1)}");
    releaseDescription = data["body"];
    releaseDownloadUrl = data["assets"][0]["browser_download_url"];
    releaseFileName = data["assets"][0]["name"];
    releaseSavePath = await getCacheFilePathFromFileName(releaseFileName!);
    // downloadDirectory.path + "/$releaseFileName";
    // String verse = data["contents"]["verse"];
    // dynamic chapter= data["contents"]["chapter"];

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json)));
    debugPrint("statusCode: $statusCode");
    // debugPrint("contentType: $contentType");
    // debugPrint("data: $data");
    debugPrint("releaseDescription: $releaseDescription");
    debugPrint(
        "currentReleaseVersion:$currentVersion , latestReleaseVersion: $latestVersion");
  }

  bool isDialogShowing = false;

  Directory downloadDirectory = Directory('/storage/emulated/0/Download');

  @override
  void dispose() {
    // IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;

  // downloading logic is handled by this method
  CancelToken cancelToken = CancelToken();

  Future<void> downloadFile(uri) async {
    final targetFile = Directory(releaseSavePath!);
    if (targetFile.existsSync()) {
      targetFile.deleteSync(recursive: true);
    } else {
      debugPrint("File with path $releaseSavePath doesn't exist");
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
          downloading = true;
        }));

    Dio dio = Dio();

    dio.download(
      uri,
      releaseSavePath,
      cancelToken: cancelToken,
      onReceiveProgress: (rcv, total) {
        // print(
        //     'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

        WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
              progress = ((rcv / total) * 100).toStringAsFixed(0);
              debugPrint(progress);
              if (_setState != null) {
                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  if (isDialogShowing) {
                    _setState!(() {
                      downloadProgress = int.parse(progress).toDouble() / 100;
                    });
                  }
                });
              }
            }));

        if (progress == '100') {
          WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
                isDownloaded = true;
                if (_setState != null) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    if (isDialogShowing) {
                      _setState!(() {});
                    }
                  });
                }
              }));
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
            if (progress == '100') {
              isDownloaded = true;
            }

            downloading = false;
            if (_setState != null) {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                if (isDialogShowing) {
                  _setState!(() {});
                }
              });
            }
          }));
    }).catchError((e) {
      if (CancelToken.isCancel(e)) {
        print('$releaseDownloadUrl: $e');
      }
    });
  }

  StateSetter? _setState;

  var _openResult = 'Unknown';

  Future<void> openFile() async {
    final result = await OpenFile.open(releaseSavePath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
    debugPrint(_openResult);
  }

  @override
  Widget build(BuildContext context) {
    if (isDialogShowing == true && isDownloaded == true) {
      Navigator.of(context).pop();
      isDialogShowing = false;
      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint("Going to pop dialog and open file");
        // cancelToken.cancel();

        // isDownloaded = false;
        openFile();
      });
    }
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Check Update",
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: _screenBasedPixelWidth),
          ),
          SizedBox(
            width: widgetSizeProvider(
                fixedSize: 5, sizeDecidingVariable: _screenBasedPixelWidth),
          ),
          SizedBox(
            width: widgetSizeProvider(
                fixedSize: 280, sizeDecidingVariable: _screenBasedPixelWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomElevatedButton(
                    onPressed: currentVersion != null
                        ? () async {
                            if (installPackagesPermissionPermanentlyDenied ==
                                false) //if this condition true then that means storage Permission is not Permanently Denied
                            {
                              if (isDownloaded == false) {
                                final statusOfInstallPackagesPermission =
                                    Platform.isAndroid || Platform.isIOS
                                        ? await Permission
                                            .requestInstallPackages
                                            .request()
                                        : PermissionStatus.granted;
                                if (statusOfInstallPackagesPermission ==
                                    PermissionStatus.granted) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(customSnackBar(
                                      snackBarText:
                                          "Checking for updates. Please Wait.",
                                      screenBasedPixelWidth:
                                          _screenBasedPixelWidth,
                                      context: context,
                                    ));
                                  await _makeGetRequest().whenComplete(() {
                                    if (latestVersion != null) {
                                      if (latestVersion! > currentVersion) {
                                        debugPrint("Latest version available");
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(customSnackBar(
                                            snackBarText: "Update available.",
                                            screenBasedPixelWidth:
                                                _screenBasedPixelWidth,
                                            context: context,
                                          ));
                                        // WidgetsBinding.instance
                                        //     ?.addPostFrameCallback((_) {
                                        customDialogBox(
                                          isDialogShowing: isDialogShowing,
                                          context: context,
                                          onIsDialogShowing: (bool value) {
                                            setState(() {
                                              isDialogShowing = value;
                                            });
                                          },
                                          dialogTitle: Text(
                                            'Update available',
                                            style: getDynamicTextStyle(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.87)),
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                            textAlign: TextAlign.center,
                                          ),
                                          dialogChildren: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CustomBox(
                                                  settingsType: 'Description',
                                                  screenBasedPixelWidth:
                                                      _screenBasedPixelWidth,
                                                  screenBasedPixelHeight:
                                                      _screenBasedPixelHeight,
                                                  settingsBoxChildren: [
                                                    SizedBox(
                                                      height: 80,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              releaseDescription!,
                                                              style: getDynamicTextStyle(
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText1
                                                                      ?.copyWith(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onSurface
                                                                              .withOpacity(
                                                                                  0.60)),
                                                                  sizeDecidingVariable:
                                                                      _screenBasedPixelWidth),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: widgetSizeProvider(
                                                      fixedSize: 28,
                                                      sizeDecidingVariable:
                                                          _screenBasedPixelWidth),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    CustomTextButton(
                                                      onPressed: () async {
                                                        storagePermissionPermanentlyDenied =
                                                            false; //for disabling permission check
                                                        if (storagePermissionPermanentlyDenied ==
                                                            false) {
                                                          const statusOfStoragePermission =
                                                              PermissionStatus
                                                                  .granted; //for disabling permission check
                                                          // final statusOfStoragePermission =
                                                          //     Platform.isAndroid ||
                                                          //             Platform
                                                          //                 .isIOS
                                                          //         ? await Permission
                                                          //             .storage
                                                          //             .request()
                                                          //         : PermissionStatus
                                                          //             .granted;
                                                          if (statusOfStoragePermission ==
                                                              PermissionStatus
                                                                  .granted) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            WidgetsBinding
                                                                .instance
                                                                ?.addPostFrameCallback(
                                                                    (_) =>
                                                                        setState(
                                                                            () {
                                                                          isDialogShowing =
                                                                              true; // set it `true` since dialog is being displayed
                                                                        }));
                                                            await showDialog<
                                                                bool>(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                cancelToken =
                                                                    CancelToken();
                                                                progress = "0";
                                                                downloadProgress =
                                                                    null;
                                                                isDownloaded =
                                                                    false;
                                                                downloadFile(
                                                                    releaseDownloadUrl);

                                                                return StatefulBuilder(
                                                                  // You need this, notice the parameters below:
                                                                  builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                    _setState =
                                                                        setState;
                                                                    return WillPopScope(
                                                                      onWillPop:
                                                                          () {
                                                                        return isDialogShowing
                                                                            ? stopPop()
                                                                            : directPop(onProcessingSomething:
                                                                                (bool value) {
                                                                                widget.onProcessingSomething.call(value);
                                                                              });
                                                                      },
                                                                      child:
                                                                          SimpleDialog(
                                                                        title:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Downloading',
                                                                            style:
                                                                                getDynamicTextStyle(textStyle: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)), sizeDecidingVariable: _screenBasedPixelWidth),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        titlePadding:
                                                                            EdgeInsets.fromLTRB(
                                                                          widgetSizeProvider(
                                                                              fixedSize: 24,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 24,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 24,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 0,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                        ),
                                                                        contentPadding:
                                                                            EdgeInsets.fromLTRB(
                                                                          widgetSizeProvider(
                                                                              fixedSize: 0,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 12,
                                                                              sizeDecidingVariable: widget.screenBasedPixelHeight),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 0,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 16,
                                                                              sizeDecidingVariable: widget.screenBasedPixelHeight),
                                                                        ),
                                                                        insetPadding:
                                                                            EdgeInsets.fromLTRB(
                                                                          widgetSizeProvider(
                                                                              fixedSize: 0,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 12,
                                                                              sizeDecidingVariable: widget.screenBasedPixelHeight),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 0,
                                                                              sizeDecidingVariable: widget.screenBasedPixelWidth),
                                                                          widgetSizeProvider(
                                                                              fixedSize: 16,
                                                                              sizeDecidingVariable: widget.screenBasedPixelHeight),
                                                                        ),
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Please do NOT exit the app during this process!",
                                                                                  style: getDynamicTextStyle(textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60)), sizeDecidingVariable: _screenBasedPixelWidth),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: widgetSizeProvider(fixedSize: 8, sizeDecidingVariable: _screenBasedPixelWidth),
                                                                                ),
                                                                                ProgressIndicator(
                                                                                  downloadProgress: downloadProgress,
                                                                                ),

                                                                                // LinearProgressIndicator(
                                                                                //   value: int.parse(progress).toDouble() /
                                                                                //       100,
                                                                                //   // downloadProgress,
                                                                                //   // animation.value,
                                                                                // ),
                                                                                SizedBox(
                                                                                  height: widgetSizeProvider(fixedSize: 28, sizeDecidingVariable: _screenBasedPixelWidth),
                                                                                ),
                                                                                FittedBox(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Downloading app-release.apk",
                                                                                        style: getDynamicTextStyle(textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60)), sizeDecidingVariable: _screenBasedPixelWidth),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: widgetSizeProvider(fixedSize: 8, sizeDecidingVariable: _screenBasedPixelWidth),
                                                                                      ),
                                                                                      CustomTextButton(
                                                                                        onPressed: () {
                                                                                          // FlutterDownloader
                                                                                          //     .cancelAll();
                                                                                          cancelToken.cancel();
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        screenBasedPixelWidth: _screenBasedPixelWidth,
                                                                                        screenBasedPixelHeight: _screenBasedPixelHeight,
                                                                                        size: const Size(20, 50),
                                                                                        borderRadius: 20,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                                                        child: const Text(
                                                                                          'Cancel',
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ).then((_) =>
                                                                isDialogShowing =
                                                                    false);
                                                          } else if (statusOfStoragePermission ==
                                                              PermissionStatus
                                                                  .denied) {
                                                            debugPrint(
                                                                'Denied. Show a dialog with a reason and again ask for the permission.');
                                                            customDialogBox(
                                                              screenBasedPixelHeight:
                                                                  _screenBasedPixelHeight,
                                                              onProcessingSomething:
                                                                  (bool
                                                                      value) {},
                                                              dialogChildren:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      dialogTextForDeniedStoragePermission,
                                                                      style: getDynamicTextStyle(
                                                                          textStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyText1
                                                                              ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60)),
                                                                          sizeDecidingVariable: _screenBasedPixelWidth),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: widgetSizeProvider(
                                                                          fixedSize:
                                                                              28,
                                                                          sizeDecidingVariable:
                                                                              _screenBasedPixelWidth),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children:
                                                                          dialogActionButtonsListForDeniedStoragePermission,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              barrierDismissible:
                                                                  true,
                                                              isDialogShowing:
                                                                  isDialogShowing,
                                                              onIsDialogShowing:
                                                                  (bool value) {
                                                                setState(() {
                                                                  isDialogShowing =
                                                                      value;
                                                                });
                                                              },
                                                              screenBasedPixelWidth:
                                                                  _screenBasedPixelWidth,
                                                              context: context,
                                                              dialogTitle: Text(
                                                                'Need Permission',
                                                                style: getDynamicTextStyle(
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(
                                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(
                                                                                0.87)),
                                                                    sizeDecidingVariable:
                                                                        _screenBasedPixelWidth),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            );
                                                          } else if (statusOfStoragePermission ==
                                                              PermissionStatus
                                                                  .permanentlyDenied) {
                                                            debugPrint(
                                                                'Take the user to the settings page.');
                                                            setState(() {
                                                              storagePermissionPermanentlyDenied =
                                                                  true;
                                                            });
                                                            addBoolToSF() async {
                                                              SharedPreferences
                                                                  prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              prefs.setBool(
                                                                  'storagePermissionPermanentlyDeniedBoolValue',
                                                                  true);
                                                            }

                                                            addBoolToSF();
                                                            customDialogBox(
                                                              screenBasedPixelHeight:
                                                                  _screenBasedPixelHeight,
                                                              onProcessingSomething:
                                                                  (bool
                                                                      value) {},
                                                              dialogChildren:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      dialogTextForPermanentlyDeniedStoragePermission,
                                                                      style: getDynamicTextStyle(
                                                                          textStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyText1
                                                                              ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60)),
                                                                          sizeDecidingVariable: _screenBasedPixelWidth),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: widgetSizeProvider(
                                                                          fixedSize:
                                                                              28,
                                                                          sizeDecidingVariable:
                                                                              _screenBasedPixelWidth),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children:
                                                                          dialogActionButtonsListForPermanentlyDeniedStoragePermission,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              barrierDismissible:
                                                                  true,
                                                              isDialogShowing:
                                                                  isDialogShowing,
                                                              onIsDialogShowing:
                                                                  (bool value) {
                                                                setState(() {
                                                                  isDialogShowing =
                                                                      value;
                                                                });
                                                              },
                                                              screenBasedPixelWidth:
                                                                  _screenBasedPixelWidth,
                                                              context: context,
                                                              dialogTitle: Text(
                                                                'Need Permission',
                                                                style: getDynamicTextStyle(
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline6
                                                                        ?.copyWith(
                                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(
                                                                                0.87)),
                                                                    sizeDecidingVariable:
                                                                        _screenBasedPixelWidth),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          customDialogBox(
                                                            screenBasedPixelHeight:
                                                                _screenBasedPixelHeight,
                                                            onProcessingSomething:
                                                                (bool value) {},
                                                            dialogChildren:
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    dialogTextForPermanentlyDeniedStoragePermission,
                                                                    style: getDynamicTextStyle(
                                                                        textStyle: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText1
                                                                            ?.copyWith(
                                                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(
                                                                                    0.60)),
                                                                        sizeDecidingVariable:
                                                                            _screenBasedPixelWidth),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  SizedBox(
                                                                    height: widgetSizeProvider(
                                                                        fixedSize:
                                                                            28,
                                                                        sizeDecidingVariable:
                                                                            _screenBasedPixelWidth),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children:
                                                                        dialogActionButtonsListForPermanentlyDeniedStoragePermission,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            barrierDismissible:
                                                                true,
                                                            isDialogShowing:
                                                                isDialogShowing,
                                                            onIsDialogShowing:
                                                                (bool value) {
                                                              setState(() {
                                                                isDialogShowing =
                                                                    value;
                                                              });
                                                            },
                                                            screenBasedPixelWidth:
                                                                _screenBasedPixelWidth,
                                                            context: context,
                                                            dialogTitle: Text(
                                                              'Need Permission',
                                                              style: getDynamicTextStyle(
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headline6
                                                                      ?.copyWith(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onSurface
                                                                              .withOpacity(
                                                                                  0.87)),
                                                                  sizeDecidingVariable:
                                                                      _screenBasedPixelWidth),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      screenBasedPixelWidth:
                                                          _screenBasedPixelWidth,
                                                      screenBasedPixelHeight:
                                                          _screenBasedPixelHeight,
                                                      size: const Size(20, 50),
                                                      borderRadius: 20,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 16),
                                                      child: const Text(
                                                        'UPDATE',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: widgetSizeProvider(
                                                          fixedSize: 8,
                                                          sizeDecidingVariable:
                                                              _screenBasedPixelWidth),
                                                    ),
                                                    CustomTextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      screenBasedPixelWidth:
                                                          _screenBasedPixelWidth,
                                                      screenBasedPixelHeight:
                                                          _screenBasedPixelHeight,
                                                      size: const Size(20, 50),
                                                      borderRadius: 20,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 16),
                                                      child: const Text(
                                                        'NO THANKS',
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          barrierDismissible: true,
                                          screenBasedPixelHeight:
                                              _screenBasedPixelHeight,
                                          screenBasedPixelWidth:
                                              _screenBasedPixelWidth,
                                          onProcessingSomething: (bool value) {
                                            widget.onProcessingSomething
                                                .call(value);
                                          },
                                        ).then((_) => isDialogShowing = false);
                                        debugPrint("dialogBox initiated");
                                        // });
                                      } else if (latestVersion ==
                                          currentVersion) {
                                        debugPrint(
                                            "Using latest version available");
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(customSnackBar(
                                            snackBarText:
                                                "Already using the latest version.",
                                            screenBasedPixelWidth:
                                                _screenBasedPixelWidth,
                                            context: context,
                                          ));
                                      } else {
                                        debugPrint(
                                            "Using higher version than available");
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(customSnackBar(
                                            snackBarText:
                                                "Already using the latest version.",
                                            screenBasedPixelWidth:
                                                _screenBasedPixelWidth,
                                            context: context,
                                          ));
                                      }
                                    }
                                    return null;
                                  });
                                } else if (statusOfInstallPackagesPermission ==
                                    PermissionStatus.denied) {
                                  debugPrint(
                                      'Denied. Show a dialog with a reason and again ask for the permission.');
                                  customDialogBox(
                                    screenBasedPixelHeight:
                                        _screenBasedPixelHeight,
                                    onProcessingSomething: (bool value) {},
                                    dialogChildren: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dialogTextForDeniedInstallPackagesPermission,
                                            style: getDynamicTextStyle(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.60)),
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: widgetSizeProvider(
                                                fixedSize: 28,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children:
                                                dialogActionButtonsListForDeniedInstallPackagesPermission,
                                          ),
                                        ],
                                      ),
                                    ),
                                    barrierDismissible: true,
                                    isDialogShowing: isDialogShowing,
                                    onIsDialogShowing: (bool value) {
                                      setState(() {
                                        isDialogShowing = value;
                                      });
                                    },
                                    screenBasedPixelWidth:
                                        _screenBasedPixelWidth,
                                    context: context,
                                    dialogTitle: Text(
                                      'Need Permission',
                                      style: getDynamicTextStyle(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.87)),
                                          sizeDecidingVariable:
                                              _screenBasedPixelWidth),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                } else if (statusOfInstallPackagesPermission ==
                                    PermissionStatus.permanentlyDenied) {
                                  debugPrint(
                                      'Take the user to the settings page.');
                                  setState(() {
                                    installPackagesPermissionPermanentlyDenied =
                                        true;
                                  });
                                  addBoolToSF() async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool(
                                        'installPackagesPermissionPermanentlyDeniedBoolValue',
                                        true);
                                  }

                                  addBoolToSF();
                                  customDialogBox(
                                    screenBasedPixelHeight:
                                        _screenBasedPixelHeight,
                                    onProcessingSomething: (bool value) {},
                                    dialogChildren: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dialogTextForPermanentlyDeniedInstallPackagesPermission,
                                            style: getDynamicTextStyle(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.60)),
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: widgetSizeProvider(
                                                fixedSize: 28,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children:
                                                dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission,
                                          ),
                                        ],
                                      ),
                                    ),
                                    barrierDismissible: true,
                                    isDialogShowing: isDialogShowing,
                                    onIsDialogShowing: (bool value) {
                                      setState(() {
                                        isDialogShowing = value;
                                      });
                                    },
                                    screenBasedPixelWidth:
                                        _screenBasedPixelWidth,
                                    context: context,
                                    dialogTitle: Text(
                                      'Need Permission',
                                      style: getDynamicTextStyle(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.87)),
                                          sizeDecidingVariable:
                                              _screenBasedPixelWidth),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                              } else if (isDownloaded == true) {
                                OpenFile.open(releaseSavePath);
                              }
                            } else {
                              customDialogBox(
                                screenBasedPixelHeight: _screenBasedPixelHeight,
                                onProcessingSomething: (bool value) {},
                                dialogChildren: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dialogTextForPermanentlyDeniedInstallPackagesPermission,
                                        style: getDynamicTextStyle(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.60)),
                                            sizeDecidingVariable:
                                                _screenBasedPixelWidth),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: widgetSizeProvider(
                                            fixedSize: 28,
                                            sizeDecidingVariable:
                                                _screenBasedPixelWidth),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children:
                                            dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission,
                                      ),
                                    ],
                                  ),
                                ),
                                barrierDismissible: true,
                                isDialogShowing: isDialogShowing,
                                onIsDialogShowing: (bool value) {
                                  setState(() {
                                    isDialogShowing = value;
                                  });
                                },
                                screenBasedPixelWidth: _screenBasedPixelWidth,
                                context: context,
                                dialogTitle: Text(
                                  'Need Permission',
                                  style: getDynamicTextStyle(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.87)),
                                      sizeDecidingVariable:
                                          _screenBasedPixelWidth),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          }
                        : null,
                    screenBasedPixelWidth: _screenBasedPixelWidth,
                    screenBasedPixelHeight: _screenBasedPixelHeight,
                    size: const Size(70, 50),
                    borderRadius: 20,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Text(
                      'Update',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

SnackBar customSnackBar(
    {required String snackBarText,
    required BuildContext context,
    required double screenBasedPixelWidth}) {
  return SnackBar(
      content: Text(
    snackBarText,
    style: getDynamicTextStyle(
        textStyle: Theme.of(context).snackBarTheme.contentTextStyle,
        sizeDecidingVariable: screenBasedPixelWidth),
    textAlign: TextAlign.center,
  ));
}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({Key? key, required this.downloadProgress})
      : super(key: key);

  final double? downloadProgress;

  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  // late AnimationController controller;
  // late Animation<double> animation;

  late double? _downloadProgress;

  @override
  void didUpdateWidget(ProgressIndicator oldWidget) {
    if (oldWidget.downloadProgress != widget.downloadProgress) {
      setState(() {
        _downloadProgress = widget.downloadProgress;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _downloadProgress = widget.downloadProgress;

    // controller = AnimationController(
    //     duration: const Duration(milliseconds: 2000), vsync: this);
    // animation = Tween(begin: 0.0, end: 1.0).animate(controller)
    //   ..addListener(() {
    //     setState(() {
    //       // the state that has changed here is the animation object’s value
    //     });
    //   });
    // controller.repeat();
  }

  @override
  void dispose() {
    // controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinearProgressIndicator(
        value: _downloadProgress == null ? null : _downloadProgress?.toDouble(),
        // animation.value,
      ),
    );
  }
}
