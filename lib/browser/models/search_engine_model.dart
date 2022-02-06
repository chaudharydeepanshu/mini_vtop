class SearchEngineModel {
  final String name;
  final String assetIcon;
  final String url;
  final String searchUrl;

  const SearchEngineModel(
      {required this.name,
      required this.url,
      required this.searchUrl,
      required this.assetIcon});

  static SearchEngineModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SearchEngineModel(
            name: map["name"],
            assetIcon: map["assetIcon"],
            url: map["url"],
            searchUrl: map["searchUrl"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "assetIcon": assetIcon,
      "url": url,
      "searchUrl": searchUrl
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

const googleSearchEngine = SearchEngineModel(
    name: "Google",
    url: "https://www.google.com/",
    searchUrl: "https://www.google.com/search?q=",
    assetIcon: "assets/browserImages/images/google_logo.png");

const yahooSearchEngine = SearchEngineModel(
    name: "Yahoo",
    url: "https://www.bing.com//",
    searchUrl: "https://search.yahoo.com/search?p=",
    assetIcon: "assets/browserImages/images/yahoo_logo.png");

const bingSearchEngine = SearchEngineModel(
    name: "Bing",
    url: "https://yahoo.com/",
    searchUrl: "https://www.bing.com/search?q=",
    assetIcon: "assets/browserImages/images/bing_logo.png");

const duckDuckGoSearchEngine = SearchEngineModel(
    name: "DuckDuckGo",
    url: "https://duckduckgo.com/",
    searchUrl: "https://duckduckgo.com/?q=",
    assetIcon: "assets/browserImages/images/duckduckgo_logo.png");

const ecosiaSearchEngine = SearchEngineModel(
    name: "Ecosia",
    url: "https://www.ecosia.org/",
    searchUrl: "https://www.ecosia.org/search?q=",
    assetIcon: "assets/browserImages/images/ecosia_logo.png");

const searchEngines = <SearchEngineModel>[
  googleSearchEngine,
  yahooSearchEngine,
  bingSearchEngine,
  duckDuckGoSearchEngine,
  ecosiaSearchEngine
];
