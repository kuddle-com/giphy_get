import 'package:flutter/widgets.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';
import 'package:giphy_get/src/client/models/type.dart';

class TabProvider with ChangeNotifier {
  String apiKey;
  String tenorApiKey;
  String clientKey;
  String tenorMediaFormat = TenorType.gif;
  String tenorPreviewFormat = TenorType.mediumGif;
  Color? tabColor;
  Color? textSelectedColor;
  Color? textUnselectedColor;
  String? searchText;
  String rating = GiphyRating.g;
  String lang = GiphyLanguage.english;
  String tenorRating = TenorRating.high;
  String tenorLang = 'en_IN';
  String country = 'IN';
  String randomID = "";

  String? _tabType;
  String get tabType => _tabType ?? '';
  set tabType(String tabType) {
    _tabType = tabType;
    notifyListeners();
  }

  TabProvider({
    required this.apiKey,
    required this.tenorApiKey,
    required this.clientKey,
    required this.tenorMediaFormat,
    required this.tenorPreviewFormat,
    this.tabColor,
    this.textSelectedColor,
    this.textUnselectedColor,
    this.searchText,
    required this.rating,
    required this.randomID,
    required this.lang,
    required this.tenorRating,
    required this.tenorLang,
    required this.country,
  });

  void setTabColor(Color tabColor) {
    tabColor = tabColor;
    notifyListeners();
  }
}
