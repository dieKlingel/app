import 'package:dieklingel_app/touch_scroll_behavior.dart';
import 'package:dieklingel_app/views/components/sub_headline.dart';
import 'package:flutter/cupertino.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: TouchScrollBehavior(),
      controller: _scrollController,
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            print("refresh");
          },
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SubHeadline(
                child: Text("Snapshot"),
              ),
              Image.network(
                "https://picsum.photos/250?image=9",
                fit: BoxFit.contain,
              ),
              const SubHeadline(
                child: Text("User Notification"),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  autofocus: true,
                  placeholder: "Title",
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  placeholder: "Message",
                  maxLines: 3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoButton.filled(
                  onPressed: null,
                  child: Text("send"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
