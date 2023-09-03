import 'package:flutter/material.dart';

class TabBottom extends StatefulWidget {
  final bool isGIF;

  const TabBottom({
    Key? key,
    required this.isGIF,
  }) : super(key: key);

  @override
  State<TabBottom> createState() => _TabBottomState();
}

class _TabBottomState extends State<TabBottom> {

  @override
  void didUpdateWidget(covariant TabBottom oldWidget) {
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
