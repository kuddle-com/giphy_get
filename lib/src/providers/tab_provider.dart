import 'package:flutter/widgets.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';
import 'package:giphy_get/src/client/models/type.dart';

class TabProvider with ChangeNotifier {
  String tenorApiKey;
  String giphyApiKey;
  String clientKey;
  String tenorMediaFilter = TenorType.tinyGif;
  Color? tabColor;
  Color? textSelectedColor;
  Color? textUnselectedColor;
  String? searchText;
  String tenorRating = TenorRating.high;
  String giphyRating = GiphyRating.g;
  String lang = GiphyLanguage.english;
  String randomID = "";

  String? _tabType;
  String get tabType => _tabType ?? '';
  set tabType(String tabType) {
    _tabType = tabType;
    notifyListeners();
  }

  TabProvider({
    required this.tenorApiKey,
    required this.giphyApiKey,
    required this.clientKey,
    required this.tenorMediaFilter,
    this.tabColor,
    this.textSelectedColor,
    this.textUnselectedColor,
    this.searchText,
    required this.tenorRating,
    required this.giphyRating,
    required this.randomID,
    required this.lang,
  });

  void setTabColor(Color tabColor) {
    tabColor = tabColor;
    notifyListeners();
  }
}
