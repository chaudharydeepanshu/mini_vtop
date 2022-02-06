import 'package:flutter/material.dart';
import 'package:mini_vtop/browser/webview_tab.dart';
import 'package:provider/provider.dart';

import 'models/browser_model.dart';
import 'models/webview_model.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({Key? key}) : super(key: key);

  @override
  _EmptyTabState createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      openNewTab(_controller.text);
    });
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
                Text(
                  "Please Wait...\nNew VTOP tab is loading",
                  style: TextStyle(color: Colors.black54, fontSize: 25.0),
                  textAlign: TextAlign.center,
                )
                // Image(image: AssetImage(settings.searchEngine.assetIcon)),
                // const SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Expanded(
                //         child: TextField(
                //       controller: _controller,
                //       onSubmitted: (value) {
                //         openNewTab(value);
                //       },
                //       textInputAction: TextInputAction.go,
                //       decoration: const InputDecoration(
                //         hintText: "Search for or type a web address",
                //         hintStyle: TextStyle(color: Colors.black54, fontSize: 25.0),
                //       ),
                //       style: const TextStyle(
                //         color: Colors.black,
                //         fontSize: 25.0,
                //       ),
                //     )),
                //     IconButton(
                //       icon: const Icon(Icons.search,
                //           color: Colors.black54, size: 25.0),
                //       onPressed: () {
                //         openNewTab(_controller.text);
                //         FocusScope.of(context).unfocus();
                //       },
                //     )
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openNewTab(value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    browserModel.addTab(WebViewTab(
      key2: GlobalKey(),
      webViewModel: WebViewModel(
          url: Uri.parse(value.startsWith("http")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
  }
}
