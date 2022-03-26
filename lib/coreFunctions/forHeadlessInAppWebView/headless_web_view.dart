import 'package:flutter_inappwebview/flutter_inappwebview.dart';

InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useOnDownloadStart: true,
      useOnLoadResource: true,
      useShouldOverrideUrlLoading: true,
      javaScriptCanOpenWindowsAutomatically: true,
      mediaPlaybackRequiresUserGesture: false,
      useShouldInterceptAjaxRequest: true,
      // userAgent:
      //     "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
    ),
    android: AndroidInAppWebViewOptions(
      safeBrowsingEnabled: true,
      supportMultipleWindows: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      useShouldInterceptRequest: true,
      useHybridComposition: true,
      thirdPartyCookiesEnabled: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));
