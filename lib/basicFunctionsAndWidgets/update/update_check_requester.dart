import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../auth/secrets.dart';

enum UpdatesProperties { version, date, description }

class UpdateCheckRequester {
  static String? latestVersion;
  static String? releaseDescription;
  static String? releaseDownloadUrl;
  static String? releaseFileName;
  static List<Map<UpdatesProperties, String>>? updatesMapList;

  Future<void> makeGetRequest(BuildContext context) async {
    // make request
    var url = Uri.parse(
      // "https://api.github.com/repos/chaudharydeepanshu/mini_vtop_releases/releases",
      "https://api.github.com/repos/chaudharydeepanshu/Mini-VTOP-Releases/releases",
    );
    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": "token $githubToken",
      },
    );

    // sample info available in response
    // int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    debugPrint(headers.toString());
    // String? contentType = headers['content-type'];
    String json = response.body;
    if (jsonDecode(json).isNotEmpty && jsonDecode(json) != null) {
      Map<String, dynamic>? data = jsonDecode(json)[0];
      if (data != null) {
        List listOfJsonDataOfUpdates = jsonDecode(json) as List;
        debugPrint(
            "listOfJsonDataOfUpdates.length: ${listOfJsonDataOfUpdates.length}");

        updatesMapList = List<Map<UpdatesProperties, String>>.generate(
            listOfJsonDataOfUpdates.length,
            (int index) => {
                  UpdatesProperties.version:
                      listOfJsonDataOfUpdates[index]["tag_name"].substring(1),
                  UpdatesProperties.date: listOfJsonDataOfUpdates[index]
                      ["published_at"],
                  UpdatesProperties.description: listOfJsonDataOfUpdates[index]
                      ["body"],
                },
            growable: true);
        debugPrint("updatesMapList.length: ${updatesMapList?.length}");
        latestVersion = data["tag_name"].substring(1);
        releaseDescription = data["body"];
        releaseFileName = "MiniVTOP-v$latestVersion-release.apk";
        debugPrint(releaseDownloadUrl);
        List listOfJsonDataOfLatestUpdateAssets = data["assets"] as List;
        for (int i = 0; i < listOfJsonDataOfLatestUpdateAssets.length; i++) {
          if (data["assets"][i]["name"] == releaseFileName) {
            debugPrint(
                "data['assets'][i]['name']: ${data["assets"][i]["name"]}");
            debugPrint("releaseFileName: $releaseFileName");
            releaseDownloadUrl = data["assets"][i]["browser_download_url"];
          }
        }
      }
    }
    // debugPrint("statusCode: $statusCode");
    // debugPrint("releaseDescription: $releaseDescription");
    // debugPrint(
    //     "currentReleaseVersion:$currentVersion , latestReleaseVersion: $latestVersion");
  }
}
