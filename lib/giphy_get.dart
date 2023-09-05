library giphy_get;

// Imports
import 'package:flutter/material.dart';
import 'package:giphy_get/src/client/models/gif.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';
import 'package:giphy_get/src/client/models/type.dart';
import 'package:giphy_get/src/providers/app_bar_provider.dart';
import 'package:giphy_get/src/providers/sheet_provider.dart';
import 'package:giphy_get/src/providers/tab_provider.dart';
import 'package:giphy_get/src/views/main_view.dart';
import 'package:provider/provider.dart';

// Giphy Client Export
export 'package:giphy_get/src/client/client.dart';
export 'package:giphy_get/src/client/models/collection.dart';
export 'package:giphy_get/src/client/models/gif.dart';
export 'package:giphy_get/src/client/models/image.dart';
export 'package:giphy_get/src/client/models/images.dart';
export 'package:giphy_get/src/client/models/languages.dart';
export 'package:giphy_get/src/client/models/rating.dart';
export 'package:giphy_get/src/client/models/type.dart';
export 'package:giphy_get/src/client/models/user.dart';
export 'package:giphy_get/src/widgets/giphy_get.widget.dart';
export 'package:giphy_get/src/widgets/giphy_gif.widget.dart';

typedef TabTopBuilder = Widget Function(BuildContext context);
typedef TabBottomBuilder = Widget Function(BuildContext context);
typedef SearchAppBarBuilder = Widget Function(
  BuildContext context,
  FocusNode focusNode,
  bool autofocus,
  TextEditingController textEditingController,
  void Function() onClearSearch,
);

class GiphyGet {
  // Show Bottom Sheet
  static Future<GiphyGif?> getGif({
    required BuildContext context,
    required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    required String tenorApiKey,
    String tenorMediaFilter = TenorType.gif,
    String clientKey = "",
    String tenorRating = TenorRating.high,
    String tenorLang = 'en_IN',
    String country = 'IN',
    String randomID = "",
    String searchText = "",
    String queryText = "",
    bool modal = true,
    bool showGIFs = true,
    bool showStickers = true,
    bool showEmojis = true,
    Color? tabColor,
    Color? textSelectedColor,
    Color? textUnselectedColor,
    int debounceTimeInMilliseconds = 350,
    TabTopBuilder? tapTopBuilder,
    TabBottomBuilder? tabBottomBuilder,
    SearchAppBarBuilder? searchAppBarBuilder,
  }) {
    if (apiKey == "") {
      throw Exception("apiKey must be not null or not empty");
    }
    if (tenorApiKey == "") {
      throw Exception("tenorApiKey must be not null or not empty");
    }

    return showModalBottomSheet<GiphyGif>(
      clipBehavior: Clip.antiAlias,
      shape: Theme.of(context).bottomSheetTheme.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
      isScrollControlled: true,
      context: context,
      builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => AppBarProvider(
              queryText = queryText,
              debounceTimeInMilliseconds,
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => SheetProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => TabProvider(
              apiKey: apiKey,
              tenorApiKey: tenorApiKey,
              clientKey: clientKey,
              tenorMediaFilter: tenorMediaFilter,
              randomID: randomID,
              tabColor: tabColor ?? Theme.of(context).colorScheme.secondary,
              textSelectedColor: textSelectedColor ??
                  Theme.of(context).textTheme.titleSmall?.color,
              textUnselectedColor: textUnselectedColor ??
                  Theme.of(context).textTheme.bodySmall?.color,
              searchText: searchText,
              rating: rating,
              lang: lang,
              tenorRating: tenorRating,
              tenorLang: tenorLang,
              country: country,
            ),
          )
        ],
        child: SafeArea(
          child: MainView(
            showGIFs: showGIFs,
            showStickers: showStickers,
            showEmojis: showEmojis,
            tabTopBuilder: tapTopBuilder,
            tabBottomBuilder: tabBottomBuilder,
            searchAppBarBuilder: searchAppBarBuilder,
          ),
        ),
      ),
    );
  }
}
