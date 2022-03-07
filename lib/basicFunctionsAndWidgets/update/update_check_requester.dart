import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

class UpdateCheckRequester {
  static String? latestVersion;
  static String? releaseDescription;
  static String? releaseDownloadUrl;
  static String? releaseFileName;

  Future<void> makeGetRequest(BuildContext context) async {
    // make request
    var url = Uri.parse(
        "https://api.github.com/repos/chaudharydeepanshu/mini_vtop_releases/releases");
    http.Response response = await http.get(url);

    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String? contentType = headers['content-type'];
    String json = response.body;
    if (jsonDecode(json).isNotEmpty) {
      Map<String, dynamic> data = jsonDecode(json)[0];
      latestVersion = data["tag_name"].substring(1);
      releaseDescription = data["body"];
      releaseDownloadUrl = data["assets"][0]["browser_download_url"];
      releaseFileName = data["assets"][0]["name"];
    }
    // // downloadDirectory.path + "/$releaseFileName";
    // // String verse = data["contents"]["verse"];
    // // dynamic chapter= data["contents"]["chapter"];
    //
    // // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json)));
    // debugPrint("statusCode: $statusCode");
    // // debugPrint("contentType: $contentType");
    // // debugPrint("data: $data");
    // debugPrint("releaseDescription: $releaseDescription");
    // debugPrint(
    //     "currentReleaseVersion:$currentVersion , latestReleaseVersion: $latestVersion");
  }
}
