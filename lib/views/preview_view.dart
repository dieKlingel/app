import 'dart:convert';

import 'package:dieklingel_app/views/call_view_fullscreen.dart';
import 'package:flutter/material.dart';

import '../messaging/messaging_client.dart';
import '../touch_scroll_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
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
    context.read<MessagingClient>().send(
          "io/user/notification",
          _bodyController.text,
        );
    _bodyController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget smallTextFieldIcon({
    required IconData icon,
    void Function()? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: SizedBox(
        width: 34,
        height: 34,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon,
            size: 35,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _image ??
                          Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "swipe down to refresh",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(
                                  CupertinoIcons.down_arrow,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                smallTextFieldIcon(
                  icon: CupertinoIcons.phone_circle,
                  onPressed: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const CallViewFullScreen(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: CupertinoTextField(
                      placeholder: "Message",
                      controller: _bodyController,
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 7),
                      decoration: BoxDecoration(
                        color: const CupertinoDynamicColor.withBrightness(
                            color: Colors.white, darkColor: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: CupertinoDynamicColor.withBrightness(
                                color: Colors.grey.shade300,
                                darkColor: Colors.grey.shade800)),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                ),
                smallTextFieldIcon(
                  icon: CupertinoIcons.arrow_up_circle,
                  onPressed: context.watch<MessagingClient>().isConnected() &&
                          _sendButtonIsEnabled
                      ? _onUserNotificationSendPressed
                      : null,
                ),
                smallTextFieldIcon(
                  icon: CupertinoIcons.lock_circle,
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                  },
                ),
              ],
            ),
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
