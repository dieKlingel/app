import 'package:flutter/material.dart';

import '../models/home.dart';

class HomePreview extends StatefulWidget {
  final String title;
  final Future<Image?> Function()? image;
  final Home home;
  final void Function()? onPressed;

  const HomePreview({
    required this.title,
    this.image,
    required this.home,
    this.onPressed,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _HomePreview();
}

class _HomePreview extends State<HomePreview> {
  Widget _image(BuildContext context) {
    return FutureBuilder<Image?>(
      future: widget.image!(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // TODO: Handle this case.
            break;
          case ConnectionState.waiting:
            return Text("loading");

          case ConnectionState.active:
            // TODO: Handle this case.
            break;
          case ConnectionState.done:
            // TODO: Handle this case.
            break;
        }
        return Text("data");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        color: Colors.red,
        child: widget.image == null ? Text("no imahe") : _image(context),
      ),
    );
  }
}
