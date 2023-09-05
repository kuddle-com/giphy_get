import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:giphy_get/src/client/models/collection.dart';
import 'package:giphy_get/src/client/models/gif.dart';
import 'package:giphy_get/src/providers/app_bar_provider.dart';
import 'package:giphy_get/src/providers/tab_provider.dart';
import 'package:giphy_get/src/client/models/image.dart';
import 'package:giphy_get/src/client/models/images.dart';
import 'package:provider/provider.dart';

import '../../client/tenor_client.dart';

class TenorTabDetail extends StatefulWidget {
  final String type;
  final ScrollController scrollController;

  const TenorTabDetail({
    Key? key,
    required this.type,
    required this.scrollController,
  }) : super(key: key);

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
        return _TenorGridItem(_gif, _selectedGif);
      },
    );
  }

  Future<void> _loadMore() async {
    //Return if is loading or no more gifs
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    // Tenor Client from library
    TenorClient _client = TenorClient(
      apiKey: _tabProvider.tenorApiKey,
      clientKey: _tabProvider.clientKey,
    );
    // Get Gif
    // If query text is not null search gif else featured
    if (_appBarProvider.queryText.isNotEmpty) {
      _collection = await _client.search(
        _appBarProvider.queryText,
        lang: _tabProvider.tenorLang,
        country: 'IN',
        rating: _tabProvider.tenorRating,
        mediaFormat: _tabProvider.tenorMediaFilter,
        next: _collection?.next,
      );
    } else {
      _collection = await _client.featured(
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
    _registerShare(gif.id!);
    Navigator.pop(context, _convertTenorGifToGiphyGif(gif));
  }

  // Register selected gif
  void _registerShare(String id) {
    TenorClient _client = TenorClient(
      apiKey: _tabProvider.tenorApiKey,
      clientKey: _tabProvider.clientKey,
    );
    _client.registerShare(id);
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

  GiphyGif _convertTenorGifToGiphyGif(TenorGif tenorGif) {
    return GiphyGif(
      title: tenorGif.title,
      type: "gif",
      id: tenorGif.id,
      slug: null,
      url: null,
      bitlyGifUrl: null,
      bitlyUrl: null,
      embedUrl: null,
      username: null,
      source: null,
      rating: null,
      contentUrl: null,
      sourceTld: null,
      sourcePostUrl: null,
      isSticker: null,
      importDatetime: null,
      trendingDatetime: null,
      user: null,
      images: GiphyImages(
        fixedWidth: GiphyFullImage(
          url: tenorGif.mediaFormats?.url ?? '',
          width: tenorGif.mediaFormats?.dims?[0].toString() ?? '200',
          height: tenorGif.mediaFormats?.dims?[1].toString() ?? '200',
          size: tenorGif.mediaFormats?.size.toString() ?? '',
          mp4: null,
          mp4Size: null,
          webp: null,
          webpSize: null,
        ),
      ),
    );
  }
}

class _TenorGridItem extends StatelessWidget {
  final TenorGif gif;
  final Function(TenorGif) selectedGif;

  const _TenorGridItem(
    this.gif,
    this.selectedGif,
  );

  @override
  Widget build(BuildContext context) {
    final double _aspectRatio = (gif.mediaFormats?.dims?.length ?? 0) >= 2
        ? gif.mediaFormats!.dims![0] / gif.mediaFormats!.dims![1]
        : 1.0;
    return ClipRRect(
      key: Key(gif.id!),
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () => selectedGif(gif),
        child: gif.mediaFormats?.url == null
            ? SizedBox()
            : ExtendedImage.network(
                gif.mediaFormats!.url!,
                semanticLabel: gif.title,
                cache: true,
                gaplessPlayback: true,
                fit: BoxFit.fill,
                headers: {'accept': 'image/*'},
                loadStateChanged: (state) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: case2(
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

  TValue? case2<TOptionType, TValue>(
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
