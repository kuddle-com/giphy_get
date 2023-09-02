import 'package:flutter/material.dart';

class GiphyTabBottom extends StatefulWidget {
  final bool isGIF;

  const GiphyTabBottom({
    Key? key,
    required this.isGIF,
  }) : super(key: key);

  @override
  State<GiphyTabBottom> createState() => _GiphyTabBottomState();
}

class _GiphyTabBottomState extends State<GiphyTabBottom> {

  @override
  void didUpdateWidget(covariant GiphyTabBottom oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Center(
        child: _giphyLogo(context),
      ),
    );
  }

  Widget _giphyLogo(BuildContext context) {
    const basePath = "assets/img/";
    String logoPath = widget.isGIF
        ? "PB_tenor.png"
        : Theme.of(context).brightness == Brightness.light
            ? "poweredby_dark.png"
            : "poweredby_light.png";

    return Container(
      width: double.maxFinite,
      height: 15,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage(
            "$basePath$logoPath",
            package: 'giphy_get',
          ),
        ),
      ),
    );
  }
}
