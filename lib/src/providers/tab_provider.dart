import 'package:flutter/widgets.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';
import 'package:giphy_get/src/client/models/type.dart';

class TabProvider with ChangeNotifier {
  String tenorApiKey;
  String giphyApiKey;
  String clientKey;
  String tenorMediaFilter = TenorType.gif;
  Color? tabColor;
  Color? textSelectedColor;
  Color? textUnselectedColor;
  String? searchText;
  String tenorRating = TenorRating.high;
  String tenorLang = 'en_IN';
  String giphyRating = GiphyRating.g;
  String giphyLang = GiphyLanguage.english;
  String country = 'IN';
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
    required this.tenorLang,
    required this.giphyRating,
    required this.giphyLang,
    required this.country,
    required this.randomID,
  });

  void setTabColor(Color tabColor) {
    tabColor = tabColor;
    notifyListeners();
  }
}
