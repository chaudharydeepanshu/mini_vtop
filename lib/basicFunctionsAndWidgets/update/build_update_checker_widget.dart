import 'dart:async';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/package_info_calc.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/stop_pop.dart';
import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/proccessing_dialog.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/update/update_check_requester.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ui/settings.dart';
import '../custom_elevated_button.dart';
import 'package:version/version.dart';
import 'package:dio/dio.dart';
import '../direct_pop.dart';
import 'package:open_file/open_file.dart';
import 'download_file.dart';
import '../get_cache_file_path_from_file_name.dart';
import '../lifecycle_event_handler.dart';

class BuildUpdateChecker extends StatefulWidget {
  const BuildUpdateChecker(
      {Key? key,
      required this.screenBasedPixelWidth,
      required this.screenBasedPixelHeight,
      required this.onProcessingSomething,
      required this.shouldAutoCheckUpdateRun})
      : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final ValueChanged<bool> onProcessingSomething;

  final bool shouldAutoCheckUpdateRun;

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

  Version? currentVersion;
  Version? latestVersion;
  String? releaseDescription;
  String? releaseDownloadUrl;
  double? downloadProgress;
  String? releaseFileName;
  String? releaseSavePath;

  bool autoCheckUpdateRan = false;
  late bool shouldAutoCheckUpdateRun;

  @override
  void didUpdateWidget(BuildUpdateChecker oldWidget) {
    if (oldWidget != widget) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    shouldAutoCheckUpdateRun = widget.shouldAutoCheckUpdateRun;
    PackageInfoCalc().init(context).whenComplete(() {
      currentVersion = Version.parse(
          PackageInfoCalc.version! + "+" + PackageInfoCalc.buildNumber!);
      UpdateCheckRequester().makeGetRequest(context).whenComplete(() {
        if (UpdateCheckRequester.latestVersion != null) {
          latestVersion =
              Version.parse("${UpdateCheckRequester.latestVersion}");
          releaseDescription = UpdateCheckRequester.releaseDescription;
          releaseDownloadUrl = UpdateCheckRequester.releaseDownloadUrl;
          releaseFileName = UpdateCheckRequester.releaseFileName;
          downloadSavePath();

          if (autoCheckUpdateRan == false && shouldAutoCheckUpdateRun == true) {
            debugPrint("autoCheckUpdateRan");
            currentVersion != null
                ? WidgetsBinding.instance
                    ?.addPostFrameCallback((_) => updateAction())
                : null;
            autoCheckUpdateRan = true;
          }
        }
      });
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

  downloadSavePath() async {
    releaseSavePath = await getCacheFilePathFromFileName(releaseFileName!);
  }

  bool isDialogShowing = false;
  Directory downloadDirectory = Directory('/storage/emulated/0/Download');
  bool downloading = false;
  String progress = '0';
  bool isDownloaded = false;
  late CancelToken cancelToken;
  StateSetter? _setState;
  var _openResult = 'Unknown';
  Future updateNowAction() async {
    storagePermissionPermanentlyDenied = false; //for disabling permission check
    if (storagePermissionPermanentlyDenied == false) {
      const statusOfStoragePermission =
          PermissionStatus.granted; //for disabling permission check
      // final statusOfStoragePermission =
      //     Platform.isAndroid ||
      //             Platform
      //                 .isIOS
      //         ? await Permission
      //             .storage
      //             .request()
      //         : PermissionStatus
      //             .granted;
      if (statusOfStoragePermission == PermissionStatus.granted) {
        Navigator.of(context).pop();

        await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            isDialogShowing = true;
            cancelToken = CancelToken();
            progress = "0";
            downloadProgress = null;
            isDownloaded = false;
            WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {
                  if (isDialogShowing) {
                    _setState!(() {});
                  }
                }));
            downloadFile(
                uri: releaseDownloadUrl,
                releaseSavePath: releaseSavePath,
                downloading: downloading,
                cancelToken: cancelToken,
                progress: progress,
                isDialogShowing: isDialogShowing,
                downloadProgress: downloadProgress,
                isDownloaded: isDownloaded,
                context: context,
                releaseDownloadUrl: releaseDownloadUrl,
                openResult: _openResult,
                onOpenResult: (String value) {
                  setState(() {
                    _openResult = value;
                  });
                },
                onProgress: (String value) {
                  WidgetsBinding.instance
                      ?.addPostFrameCallback((_) => setState(() {
                            progress = value;
                            debugPrint(progress);
                            if (_setState != null) {
                              WidgetsBinding.instance
                                  ?.addPostFrameCallback((_) {
                                if (isDialogShowing) {
                                  _setState!(() {
                                    downloadProgress =
                                        int.parse(progress).toDouble() / 100;
                                  });
                                }
                              });
                            }
                          }));
                },
                onIsDownloaded: (bool value) {
                  WidgetsBinding.instance
                      ?.addPostFrameCallback((_) => setState(() {
                            isDownloaded = value;
                            if (_setState != null) {
                              WidgetsBinding.instance
                                  ?.addPostFrameCallback((_) {
                                if (isDialogShowing) {
                                  _setState!(() {});
                                }
                              });
                            }
                          }));
                },
                onDownloading: (bool value) {
                  if (_setState != null) {
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      if (isDialogShowing) {
                        _setState!(() {});
                      }
                    });
                  }
                },
                onIsDialogBoxShowing: (bool value) {
                  WidgetsBinding.instance
                      ?.addPostFrameCallback((_) => setState(() {
                            isDialogShowing = value;
                          }));
                });
            return StatefulBuilder(
              // You need this, notice the parameters below:
              builder: (BuildContext context, StateSetter setState) {
                _setState = setState;

                WidgetsBinding.instance
                    ?.addPostFrameCallback((_) => setState(() {
                          WidgetsBinding.instance?.addPostFrameCallback((_) {
                            Timer.periodic(const Duration(seconds: 1), (timer) {
                              debugPrint(isDialogShowing.toString());
                              if (isDialogShowing) {
                                _setState!(() {});
                              } else {
                                timer.cancel();
                              }
                            });
                          });
                        }));

                return WillPopScope(
                  onWillPop: () {
                    return isDialogShowing
                        ? stopPop()
                        : directPop(onProcessingSomething: (bool value) {
                            widget.onProcessingSomething.call(value);
                          });
                  },
                  child: AlertDialog(
                    title: Center(
                      child: Text(
                        'Downloading',
                        style: getDynamicTextStyle(
                            textStyle: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.87)),
                            sizeDecidingVariable: _screenBasedPixelWidth),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    titlePadding: EdgeInsets.fromLTRB(
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
                    contentPadding: EdgeInsets.fromLTRB(
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
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: widgetSizeProvider(
                          fixedSize: 40,
                          sizeDecidingVariable: widget.screenBasedPixelWidth),
                      vertical: widgetSizeProvider(
                          fixedSize: 24,
                          sizeDecidingVariable: widget.screenBasedPixelWidth),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Please do NOT exit the app during this process!",
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
                                    fixedSize: 8,
                                    sizeDecidingVariable:
                                        _screenBasedPixelWidth),
                              ),
                              ProgressIndicator(
                                downloadProgress: downloadProgress,
                              ),
                              SizedBox(
                                height: widgetSizeProvider(
                                    fixedSize: 28,
                                    sizeDecidingVariable:
                                        _screenBasedPixelWidth),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Downloading app-release.apk",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
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
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Text(
                          'Cancel',
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ).then((_) {
          if (isDownloaded == false) {
            cancelToken.cancel();
          }

          return isDialogShowing = false;
        });
      } else if (statusOfStoragePermission == PermissionStatus.denied) {
        debugPrint(
            'Denied. Show a dialog with a reason and again ask for the permission.');
        customAlertDialogBox(
          screenBasedPixelHeight: _screenBasedPixelHeight,
          onProcessingSomething: (bool value) {
            widget.onProcessingSomething.call(value);
          },
          dialogContent: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dialogTextForDeniedStoragePermission,
                  style: getDynamicTextStyle(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.60)),
                      sizeDecidingVariable: _screenBasedPixelWidth),
                  textAlign: TextAlign.center,
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
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87)),
                sizeDecidingVariable: _screenBasedPixelWidth),
            textAlign: TextAlign.center,
          ),
          dialogActions: dialogActionButtonsListForDeniedStoragePermission,
        ).then((_) => isDialogShowing = false);
      } else if (statusOfStoragePermission ==
          PermissionStatus.permanentlyDenied) {
        debugPrint('Take the user to the settings page.');
        setState(() {
          storagePermissionPermanentlyDenied = true;
        });
        addBoolToSF() async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('storagePermissionPermanentlyDeniedBoolValue', true);
        }

        addBoolToSF();
        customAlertDialogBox(
          screenBasedPixelHeight: _screenBasedPixelHeight,
          onProcessingSomething: (bool value) {
            widget.onProcessingSomething.call(value);
          },
          dialogContent: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dialogTextForPermanentlyDeniedStoragePermission,
                  style: getDynamicTextStyle(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.60)),
                      sizeDecidingVariable: _screenBasedPixelWidth),
                  textAlign: TextAlign.center,
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
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87)),
                sizeDecidingVariable: _screenBasedPixelWidth),
            textAlign: TextAlign.center,
          ),
          dialogActions:
              dialogActionButtonsListForPermanentlyDeniedStoragePermission,
        ).then((_) => isDialogShowing = false);
      }
    } else {
      customAlertDialogBox(
        screenBasedPixelHeight: _screenBasedPixelHeight,
        onProcessingSomething: (bool value) {
          widget.onProcessingSomething.call(value);
        },
        dialogContent: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dialogTextForPermanentlyDeniedStoragePermission,
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.60)),
                    sizeDecidingVariable: _screenBasedPixelWidth),
                textAlign: TextAlign.center,
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
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.87)),
              sizeDecidingVariable: _screenBasedPixelWidth),
          textAlign: TextAlign.center,
        ),
        dialogActions:
            dialogActionButtonsListForPermanentlyDeniedStoragePermission,
      ).then((_) => isDialogShowing = false);
    }
  }

  Future updateAction() async {
    ScrollController? controller = ScrollController();
    print("releaseDescription: $releaseDescription");
    installPackagesPermissionPermanentlyDenied =
        false; //for disabling permission check
    if (installPackagesPermissionPermanentlyDenied ==
        false) //if this condition true then that means storage Permission is not Permanently Denied
    {
      if (isDownloaded == false) {
        const statusOfInstallPackagesPermission =
            PermissionStatus.granted; //for disabling permission check
        // final statusOfInstallPackagesPermission =
        //     Platform.isAndroid || Platform.isIOS
        //         ? await Permission
        //             .requestInstallPackages
        //             .request()
        //         : PermissionStatus.granted;
        if (statusOfInstallPackagesPermission == PermissionStatus.granted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(customSnackBar(
              snackBarText: "Checking for updates. Please Wait.",
              screenBasedPixelWidth: _screenBasedPixelWidth,
              context: context,
            ));

          if (latestVersion != null) {
            if (latestVersion! > currentVersion) {
              debugPrint("Latest version available");
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(customSnackBar(
                  snackBarText: "Update available.",
                  screenBasedPixelWidth: _screenBasedPixelWidth,
                  context: context,
                ));
              // WidgetsBinding.instance
              //     ?.addPostFrameCallback((_) {
              customAlertDialogBox(
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
                      sizeDecidingVariable: _screenBasedPixelWidth),
                  textAlign: TextAlign.center,
                ),
                dialogContent: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomBox(
                          settingsType: 'Update description',
                          screenBasedPixelWidth: _screenBasedPixelWidth,
                          screenBasedPixelHeight: _screenBasedPixelHeight,
                          settingsBoxChildren: [
                            SizedBox(
                              height: widgetSizeProvider(
                                  fixedSize: 60,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              width: widgetSizeProvider(
                                  fixedSize: double.maxFinite,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Markdown(
                                        padding: const EdgeInsets.all(0),
                                        styleSheet: MarkdownStyleSheet(
                                          h3: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: widgetSizeProvider(
                                                fixedSize: 16,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                          p: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: widgetSizeProvider(
                                                fixedSize: 14,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                        ),
                                        shrinkWrap: true,
                                        controller: controller,
                                        selectable: false,
                                        data: releaseDescription! == ""
                                            ? "No description 🦥"
                                            : releaseDescription!,
                                      ),
                                      // Text(
                                      //   releaseDescription!,
                                      //   style: getDynamicTextStyle(
                                      //       textStyle: Theme.of(context)
                                      //           .textTheme
                                      //           .bodyText1
                                      //           ?.copyWith(
                                      //               color: Theme.of(context)
                                      //                   .colorScheme
                                      //                   .onSurface
                                      //                   .withOpacity(0.60)),
                                      //       sizeDecidingVariable:
                                      //           _screenBasedPixelWidth),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        CustomBox(
                          settingsType: 'Update version',
                          screenBasedPixelWidth: _screenBasedPixelWidth,
                          screenBasedPixelHeight: _screenBasedPixelHeight,
                          settingsBoxChildren: [
                            SizedBox(
                              height: widgetSizeProvider(
                                  fixedSize: 20,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              width: widgetSizeProvider(
                                  fixedSize: double.maxFinite,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Markdown(
                                        padding: const EdgeInsets.all(0),
                                        styleSheet: MarkdownStyleSheet(
                                          h3: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: widgetSizeProvider(
                                                fixedSize: 16,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                          p: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: widgetSizeProvider(
                                                fixedSize: 14,
                                                sizeDecidingVariable:
                                                    _screenBasedPixelWidth),
                                          ),
                                        ),
                                        shrinkWrap: true,
                                        controller: controller,
                                        selectable: false,
                                        data: UpdateCheckRequester
                                                    .latestVersion ==
                                                null
                                            ? "No version tag 🦥"
                                            : "v${UpdateCheckRequester.latestVersion}",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: true,
                screenBasedPixelHeight: _screenBasedPixelHeight,
                screenBasedPixelWidth: _screenBasedPixelWidth,
                onProcessingSomething: (bool value) {
                  widget.onProcessingSomething.call(value);
                },
                dialogActions: [
                  CustomTextButton(
                    onPressed: updateNowAction,
                    screenBasedPixelWidth: _screenBasedPixelWidth,
                    screenBasedPixelHeight: _screenBasedPixelHeight,
                    size: const Size(20, 50),
                    borderRadius: 20,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Text(
                      'UPDATE',
                    ),
                  ),
                  CustomTextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    screenBasedPixelWidth: _screenBasedPixelWidth,
                    screenBasedPixelHeight: _screenBasedPixelHeight,
                    size: const Size(20, 50),
                    borderRadius: 20,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Text(
                      'NO THANKS',
                    ),
                  )
                ],
              ).then((_) => isDialogShowing = false);
              debugPrint("dialogBox initiated");
              // });
            } else if (latestVersion == currentVersion) {
              debugPrint("Using latest version available");
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(customSnackBar(
                  snackBarText: "Already using the latest version.",
                  screenBasedPixelWidth: _screenBasedPixelWidth,
                  context: context,
                ));
            } else {
              debugPrint("Using higher version than available");
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(customSnackBar(
                  snackBarText: "Already using the latest version.",
                  screenBasedPixelWidth: _screenBasedPixelWidth,
                  context: context,
                ));
            }
          } else {
            debugPrint("No information available about latest version");
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(customSnackBar(
                snackBarText: "Sorry no info available about update.",
                screenBasedPixelWidth: _screenBasedPixelWidth,
                context: context,
              ));
          }
          return null;
        } else if (statusOfInstallPackagesPermission ==
            PermissionStatus.denied) {
          debugPrint(
              'Denied. Show a dialog with a reason and again ask for the permission.');
          customAlertDialogBox(
            screenBasedPixelHeight: _screenBasedPixelHeight,
            onProcessingSomething: (bool value) {
              widget.onProcessingSomething.call(value);
            },
            dialogContent: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                        sizeDecidingVariable: _screenBasedPixelWidth),
                    textAlign: TextAlign.center,
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
                  textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.87)),
                  sizeDecidingVariable: _screenBasedPixelWidth),
              textAlign: TextAlign.center,
            ),
            dialogActions:
                dialogActionButtonsListForDeniedInstallPackagesPermission,
          ).then((_) => isDialogShowing = false);
        } else if (statusOfInstallPackagesPermission ==
            PermissionStatus.permanentlyDenied) {
          debugPrint('Take the user to the settings page.');
          setState(() {
            installPackagesPermissionPermanentlyDenied = true;
          });
          addBoolToSF() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool(
                'installPackagesPermissionPermanentlyDeniedBoolValue', true);
          }

          addBoolToSF();
          customAlertDialogBox(
            screenBasedPixelHeight: _screenBasedPixelHeight,
            onProcessingSomething: (bool value) {
              widget.onProcessingSomething.call(value);
            },
            dialogContent: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        sizeDecidingVariable: _screenBasedPixelWidth),
                    textAlign: TextAlign.center,
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
                  textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.87)),
                  sizeDecidingVariable: _screenBasedPixelWidth),
              textAlign: TextAlign.center,
            ),
            dialogActions:
                dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission,
          ).then((_) => isDialogShowing = false);
        }
      } else if (isDownloaded == true) {
        OpenFile.open(releaseSavePath);
      }
    } else {
      customAlertDialogBox(
        screenBasedPixelHeight: _screenBasedPixelHeight,
        onProcessingSomething: (bool value) {
          widget.onProcessingSomething.call(value);
        },
        dialogContent: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dialogTextForPermanentlyDeniedInstallPackagesPermission,
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.60)),
                    sizeDecidingVariable: _screenBasedPixelWidth),
                textAlign: TextAlign.center,
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
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.87)),
              sizeDecidingVariable: _screenBasedPixelWidth),
          textAlign: TextAlign.center,
        ),
        dialogActions:
            dialogActionButtonsListForPermanentlyDeniedInstallPackagesPermission,
      ).then((_) => isDialogShowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return shouldAutoCheckUpdateRun == false
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  "Check Update",
                  overflow: TextOverflow.ellipsis,
                  style: getDynamicTextStyle(
                      textStyle: Theme.of(context).textTheme.bodyText1,
                      sizeDecidingVariable: _screenBasedPixelWidth),
                ),
              ),
              // SizedBox(
              //   width: widgetSizeProvider(
              //       fixedSize: 5, sizeDecidingVariable: _screenBasedPixelWidth),
              // ),
              Flexible(
                flex: 1,
                child: CustomElevatedButton(
                  onPressed: currentVersion != null ? updateAction : null,
                  screenBasedPixelWidth: _screenBasedPixelWidth,
                  screenBasedPixelHeight: _screenBasedPixelHeight,
                  size: const Size(70, 50),
                  borderRadius: 20,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Text(
                    'Update',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
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
        value: _downloadProgress,
      ),
    );
  }
}
