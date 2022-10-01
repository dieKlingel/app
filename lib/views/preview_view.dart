import 'dart:convert';

import 'package:dieklingel_app/messaging/messaging_client.dart';
import 'package:dieklingel_app/touch_scroll_behavior.dart';
import 'package:dieklingel_app/views/components/sub_headline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sendButtonIsEnabled = false;
  Image? _image;

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() {
      setState(() {
        _sendButtonIsEnabled = _bodyController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  void initialize() {
    context.read<MessagingClient>().messageController.stream.listen((event) {
      switch (event.topic) {
        case "io/camera/snapshot":
          if (event.message.isEmpty) {
            context.read<MessagingClient>().send("io/camera/trigger", "now");
            break;
          }
          String base64 = event.message.startsWith("data:")
              ? event.message.split(";").last
              : event.message;
          Uint8List bytes = base64Decode(base64);
          setState(() {
            _image = Image.memory(bytes);
          });
          break;
      }
    });
  }

  Future<void> _onRefresh() async {
    if (!context.read<MessagingClient>().isConnected()) return;
    context.read<MessagingClient>().send("io/camera/trigger", "latest");
  }

  void _onUserNotificationSendPressed() {
    Map<String, dynamic> message = {
      "title": _titleController.text,
      "body": _bodyController.text,
    };
    context.read<MessagingClient>().send(
          "io/user/notification",
          jsonEncode(message),
        );
    _titleController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: TouchScrollBehavior(),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _onRefresh,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SubHeadline(
                child: Text("Snapshot"),
              ),
              //_image ?? Container(),
              //Image.network("https://picsum.photos/250?image=9"),
              Container(
                child: _image,
              ),
              const SubHeadline(
                child: Text("User Notification"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  controller: _titleController,
                  placeholder: "Title",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  controller: _bodyController,
                  placeholder: "Message",
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoButton.filled(
                  onPressed: context.watch<MessagingClient>().isConnected() &&
                          _sendButtonIsEnabled
                      ? _onUserNotificationSendPressed
                      : null,
                  child: const Text("Send"),
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
