import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:giphy_get/src/client/models/collection.dart';
import 'package:giphy_get/src/client/models/gif.dart';
import 'package:giphy_get/src/providers/app_bar_provider.dart';
import 'package:giphy_get/src/providers/tab_provider.dart';
import 'package:provider/provider.dart';

import '../../client/tenor_client.dart';

class TenorTabDetail extends StatefulWidget {
  final String type;
  final ScrollController scrollController;

  TenorTabDetail({Key? key, required this.type, required this.scrollController})
      : super(key: key);

  @override
  _TenorTabDetailState createState() => _TenorTabDetailState();
}

class _TenorTabDetailState extends State<TenorTabDetail> {
  // Tab Provider
  late TabProvider _tabProvider;

  // AppBar Provider
  late AppBarProvider _appBarProvider;

  // Collection
  TenorCollection? _collection;

  // List of gifs
  List<TenorGif> _list = [];

  // Direction
  final Axis _scrollDirection = Axis.vertical;

  // Axis count
  late int _crossAxisCount;

  // Spacing between gifs in grid
  double _spacing = 8.0;

  // Default gif with
  double _gifWidth = 200.0;

  // is Loading gifs
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Tab Provider
    _tabProvider = Provider.of<TabProvider>(context, listen: false);

    // AppBar Provider
    _appBarProvider = Provider.of<AppBarProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ScrollController
    widget.scrollController..addListener(_scrollListener);

    // Listen query
    _appBarProvider.addListener(_listenerQuery);

    // Set items count responsive
    _crossAxisCount = (MediaQuery.of(context).size.width / _gifWidth).round();

    // Set vertical max items count
    int _mainAxisCount =
        ((MediaQuery.of(context).size.height - 30) / _gifWidth).round();

    // Load Initial Data
    _loadMore();
  }

  @override
  void dispose() {
    // dispose listener
    // Important
    widget.scrollController.removeListener(_scrollListener);
    _appBarProvider.removeListener(_listenerQuery);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return MasonryGridView.count(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      scrollDirection: _scrollDirection,
      controller: widget.scrollController,
      itemCount: _list.length,
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: _spacing,
      crossAxisSpacing: _spacing,
      itemBuilder: (ctx, idx) {
        TenorGif _gif = _list[idx];
        return _item(_gif);
      },
    );
  }

  Widget _item(TenorGif gif) {
    double _aspectRatio;

    if (gif.mediaFormats != null && gif.mediaFormats!.dims != null && gif.mediaFormats!.dims!.length >= 2) {
      _aspectRatio = gif.mediaFormats!.dims![0] / gif.mediaFormats!.dims![1];
    } else {
      _aspectRatio = 1.0;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () => _selectedGif(gif),
        child: gif.mediaFormats == null || gif.mediaFormats?.url == null
            ? Container()
            : ExtendedImage.network(
                gif.mediaFormats!.url!,
                semanticLabel: gif.title,
                cache: true,
                gaplessPlayback: true,
                fit: BoxFit.fill,
                headers: {'accept': 'image/*'},
                loadStateChanged: (state) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: gif.mediaFormats == null
                      ? Container()
                      : _mediaViewState(
                          state.extendedImageLoadState,
                          {
                            LoadState.loading: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: Container(
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                            LoadState.completed: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: ExtendedRawImage(
                                fit: BoxFit.fill,
                                image: state.extendedImageInfo?.image,
                              ),
                            ),
                            LoadState.failed: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: Container(
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          },
                          AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: Container(
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                ),
              ),
      ),
    );
  }

  Future<void> _loadMore() async {
    print("Total of collections: ${_collection?.results.length}");
    //Return if is loading or no more gifs
    if (_isLoading) {
      print("No more object");
      return;
    }

    _isLoading = true;

    // Tenor Client from library
    TenorClient client = TenorClient(apiKey: _tabProvider.tenorApiKey, clientKey: _tabProvider.clientKey);
    // Get Gif
    // If query text is not null search gif else featured
    if (_appBarProvider.queryText.isNotEmpty) {
      _collection = await client.search(
        _appBarProvider.queryText,
        lang: _tabProvider.tenorLang,
        country: 'IN',
        rating: _tabProvider.tenorRating,
        mediaFormat: _tabProvider.tenorMediaFilter,
        next: _collection?.next,
      );
    } else {
      _collection = await client.featured(
        lang: _tabProvider.tenorLang,
        country: 'IN',
        rating: _tabProvider.tenorRating,
        mediaFormat: _tabProvider.tenorMediaFilter,
        next: _collection?.next,
      );
    }

    // Set result to list
    if (_collection!.results.isNotEmpty && mounted) {
      setState(() {
        _list.addAll(_collection!.results);
      });
    }

    _isLoading = false;
  }

  // Scroll listener. if scroll end load more gifs
  void _scrollListener() {
    if (widget.scrollController.positions.last.extentAfter.lessThan(500) &&
        !_isLoading) {
      _loadMore();
    }
  }

  // Return selected gif
  void _selectedGif(TenorGif gif) {
    Navigator.pop(context, convertTenorGifToGiphyGif(gif));
  }

  // listener query
  void _listenerQuery() {
    // Reset pagination
    _collection = null;

    // Reset list
    _list = [];

    // Load data
    _loadMore();
  }

  TValue? _mediaViewState<TOptionType, TValue>(
    TOptionType selectedOption,
    Map<TOptionType, TValue> branches, [
    TValue? defaultValue = null,
  ]) {
    if (!branches.containsKey(selectedOption)) {
      return defaultValue;
    }

    return branches[selectedOption];
  }
}
