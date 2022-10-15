import 'dart:convert';

import 'package:dieklingel_app/event/system_event.dart';
import 'package:dieklingel_app/event/system_event_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SystemEventListTile extends StatefulWidget {
  final SystemEvent event;

  const SystemEventListTile({
    super.key,
    required this.event,
  });

  @override
  State<SystemEventListTile> createState() => _SystemEventListTile();
}

class _SystemEventListTile extends State<SystemEventListTile>
    with AutomaticKeepAliveClientMixin {
  Image? chached;

  TextStyle textStyle() {
    return const TextStyle(color: Colors.white);
  }

  Widget _notification(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              color: CupertinoDynamicColor.withBrightness(
                color: Colors.blue.shade400,
                darkColor: Colors.blue.shade200,
              ).withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Text(
                  widget.event.payload,
                  style: textStyle(),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Icon(
            CupertinoIcons.chat_bubble_text_fill,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _text(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: CupertinoDynamicColor.withBrightness(
          color: Colors.blue.shade400,
          darkColor: Colors.blue.shade200,
        ).withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Text(
            widget.event.payload,
            style: textStyle(),
          ),
        ),
      ),
    );
  }

  Widget _payload(BuildContext context) {
    switch (widget.event.type) {
      case SystemEventType.image:
        if (null == chached) {
          String b64 = widget.event.payload.startsWith("data:")
              ? widget.event.payload.split(";").last
              : widget.event.payload;
          Uint8List bytes = base64Decode(b64);
          chached = Image.memory(
            bytes,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: frame != null
                    ? child
                    : const SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(strokeWidth: 6),
                      ),
              );
            },
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: chached!,
        );
      case SystemEventType.text:
        return _text(context);
      case SystemEventType.notification:
        return _notification(context);
      default:
        return const Text("unsupported type");
    }
  }

  Widget _timestamp(BuildContext context) {
    DateTime localTimestampt = widget.event.timestamp.toLocal();
    String year = localTimestampt.year.toString().padLeft(2, "0");
    String month = localTimestampt.month.toString().padLeft(2, "0");
    String day = localTimestampt.day.toString().padLeft(2, "0");
    String hour = localTimestampt.hour.toString().padLeft(2, "0");
    String minute = localTimestampt.minute.toString().padLeft(2, "0");

    String text = "$year-$month-$day $hour:$minute";
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.0,
        color: CupertinoDynamicColor.withBrightness(
          color: Colors.grey,
          darkColor: Colors.black54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _payload(context),
          Align(
            alignment: Alignment.centerRight,
            child: _timestamp(context),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
