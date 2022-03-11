import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
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
  List<Map<UpdatesProperties, String>>? updatesMapList = [];
  List<Map<UpdatesProperties, String>>? newUpdatesMapListOf = [];
  List<Map<UpdatesProperties, String>>? currentUpdatesMapListOf = [];
  List<Map<UpdatesProperties, String>>? oldUpdatesMapListOf = [];
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

  final changelogsContentScrollController = ScrollController();
  final changelogsScrollController = ScrollController();

  void _scrollDown() {
    changelogsScrollController.animateTo(
      changelogsScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollUp() {
    changelogsScrollController.animateTo(
      changelogsScrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();

    // Setup the changelogsContentScrollController listener.
    changelogsContentScrollController.addListener(() {
      if (changelogsContentScrollController.position.atEdge) {
        bool isTop = changelogsContentScrollController.position.pixels == 0;
        if (isTop) {
          debugPrint('At the top');
          _scrollUp();
        } else {
          debugPrint('At the bottom');
          _scrollDown();
        }
      } else {
        // debugPrint('Not at bottom not at top');
      }
    });

    shouldAutoCheckUpdateRun = widget.shouldAutoCheckUpdateRun;
    PackageInfoCalc().init(context).whenComplete(() {
      currentVersion = Version.parse(
          PackageInfoCalc.version! + "+" + PackageInfoCalc.buildNumber!);
      if (autoCheckUpdateRan == false && shouldAutoCheckUpdateRun == true) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(customSnackBar(
            snackBarText: "Checking for updates. Please Wait.",
            screenBasedPixelWidth: _screenBasedPixelWidth,
            context: context,
          ));
        UpdateCheckRequester().makeGetRequest(context).whenComplete(() {
          if (UpdateCheckRequester.latestVersion != null &&
              UpdateCheckRequester.releaseDownloadUrl != null) {
            latestVersion =
                Version.parse("${UpdateCheckRequester.latestVersion}");
            releaseDescription = UpdateCheckRequester.releaseDescription;
            releaseDownloadUrl = UpdateCheckRequester.releaseDownloadUrl;
            releaseFileName = UpdateCheckRequester.releaseFileName;
            updatesMapList = UpdateCheckRequester.updatesMapList;
            newUpdatesMapListOf = [];
            currentUpdatesMapListOf = [];
            oldUpdatesMapListOf = [];
            for (int i = 0; i < updatesMapList!.length; i++) {
              String? updateVersion =
                  updatesMapList![i][UpdatesProperties.version];
              if (currentVersion! < Version.parse(updateVersion)) {
                newUpdatesMapListOf?.add(updatesMapList![i]);
              } else if (currentVersion == Version.parse(updateVersion)) {
                currentUpdatesMapListOf?.add(updatesMapList![i]);
              } else {
                oldUpdatesMapListOf?.add(updatesMapList![i]);
              }
            }
            downloadSavePath();
          }

          if (autoCheckUpdateRan == false && shouldAutoCheckUpdateRun == true) {
            debugPrint("autoCheckUpdateRan");
            currentVersion != null
                ? WidgetsBinding.instance
                    ?.addPostFrameCallback((_) => updateAction())
                : null;
            autoCheckUpdateRan = true;
          }
        });
      }
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
                                      "Downloading $releaseFileName",
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
          dialogTitle: 'Need Permission',
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
          dialogTitle: 'Need Permission',
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
        dialogTitle: 'Need Permission',
        dialogActions:
            dialogActionButtonsListForPermanentlyDeniedStoragePermission,
      ).then((_) => isDialogShowing = false);
    }
  }

  Future updateAction() async {
    ScrollController? controller = ScrollController();
    debugPrint("releaseDescription: $releaseDescription");
    debugPrint("AllUpdatesMapList: $updatesMapList");
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
          // ScaffoldMessenger.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(customSnackBar(
          //     snackBarText: "Checking for updates. Please Wait.",
          //     screenBasedPixelWidth: _screenBasedPixelWidth,
          //     context: context,
          //   ));

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
                dialogTitle: "Update Available",
                dialogContent: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    controller: changelogsScrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomBox(
                          settingsType: 'Changelogs',
                          screenBasedPixelWidth: _screenBasedPixelWidth,
                          screenBasedPixelHeight: _screenBasedPixelHeight,
                          settingsBoxChildren: [
                            SizedBox(
                              height: widgetSizeProvider(
                                  fixedSize: 110,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              width: widgetSizeProvider(
                                  fixedSize: double.maxFinite,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                              child: ListView(
                                controller: changelogsContentScrollController,
                                children: [
                                  newUpdatesMapListOf!.isNotEmpty
                                      ? UpdateDescriptionContent(
                                          updatesMapListOf: newUpdatesMapListOf,
                                          screenBasedPixelWidth:
                                              _screenBasedPixelWidth,
                                          currentVersion: currentVersion,
                                          controller: controller,
                                          updateTypeTag: "New")
                                      : const SizedBox(),
                                  currentUpdatesMapListOf!.isNotEmpty
                                      ? UpdateDescriptionContent(
                                          updatesMapListOf:
                                              currentUpdatesMapListOf,
                                          screenBasedPixelWidth:
                                              _screenBasedPixelWidth,
                                          currentVersion: currentVersion,
                                          controller: controller,
                                          updateTypeTag: "Current")
                                      : const SizedBox(),
                                  oldUpdatesMapListOf!.isNotEmpty
                                      ? UpdateDescriptionContent(
                                          updatesMapListOf: oldUpdatesMapListOf,
                                          screenBasedPixelWidth:
                                              _screenBasedPixelWidth,
                                          currentVersion: currentVersion,
                                          controller: controller,
                                          updateTypeTag: "Old")
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // CustomBox(
                        //   settingsType: 'Update version',
                        //   screenBasedPixelWidth: _screenBasedPixelWidth,
                        //   screenBasedPixelHeight: _screenBasedPixelHeight,
                        //   settingsBoxChildren: [
                        //     SizedBox(
                        //       height: widgetSizeProvider(
                        //           fixedSize: 20,
                        //           sizeDecidingVariable: _screenBasedPixelWidth),
                        //       width: widgetSizeProvider(
                        //           fixedSize: double.maxFinite,
                        //           sizeDecidingVariable: _screenBasedPixelWidth),
                        //       child: SingleChildScrollView(
                        //         child: Row(
                        //           children: [
                        //             Flexible(
                        //               child: Markdown(
                        //                 padding: const EdgeInsets.all(0),
                        //                 styleSheet: MarkdownStyleSheet(
                        //                   h3: TextStyle(
                        //                     fontWeight: FontWeight.bold,
                        //                     fontSize: widgetSizeProvider(
                        //                         fixedSize: 16,
                        //                         sizeDecidingVariable:
                        //                             _screenBasedPixelWidth),
                        //                   ),
                        //                   p: TextStyle(
                        //                     fontWeight: FontWeight.bold,
                        //                     fontSize: widgetSizeProvider(
                        //                         fixedSize: 14,
                        //                         sizeDecidingVariable:
                        //                             _screenBasedPixelWidth),
                        //                   ),
                        //                 ),
                        //                 shrinkWrap: true,
                        //                 controller: controller,
                        //                 selectable: false,
                        //                 data: UpdateCheckRequester
                        //                             .latestVersion ==
                        //                         null
                        //                     ? "No version tag 🦥"
                        //                     : "v${UpdateCheckRequester.latestVersion}",
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
            dialogTitle: 'Need Permission',
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
            dialogTitle: 'Need Permission',
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
        dialogTitle: 'Need Permission',
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
                  onPressed: currentVersion != null
                      ? () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(customSnackBar(
                              snackBarText:
                                  "Checking for updates. Please Wait.",
                              screenBasedPixelWidth: _screenBasedPixelWidth,
                              context: context,
                            ));
                          UpdateCheckRequester()
                              .makeGetRequest(context)
                              .whenComplete(() {
                            if (UpdateCheckRequester.latestVersion != null &&
                                UpdateCheckRequester.releaseDownloadUrl !=
                                    null) {
                              latestVersion = Version.parse(
                                  "${UpdateCheckRequester.latestVersion}");
                              releaseDescription =
                                  UpdateCheckRequester.releaseDescription;
                              releaseDownloadUrl =
                                  UpdateCheckRequester.releaseDownloadUrl;
                              releaseFileName =
                                  UpdateCheckRequester.releaseFileName;
                              updatesMapList =
                                  UpdateCheckRequester.updatesMapList;
                              updatesMapList =
                                  UpdateCheckRequester.updatesMapList;
                              newUpdatesMapListOf = [];
                              currentUpdatesMapListOf = [];
                              oldUpdatesMapListOf = [];
                              for (int i = 0; i < updatesMapList!.length; i++) {
                                String? updateVersion = updatesMapList![i]
                                    [UpdatesProperties.version];
                                if (currentVersion! <
                                    Version.parse(updateVersion)) {
                                  newUpdatesMapListOf?.add(updatesMapList![i]);
                                } else if (currentVersion ==
                                    Version.parse(updateVersion)) {
                                  currentUpdatesMapListOf
                                      ?.add(updatesMapList![i]);
                                } else {
                                  oldUpdatesMapListOf?.add(updatesMapList![i]);
                                }
                              }
                              downloadSavePath();
                            }
                            updateAction();
                          });
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}

class UpdateDescriptionContent extends StatelessWidget {
  const UpdateDescriptionContent({
    Key? key,
    required this.updatesMapListOf,
    required double screenBasedPixelWidth,
    required this.currentVersion,
    required this.controller,
    // required this.updateDescription,
    required this.updateTypeTag,
  })  : _screenBasedPixelWidth = screenBasedPixelWidth,
        super(key: key);

  final List<Map<UpdatesProperties, String>>? updatesMapListOf;
  final double _screenBasedPixelWidth;
  final Version? currentVersion;
  final ScrollController? controller;
  // final String? updateDescription;
  final String updateTypeTag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.5, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 15),
              child: Column(
                children: List<Widget>.generate(updatesMapListOf!.length,
                    (int index) {
                  String? updateVersion =
                      updatesMapListOf![index][UpdatesProperties.version];
                  DateTime? updateDateInIsoFormat = DateTime.parse(
                      '${updatesMapListOf![index][UpdatesProperties.date]}');
                  String updateDate =
                      DateFormat('dd MMMM yyyy').format(updateDateInIsoFormat);
                  String? updateDescription =
                      updatesMapListOf![index][UpdatesProperties.description];
                  // String updateTypeTag;
                  if (index == 0 ||
                      currentVersion! < Version.parse(updateVersion)) {
                    // updateTypeTag = "New";
                  } else if (currentVersion == Version.parse(updateVersion)) {
                    // updateTypeTag = "Current";
                  } else {
                    // updateTypeTag = "Old";
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: CustomChips(
                              chipText: "v" + updateVersion!,
                              screenBasedPixelWidth: _screenBasedPixelWidth,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: CustomChips(
                              chipText: updateDate,
                              screenBasedPixelWidth: _screenBasedPixelWidth,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, bottom: 8.0, top: 8.0),
                        child: Markdown(
                          padding: const EdgeInsets.all(0),
                          styleSheet: MarkdownStyleSheet(
                            h3: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widgetSizeProvider(
                                  fixedSize: 14,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                            ),
                            p: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widgetSizeProvider(
                                  fixedSize: 12,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                            ),
                          ),
                          shrinkWrap: true,
                          controller: controller,
                          selectable: false,
                          data: updateDescription == null ||
                                  updateDescription == ""
                              ? "No description 🦥"
                              : updateDescription,
                        ),
                      ),
                    ],
                  );
                }, growable: false),
              ),
            ),
          ),
        ),
        CustomChips(
          chipText: updateTypeTag,
          screenBasedPixelWidth: _screenBasedPixelWidth,
        ),
      ],
    );
    // Stack(
    //   alignment: Alignment.topCenter,
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.only(top: 12.5, bottom: 8.0),
    //       child: Container(
    //         decoration: BoxDecoration(
    //           border: Border.all(
    //               color: Theme.of(context).colorScheme.onPrimaryContainer,
    //               width: 1),
    //           borderRadius: const BorderRadius.all(Radius.circular(10)),
    //         ),
    //         child: Padding(
    //           padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 15),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Flexible(
    //                     flex: 1,
    //                     child: CustomChips(
    //                       chipText: "v" + updateVersion!,
    //                       screenBasedPixelWidth: _screenBasedPixelWidth,
    //                     ),
    //                   ),
    //                   Flexible(
    //                     flex: 2,
    //                     child: CustomChips(
    //                       chipText: updateDate,
    //                       screenBasedPixelWidth: _screenBasedPixelWidth,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Padding(
    //                 padding:
    //                     const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
    //                 child: Markdown(
    //                   padding: const EdgeInsets.all(0),
    //                   styleSheet: MarkdownStyleSheet(
    //                     h3: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: widgetSizeProvider(
    //                           fixedSize: 14,
    //                           sizeDecidingVariable: _screenBasedPixelWidth),
    //                     ),
    //                     p: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: widgetSizeProvider(
    //                           fixedSize: 12,
    //                           sizeDecidingVariable: _screenBasedPixelWidth),
    //                     ),
    //                   ),
    //                   shrinkWrap: true,
    //                   controller: controller,
    //                   selectable: false,
    //                   data: updateDescription == null || updateDescription == ""
    //                       ? "No description 🦥"
    //                       : updateDescription!,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //     CustomChips(
    //       chipText: updateTypeTag,
    //       screenBasedPixelWidth: _screenBasedPixelWidth,
    //     ),
    //   ],
    // );
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

class CustomChips extends StatefulWidget {
  const CustomChips(
      {Key? key, required this.screenBasedPixelWidth, required this.chipText})
      : super(key: key);

  final double screenBasedPixelWidth;
  final String chipText;

  @override
  _CustomChipsState createState() => _CustomChipsState();
}

class _CustomChipsState extends State<CustomChips> {
  late double _screenBasedPixelWidth;
  late String _chipText;

  @override
  void didUpdateWidget(CustomChips oldWidget) {
    if (oldWidget != widget) {
      setState(() {
        _screenBasedPixelWidth = widget.screenBasedPixelWidth;
        _chipText = widget.chipText;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _screenBasedPixelWidth = widget.screenBasedPixelWidth;
    _chipText = widget.chipText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(1000)),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          widgetSizeProvider(
              fixedSize: 4, sizeDecidingVariable: _screenBasedPixelWidth),
        ),
        child: Text(
          _chipText,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
            fontSize: widgetSizeProvider(
                fixedSize: 14, sizeDecidingVariable: _screenBasedPixelWidth),
          ),
        ),
      ),
    );
  }
}
