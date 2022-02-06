import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../custom_popup_menu_item.dart';
import '../../models/browser_model.dart';
import '../../models/webview_model.dart';
import 'android_settings.dart';
import 'cross_platform_settings.dart';
import 'ios_settings.dart';

class PopupSettingsMenuActions {
  static const String resetBrowserSettings = "Reset Browser Settings";
  static const String resetWebViewSettings = "Reset WebView Settings";

  static const List<String> choices = <String>[
    resetBrowserSettings,
    resetWebViewSettings,
  ];
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
                onTap: (value) {
                  FocusScope.of(context).unfocus();
                },
                tabs: const [
                  Tab(
                    text: "Cross-Platform",
                    icon: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/browserImages/icon/icon.png"),
                      ),
                    ),
                  ),
                  Tab(
                    text: "Android",
                    icon: Icon(
                      Icons.android,
                      color: Colors.green,
                    ),
                  ),
                  Tab(
                    text: "iOS",
                    icon: Icon(FlutterIcons.apple1_ant),
                  ),
                ]),
            title: const Text(
              "Settings",
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: _popupMenuChoiceAction,
                itemBuilder: (context) {
                  var items = [
                    CustomPopupMenuItem<String>(
                      enabled: true,
                      value: PopupSettingsMenuActions.resetBrowserSettings,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(PopupSettingsMenuActions.resetBrowserSettings),
                            Icon(
                              FlutterIcons.web_fou,
                              color: Colors.black,
                            )
                          ]),
                    ),
                    CustomPopupMenuItem<String>(
                      enabled: true,
                      value: PopupSettingsMenuActions.resetWebViewSettings,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(PopupSettingsMenuActions.resetWebViewSettings),
                            Icon(
                              FlutterIcons.web_mdi,
                              color: Colors.black,
                            )
                          ]),
                    )
                  ];

                  return items;
                },
              )
            ],
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CrossPlatformSettings(),
              AndroidSettings(),
              IOSSettings(),
            ],
          ),
        ));
  }

  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case PopupSettingsMenuActions.resetBrowserSettings:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        setState(() {
          browserModel.updateSettings(BrowserSettings());
          browserModel.save();
        });
        break;
      case PopupSettingsMenuActions.resetWebViewSettings:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        var settings = browserModel.getSettings();
        var currentWebViewModel =
            Provider.of<WebViewModel>(context, listen: false);
        var _webViewController = currentWebViewModel.webViewController;
        await _webViewController?.setOptions(
            options: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    incognito: currentWebViewModel.isIncognitoMode,
                    useOnDownloadStart: true,
                    useOnLoadResource: true),
                android: AndroidInAppWebViewOptions(safeBrowsingEnabled: true),
                ios: IOSInAppWebViewOptions(
                    allowsLinkPreview: false,
                    isFraudulentWebsiteWarningEnabled: true)));
        currentWebViewModel.options = await _webViewController?.getOptions();
        browserModel.save();
        setState(() {});
        break;
    }
  }
}
