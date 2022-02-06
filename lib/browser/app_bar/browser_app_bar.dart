import 'package:flutter/material.dart';
import 'package:mini_vtop/browser/app_bar/webview_tab_app_bar.dart';

import 'find_on_page_app_bar.dart';

class BrowserAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const BrowserAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  _BrowserAppBarState createState() => _BrowserAppBarState();

  @override
  final Size preferredSize;
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  bool _isFindingOnPage = false;

  @override
  Widget build(BuildContext context) {
    return _isFindingOnPage
        ? FindOnPageAppBar(
            hideFindOnPage: () {
              setState(() {
                _isFindingOnPage = false;
              });
            },
          )
        : WebViewTabAppBar(
            showFindOnPage: () {
              setState(() {
                _isFindingOnPage = true;
              });
            },
          );
  }
}
